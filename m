Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 96E6D6B02C6
	for <linux-mm@kvack.org>; Fri,  3 May 2013 04:37:55 -0400 (EDT)
Date: Fri, 3 May 2013 09:37:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm: pagevec: Defer deciding what LRU to add a page
 to until pagevec drain time
Message-ID: <20130503083749.GL11497@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
 <1367253119-6461-2-git-send-email-mgorman@suse.de>
 <20130503075158.GB10633@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130503075158.GB10633@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Fri, May 03, 2013 at 09:51:58AM +0200, Jan Kara wrote:
> > @@ -789,17 +787,16 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
> >  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
> >  				 void *arg)
> >  {
> > -	enum lru_list lru = (enum lru_list)arg;
> > -	int file = is_file_lru(lru);
> > -	int active = is_active_lru(lru);
> > +	enum lru_list requested_lru = (enum lru_list)arg;
> > +	int file = page_is_file_cache(page);
> > +	int active = PageActive(page);
> > +	enum lru_list lru = page_lru(page);
> >  
> > -	VM_BUG_ON(PageActive(page));
> > +	WARN_ON_ONCE(requested_lru < NR_LRU_LISTS && requested_lru != lru);
>   Hum, so __lru_cache_add() calls this with 'requested_lru' set to whatever
> LRU we currently want to add a page. How should this always be equal to the
> LRU of all the pages we have cached in the pagevec?
> 

It wouldn't necessarily be and and for a pagevec drain, it's ignored
completely.

> And if I'm right, there doesn't seem to be a reason to pass requested_lru
> to this function at all, does it?
> 

You've already noticed that it gets thrown away later in the third
patch. It was left in this patch as a debugging aid in case there was a
direct pagevec user that expected to place pages on an LRU that was at
odds with the page flags.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
