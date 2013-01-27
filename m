Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 1BD2B6B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 22:16:25 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so735065dac.26
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 19:16:24 -0800 (PST)
Message-ID: <1359256581.4159.16.camel@kernel>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 26 Jan 2013 21:16:21 -0600
In-Reply-To: <alpine.LNX.2.00.1301261826000.7411@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251753380.29196@eggly.anvils>
	 <1359249282.4159.4.camel@kernel>
	 <alpine.LNX.2.00.1301261826000.7411@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2013-01-26 at 18:54 -0800, Hugh Dickins wrote:
> On Sat, 26 Jan 2013, Simon Jeons wrote:
> > On Fri, 2013-01-25 at 17:54 -0800, Hugh Dickins wrote:
> > > From: Petr Holasek <pholasek@redhat.com>
> > > @@ -1122,6 +1166,18 @@ struct rmap_item *unstable_tree_search_i
> > >  			return NULL;
> > >  		}
> > >  
> > > +		/*
> > > +		 * If tree_page has been migrated to another NUMA node, it
> > > +		 * will be flushed out and put into the right unstable tree
> > 
> > Then why not insert the new page to unstable tree during page migration
> > against current upstream? Because default behavior is merge across
> > nodes.
> 
> I don't understand the words "against current upstream" in your question.

I mean current upstream codes without numa awareness. :)

> 
> We cannot move a page (strictly, a node) from one tree to another during
> page migration itself, because the necessary ksm_thread_mutex is not held.
> Not would we even want to while "merge across nodes".
> 
> Ah, perhaps you are pointing out that in current upstream, the only user
> of ksm page migration is memory hotremove, which in current upstream does
> hold ksm_thread_mutex.
> 
> So you'd like us to add code for moving a node from one tree to another
> in ksm_migrate_page() (and what would it do when it collides with an

Without numa awareness, I still can't understand your explanation why
can't insert the node to the tree just after page migration instead of
inserting it at the next scan.

> existing node?), code which will then be removed a few patches later
> when ksm page migration is fully enabled?
> 
> No, I'm not going to put any more thought into that.  When Andrea pointed
> out the problem with Petr's original change to ksm_migrate_page(), I did
> indeed think that we could do something cleverer at that point; but once
> I got down to trying it, found that a dead end.  I wasn't going to be
> able to test the hotremove case properly anyway, so no good pursuing
> solutions that couldn't be generalized.
> 
> Hugh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
