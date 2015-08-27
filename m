Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 278CE6B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:36:43 -0400 (EDT)
Received: by qkfh127 with SMTP id h127so13482768qkf.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:36:43 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id f23si3098194qge.2.2015.08.27.09.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Aug 2015 09:36:42 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 27 Aug 2015 10:36:41 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4C62F19D8040
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:27:33 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7RGabe645088920
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:36:37 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7RGaa1q018298
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:36:37 -0600
Date: Thu, 27 Aug 2015 09:36:34 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150827163634.GD4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
 <20150827150917.GF27052@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150827150917.GF27052@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, Aug 27, 2015 at 05:09:17PM +0200, Michal Hocko wrote:
> On Wed 26-08-15 14:29:16, Paul E. McKenney wrote:
> > On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
> [...]
> > > But if you do one day implement that, wouldn't sl?b.c have to use
> > > call_rcu_with_added_meaning() instead of call_rcu(), to be in danger
> > > of getting that bit set?  (No rcu_head is placed in a PageTail page.)
> > 
> > Good point, call_rcu_lazy(), but yes.
> > 
> > > So although it might be a little strange not to use a variant intended
> > > for freeing memory when indeed that's what it's doing, it would not be
> > > the end of the world for SLAB_DESTROY_BY_RCU to carry on using straight
> > > call_rcu(), in defence of the struct page safety Kirill is proposing.
> > 
> > As long as you are OK with the bottom bit being zero throughout the RCU
> > processing, yes.
> 
> I am really not sure I udnerstand. What will prevent
> call_rcu(&page->rcu_head, free_page_rcu) done in a random driver?

As long as it uses call_rcu(), call_rcu_bh(), call_rcu_sched(),
or call_srcu() and not some future call_rcu_lazy(), no problem.

But yes, if you are going to assume that RCU leaves the bottom
bit of the rcu_head structure's ->next field zero, then everything
everywhere in the kernel might in the future need to be careful of
exactly what variant of call_rcu() is used.

> Cannot the RCU simply claim bit1? I can see 1146edcbef37 ("rcu: Loosen
> __call_rcu()'s rcu_head alignment constraint") but AFAIU all it would
> take to fix this would be to require struct rcu_head to be aligned to
> 32b no?

There are some architectures that guarantee only 16-bit alignment.
If those architectures are fixed to do 32-bit alignment, or if support
for them is dropped, then the future restrictions mentioned above could
be dropped.

							Thanx, Paul

> Btw. Do we need the same think for page::mapping and KSM?
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
