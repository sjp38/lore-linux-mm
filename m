Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBBD6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:09:11 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v72so1612428ywa.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:09:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si327720ybj.234.2017.09.28.03.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 03:09:10 -0700 (PDT)
Date: Thu, 28 Sep 2017 12:09:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] A multithread lockless deduplication engine
Message-ID: <20170928100906.GF30973@redhat.com>
References: <0d61c58a-8d73-4037-b15d-1f0f25a3ad62.ljy@baibantech.com.cn>
 <20170926114747.tjiyopglxeeudy65@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170926114747.tjiyopglxeeudy65@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: XaviLi <ljy@baibantech.com.cn>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Hello XaviLi,

On Tue, Sep 26, 2017 at 01:47:47PM +0200, Michal Hocko wrote:
> [Let's add some more people and linux-mm to the CC list]
> 
> On Wed 20-09-17 11:23:50, XaviLi wrote:
> > PageONE (Page Object Non-duplicate Engine) is a multithread kernel page deduplication engine. It is based on a lock-less tree algorithm we currently named as SD (Static and Dynamic) Tree. Normal operations such as insert/query/delete to this tree are block-less. Adding more CPU cores can linearly boost speed as far as we tested. Multithreading gives not only opportunity to work faster. It also allows any CPU to donate spare time for the job. Therefore, it reveals a way to use CPU more efficiently. PPR is from an open source solution named Dynamic VM:
> > https://github.com/baibantech/dynamic_vm.git 
> > 
> > patch can be found here:  https://github.com/baibantech/dynamic_vm/tree/master/dynamic_vm_0.5
> > 
> > One work thread of PageONE can match the speed of KSM daemon. Adding more CPUs can increase speed linearly. Here we can see a brief test:
> > 
> > Test environment
> > DELL R730
> > Intel(R) Xeon(R) E5-2650 v4 (2.20 GHz, of Cores 12, threads 24); 
> > 256GB RAM
> > Host OS: Ubuntu server 14.04 Host kernel: 4.4.1
> > Qemu: 2.9.0
> > Guest OS: Ubuntu server 16.04 Guest kernel: 4.4.76
> > 
> > We ran 12 VMs together. Each create 16GB data in memory. After all data is ready we start dedup-engine and see how host-side used memory amount changes.
> > 
> > KSM:
> > Configuration: sleep_millisecs = 0, pages_to_scan = 1000000
> > Starting used memory: 216.8G
> > Result: KSM start merging pages immediately after turned on. KSM daemon took 100% of one CPU for 13:16 until used memory was reduced to 79.0GB.
> > 
> > PageONE:
> > Configuration: merge_period(secs) = 20, work threads = 12
> > Starting used memory: 207.3G
> > (Which means PageONE scans full physical memory in 20 secs period. Pages was merged if not changed in 2 merge_periods.)
> > Result: In the first two periods PageONE only observe and identify unchanged pages. Little CPU was used in this time. As the third period begin all 12 threads start using 100% CPU to do real merge job. 00:58 later used memory was reduced to 70.5GB.
> > 
> > We ran the above test using the data quite easy for red-black tree of KSM. Every difference can be detected by comparing the first 8 bytes. Then we ran another test in which each data was begin with random zero bytes for comparison. The average size of zero data was 128 bytes. Result is shown below:
> > 
> > KSM:
> > Configuration: sleep_millisecs = 0, pages_to_scan = 1000000
> > Starting used memory: 216.8G
> > Result: 19:49 minutes until used memory was reduced to 78.7GB.
> > 
> > PageONE:
> > Configuration: merge period(secs) = 20, work threads = 12
> > Starting used memory: 210.3G
> > Result: First 2 periods same as above. 1:09 after merge job start memory was reduced to 72GB.
> > 
> > PageONE shows little difference in the two tests because SD tree search compare each key bit just once in most cases.

Could you repeat the whole benchmark while giving only 1 CPU to PageONE
and after applying the following crc32c-intel patch to KSM?

https://www.spinics.net/lists/linux-mm/msg132394.html

You may consider also echo 1 > /sys/kernel/mm/ksm/use_zero_pages if
you single out zero pages in pone (but it doesn't look like you have
such feature in pone).

The second test is exercising the worst case possible of KSM so I
don't see how it's worth worrying about. Likely pone would also have a
worst case to exercise (it uses hash_64 so it very likely also has a
worst case to exercise). For KSM there are already plans to alter the
memcmp so it's more scattered randomly.

Making KSM multithreaded with one ksmd thread per CPU is entirely
possible, the rbtree rebalance will require some locking of course but
the high CPU usage parts of KSM are fully scalable (mm walk, checksum,
memcompare, writeprotection, pagetable replacement). We didn't
multithread ksmd to keep it simpler primarily but also because nobody
asked for this feature yet. Why didn't you simply multithread KSM
which provides a solid base also supporting KSMscale?

Are you using an hash to find equality? That can't be done currently
to avoid infringing. I see various memcmp in your patch but all around
#if 0... so what are you using for finding page equality?

How does PageONE deal with 1million of equal virtual pages? Does it
lockup in rmap? KSM in v4.13 can handle infinite amount of equal
virtual page content to dedup while generating O(1) complexity in rmap
walks. Without this, KSM was unusable for enterprise use and had to be
disabled, because the kernel would lockup for several seconds after
deduplicating million of virtual pages with same content (i.e. during
NUMA balancing induced page migrations or during compaction induced
page migrations, let alone swapping the million-times deduplicated KSM
page).

KSM is usually an activity run in the background so nobody asked to
dedicate more than one core to it, and what's relevant is to do the
dedup in the most efficient way possible (i.e. less CPU used and no
interference to the rest of the system whatsoever), not how long it
takes if you run it on all available CPUs loading 100% of the system
with it.

So comparing a dedup algorithm running concurrently on 12 threads vs
another dedup algorithm running in 1 thread only, is an apple to
oranges comparison.

Comparing KSM (with crc32 as cksum, to apply on top of upstream) vs
PageOne restricted to a single thread (also more realistic production
environment), will be a more interesting and meaningful comparison.

It looks like rmap is supported by pone but the patch has a multitude
of #if 0 and around all rmap code so it's not so clear. Rmap walks
have to work flawlessy on all deduplicated pages, or pone would then
break not just swapping but also NUMA Balancing compaction and in turn
THP utilization and THP utilization is critical for virtual machines
(MADV_HUGEPAGE is always set by QEMU, to run direct compactin also with
defrag=madvise or defer+madvise).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
