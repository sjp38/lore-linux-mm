Date: Wed, 6 Apr 2005 00:58:04 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: "orphaned pagecache memleak fix" question.
Message-Id: <20050406005804.0045faf9.akpm@osdl.org>
In-Reply-To: <16978.46735.644387.570159@gargle.gargle.HOWL>
References: <16978.46735.644387.570159@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrea@Suse.DE, linux-mm@kvack.org, AKPM@osdl.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Hello,
> 
> I have few question about recent "orphaned pagecache memleak fix"
> change-set:

Something was wrong with that patch.  I accidentally left a printk in there
and nobody has ever reported the printk coming out.

IOW: we can probably revert it (or fix it!) but first we need to get down
and work out what's happening.

>  - how is it supposed to work with file systems that use page->private
>  (and PG_private) for something else than buffer head ring? Such file
>  systems may leak truncated pages for precisely the same reasons
>  reiserfs does, and try_to_free_buffers(page) will most likely oops;

You're screwed, sorry.  If PagePrivate is set and ->mapping is null we just
assume that the thing at ->private is buffers.  It's awful.

If the fs doesn't leave buffers at ->private then it simply cannot allow
->invalidatepage() to return 0.  It must invalidate the page.  We could do
that right now in ext3 (for example) by blocking in ->invalidatepage(). 
(Run a commit, retry the invalidation).

The assumption that the thing at ->private is buffers should be viewed
as a performance hack for buffer-backed address_spaces only.

Note that the patch to which you refer doesn't add this hack - it's already
been there for a long time, in a different place:

		if (PagePrivate(page)) {
			if (!try_to_release_page(page, sc->gfp_mask))
				goto activate_locked;
			if (!mapping && page_count(page) == 1)
				goto free_it;
		}

If we get here with a null ->mapping, we'll assume that ->private contains
a buffer ring.


To which reiserfs do you refer?  reiser4, I assume?


>  - as I see it, nr_dirty shouldn't be updated after calling
>  ClearPageDirty() because page->mapping was NULL already at the time of
>  corresponding __set_page_dirty_nobuffers() call. Right?

That seems to be correct, yes.

>  - wouldn't it be simpler to unconditionally remove page from LRU in
>  ->invalidatepage()?

I guess that's an option, yes.  If the fs cannot successfully invalidate
the page then it can either block (as described above) or remove the page
from the LRU.  The fs then wholly owns the page.

I think it would be better to make ->invalidatepage always succeed though. 
The situation is probably rare.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
