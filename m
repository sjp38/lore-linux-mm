Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16CD06B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:43:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p9so1781217pgc.6
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:43:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si3887505pgq.14.2017.11.01.00.43.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 00:43:03 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <94aa563c-14da-7892-51a0-e1799cdad050@suse.cz>
Date: Wed, 1 Nov 2017 08:42:57 +0100
MIME-Version: 1.0
In-Reply-To: <20171031191506.GB2799@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On 10/31/2017 08:15 PM, Andrea Arcangeli wrote:
> On Tue, Oct 31, 2017 at 03:28:26PM +0100, Vlastimil Babka wrote:
>> Hmm that could indeed work, Dmitry can you try the patch below?
>> But it still seems rather fragile so I'd hope Andrea can do it more
>> robust, or at least make sure that we don't reintroduce this kind of
>> problem in the future (explicitly set vma to NULL with a comment?).
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks. OK so here's the full patch for the immediate issue, unless we
decide to do something more general.

----8<----
