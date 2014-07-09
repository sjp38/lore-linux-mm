Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 23F9E6B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 00:13:33 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id vb8so7530900obc.11
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 21:13:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p2si61685837oei.104.2014.07.08.21.13.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 21:13:32 -0700 (PDT)
Message-ID: <53BCBF1F.1000506@oracle.com>
Date: Wed, 09 Jul 2014 00:03:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org>
In-Reply-To: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hughd@google.com, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/02/2014 03:25 PM, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: shmem: fix faulting into a hole while it's punched, take 2
> has been added to the -mm tree.  Its filename is
>      shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Hugh Dickins <hughd@google.com>
> Subject: shmem: fix faulting into a hole while it's punched, take 2
> 
> Trinity finds that mmap access to a hole while it's punched from shmem can
> prevent the madvise(MADV_REMOVE) or fallocate(FALLOC_FL_PUNCH_HOLE) from
> completing, until the (killable) reader stops; with the puncher's hold on
> i_mutex locking out all other writers until it can complete.  This issue
> was tagged with CVE-2014-4171.
> 
> It appears that the tmpfs fault path is too light in comparison with its
> hole-punching path, lacking an i_data_sem to obstruct it; but we don't
> want to slow down the common case.  It is not a problem in truncation,
> because there the SIGBUS beyond i_size stops pages from being appended.
> 
> The origin of this problem is my v3.1 commit d0823576bf4b ("mm: pincer in
> truncate_inode_pages_range"), once it was duplicated into shmem.c.  It
> seemed like a nice idea at the time, to ensure (barring RCU lookup
> fuzziness) that there's an instant when the entire hole is empty; but the
> indefinitely repeated scans to ensure that make it vulnerable.
> 
> Revert that "enhancement" to hole-punch from shmem_undo_range(), but
> retain the unproblematic rescanning when it's truncating; add a couple of
> comments there.
> 
> Remove the "indices[0] >= end" test: that is now handled satisfactorily by
> the inner loop, and mem_cgroup_uncharge_start()/end() are too light to be
> worth avoiding here.
> 
> But if we do not always loop indefinitely, we do need to handle the case
> of swap swizzled back to page before shmem_free_swap() gets it: add a
> retry for that case, as suggested by Konstantin Khlebnikov.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Suggested-and-Tested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Lukas Czerner <lczerner@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: <stable@vger.kernel.org>	[3.1+]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I suspect there's something off with this patch, as the shmem_fallocate
hangs are back... Pretty much same as before:

[  363.600969] INFO: task trinity-c327:9203 blocked for more than 120 seconds.
[  363.605359]       Not tainted 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty #772
[  363.609730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.615861] trinity-c327    D 000000000000000b 13496  9203   8559 0x10000004
[  363.620284]  ffff8800b857bce8 0000000000000002 ffffffff9dc11b10 0000000000000001
[  363.624468]  ffff880104860000 ffff8800b857bfd8 00000000001d7740 00000000001d7740
[  363.629118]  ffff880104863000 ffff880104860000 ffff8800b857bcd8 ffff8801eaed8868
[  363.633879] Call Trace:
[  363.635442]  [<ffffffff9a4dc535>] schedule+0x65/0x70
[  363.638638]  [<ffffffff9a4dc948>] schedule_preempt_disabled+0x18/0x30
[  363.642833]  [<ffffffff9a4df0a5>] mutex_lock_nested+0x2e5/0x550
[  363.646599]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
[  363.651319]  [<ffffffff9719b721>] ? get_parent_ip+0x11/0x50
[  363.654683]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
[  363.658264]  [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
[  363.662010]  [<ffffffff971bd96e>] ? put_lock_stats.isra.12+0xe/0x30
[  363.665866]  [<ffffffff9730c043>] do_fallocate+0x153/0x1d0
[  363.669381]  [<ffffffff972b472f>] SyS_madvise+0x33f/0x970
[  363.672906]  [<ffffffff9a4e3f13>] tracesys+0xe1/0xe6
[  363.682900] 2 locks held by trinity-c327/9203:
[  363.684928]  #0:  (sb_writers#12){.+.+.+}, at: [<ffffffff9730c02d>] do_fallocate+0x13d/0x1d0
[  363.715102]  #1:  (&sb->s_type->i_mutex_key#16){+.+.+.}, at: [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
