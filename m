Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EAD026B0007
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 06:34:22 -0500 (EST)
Date: Thu, 14 Feb 2013 11:34:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
Message-ID: <20130214113418.GB7367@suse.de>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
 <alpine.LNX.2.00.1301251759470.29196@eggly.anvils>
 <20130205171805.GK21389@suse.de>
 <alpine.LNX.2.00.1302071607360.2133@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302071607360.2133@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 07, 2013 at 04:33:58PM -0800, Hugh Dickins wrote:
> > > <SNIP>
> > > --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:53.244205966 -0800
> > > +++ mmotm/mm/ksm.c	2013-01-25 14:36:58.856206099 -0800
> > > @@ -514,15 +514,14 @@ static void remove_node_from_stable_tree
> > >   * but this is different - made simpler by ksm_thread_mutex being held, but
> > >   * interesting for assuming that no other use of the struct page could ever
> > >   * put our expected_mapping into page->mapping (or a field of the union which
> > > - * coincides with page->mapping).  The RCU calls are not for KSM at all, but
> > > - * to keep the page_count protocol described with page_cache_get_speculative.
> > > + * coincides with page->mapping).
> > >   *
> > >   * Note: it is possible that get_ksm_page() will return NULL one moment,
> > >   * then page the next, if the page is in between page_freeze_refs() and
> > >   * page_unfreeze_refs(): this shouldn't be a problem anywhere, the page
> > >   * is on its way to being freed; but it is an anomaly to bear in mind.
> > >   */
> > > -static struct page *get_ksm_page(struct stable_node *stable_node)
> > > +static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
> > >  {
> > 
> > The naming is unhelpful :(
> > 
> > Because the second parameter is called "locked", it implies that the
> > caller of this function holds the page lock (which is obviously very
> > silly). ret_locked maybe?
> 
> I'd prefer "lock_it": I'll make that change unless you've a better.
> 

I don't.

> > 
> > As the function is akin to find_lock_page I would  prefer if there was
> > a new get_lock_ksm_page() instead of locking depending on the value of a
> > parameter.
> 
> I demur.  If it were a global interface rather than a function static
> to ksm.c, yes, I'm sure Linus would side very strongly with you, and I'd
> be providing a pair of wrappers to get_ksm_page() to hide the bool arg.
> 
> But this is a private function (you're invited :) which doesn't need
> that level of hand-holding.
> 
> And I'm a firm believer in having one, difficult, function where all
> the heavy thought is focussed, which does the nasty work and spares
> everywhere else from having to worry about the difficulties.
> 

Ok, I'm convinced. As you say, the case for having one function is a lot
strong later in the series when this function becomes quite complex. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
