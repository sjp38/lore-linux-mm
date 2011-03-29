Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C50008D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:59:41 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576757Ab1C2S7N (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 29 Mar 2011 20:59:13 +0200
Date: Tue, 29 Mar 2011 20:59:13 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110329185913.GF30387@router-fw-old.local.net-space.pl>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl> <20110328153735.d797c5b3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328153735.d797c5b3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 03:37:35PM -0700, Andrew Morton wrote:
> On Mon, 28 Mar 2011 11:25:07 +0200
> Daniel Kiper <dkiper@net-space.pl> wrote:
> > +/*
> > + * 0 priority makes this the fallthrough default. All
> > + * architectures wanting to override this should set
> > + * a higher priority and return NOTIFY_STOP to keep
> > + * this from running.
> > + */
> > +
> > +static struct notifier_block generic_online_page_nb = {
> > +	.notifier_call = generic_online_page_notifier,
> > +	.priority = 0
> > +};
> > +
> > +static int __init init_online_page_chain(void)
> > +{
> > +	return register_online_page_notifier(&generic_online_page_nb);
> > +}
> > +pure_initcall(init_online_page_chain);
> > +
> > +static void online_page(struct page *page)
> > +{
> > +	raw_notifier_call_chain(&online_page_chain, 0, page);
> > +}
>
> This is a bit strange.  Normally we'll use a notifier chain to tell
> listeners "hey, X just happened".  But this code is different - it
> instead uses a notifier chain to tell handlers "hey, do X".  Where in
> this case, X is "free a page".
>
> And this (ab)use of notifiers is not a good fit!  Because we have the
> obvious problem that if there are three registered noftifiers, we don't
> want to be freeing the page three times.  Hence the tricks with
> notifier callout return values.
>
> If there are multiple independent notifier handlers, how do we manage
> their priorities?  And what are the effects of the ordering of the
> registration calls?
>
> And when one callback overrides an existing one, is there any point in
> leaving the original one installed at all?
>
> I dunno, it's all a bit confusing and strange.  Perhaps it would help
> if you were to explain exactly what behaviour you want here, and we can
> look to see if there is a more idiomatic way of doing it.

OK. I am looking for simple generic mechanism which allow runtime
registration/unregistration of generic or module specific (in that
case Xen) page onlining function. Dave Hansen sugested compile time
solution (https://lkml.org/lkml/2011/2/8/235), however, it does not
fit well in my new project on which I am working on (I am going post
details at the end of April).

> Also...  I don't think we need (the undocumented)
> OP_DO_NOT_INCREMENT_TOTAL_COUNTERS and OP_INCREMENT_TOTAL_COUNTERS.
> Just do
>
> void __online_page_increment_counters(struct page *page,
> 					bool inc_total_counters);
>
> and pass it "true" or false".

What do you think about __online_page_increment_counters()
(totalram_pages and totalhigh_pages) and
__online_page_set_limits() (num_physpages and max_mapnr) ???

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
