Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 966566B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:18:53 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so3757366yha.40
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:18:53 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x29si12961055yha.136.2013.12.16.07.18.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 07:18:52 -0800 (PST)
Message-ID: <52AF19CF.2060102@oracle.com>
Date: Mon, 16 Dec 2013 10:18:39 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap
 file prefetch
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com> <52AA0613.2000908@oracle.com> <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com> <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com> <52AE271C.4040805@oracle.com> <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com> <20131216124754.29063E0090@blue.fi.intel.com>
In-Reply-To: <20131216124754.29063E0090@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

On 12/16/2013 07:47 AM, Kirill A. Shutemov wrote:
> I probably miss some context here. Do you have crash on some use-case or
> what? Could you point me to start of discussion.

Yes, Sorry, here's the crash that started this discussion originally:

The code points to:

         for (index = start; index != end; index += PAGE_SIZE) {
                 pte_t pte;
                 swp_entry_t entry;
                 struct page *page;
                 spinlock_t *ptl;

                 orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);  <=== HERE
                 pte = *(orig_pte + ((index - start) / PAGE_SIZE));
                 pte_unmap_unlock(orig_pte, ptl);


[ 1840.379128] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 1840.506540] IP: [<ffffffff81199c09>] do_raw_spin_trylock+0x9/0x60
[ 1840.507378] PGD e07f80067 PUD e07f81067 PMD 0
[ 1840.507966] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1840.508833] Dumping ftrace buffer:
[ 1840.509859]    (ftrace buffer empty)
[ 1840.510187] Modules linked in:
[ 1840.510187] CPU: 10 PID: 39165 Comm: trinity-child10 Not tainted 
3.13.0-rc3-next-20131212-sasha-00007-gbcfdb32 #4062
[ 1840.510187] task: ffff880d89feb000 ti: ffff880d8f8dc000 task.ti: ffff880d8f8dc000
[ 1840.510187] RIP: 0010:[<ffffffff81199c09>]  [<ffffffff81199c09>] do_raw_spin_trylock+0x9/0x60
[ 1840.510187] RSP: 0018:ffff880d8f8ddc78  EFLAGS: 00010296
[ 1840.510187] RAX: ffff880d89feb000 RBX: 0000000000000000 RCX: 0000000000000000
[ 1840.510187] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[ 1840.510187] RBP: ffff880d8f8ddc78 R08: 0000000000000000 R09: 0000000000000000
[ 1840.510187] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000018
[ 1840.510187] R13: ffff880d91e9c2d8 R14: 00003ffffffff000 R15: ffff880000000000
[ 1840.510187] FS:  00007f394f15e700(0000) GS:ffff880fe0a00000(0000) knlGS:0000000000000000
[ 1840.510187] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1840.510187] CR2: 0000000000000000 CR3: 0000000eb9d7f000 CR4: 00000000000006e0
[ 1840.510187] DR0: 0000000000694000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1840.510187] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1840.510187] Stack:
[ 1840.510187]  ffff880d8f8ddca8 ffffffff843b0768 ffffffff8127885f ffffffff843b1725
[ 1840.510187]  00007f390b600000 0000000000000000 ffff880d8f8ddd08 ffffffff8127885f
[ 1840.510187]  0000000000000000 ffff880efc0cc600 00007f390b800000 0000000d190001e0
[ 1840.510187] Call Trace:
[ 1840.510187]  [<ffffffff843b0768>] _raw_spin_lock+0x48/0x80
[ 1840.510187]  [<ffffffff8127885f>] ? swapin_walk_pmd_entry+0xff/0x250
[ 1840.510187]  [<ffffffff843b1725>] ? _raw_spin_unlock+0x35/0x60
[ 1840.510187]  [<ffffffff8127885f>] swapin_walk_pmd_entry+0xff/0x250
[ 1840.510187]  [<ffffffff81290f98>] walk_pmd_range+0xf8/0x240
[ 1840.510187]  [<ffffffff812911e3>] walk_pud_range+0x103/0x150
[ 1840.510187]  [<ffffffff81291451>] walk_page_range+0x221/0x2a0
[ 1840.510187]  [<ffffffff81278a32>] madvise_willneed+0x82/0x160
[ 1840.510187]  [<ffffffff81278760>] ? madvise_hwpoison+0x140/0x140
[ 1840.510187]  [<ffffffff81278e3e>] madvise_vma+0x11e/0x1c0
[ 1840.510187]  [<ffffffff81279068>] SyS_madvise+0x188/0x250
[ 1840.510187]  [<ffffffff843baed0>] tracesys+0xdd/0xe2
[ 1840.510187] Code: 40 00 e8 ab 32 fc ff 84 c0 0f 84 3b ff ff ff 48 83 c4 18 31 c0 5b 41 5c 41 5d 
41 5e 41 5f c9 c3 90 90 55 48 89 e5 66 66 66 66 90 <8b> 17 0f b7 ca 89 d0 c1 e8 10 83 e0 fe 39 c1 75 
36 8d 8a 00 00
[ 1840.510187] RIP  [<ffffffff81199c09>] do_raw_spin_trylock+0x9/0x60
[ 1840.510187]  RSP <ffff880d8f8ddc78>
[ 1840.510187] CR2: 0000000000000000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
