Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D1CC06B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 18:27:31 -0500 (EST)
Received: by iacb35 with SMTP id b35so29238296iac.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 15:27:31 -0800 (PST)
Date: Thu, 29 Dec 2011 15:27:17 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
In-Reply-To: <20111229145548.e34cb2f3.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <20111229145548.e34cb2f3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

On Thu, 29 Dec 2011, Andrew Morton wrote:
> On Wed, 28 Dec 2011 20:39:36 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
> > by lists of pages_to_free
> 
> One effect of the pagevec handling was to limit lru_lock hold times and
> interrupt-disabled times.
> 
> This patch removes that upper bound and has the potential to cause
> various latency problems when processing large numbers of pages.
> 
> The affected functions have rather a lot of callers.  I don't think
> that auditing all these callers and convincing ourselves that none of
> them pass in 10,000 pages is sufficient, because that doesn't prevent us
> from introducing such latency problems as the MM code evolves.

That's an interesting slant on it, that hadn't crossed my mind;
but it looks like intervening changes have answered that concern.

putback_lru_pages() has one caller, shrink_inactive_list();
move_active_pages_to_lru() has one caller, shrink_active_list().
Following those back, they're in all cases capped to SWAP_CLUSTER_MAX
pages per call.  That's 32 pages, not so very much more than the 14
page limit the pagevecs were imposing.

And both shrink_inactive_list() and shrink_active_list() gather these
pages with isolate_lru_pages(), which does not drop lock or enable
interrupts at all - probably why the SWAP_CLUSTER_MAX cap got imposed.

(Don't be deceived by mm/migrate.c's putback_lru_pages()!
That's a distinct function, unaffected by this patch.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
