Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2FC076B000A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 04:08:12 -0500 (EST)
Date: Fri, 8 Feb 2013 10:08:05 +0100 (CET)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <20130207154042.92430aed.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1302080948110.3225@localhost>
References: <1360055531-26309-1-git-send-email-lczerner@redhat.com> <1360055531-26309-11-git-send-email-lczerner@redhat.com> <20130207154042.92430aed.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Thu, 7 Feb 2013, Andrew Morton wrote:

> Date: Thu, 7 Feb 2013 15:40:42 -0800
> From: Andrew Morton <akpm@linux-foundation.org>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     Hugh Dickins <hughd@google.com>
> Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
>      non page aligned ranges
> 
> On Tue,  5 Feb 2013 10:12:03 +0100
> Lukas Czerner <lczerner@redhat.com> wrote:
> 
> > This commit changes truncate_inode_pages_range() so it can handle non
> > page aligned regions of the truncate. Currently we can hit BUG_ON when
> > the end of the range is not page aligned, but we can handle unaligned
> > start of the range.
> > 
> > Being able to handle non page aligned regions of the page can help file
> > system punch_hole implementations and save some work, because once we're
> > holding the page we might as well deal with it right away.
> > 
> > In previous commits we've changed ->invalidatepage() prototype to accept
> > 'length' argument to be able to specify range to invalidate. No we can
> > use that new ability in truncate_inode_pages_range().
> > 
> > ...
> >
> > +	/*
> > +	 * 'start' and 'end' always covers the range of pages to be fully
> > +	 * truncated. Partial pages are covered with 'partial_start' at the
> > +	 * start of the range and 'partial_end' at the end of the range.
> > +	 * Note that 'end' is exclusive while 'lend' is inclusive.
> > +	 */
> 
> That helped ;)  So the bytes to be truncated are
> 
> (start*PAGE_SIZE + partial_start) -> (end*PAGE_SIZE + partial_end) - 1
> 
> yes?

The start of the range is not right, because 'start' and 'end'
covers pages to be _fully_ truncated. See the while cycle and 
then 'if (partial_start)' condition where we search for the
page (start - 1) and do_invalidate within that page.

So it should be like this:


(start*PAGE_SIZE - partial_start*(PAGE_SIZE - partial_start) ->
(end*PAGE_END + partial_end) - 1


assuming that you want the range to be inclusive on both sides.

-Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
