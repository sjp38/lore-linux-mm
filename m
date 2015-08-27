Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8079C6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 15:08:17 -0400 (EDT)
Received: by iodt126 with SMTP id t126so68820742iod.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:08:17 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id z21si2779153iod.138.2015.08.27.12.08.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Aug 2015 12:08:16 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 27 Aug 2015 13:08:16 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2B36019D8040
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:59:10 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7RJ8E5F49414368
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:08:14 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7RJ8CC2027696
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:08:14 -0600
Date: Thu, 27 Aug 2015 12:01:38 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150827190138.GG4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
 <20150827150917.GF27052@dhcp22.suse.cz>
 <20150827163634.GD4029@linux.vnet.ibm.com>
 <20150827181434.GB29584@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150827181434.GB29584@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, Aug 27, 2015 at 08:14:35PM +0200, Michal Hocko wrote:
> On Thu 27-08-15 09:36:34, Paul E. McKenney wrote:
> > On Thu, Aug 27, 2015 at 05:09:17PM +0200, Michal Hocko wrote:
> > > On Wed 26-08-15 14:29:16, Paul E. McKenney wrote:
> > > > On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
> > > [...]
> > > > > But if you do one day implement that, wouldn't sl?b.c have to use
> > > > > call_rcu_with_added_meaning() instead of call_rcu(), to be in danger
> > > > > of getting that bit set?  (No rcu_head is placed in a PageTail page.)
> > > > 
> > > > Good point, call_rcu_lazy(), but yes.
> > > > 
> > > > > So although it might be a little strange not to use a variant intended
> > > > > for freeing memory when indeed that's what it's doing, it would not be
> > > > > the end of the world for SLAB_DESTROY_BY_RCU to carry on using straight
> > > > > call_rcu(), in defence of the struct page safety Kirill is proposing.
> > > > 
> > > > As long as you are OK with the bottom bit being zero throughout the RCU
> > > > processing, yes.
> > > 
> > > I am really not sure I udnerstand. What will prevent
> > > call_rcu(&page->rcu_head, free_page_rcu) done in a random driver?
> > 
> > As long as it uses call_rcu(), call_rcu_bh(), call_rcu_sched(),
> > or call_srcu() and not some future call_rcu_lazy(), no problem.
> > 
> > But yes, if you are going to assume that RCU leaves the bottom
> > bit of the rcu_head structure's ->next field zero, then everything
> > everywhere in the kernel might in the future need to be careful of
> > exactly what variant of call_rcu() is used.
> 
> OK, so it would be call_rcu_$special to use the bit. This wasn't entirely
> clear to me. I thought it would be opposite.

Yes.  And I cannot resist adding that the need to avoid
call_rcu_$special() would be with respect to a given rcu_head structure,
not global.  Though I believe that you already figured that out.  ;-)

> > > Cannot the RCU simply claim bit1? I can see 1146edcbef37 ("rcu: Loosen
> > > __call_rcu()'s rcu_head alignment constraint") but AFAIU all it would
> > > take to fix this would be to require struct rcu_head to be aligned to
> > > 32b no?
> > 
> > There are some architectures that guarantee only 16-bit alignment.
> > If those architectures are fixed to do 32-bit alignment, or if support
> > for them is dropped, then the future restrictions mentioned above could
> > be dropped.
> 
> My understanding of the discussion which led to the above patch is that
> m68k allows for 32b alignment you just have to be explicit about that
> (http://thread.gmane.org/gmane.linux.ports.m68k/5932/focus=5960). Which
> other archs would be affected?
> 
> I mean, this patch allows for quite some simplification in the mm code.
> And I think that RCU can live with mm of the low bits without any
> issues. You've said that one bit should be sufficient for the RCU use
> case. So having 2 bits sounds like a good thing.

As long as MM doesn't use call_rcu_$special() for the rcu_head structure
in question, as long as MM is OK with the bottom bit of ->next always
being zero during a grace period, and as long as MM avoids writing
to ->next during a grace period, we should be good as is, even if a
call_rcu_$special() becomes necessary.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
