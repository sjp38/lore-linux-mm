Date: Tue, 6 Nov 2007 21:55:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
Message-ID: <20071106215552.4ab7df81@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<20071103185516.24832ab0@bree.surriel.com>
	<Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 18:23:44 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 3 Nov 2007, Rik van Riel wrote:
> 
> > Define page_file_cache() function to answer the question:
> > 	is page backed by a file?
> 
> Well its not clear what is meant by a file in the first place.
> By file you mean disk space in contrast to ram based filesystems?

Yes.  I have improved the comment over page_file_cache() a bit:

/**
 * page_file_cache(@page)
 * Returns !0 if @page is page cache page backed by a regular filesystem,
 * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
 *
 * We would like to get this info without a page flag, but the state
 * needs to survive until the page is last deleted from the LRU, which
 * could be as far down as __page_cache_release.
 */

> I think we could add a flag to the bdi to indicate wheter the backing 
> store is a disk file. In fact you can also deduce if if a device has
> no writeback capability set in the BDI.
> 
> > Unfortunately this needs to use a page flag, since the
> > PG_swapbacked state needs to be preserved all the way
> > to the point where the page is last removed from the
> > LRU.  Trying to derive the status from other info in
> > the page resulted in wrong VM statistics in earlier
> > split VM patchsets.
> 
> The bdi may avoid that extra flag.

The bdi will no longer be accessible by the time a page
makes it to free_hot_cold_page, which is one place in the
kernel where this information is needed.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
