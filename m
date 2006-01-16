Date: Mon, 16 Jan 2006 12:32:14 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <Pine.LNX.4.62.0601152251080.17034@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0601161143190.7123@goblin.wat.veritas.com>
References: <20060114155517.GA30543@wotan.suse.de>
 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
 <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601151053420.4500@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0601152251080.17034@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 15 Jan 2006, Christoph Lameter wrote:
> On Sun, 15 Jan 2006, Hugh Dickins wrote:
> > 
> > Good.  And whether it's your or Nick's patch that goes in, please also
> > remove that PageReserved test which you recently put in check_pte_range.
> 
> Zero pages are still marked reserved AFAIK. Why not check for it?

Indeed they are, at present and quite likely into posterity.  But
they're not a common case here, and migrate_page_add now handles them
silently, so why bother to complicate it with an unnecessary check?

You added the test because the WARN_ON fired, you're now doing the
right thing and removing the WARN_ON because it was inevitably racy,
so it would make sense to remove the PageReserved test too.

If you look through the rest of mm/, you'll find 2.6.15 removed all
the PageReserved tests, except at the low level in page_alloc.c:
so it's retrograde for you to be adding one back here.  Testing
PageLRU would be more relevant, if you insist on such a test.

Or have you found the zero page mapcount distorting get_stats stats?
If that's an issue, then better add a commented test for it there.

Hmm, that battery of unusual tests at the start of migrate_page_add
is odd: the tests don't quite match the comment, and it isn't clear
what reasoning lies behind the comment anyway.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
