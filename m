Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF2E6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 18:05:23 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so11049437qkd.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:05:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q29si10342735qkh.99.2015.09.09.15.05.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 15:05:22 -0700 (PDT)
Date: Thu, 10 Sep 2015 00:05:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
Message-ID: <20150909220517.GH10639@redhat.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
 <55DC3BD4.6020602@suse.cz>
 <alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, James Hartshorn <jhartshorn@connexity.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Sep 01, 2015 at 03:26:34PM -0700, David Rientjes wrote:
> I don't believe it is an issue that cannot be worked around in userspace 
> either with MADV_NOHUGEPAGE or PR_SET_THP_DISABLE.

Agreed, for the legit cases where THP can hurt, the bugreport should
be sent to the databases so they can use one of the two above
features.

It really depends on the database if it hurts or not, in fact the
majority of databases benefits from THP (others can provide the exact
details). So in average it's still a net gain even for databases.

I'm aware of a single db case where THP hurts and it makes perfect
sense why it hurts (and it's not Oracle): redis and only during
snapshotting, see the end of the email.

Setting THP global tweak to "madvise" was designed for embedded
systems were losing even 4k of RAM matters, "madvise" should be more
about the memory footprint then the performance.

qemu-kvm uses MADV_HUGEPAGE so it is enabled even when the the global
setting is "madvise" exactly because with qemu the memory footprint
won't change regardless enabled or disabled. If you're very low on
memory "madvise" makes sense just in case.

Note also that even Oracle if run in KVM guests (and I'd recommend to
run it always in KVM guests) performs almost _half_ a slow, if THP is
not enabled in the _host_.

About Oracle I think it's more a case that THP cannot help Oracle
because Oracle already uses hugetlbfs which is guaranteed equal or
faster of THP as it has the memory preallocated matching the SGA,
1GByte page support, it doesn't need compaction, it doesn't run into
constraints by the restriction of preallocating the memory at
boot. Still I've no idea how THP could hurt Oracle, unless they got a
buggy implementation in their version of the kernels... or unless they
entirely missed the feature in some of their kernels.

I can't recall any outstanding THP related bugreport from Oracle, feel
free to search the kernel lists to point me to an open bugreport from
Oracle about THP performance hurting Oracle so I can have a look at
some data. I'm only aware about the generic allegations on their
website.

My guess was that THP being a tradeoff, from a purely risk-off
prospective (they can't get benefit from the winning side of the trade
anyway as they already rightfully optimized everything with hugetlbfs)
it's fair enough for Oracle to recommend to disable THP for Oracle
(including when it's run in the KVM guests). Even then I think they
should simply use the prctl if that's the reason of they
recommendation, so other processes like java and other apps can still
run much faster with THP (especially in guest, and that applies to all
hypervisors including proprietary ones, it's an hardware issue with
EPT/NPT, software can do nothing but use THP both on guest and host to
optimize).

The alternate malloc allocator also should consider disabling THP with
MADV_NOHUGEPAGE if it's totally relying on MADV_DONTNEED in order to
free up memory in a 4k fragmented way and the user needs low memory
footprint. That's what MADV_NOHUGEPAGE is for. If Kirill's
split_huge_page change goes in, that such a MADV_DONTNEED will
generate a even more extreme memory loss in the alternate malloc
allocator, because currently khugepaged won't collapse the hugepage if
the pte of the surrounding 4k pages within the 2m hugepage are not
young (young as in pte_young), i.e. if there's some memory pressure,
the 4k hole will remain an hole and khugepaged will skip it and the
memory can potentially remain free forever. After the split_huge_page
change proposed, there will be no way MADV_DONTNEED can free up any
memory at all, within a 2MB hugepage, no matter the memory pressure.

Now changing topic to some technical issue with redis. redis uses
fork() to create a readonly snapshot, then in the child it writes the
readonly data in memory to the disk. What happens is the parent still
writes to the memory while the child is snapshotting to the disk. So
during this snapshotting time, with THP each write redis does in the
parent results in a 2MByte allocation and 4MBbyte of memory accessed
by the CPU, instead of a 4kbyte allocation and 8kbyte of memory
accessed by the CPU. The writes are randomly scattered across all the
address space. In short during the snapshotting each writes gets 512
times higher latency, more L1/L2 cache is destroyed and the amount of
memory usage increases almost 512 times. There's no way the faster TLB
miss benefits and the larger TLB can offset that cost in this special
load and we're not even accounting for the compaction cost.

What redis I think really should do is to use userfaultfd write
protection tracking mode as soon as I finish writing it.

I doubt redis likes if the amount of memory usage doubles up during
snapshotting, but that can currently happen with fork() regardless of
THP.

userfaultfd will make the maximal ram utilization during snapshotting
configurable, once the limit hits, the wrprotect faults will throttle
on the snapshot disk I/O gracefully. It can still take twice the same
of the ram if it wants to and in such case it never risks having to
throttle on I/O, but it's not forced to, like it is now with fork().

Furthermore with userfaultfd redis won't have fork(), it will use
clone() instead. It won't have to duplicate all pagetables. The
wrprotect faults will talk directly to the userfaultfd thread that
will copy the memory off to a private location and then unblock the
fault that will just return to userland without having to do any
copy_page inside the kernel (the other thread will do the copy in
userland potentially in another CPU, which can be guaranteed with CPU
pinning if needed) and the L1/L2 cache of the master redis process
that is trying to write to the memory, will be totally unaffected (not
even the current 8k will be used).

Then it's up to redis if it wants to do userfaults with 4k or 2MByte
size, it's userland handling the page fault after all, the userfaultfd
kernel code has no control on the size of the page fault. If the
readonly THP page was mapped by a trans_huge_pmd, when the UFFDIO
ioctl marks read-write only 4k of it (or any region not multiple of
2MBytes or not aligned to 2Mbytes), the UFFDIO wrprotection ioctl will
take care of splitting the trans_huge_pmd. If the cost of splitting a
THP (with the split_huge_page change proposed it'll only actually
split the trans_huge_pmd) while marking a 4k region read-write it's
still too much, redis can still use MADV_NOHUGEPAGE with userfaultfd
too.

My guess is that THP + userfaultfd write tracking doing 4k faults in
userland will work optimally for redis snapshotting (both with the
current split_huge_page or the proposed change).

qemu is going to use the same model for KVM postcopy live
snapshotting to use in COLO fault tolerance or other features.

Now until userfaultfd is capable of write protect tracking, we could
introduce a new MADV_....HUGEPAGE to tell the kernel that copy on
write faults must be done by splitting the hugepage and using 4k
pages. That will also fix it. Just I'm not sure if it's worth it.

For now, redis should simply use MADV_NOHUGEPAGE (perhaps it already
does, I haven't checked).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
