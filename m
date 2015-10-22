Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3D86B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:49:49 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so127246042wic.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:49:48 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id bw2si17307441wjc.127.2015.10.22.02.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 02:49:47 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so110899546wic.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:49:47 -0700 (PDT)
Date: Thu, 22 Oct 2015 12:49:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv12 14/37] futex, thp: remove special case for THP in
 get_futex_key
Message-ID: <20151022094945.GE10597@node.shutemov.name>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-15-git-send-email-kirill.shutemov@linux.intel.com>
 <20151022082433.GA29487@littlebeast.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022082433.GA29487@littlebeast.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Savkov <artem.savkov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 22, 2015 at 10:24:33AM +0200, Artem Savkov wrote:
> On Tue, Oct 06, 2015 at 06:23:41PM +0300, Kirill A. Shutemov wrote:
> > With new THP refcounting, we don't need tricks to stabilize huge page.
> > If we've got reference to tail page, it can't split under us.
> > 
> > This patch effectively reverts a5b338f2b0b1.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Tested-by: Sasha Levin <sasha.levin@oracle.com>
> > Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Acked-by: Jerome Marchand <jmarchan@redhat.com>
> > ---
> >  kernel/futex.c | 61 ++++++++++++----------------------------------------------
> >  1 file changed, 12 insertions(+), 49 deletions(-)
> 
> This patch breaks compound page futexes with the following panic:
> 
> [   33.465456] general protection fault: 0000 [#1] SMP 
> [   33.465991] CPU: 1 PID: 523 Comm: tst Not tainted 4.3.0-rc6-next-20151022 #139
> [   33.466585] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
> [   33.467370] task: ffff88007bf13a80 ti: ffff88006bdac000 task.ti: ffff88006bdac000
> [   33.467960] RIP: 0010:[<ffffffff81132b3a>]  [<ffffffff81132b3a>] get_futex_key+0x2ba/0x410
> [   33.468332] RSP: 0018:ffff88006bdafc18  EFLAGS: 00010202
> [   33.468332] RAX: dead000000000000 RBX: ffffea0001a50040 RCX: 0000000000000001
> [   33.468332] RDX: ffffea0001a50001 RSI: 0000000000000000 RDI: ffffea0001a50040
> [   33.468332] RBP: ffff88006bdafc58 R08: 0000000000000000 R09: 0000000000000000
> [   33.468332] R10: 0000000000000000 R11: 0000000000000001 R12: 00007f4983601000
> [   33.468332] R13: 0000000000000001 R14: ffff88006bdafd70 R15: 0000000000000000
> [   33.468332] FS:  00007f4983fa4700(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
> [   33.468332] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   33.468332] CR2: 00007f4983601000 CR3: 000000007becb000 CR4: 00000000000006a0
> [   33.468332] Stack:
> [   33.468332]  ffff88006bf2ed00 00000000831169c0 ffffea0001a50040 00007f4983601000
> [   33.468332]  ffff88006bdafce8 ffff88006bdafd38 ffff88006bdafd70 ffff88007bf13a80
> [   33.468332]  ffff88006bdafcb0 ffffffff8113329a ffff88006bdafd80 0000000000000000
> [   33.468332] Call Trace:
> [   33.468332]  [<ffffffff8113329a>] futex_wait_setup+0x4a/0x1d0
> [   33.468332]  [<ffffffff81133540>] futex_wait+0x120/0x330
> [   33.468332]  [<ffffffff8111def0>] ? enqueue_hrtimer+0x50/0x50
> [   33.468332]  [<ffffffff8113587e>] do_futex+0x11e/0x1050
> [   33.468332]  [<ffffffff810e9825>] ? __lock_acquire+0x8c5/0x2830
> [   33.468332]  [<ffffffff8105da35>] ? kvm_clock_read+0x35/0x50
> [   33.468332]  [<ffffffff8105da91>] ? kvm_clock_get_cycles+0x11/0x20
> [   33.468332]  [<ffffffff81136860>] SyS_futex+0xb0/0x240
> [   33.468332]  [<ffffffff81cc3db2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [   33.468332] Code: 48 83 05 c9 e2 54 02 01 e9 56 ff ff ff 48 8b 57 20 f6 c2 01 0f 85 43 01 00 00 a8 01 0f 85 d2 00 00 00 41 83 4e 10 01 48 8b 47 08 <48> 8b 10 49 89 56 08 48 8b 07 f6 c4 40 0f 84 82 00 00 00 48 83 
> [   33.468332] RIP  [<ffffffff81132b3a>] get_futex_key+0x2ba/0x410
> [   33.468332]  RSP <ffff88006bdafc18>
> [   33.483135] ---[ end trace 537578e223c13ed1 ]---
> [   33.483502] Kernel panic - not syncing: Fatal exception
> [   33.484020] Kernel Offset: disabled
> [   33.484313] ---[ end Kernel panic - not syncing: Fatal exception
> 
> This can be triggered with the following reproducer (based on
> futex_wake04 test from ltp):
> 
> #include <errno.h>
> #include <stdio.h>
> #include <stdint.h>
> #include <unistd.h>
> #include <linux/futex.h>
> #include <sys/mman.h>
> #include <sys/syscall.h>
> #include <sys/time.h>
> 
> #define HPGSZ 2097152
> int main(int argc, char **argv) {
>   long ret = 0;
>   void *addr;
>   uint32_t *futex;
>   int pgsz = getpagesize();
> 
>   addr = mmap(NULL, HPGSZ, PROT_WRITE | PROT_READ,
>               MAP_SHARED | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
>   if (addr == MAP_FAILED) {
>     fprintf(stderr, "Failed to alloc hugepage\n");
>     return -1;
>   }
> 
>   futex = (uint32_t *)((char *)addr + pgsz);
>   *futex = 0;
> 
>   ret = syscall(SYS_futex, futex, FUTEX_WAIT, *futex, NULL, NULL, 0);
>   if (ret < 0) {
>     perror("Syscall failed");
>   }
> 
>   munmap(addr, HPGSZ);
> 
>   return 0;
> }

Thanks for report. Patch below fixes the issue for me.
Could you test it as well?

diff --git a/kernel/futex.c b/kernel/futex.c
index 470c06c3299a..b29add22c454 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -470,6 +470,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
 	struct page *page;
+	struct address_space *mapping;
 	int err, ro = 0;
 
 	/*
@@ -535,7 +536,8 @@ again:
 	 * shmem_writepage move it from filecache to swapcache beneath us:
 	 * an unlikely race, but we do need to retry for page->mapping.
 	 */
-	if (!page->mapping) {
+	mapping = compound_head(page)->mapping;
+	if (!mapping) {
 		int shmem_swizzled = PageSwapCache(page);
 		unlock_page(page);
 		put_page(page);
@@ -566,7 +568,7 @@ again:
 		key->private.address = address;
 	} else {
 		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
-		key->shared.inode = page->mapping->host;
+		key->shared.inode = mapping->host;
 		key->shared.pgoff = basepage_index(page);
 	}
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
