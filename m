Date: Tue, 2 Dec 2008 14:12:05 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
In-Reply-To: <Pine.LNX.4.64.0812020710371.9474@quilx.com>
Message-ID: <Pine.LNX.4.64.0812021357390.28623@blonde.anvils>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010038220.11401@blonde.site> <Pine.LNX.4.64.0812010843230.15331@quilx.com>
 <Pine.LNX.4.64.0812012349330.18893@blonde.anvils> <Pine.LNX.4.64.0812012014150.30344@quilx.com>
 <Pine.LNX.4.64.0812020947440.5306@blonde.anvils> <Pine.LNX.4.64.0812020710371.9474@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008, Christoph Lameter wrote:
> On Tue, 2 Dec 2008, Hugh Dickins wrote:
> 
> > > But they are always clear on free. The checking is irrelevant.
> >
> > How about CHECK_PAGE_FLAGS_CLEAR_AT_FREE?
> 
> Strange name.

Looks like I'm not going to be able to satisfy you then.  I didn't
introduce the names in the patch, so let's leave them as is for now,
and everybody can muse on what they should get called in the end.

> > > If (page->flags & (all the flags including dirty and SwapBacked))
> > > 	zap-em.
> >
> > That's exactly what I did, isn't it?
> 
> Yes but you added another instance of this.

Did I?  Whereabouts?  I wonder if you're thinking of the
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
in prep_new_page(), which replaces the clearing of another
collection of flags which somehow didn't get named before.

That clearing is a temporary measure, to keep the handling
of PageReserved unchanged in that patch; then it vanishes in the
next patch, where we treat all bad_page candidates the same way.

> Can you consolidate all the check and clears into one?

You mean one test_and_clear_bits() that somehow covers the different
cases of what we expect at free time and what we need at alloc time?
I don't think so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
