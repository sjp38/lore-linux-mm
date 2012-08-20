Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 3ECA36B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 11:53:57 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so6283454ggn.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 08:53:56 -0700 (PDT)
Date: Mon, 20 Aug 2012 08:53:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 06/15] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <alpine.LFD.2.00.1208201221360.3975@vpn-8-6.rdu.redhat.com>
Message-ID: <alpine.LSU.2.00.1208200851500.25707@eggly.anvils>
References: <1343376074-28034-1-git-send-email-lczerner@redhat.com> <1343376074-28034-7-git-send-email-lczerner@redhat.com> <alpine.LSU.2.00.1208192144260.2390@eggly.anvils> <alpine.LFD.2.00.1208201221360.3975@vpn-8-6.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Urrgh, now I messed up trying to correct linux-mm: resend to fix.

On Mon, 20 Aug 2012, Lukas Czerner wrote:
> On Sun, 19 Aug 2012, Hugh Dickins wrote:
> > 
> > This looks good to me.  I like the way you provide the same args
> > to do_invalidatepage_range() as to zero_user_segment():
> > 
> > 		zero_user_segment(page, partial_start, top);
> > 		if (page_has_private(page))
> > 			do_invalidatepage_range(page, partial_start, top);
> > 
> > Unfortunately, that is not what patches 01-05 are expecting...
> 
> Thank for the review Hugh. The fact is that the third argument of
> the invalidatepage_range() was meant to be length and the problem is
> actually in this patch, where I am passing end offset as the third
> argument.
> 
> But you've made it clear that you would like better the semantics
> where the third argument is actually the end offset. Is that right ?
> If so, I'll change it accordingly, otherwise I'll just fix this
> patch.

I do get irritated by gratuitous differences between function calling
conventions, so yes, I liked that you (appeared to) follow
zero_user_segment() here.

However, I don't think my opinion and that precedent are very important
in this case.  What do the VFS people think makes the most sensible
interface for ->invalidatepage_range()?  page, startoffset-within-page,
length-within-page or page, startoffset-within-page, endoffset-within-page?
(where "within" may actually take you to the end of the page).

If they think 3rd arg should be length (and I'd still suggest unsigned
int for both 2nd and 3rd argument, to make it clearer that it's inside
the page, not an erroneous use of unsigned long for ssize_t or loff_t),
that's okay by me.

I can see advantages to length, actually: it's often unclear
whether "end" is of the "last-of-this" or "start-of-next" variety;
in most of mm we are consistent in using end in the start-of-next
sense, but here truncate_inode_pages_range() itself has gone for
the last-of-this meaning.

But even you keep to length, you still need to go through patches 01-05,
changing block_invalidatepage() etc. to
	block_invalidatepage_range(page, offset, PAGE_CACHE_SIZE - offset);
and removing (or more probably replacing by some BUG_ONs for now) the
strange "(stop < length)" stuff in the invalidatatepage_range()s.

I do not think it's a good idea to be lenient about out-of-range args
there: that approach has already wasted time.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
