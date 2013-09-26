Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5FE6B003A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:48:18 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so432791pbc.26
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:48:18 -0700 (PDT)
Message-ID: <52439258.3010904@oracle.com>
Date: Thu, 26 Sep 2013 09:48:08 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:cf17e720
 pmd:05a22067
References: <20130926004028.GB9394@localhost>
In-Reply-To: <20130926004028.GB9394@localhost>
Content-Type: multipart/mixed;
 boundary="------------070901040104010602020109"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------070901040104010602020109
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Hi Fengguang,

Would you please have a try with the attached patch?
It added a small fix based on Vlastimil's patch.

Thanks,
-Bob

On 09/26/2013 08:40 AM, Fengguang Wu wrote:
> Hi Vlastimil,
> 
> FYI, this bug seems still not fixed in linux-next 20130925.
> 
> commit 7a8010cd36273ff5f6fea5201ef9232f30cebbd9
> Author: Vlastimil Babka <vbabka@suse.cz>
> Date:   Wed Sep 11 14:22:35 2013 -0700
> 
>     mm: munlock: manual pte walk in fast path instead of follow_page_mask()
>     
>     Currently munlock_vma_pages_range() calls follow_page_mask() to obtain
>     each individual struct page.  This entails repeated full page table
>     translations and page table lock taken for each page separately.
>     
>     This patch avoids the costly follow_page_mask() where possible, by
>     iterating over ptes within single pmd under single page table lock.  The
>     first pte is obtained by get_locked_pte() for non-THP page acquired by the
>     initial follow_page_mask().  The rest of the on-stack pagevec for munlock
>     is filled up using pte_walk as long as pte_present() and vm_normal_page()
>     are sufficient to obtain the struct page.
>     
>     After this patch, a 14% speedup was measured for munlocking a 56GB large
>     memory area with THP disabled.
>     
>     Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>     Cc: Jorn Engel <joern@logfs.org>
>     Cc: Mel Gorman <mgorman@suse.de>
>     Cc: Michel Lespinasse <walken@google.com>
>     Cc: Hugh Dickins <hughd@google.com>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Johannes Weiner <hannes@cmpxchg.org>
>     Cc: Michal Hocko <mhocko@suse.cz>
>     Cc: Vlastimil Babka <vbabka@suse.cz>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> 
> [   89.835504] init: plymouth-upstart-bridge main process (3556) terminated with status 1
> [   89.986606] init: tty6 main process (3529) killed by TERM signal
> [   91.414086] BUG: Bad page map in process killall5  pte:cf17e720 pmd:05a22067
> [   91.416626] addr:bfc00000 vm_flags:00100173 anon_vma:cf128c80 mapping:  (null) index:bfff0
> [   91.419402] CPU: 0 PID: 3574 Comm: killall5 Not tainted 3.12.0-rc1-00010-g5fbc0a6 #24
> [   91.422171] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   91.423998]  00000000 00000000 c0199e34 c1db5db4 00000000 c0199e54 c10e72d4 000bfff0
> [   91.427933]  00000000 bfc00000 00000000 000cf17e cf17e720 c0199e74 c10e7995 00000000
> [   91.431940]  bfc00000 cf1ca190 bfc00000 cf180000 cf1ca190 c0199ee0 c10eb8cf ce6d1900
> [   91.435894] Call Trace:
> [   91.436969]  [<c1db5db4>] dump_stack+0x4b/0x66
> [   91.438503]  [<c10e72d4>] print_bad_pte+0x14b/0x162
> [   91.440204]  [<c10e7995>] vm_normal_page+0x67/0x9b
> [   91.441811]  [<c10eb8cf>] munlock_vma_pages_range+0xf9/0x176
> [   91.443633]  [<c10ede09>] exit_mmap+0x86/0xf7
> [   91.445156]  [<c10885b8>] ? lock_release+0x169/0x1ef
> [   91.446795]  [<c113e5b6>] ? rcu_read_unlock+0x17/0x23
> [   91.448465]  [<c113effe>] ? exit_aio+0x2b/0x6c
> [   91.449990]  [<c103d4b0>] mmput+0x6a/0xcb
> [   91.451508]  [<c104141a>] do_exit+0x362/0x8be
> [   91.453013]  [<c105d280>] ? hrtimer_debug_hint+0xd/0xd
> [   91.454700]  [<c10419f8>] do_group_exit+0x51/0x9e
> [   91.456296]  [<c1041a5b>] SyS_exit_group+0x16/0x16
> [   91.457901]  [<c1dc6719>] sysenter_do_call+0x12/0x33
> [   91.459553] Disabling lock debugging due to kernel taint
> 
> git bisect start 272b98c6455f00884f0350f775c5342358ebb73f v3.11 --
> git bisect good 57d730924d5cc2c3e280af16a9306587c3a511db  # 02:21    495+  Merge branch 'timers-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect good 3bb22ec53e2bd12a241ed84359bffd591a40ab87  # 12:03    495+  staging/lustre/ptlrpc: convert to new shrinker API
> git bisect  bad a5b7c87f92076352dbff2fe0423ec255e1c9a71b  # 12:18     31-  vmscan, memcg: do softlimit reclaim also for targeted reclaim
> git bisect good 3d94ea51c1d8db6f41268a9d2aea5f5771e9a8d3  # 15:40    495+  ocfs2: clean up dead code in ocfs2_acl_from_xattr()
> git bisect  bad d62a201f24cba74e2fbf9f6f7af86ff5f5e276fc  # 16:46     79-  checkpatch: enforce sane perl version
> git bisect good 83467efbdb7948146581a56cbd683a22a0684bbb  # 01:29    585+  mm: migrate: check movability of hugepage in unmap_and_move_huge_page()
> git bisect  bad 2bff24a3707093c435ab3241c47dcdb5f16e432b  # 02:07    148-  memcg: fix multiple large threshold notifications
> git bisect  bad 1ecfd533f4c528b0b4cc5bc115c4c47f0b5e4828  # 02:34     64-  mm/mremap.c: call pud_free() after fail calling pmd_alloc()
> git bisect good 0ec3b74c7f5599c8a4d2b33d430a5470af26ebf6  # 13:10   1170+  mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
> git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 16:52   1170+  mm: munlock: remove redundant get_page/put_page pair on the fast path
> git bisect  bad 187320932dcece9c4b93f38f56d1f888bd5c325f  # 17:11      0-  mm/sparse: introduce alloc_usemap_and_memmap
> git bisect  bad 6e543d5780e36ff5ee56c44d7e2e30db3457a7ed  # 17:29      2-  mm: vmscan: fix do_try_to_free_pages() livelock
> git bisect  bad 7a8010cd36273ff5f6fea5201ef9232f30cebbd9  # 17:59     14-  mm: munlock: manual pte walk in fast path instead of follow_page_mask()
> git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 22:10   3510+  mm: munlock: remove redundant get_page/put_page pair on the fast path
> git bisect  bad 5fbc0a6263a147cde905affbfb6622c26684344f  # 22:10      0-  Merge remote-tracking branch 'pinctrl/for-next' into kbuild_tmp
> git bisect good 87e37036dcf96eb73a8627524be8b722bd1ac526  # 04:31   3510+  Revert "mm: munlock: manual pte walk in fast path instead of follow_page_mask()"
> git bisect  bad 22356f447ceb8d97a4885792e7d9e4607f712e1b  # 04:40     48-  mm: Place preemption point in do_mlockall() loop
> git bisect  bad 050f4da86e9bdbcc9e11789e0f291aafa57b8a20  # 04:55    133-  Add linux-next specific files for 20130925
> 
> Thanks,
> Fengguang
> 

--------------070901040104010602020109
Content-Type: text/x-patch;
 name="0001-mm-munlock-Prevent-walking-off-the-end-of-a-pagetabl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-mm-munlock-Prevent-walking-off-the-end-of-a-pagetabl.pa";
 filename*1="tch"


--------------070901040104010602020109--
