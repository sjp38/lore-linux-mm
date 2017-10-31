Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2F646B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:37:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 189so44606497iow.14
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:37:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor828161iom.91.2017.10.31.08.37.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 08:37:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
References: <94eb2c0433c8f42cac055cc86991@google.com> <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz> <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz> <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Oct 2017 08:37:47 -0700
Message-ID: <CA+55aFwWJyArZMEuo1-4+VaiP95e__cRHkVvrfiQ+NUVJ15DNQ@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Thorsten Leemhuis <regressions@leemhuis.info>

On Tue, Oct 31, 2017 at 6:57 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> However, __do_page_fault() only expects that mmap_sem to be released
> when handle_mm_fault() returns with VM_FAULT_RETRY. It doesn't expect it
> to be released and then acquired again, because then vma can be indeed
> gone.

Yes. Accessing "vma" after calling "handle_mm_fault()" is a bug. An
unfortunate issue with userfaultfd.

The suggested fix to simply look up pkey beforehand seems sane and simple.

But sadly, from a quick check, it looks like arch/um/ has the same
bug, but even worse. It will do

 (a) handle_mm_fault() in a loop without re-calculating vma. Don't ask me why.

 (b) flush_tlb_page(vma, address); afterwards

but much more importantly, I think __get_user_pages() is broken in two ways:

 - faultin_page() does:

        ret = handle_mm_fault(vma, address, fault_flags);
        ...
        if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))

   (easily fixed the same way)

 - more annoyingly and harder to fix: the retry case in
__get_user_pages(), and the VMA saving there.

Ho humm.

Andrea, looking at that get_user_pages() case, I really think it's
userfaultfd that is broken.

Could we perhaps limit userfaultfd to _only_ do the VM_FAULT_RETRY,
and simply fail for non-retry faults?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
