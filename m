Date: Sun, 8 Jun 2008 18:03:40 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080608180340.4abca025@bree.surriel.com>
In-Reply-To: <20080608135704.a4b0dbe1.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 13:57:04 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > If you want I'll get rid of CONFIG_NORECLAIM_LRU and make everything
> > just compile in always.
> 
> Seems unlikely to be useful?  The only way in which this would be an
> advantage if if we hae some other feature which also needs a page flag
> but which will never be concurrently enabled with this one.
> 
> > Please let me know what your preference is.
> 
> Don't use another page flag?

To explain in more detail why we need the page flag:

When we move a page from the active or inactive list onto the
noreclaim list, we need to know what list it was on, in order
to adjust the zone counts for that list (NR_ACTIVE_ANON, etc).

For the same reason, we need to be able to identify whether
a page is already on the noreclaim list, so we can adjust
the statistics for the noreclaim pages, too. We cannot afford
to accidentally move a page onto the noreclaim list twice, or
try to remove it from the noreclaim list twice.

We need to know how many pages of each type there are in
each zone, and we need a way to specify that a page has
just become noreclaim. If a page is sitting a pagevec
somewhere, and it has just become unreclaimable, we want
that page to end up on the noreclaim list once that
pagevec is flushed.

As far as I can see, this requires a page flag.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
