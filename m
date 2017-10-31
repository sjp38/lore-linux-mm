Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2706B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:15:09 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m198so14133oig.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:15:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x206si1227130oia.52.2017.10.31.12.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 12:15:08 -0700 (PDT)
Date: Tue, 31 Oct 2017 20:15:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Message-ID: <20171031191506.GB2799@redhat.com>
References: <94eb2c0433c8f42cac055cc86991@google.com>
 <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
 <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz>
 <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
 <20171031141152.tzx47fy26pvx7xug@node.shutemov.name>
 <fbf1e43d-1f73-09c1-1837-3600bcedd5d2@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbf1e43d-1f73-09c1-1837-3600bcedd5d2@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Tue, Oct 31, 2017 at 03:28:26PM +0100, Vlastimil Babka wrote:
> Hmm that could indeed work, Dmitry can you try the patch below?
> But it still seems rather fragile so I'd hope Andrea can do it more
> robust, or at least make sure that we don't reintroduce this kind of
> problem in the future (explicitly set vma to NULL with a comment?).

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

> 
> ----8<----
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index e2baeaa053a5..9bd16fc621db 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1441,6 +1441,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
>  	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
>  	 */
> +	pkey = vma_pkey(vma);
>  	fault = handle_mm_fault(vma, address, flags);
>  	major |= fault & VM_FAULT_MAJOR;
>  
> @@ -1467,7 +1468,6 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		return;
>  	}
>  
> -	pkey = vma_pkey(vma);
>  	up_read(&mm->mmap_sem);
>  	if (unlikely(fault & VM_FAULT_ERROR)) {
>  		mm_fault_error(regs, error_code, address, &pkey, fault);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
