Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id BED716B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 21:54:41 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so733960dal.15
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 18:54:40 -0800 (PST)
Date: Sat, 26 Jan 2013 18:54:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
In-Reply-To: <1359249282.4159.4.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301261826000.7411@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251753380.29196@eggly.anvils> <1359249282.4159.4.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Jan 2013, Simon Jeons wrote:
> On Fri, 2013-01-25 at 17:54 -0800, Hugh Dickins wrote:
> > From: Petr Holasek <pholasek@redhat.com>
> > @@ -1122,6 +1166,18 @@ struct rmap_item *unstable_tree_search_i
> >  			return NULL;
> >  		}
> >  
> > +		/*
> > +		 * If tree_page has been migrated to another NUMA node, it
> > +		 * will be flushed out and put into the right unstable tree
> 
> Then why not insert the new page to unstable tree during page migration
> against current upstream? Because default behavior is merge across
> nodes.

I don't understand the words "against current upstream" in your question.

We cannot move a page (strictly, a node) from one tree to another during
page migration itself, because the necessary ksm_thread_mutex is not held.
Not would we even want to while "merge across nodes".

Ah, perhaps you are pointing out that in current upstream, the only user
of ksm page migration is memory hotremove, which in current upstream does
hold ksm_thread_mutex.

So you'd like us to add code for moving a node from one tree to another
in ksm_migrate_page() (and what would it do when it collides with an
existing node?), code which will then be removed a few patches later
when ksm page migration is fully enabled?

No, I'm not going to put any more thought into that.  When Andrea pointed
out the problem with Petr's original change to ksm_migrate_page(), I did
indeed think that we could do something cleverer at that point; but once
I got down to trying it, found that a dead end.  I wasn't going to be
able to test the hotremove case properly anyway, so no good pursuing
solutions that couldn't be generalized.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
