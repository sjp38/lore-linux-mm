Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id DA8326B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 12:10:07 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id ld13so8264075vcb.19
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:10:07 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id tq2si2782926vdc.3.2014.03.31.09.10.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 09:10:07 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id ks9so8664563vcb.13
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:10:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
	<1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
	<533016CB.4090807@citrix.com>
	<CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
	<CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
	<20140331122625.GR25087@suse.de>
	<CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
Date: Mon, 31 Mar 2014 09:10:07 -0700
Message-ID: <CA+55aFwM5GXr3m2GyL6-PWS-VepPO7HVN-311tM3tFDtDVuGYA@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>
Cc: Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Cyrill Gorcunov <gorcunov@gmail.com>

[ Adding x86 maintainers - Ingo was involved earlier, make it more explicit ]

On Mon, Mar 31, 2014 at 8:41 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So on x86, the obvious model is to use another bit. We've got several.
> The _PAGE_NUMA case only matters for when _PAGE_PRESENT is clear, and
> when that bit is clear the hardware doesn't care about any of the
> other bits. Currently we use:
>
>   #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
>   #define _PAGE_BIT_FILE          _PAGE_BIT_DIRTY
>
> which are bits 8 and 6 respectively, afaik.

Side note to the x86 guys: I think it was a mistake (long long long
ago) to define these "valid when not present" bits in terms of the
"valid when present" bits.

It causes insane situations like this:

  #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE

which makes no sense *except* if you think that those bits can have
random odd hardware-defined values. But they really can't. They are
just random bit numbers we chose.

It has *also* caused horrible pain with the whole "soft dirty" thing,
and we have absolutely ridiculous macros in pgtable-2level.h for the
insane soft-dirty case, trying to keep the swap bits spread out "just
right" to make soft-dirty (_PAGE_BIT_HIDDEN aka bit 11) not alias with
the bits we use for swap offsets etc.

So how about we just say:

 - define the bits we use when PAGE_PRESENT==0 separately and explicitly

 - clean up the crazy soft-dirty crap, preferably by just making it
depend on a 64-bit pte (so you have to have X86_PAE enabled or be on
x86-64)

that would sound like a good cleanup, because right now it's a
complete nightmare to think about which bits are used how when P is 0.
The above insane #if being the prime example of that confusion.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
