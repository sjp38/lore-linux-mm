Date: Thu, 3 Apr 2003 16:38:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
In-Reply-To: <92070000.1049381395@[10.1.1.5]>
Message-ID: <Pine.LNX.4.44.0304031615190.1951-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Apr 2003, Dave McCracken wrote:
> 
> I thought of a big hole in the simpler scheme you suggested.  It occurred
> to me that try_to_unmap will fail.  It will see the PageAnon flag so it'll
> just walk the pte_chain and assume it doesn't have to walk the vmas.  This
> will leave the page with some stranded mappings.  Actually
> page_convert_anon will then finish, and we'll have a page where
> try_to_unmap claims it has succeeded but still has mappings.

I don't see that as a big hole at all.  While we're in page_convert_anon,
yes, page_referenced won't find all the ptes and try_to_unmap won't be
able to unmap them all; but there are plenty of other reasons why a page
may be briefly unfreeable even though try_to_unmap succeeded, it'll just
try again later.

I haven't really had my think yet, but the only difficulty I've seen so
far is in maintaining the nr_mapped stats correctly.  page_convert_anon
insert an initial dummy entry (the entry install_page is about to add?)
to make sure page_mapped cannot go false?

(Hmm, is the current page_convert_anon maintaining nr_reverse_maps
correctly?  I would think not, since it's doing nothing about it, and
page_remove_rmap would decrement seeing an Anon.  But perhaps I'm
confused again, a quick test doesn't show the drop I'd expect.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
