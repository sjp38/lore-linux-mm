Date: Mon, 24 May 2004 21:59:36 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
In-Reply-To: <20040525045059.GW29378@dualathlon.random>
Message-ID: <Pine.LNX.4.58.0405242156380.9951@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston> <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
 <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
 <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
 <20040525034326.GT29378@dualathlon.random> <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
 <20040525042054.GU29378@dualathlon.random> <Pine.LNX.4.58.0405242137210.32189@ppc970.osdl.org>
 <20040525045059.GW29378@dualathlon.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Tue, 25 May 2004, Andrea Arcangeli wrote:
> 
> no, that's not what I remeber from alpha, alpha always sets the young
> bit as soon as it sets the pte from non-null to something.

Yes.

However, whtn the page is _aged_ later, the young bits will be cleared.

And _that_ is when you will now start getting infinite page faults, 
because with your patch the young bits will never be set again on a normal 
read.

See what I'm saying?

Your patch literally leaves the page table alone on pure reads. Which is 
not acceptable, since the page being marked old was what caused the 
read-fault in the first place.

But yes, pages will be young by default, so you won't ever actually _see_ 
this behaviour until you start having memory pressure and VM reclaim 
starts trying to age the things.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
