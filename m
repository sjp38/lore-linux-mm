Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACF4F6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 06:17:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v9so2002865oif.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 03:17:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v18si167823oif.108.2017.11.01.03.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 03:17:47 -0700 (PDT)
Date: Wed, 1 Nov 2017 11:17:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Message-ID: <20171101101744.GA1846@redhat.com>
References: <94eb2c0433c8f42cac055cc86991@google.com>
 <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
 <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz>
 <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
 <20171031141152.tzx47fy26pvx7xug@node.shutemov.name>
 <fbf1e43d-1f73-09c1-1837-3600bcedd5d2@suse.cz>
 <20171031191506.GB2799@redhat.com>
 <94aa563c-14da-7892-51a0-e1799cdad050@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94aa563c-14da-7892-51a0-e1799cdad050@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Wed, Nov 01, 2017 at 08:42:57AM +0100, Vlastimil Babka wrote:
> The vma should be pinned by mmap_sem, but handle_userfault() will in some
> scenarios release it and then acquire again, so when we return to

In the above message and especially in the below comment, I would
suggest to take the opportunity to more accurately document the
specific scenario instead of "some scenario" which is only "A return
to userland to repeat the page fault later with a VM_FAULT_NOPAGE
retval (potentially after handling any pending signal during the
return to userland). The return to userland is identified whenever
FAULT_FLAG_USER|FAULT_FLAG_KILLABLE are both set in vmf->flags".

> +	 * in some scenario (and not return VM_FAULT_RETRY), we have to be

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
