Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id CBCB06B0037
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 12:27:06 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gf5so5886667lab.7
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:27:05 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id w10si9116205lal.126.2014.03.31.09.27.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 09:27:05 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so5834797lbi.8
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:27:04 -0700 (PDT)
Date: Mon, 31 Mar 2014 20:27:02 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
Message-ID: <20140331162702.GK4872@moon>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
 <1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
 <533016CB.4090807@citrix.com>
 <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
 <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
 <20140331122625.GR25087@suse.de>
 <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
 <CA+55aFwM5GXr3m2GyL6-PWS-VepPO7HVN-311tM3tFDtDVuGYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwM5GXr3m2GyL6-PWS-VepPO7HVN-311tM3tFDtDVuGYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Mon, Mar 31, 2014 at 09:10:07AM -0700, Linus Torvalds wrote:
> 
> It causes insane situations like this:
> 
>   #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
> 
> which makes no sense *except* if you think that those bits can have
> random odd hardware-defined values. But they really can't. They are
> just random bit numbers we chose.

I never understand this ifdef (I've asked once but got no reply).

> It has *also* caused horrible pain with the whole "soft dirty" thing,
> and we have absolutely ridiculous macros in pgtable-2level.h for the
> insane soft-dirty case, trying to keep the swap bits spread out "just
> right" to make soft-dirty (_PAGE_BIT_HIDDEN aka bit 11) not alias with
> the bits we use for swap offsets etc.
> 
> So how about we just say:
> 
>  - define the bits we use when PAGE_PRESENT==0 separately and explicitly
> 
>  - clean up the crazy soft-dirty crap, preferably by just making it
> depend on a 64-bit pte (so you have to have X86_PAE enabled or be on
> x86-64)

Sounds good for me, i'll try my best (if noone object).

> 
> that would sound like a good cleanup, because right now it's a
> complete nightmare to think about which bits are used how when P is 0.
> The above insane #if being the prime example of that confusion.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
