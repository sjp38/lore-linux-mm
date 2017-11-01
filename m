Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8706B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:14:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 5so988252wmk.13
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 05:14:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si4793edc.100.2017.11.01.05.14.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 05:14:47 -0700 (PDT)
Subject: Re: KASAN: use-after-free Read in __do_page_fault
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
 <20171101101744.GA1846@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ec9d483c-3151-4bfe-2e5b-9396afd84bab@suse.cz>
Date: Wed, 1 Nov 2017 13:14:45 +0100
MIME-Version: 1.0
In-Reply-To: <20171101101744.GA1846@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On 11/01/2017 11:17 AM, Andrea Arcangeli wrote:
> On Wed, Nov 01, 2017 at 08:42:57AM +0100, Vlastimil Babka wrote:
>> The vma should be pinned by mmap_sem, but handle_userfault() will in some
>> scenarios release it and then acquire again, so when we return to
> 
> In the above message and especially in the below comment, I would
> suggest to take the opportunity to more accurately document the
> specific scenario instead of "some scenario" which is only "A return
> to userland to repeat the page fault later with a VM_FAULT_NOPAGE
> retval (potentially after handling any pending signal during the
> return to userland). The return to userland is identified whenever
> FAULT_FLAG_USER|FAULT_FLAG_KILLABLE are both set in vmf->flags".

OK, updated patch below
----8<----
