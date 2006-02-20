Date: Mon, 20 Feb 2006 16:30:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: VM_PFNMAP and do_no_pfn handler
In-Reply-To: <yq0psliqb2p.fsf@jaguar.mkp.net>
Message-ID: <Pine.LNX.4.61.0602201620340.12699@goblin.wat.veritas.com>
References: <yq0y806qfgd.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0602201526260.12160@goblin.wat.veritas.com>
 <yq0psliqb2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@sgi.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Carsten Otte <cotte@de.ibm.com>, roe@sgi.com, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Feb 2006, Jes Sorensen wrote:
> 
> Thanks for the explanation. It just seemed to me that is_cow_mapping()
> seemed a bit of a strange name for a
> 'this_mapping_really_has_no_struct_page_behind_it_honest()' function.
> Is there some reason why we try to look up the struct page for
> anything mapped VM_PFNMAP?

If it's a Copy-On-Write mapping, then a write fault on a page (or page
frame!) in that mapping will copy the original to an ordinary anonymous
page, which will then be substituted into the mapping in that position.

So although the vma is marked VM_PFNMAP, if it is_cow_mapping, then it
might contain ordinary struct-page-type pages, which have to be dealt
with in the normal way (otherwise they'll get leaked).

(At first we thought this was not a realistic situation; then we found
some apps did it, and we thought they were just being silly; then we
found that some really relied on COW-ing in a PFNMAP area.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
