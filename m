Date: Wed, 26 May 2004 00:42:58 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040525224258.GK29378@dualathlon.random>
References: <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org> <20040525034326.GT29378@dualathlon.random> <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org> <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk> <Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org> <20040525212720.GG29378@dualathlon.random> <Pine.LNX.4.58.0405251440120.9951@ppc970.osdl.org> <20040525215500.GI29378@dualathlon.random> <Pine.LNX.4.58.0405251500250.9951@ppc970.osdl.org> <20040526021845.A1302@den.park.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040526021845.A1302@den.park.msu.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Linus Torvalds <torvalds@osdl.org>, Matthew Wilcox <willy@debian.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2004 at 02:18:45AM +0400, Ivan Kokshaysky wrote:
> On Tue, May 25, 2004 at 03:01:55PM -0700, Linus Torvalds wrote:
> > A "not-present" fault is a totally different fault from a "protection 
> > fault". Only the not-present fault ends up walking the page tables, if I 
> > remember correctly.
> 
> Precisely. The architecture reference manual says:
> "Additionally, when the software changes any part (except the software
> field) of a *valid* PTE, it must also execute a tbi instruction."

thanks for checking.

after various searching on the x86 docs I found:

	Whenever a page-directory or page-table entry is changed (including when
	the present flag is set to zero), the operating-system must immediately
	invalidate the corresponding entry in the TLB so that it can be updated
	the next time the entry is referenced.

according to the above we'd need to flush the tlb even in
do_anonymous_page on x86, or am I reading it wrong? We're not really
doing that, is that a bug? I'd be very surprised if we overlooked x86
wasting some time in some page fault loop, I guess it works like the
alpha in practice even if the specs tells us we've to flush.

anyways to make things work right with my approch I'd need to flush the
tlb after the handle_*_page_fault operations (they could return 1
if a flush is required before returning from the page fault) and I
should resurrect pte_establish in do_wp_page. but then I certainly agree
leaving ptep_establish in handle_mm_fault is fine if we've to flush the
tlb anyways, so I'm not going to update my patch unless anybody prefers
it for any other reason I don't see.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
