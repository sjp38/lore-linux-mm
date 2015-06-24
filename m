Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 07A156B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 18:26:55 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so1628568wiw.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 15:26:54 -0700 (PDT)
Received: from jazz.pogo.org.uk (jazz.pogo.org.uk. [2001:41c8:51:8a7::167])
        by mx.google.com with ESMTPS id dv8si5220170wib.91.2015.06.24.15.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 15:26:53 -0700 (PDT)
Date: Wed, 24 Jun 2015 23:26:49 +0100 (BST)
From: Mark Hills <mark@xwax.org>
Subject: Re: Write throughput impaired by touching dirty_ratio
In-Reply-To: <558A69F8.2080304@suse.cz>
Message-ID: <1506242140070.1867@stax.localdomain>
References: <1506191513210.2879@stax.localdomain> <558A69F8.2080304@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 24 Jun 2015, Vlastimil Babka wrote:

> [add some CC's]
> 
> On 06/19/2015 05:16 PM, Mark Hills wrote:
> > I noticed that any change to vm.dirty_ratio causes write throuput to 
> > plummet -- to around 5Mbyte/sec.
> > 
> >   <system bootup, kernel 4.0.5>
> > 
> >   # dd if=/dev/zero of=/path/to/file bs=1M
> > 
> >   # sysctl vm.dirty_ratio
> >   vm.dirty_ratio = 20
> >   <all ok; writes at ~150Mbyte/sec>
> > 
> >   # sysctl vm.dirty_ratio=20
> >   <all continues to be ok>
> > 
> >   # sysctl vm.dirty_ratio=21
> >   <writes drop to ~5Mbyte/sec>
> > 
> >   # sysctl vm.dirty_ratio=20
> >   <writes continue to be slow at ~5Mbyte/sec>
> > 
> > The test shows that return to the previous value does not restore the old 
> > behaviour. I return the system to usable state with a reboot.
> > 
> > Reads continue to be fast and are not affected.
> > 
> > A quick look at the code suggests differing behaviour from 
> > writeback_set_ratelimit on startup. And that some of the calculations (eg. 
> > global_dirty_limit) is badly behaved once the system has booted.
> 
> Hmm, so the only thing that dirty_ratio_handler() changes except the
> vm_dirty_ratio itself, is ratelimit_pages through writeback_set_ratelimit(). So
> I assume the problem is with ratelimit_pages. There's num_online_cpus() used in
> the calculation, which I think would differ between the initial system state
> (where we are called by page_writeback_init()) and later when all CPU's are
> onlined. But I don't see CPU onlining code updating the limit (unlike memory
> hotplug which does that), so that's suspicious.
> 
> Another suspicious thing is that global_dirty_limits() looks at current
> process's flag. It seems odd to me that the process calling the sysctl would
> determine a value global to the system.

Yes, I also spotted this. The fragment of code is:

  	tsk = current;
	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
		background += background / 4;
		dirty += dirty / 4;
	}

It seems to imply the code was not always used from the /proc interface. 
It's relevant in a moment...

> If you are brave enough (and have kernel configured properly and with
> debuginfo),

I'm brave... :) I hadn't seen this tool before, thanks for introducing me 
to it, I will use it more now, I'm sure.

> you can verify how value of ratelimit_pages variable changes on the live 
> system, using the crash tool. Just start it, and if everything works, 
> you can inspect the live system. It's a bit complicated since there are 
> two static variables called "ratelimit_pages" in the kernel so we can't 
> print them easily (or I don't know how). First we have to get the 
> variable address:
> 
> crash> sym ratelimit_pages
> ffffffff81e67200 (d) ratelimit_pages
> ffffffff81ef4638 (d) ratelimit_pages
> 
> One will be absurdly high (probably less on your 32bit) so it's not the one we want:
> 
> crash> rd -d ffffffff81ef4638 1
> ffffffff81ef4638:    4294967328768
> 
> The second will have a smaller value:
> (my system after boot with dirty ratio = 20)
> crash> rd -d ffffffff81e67200 1
> ffffffff81e67200:             1577
> 
> (after changing to 21)
> crash> rd -d ffffffff81e67200 1
> ffffffff81e67200:             1570
> 
> (after changing back to 20)
> crash> rd -d ffffffff81e67200 1
> ffffffff81e67200:             1496

In my case there's only one such symbol (perhaps because this kernel 
config is quite slimmed down?)

  crash> sym ratelimit_pages
  c148b618 (d) ratelimit_pages

  (bootup with dirty_ratio 20)
  crash> rd -d ratelimit_pages
  c148b618:            78 

  (after changing to 21)
  crash> rd -d ratelimit_pages
  c148b618:            16 

  (after changing back to 20)
  crash> rd -d ratelimit_pages
  c148b618:            16 

Compared to your system, even the bootup value seems pretty low.

So I am new to this code, but I took a look. Seems like we're basically 
hitting the lower bound of 16.

  void writeback_set_ratelimit(void)
  {
	unsigned long background_thresh;
	unsigned long dirty_thresh;
	global_dirty_limits(&background_thresh, &dirty_thresh);
	global_dirty_limit = dirty_thresh;
	ratelimit_pages = dirty_thresh / (num_online_cpus() * 32);
	if (ratelimit_pages < 16)
		ratelimit_pages = 16;
  }

>From this code, we don't have dirty_thresh preserved, but we do have 
global_dirty_limit:

  crash> rd -d global_dirty_limit
  c1545080:             0 

And if that is zero then:

  ratelimit_pages = 0 / (num_online_cpus() * 32)
                  = 0

So it seems like this is the path to follow.

The function global_dirty_limits() produces the value for dirty_thresh 
and, aside from a potential multiply by 0.25 (the 'task dependent' 
mentioned before) the value is derived as:

  if (vm_dirty_bytes)
	dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
  else
	dirty = (vm_dirty_ratio * available_memory) / 100;

I checked the vm_dirty_bytes codepath and that works:

  (vm.dirty_bytes = 1048576000, 1000Mb)
  crash> rd -d ratelimit_pages
  c148b618:           1000 

Therefore it's the 'else' case, and this points to available_memory is 
zero, or near it (in my case < 5). This value is the direct result of 
global_dirtyable_memory(), which I've annotated with some values:

  static unsigned long global_dirtyable_memory(void)
  {
	unsigned long x;

	x = global_page_state(NR_FREE_PAGES);      //   2648091
	x -= min(x, dirty_balance_reserve);        //  - 175522

	x += global_page_state(NR_INACTIVE_FILE);  //  + 156369
	x += global_page_state(NR_ACTIVE_FILE);    //  +   3475  = 2632413

	if (!vm_highmem_is_dirtyable)
		x -= highmem_dirtyable_memory(x);

	return x + 1;	/* Ensure that we never return 0 */
  }

If I'm correct here, global includes the highmem stuff, and it implies 
that highmem_dirtyable_memory() is returning a value only slightly less 
than or equal to the sum of the others.

To test, I flipped the vm_highmem_is_dirtyable (which had no effect until 
I forced it to re-evaluate ratelimit_pages):

  $ echo 1 > /proc/sys/vm/highmem_is_dirtyable
  $ echo 21 > /proc/sys/vm/dirty_ratio
  $ echo 20 > /proc/sys/vm/dirty_ratio 

  crash> rd -d ratelimit_pages
  c148b618:          2186 

The value is now healthy, more so than even the value we started 
with on bootup.

My questions and observations are:

* What does highmem_is_dirtyable actually mean, and should it really 
  default to 1?

  Is it actually a misnomer? Since it's only used in 
  global_dirtyable_memory(), it doesn't actually prevent dirtying of 
  highmem, it just attempts to place a limit that corresponds to the 
  amount of non-highmem.I have limited understanding at the moment, but 
  that would be something different.

* That the codepaths around setting highmem_is_dirtyable from /proc
  is broken; it also needs to make a call to writeback_set_ratelimit()

* Even with highmem_is_dirtyable=1, there's still a sizeable difference 
  between the value on bootup (78) and the evaluation once booted (2186). 
  This goes the wrong direction and is far too big a difference to be 
  solely nr_cpus_online() switching from 1 to 8.

The machine is 32-bit with 12GiB of RAM.

For info, I posted a typical zoneinfo, below.

> So yes, it does differ but not drastically. A difference between 1 and 8 
> online CPU's would look differently I think. So my theory above is 
> questionable. But you might try what it looks like on your system...
> 
> > 
> > The system is an HP xw6600, running i686 kernel. This happens whether 
> > internal SATA HDD, SSD or external USB drive is used. I first saw this on 
> > kernel 4.0.4, and 4.0.5 is also affected.
> 
> So what was the last version where you did change the dirty ratio and it worked
> fine?

Sorry, I don't know when it broke. I don't immediately have access to an 
old kernel to test, but I could do that if necessary.
 
> > It would suprise me if I'm the only person who was setting dirty_ratio.
> > 
> > Have others seen this behaviour? Thanks
> > 
> 

Thanks, I hope you find this useful.

-- 
Mark


Node 0, zone      DMA
  pages free     1566
        min      196
        low      245
        high     294
        scanned  0
        spanned  4095
        present  3989
        managed  3970
    nr_free_pages 1566
    nr_alloc_batch 49
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 163
    nr_active_file 1129
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 1292
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 842
    nr_slab_unreclaimable 162
    nr_page_table_pages 17
    nr_kernel_stack 4
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   661
    nr_written   661
    nr_pages_scanned 0
    workingset_refault 0
    workingset_activate 0
    workingset_nodereclaim 0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 377, 12165, 12165)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 2
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 3
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 4
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 5
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 6
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 7
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
  all_unreclaimable: 0
  start_pfn:         1
  inactive_ratio:    1
Node 0, zone   Normal
  pages free     37336
        min      4789
        low      5986
        high     7183
        scanned  0
        spanned  123902
        present  123902
        managed  96773
    nr_free_pages 37336
    nr_alloc_batch 331
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 4016
    nr_active_file 26672
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    1
    nr_file_pages 30684
    nr_dirty     4
    nr_writeback 0
    nr_slab_reclaimable 19865
    nr_slab_unreclaimable 4673
    nr_page_table_pages 1027
    nr_kernel_stack 281
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   14354
    nr_written   21672
    nr_pages_scanned 0
    workingset_refault 0
    workingset_activate 0
    workingset_nodereclaim 0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 0, 94302, 94302)
  pagesets
    cpu: 0
              count: 78
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 1
              count: 140
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 2
              count: 116
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 3
              count: 100
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 4
              count: 70
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 5
              count: 82
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 6
              count: 144
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 7
              count: 59
              high:  186
              batch: 31
  vm stats threshold: 24
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    1
Node 0, zone  HighMem
  pages free     2536526
        min      128
        low      37501
        high     74874
        scanned  0
        spanned  3214338
        present  3017668
        managed  3017668
    nr_free_pages 2536526
    nr_alloc_batch 10793
    nr_inactive_anon 2118
    nr_active_anon 118021
    nr_inactive_file 80138
    nr_active_file 273523
    nr_unevictable 3475
    nr_mlock     3475
    nr_anon_pages 119672
    nr_mapped    48158
    nr_file_pages 357567
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     2766
    nr_dirtied   1882996
    nr_written   1695681
    nr_pages_scanned 0
    workingset_refault 0
    workingset_activate 0
    workingset_nodereclaim 0
    nr_anon_transparent_hugepages 151
    nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 171
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 1
              count: 80
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 2
              count: 91
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 3
              count: 173
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 4
              count: 114
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 5
              count: 159
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 6
              count: 130
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 7
              count: 62
              high:  186
              batch: 31
  vm stats threshold: 64
  all_unreclaimable: 0
  start_pfn:         127998
  inactive_ratio:    10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
