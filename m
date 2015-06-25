Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB096B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 05:20:59 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so11889366wiw.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 02:20:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by11si7559626wib.105.2015.06.25.02.20.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 02:20:57 -0700 (PDT)
Date: Thu, 25 Jun 2015 11:20:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Write throughput impaired by touching dirty_ratio
Message-ID: <20150625092056.GB17237@dhcp22.suse.cz>
References: <1506191513210.2879@stax.localdomain>
 <558A69F8.2080304@suse.cz>
 <1506242140070.1867@stax.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506242140070.1867@stax.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-06-15 23:26:49, Mark Hills wrote:
> On Wed, 24 Jun 2015, Vlastimil Babka wrote:
[...]
> > Another suspicious thing is that global_dirty_limits() looks at current
> > process's flag. It seems odd to me that the process calling the sysctl would
> > determine a value global to the system.
> 
> Yes, I also spotted this. The fragment of code is:
> 
>   	tsk = current;
> 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> 		background += background / 4;
> 		dirty += dirty / 4;
> 	}

Yes this might be confusing for the proc path but it shouldn't be hit
there because PF_LESS_THROTTLE is currently only used from the nfs code
(to tell the throttling code to not throttle it because it is freeing
memory) and you usually do not set proc values from th RT context.  So
this shouldn't matter.

[...]
>   crash> sym ratelimit_pages
>   c148b618 (d) ratelimit_pages
> 
>   (bootup with dirty_ratio 20)
>   crash> rd -d ratelimit_pages
>   c148b618:            78 
> 
>   (after changing to 21)
>   crash> rd -d ratelimit_pages
>   c148b618:            16 
> 
>   (after changing back to 20)
>   crash> rd -d ratelimit_pages
>   c148b618:            16 
> 
> Compared to your system, even the bootup value seems pretty low.
> 
> So I am new to this code, but I took a look. Seems like we're basically 
> hitting the lower bound of 16.

Yes this is really low and as suspected your writers are throttled every
few pages.

> 
>   void writeback_set_ratelimit(void)
>   {
> 	unsigned long background_thresh;
> 	unsigned long dirty_thresh;
> 	global_dirty_limits(&background_thresh, &dirty_thresh);
> 	global_dirty_limit = dirty_thresh;
> 	ratelimit_pages = dirty_thresh / (num_online_cpus() * 32);
> 	if (ratelimit_pages < 16)
> 		ratelimit_pages = 16;
>   }
> 
> From this code, we don't have dirty_thresh preserved, but we do have 
> global_dirty_limit:
> 
>   crash> rd -d global_dirty_limit
>   c1545080:             0 

This is really bad.

> And if that is zero then:
> 
>   ratelimit_pages = 0 / (num_online_cpus() * 32)
>                   = 0
> 
> So it seems like this is the path to follow.
> 
> The function global_dirty_limits() produces the value for dirty_thresh 
> and, aside from a potential multiply by 0.25 (the 'task dependent' 
> mentioned before) the value is derived as:
> 
>   if (vm_dirty_bytes)
> 	dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
>   else
> 	dirty = (vm_dirty_ratio * available_memory) / 100;
> 
> I checked the vm_dirty_bytes codepath and that works:
> 
>   (vm.dirty_bytes = 1048576000, 1000Mb)
>   crash> rd -d ratelimit_pages
>   c148b618:           1000 
> 
> Therefore it's the 'else' case, and this points to available_memory is 
> zero, or near it (in my case < 5).

OK so it looks like you do not basically have any dirtyable memory.
Which smells like a highmem issue.

> This value is the direct result of 
> global_dirtyable_memory(), which I've annotated with some values:
> 
>   static unsigned long global_dirtyable_memory(void)
>   {
> 	unsigned long x;
> 
> 	x = global_page_state(NR_FREE_PAGES);      //   2648091
> 	x -= min(x, dirty_balance_reserve);        //  - 175522
> 
> 	x += global_page_state(NR_INACTIVE_FILE);  //  + 156369
> 	x += global_page_state(NR_ACTIVE_FILE);    //  +   3475  = 2632413
> 
> 	if (!vm_highmem_is_dirtyable)
> 		x -= highmem_dirtyable_memory(x);
> 
> 	return x + 1;	/* Ensure that we never return 0 */
>   }
> 
> If I'm correct here, global includes the highmem stuff, and it implies 
> that highmem_dirtyable_memory() is returning a value only slightly less 
> than or equal to the sum of the others.

Exactly!

> To test, I flipped the vm_highmem_is_dirtyable (which had no effect until 
> I forced it to re-evaluate ratelimit_pages):
> 
>   $ echo 1 > /proc/sys/vm/highmem_is_dirtyable
>   $ echo 21 > /proc/sys/vm/dirty_ratio
>   $ echo 20 > /proc/sys/vm/dirty_ratio 
> 
>   crash> rd -d ratelimit_pages
>   c148b618:          2186 
> 
> The value is now healthy, more so than even the value we started 
> with on bootup.

>From your /proc/zoneinfo:
> Node 0, zone  HighMem
>   pages free     2536526
>         min      128
>         low      37501
>         high     74874
>         scanned  0
>         spanned  3214338
>         present  3017668
>         managed  3017668

You have 11G of highmem. Which is a lot wrt. the the lowmem

> Node 0, zone   Normal
>   pages free     37336
>         min      4789
>         low      5986
>         high     7183
>         scanned  0
>         spanned  123902
>         present  123902
>         managed  96773

which is only 378M! So something had to eat portion of the lowmem.
I think it is a bad idea to use 32b kernel with that amount of memory in
general. The lowmem pressure is even worse by the fact that something is
eating already precious amount of lowmem. What is the reason to stick
with 32b kernel anyway?

> My questions and observations are:
> 
> * What does highmem_is_dirtyable actually mean, and should it really 
>   default to 1?

It says whether highmem should be considered dirtyable. It is not by
default. See more for motivation in 195cf453d2c3 ("mm/page-writeback:
highmem_is_dirtyable option").

>   Is it actually a misnomer? Since it's only used in 
>   global_dirtyable_memory(), it doesn't actually prevent dirtying of 
>   highmem, it just attempts to place a limit that corresponds to the 
>   amount of non-highmem.I have limited understanding at the moment, but 
>   that would be something different.
> 
> * That the codepaths around setting highmem_is_dirtyable from /proc
>   is broken; it also needs to make a call to writeback_set_ratelimit()

That should be probably fixed.

> * Even with highmem_is_dirtyable=1, there's still a sizeable difference 
>   between the value on bootup (78) and the evaluation once booted (2186). 
>   This goes the wrong direction and is far too big a difference to be 
>   solely nr_cpus_online() switching from 1 to 8.

I am not sure where the 78 came from because the default value is 32 and
it is not set anywhere else but writeback_set_ratelimit. At least it
looks like that from the quick code inspection. I am not an expert in
that area.

> The machine is 32-bit with 12GiB of RAM.

I think you should really consider 64b kernel for such a machine. You
would suffer from the low mem pressure otherwise and I do not see a good
reason for that. If you depend on 32b userspace then it should run just
fine on top of 64b kernel.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
