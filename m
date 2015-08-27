Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id A0F936B0255
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 14:14:38 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so134502wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:14:38 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id y6si18077471wix.78.2015.08.27.11.14.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 11:14:37 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so1023243wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:14:36 -0700 (PDT)
Date: Thu, 27 Aug 2015 20:14:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150827181434.GB29584@dhcp22.suse.cz>
References: <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
 <20150827150917.GF27052@dhcp22.suse.cz>
 <20150827163634.GD4029@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150827163634.GD4029@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu 27-08-15 09:36:34, Paul E. McKenney wrote:
> On Thu, Aug 27, 2015 at 05:09:17PM +0200, Michal Hocko wrote:
> > On Wed 26-08-15 14:29:16, Paul E. McKenney wrote:
> > > On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
> > [...]
> > > > But if you do one day implement that, wouldn't sl?b.c have to use
> > > > call_rcu_with_added_meaning() instead of call_rcu(), to be in danger
> > > > of getting that bit set?  (No rcu_head is placed in a PageTail page.)
> > > 
> > > Good point, call_rcu_lazy(), but yes.
> > > 
> > > > So although it might be a little strange not to use a variant intended
> > > > for freeing memory when indeed that's what it's doing, it would not be
> > > > the end of the world for SLAB_DESTROY_BY_RCU to carry on using straight
> > > > call_rcu(), in defence of the struct page safety Kirill is proposing.
> > > 
> > > As long as you are OK with the bottom bit being zero throughout the RCU
> > > processing, yes.
> > 
> > I am really not sure I udnerstand. What will prevent
> > call_rcu(&page->rcu_head, free_page_rcu) done in a random driver?
> 
> As long as it uses call_rcu(), call_rcu_bh(), call_rcu_sched(),
> or call_srcu() and not some future call_rcu_lazy(), no problem.
> 
> But yes, if you are going to assume that RCU leaves the bottom
> bit of the rcu_head structure's ->next field zero, then everything
> everywhere in the kernel might in the future need to be careful of
> exactly what variant of call_rcu() is used.

OK, so it would be call_rcu_$special to use the bit. This wasn't entirely
clear to me. I thought it would be opposite.

> > Cannot the RCU simply claim bit1? I can see 1146edcbef37 ("rcu: Loosen
> > __call_rcu()'s rcu_head alignment constraint") but AFAIU all it would
> > take to fix this would be to require struct rcu_head to be aligned to
> > 32b no?
> 
> There are some architectures that guarantee only 16-bit alignment.
> If those architectures are fixed to do 32-bit alignment, or if support
> for them is dropped, then the future restrictions mentioned above could
> be dropped.

My understanding of the discussion which led to the above patch is that
m68k allows for 32b alignment you just have to be explicit about that
(http://thread.gmane.org/gmane.linux.ports.m68k/5932/focus=5960). Which
other archs would be affected?

I mean, this patch allows for quite some simplification in the mm code.
And I think that RCU can live with mm of the low bits without any
issues. You've said that one bit should be sufficient for the RCU use
case. So having 2 bits sounds like a good thing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
