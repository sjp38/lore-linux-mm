Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D6A666B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 12:23:08 -0400 (EDT)
Date: Sat, 4 Jul 2009 09:44:38 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: handle_mm_fault() calling convention cleanup..
In-Reply-To: <1246664107.7551.11.camel@pasglop>
Message-ID: <alpine.LFD.2.01.0907040937040.3210@localhost.localdomain>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <1246664107.7551.11.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Sat, 4 Jul 2009, Benjamin Herrenschmidt wrote:
> 
> BTW. I'd like to extend these if there's no objection one of these days
> to also pass whether it was an exec fault, and pass the full flags to
> ptep_set_access_flags().

Sure. No problem, and sounds sane.

Just a tiny word of warning: right now, the conversion I did pretty much 
depended on the fact that even if I missed a spot, it wouldn't actually 
make any difference. If somebody used "flags" as a binary value (ie like 
the old "write_access" kind of semantics), things would still all work, 
because it was still a "zero-vs-nonzero" issue wrt writes.

And there were cases in the hugepage handling that I had missed, that 
Hugh picked up. Maybe he picked them all - but be careful.

I didn't add any flags (like the FAULT_FLAG_RETRY thing that started it 
all) that would actually _require_ everybody to always treat it as a 
bitmask. And some places still pass the flags down as basically just the 
"write or not" thing. ptep_set_access_flags() stands out as one of them 
(and I think your suggestion would actually clean things up), but there 
are probably others.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
