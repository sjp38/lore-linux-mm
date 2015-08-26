Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC3D6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 19:35:01 -0400 (EDT)
Received: by qgeg42 with SMTP id g42so1818513qge.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 16:35:01 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id 71si286326qky.1.2015.08.26.16.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Aug 2015 16:35:00 -0700 (PDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 26 Aug 2015 17:34:59 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9A3323E4003F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 17:34:57 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7QNYvfV44499120
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 16:34:57 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7QNYuFk016683
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 17:34:57 -0600
Date: Wed, 26 Aug 2015 16:34:56 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150826233455.GH11078@linux.vnet.ibm.com>
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
 <alpine.LSU.2.11.1508261526260.2585@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508261526260.2585@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, Aug 26, 2015 at 03:28:39PM -0700, Hugh Dickins wrote:
> On Wed, 26 Aug 2015, Paul E. McKenney wrote:
> > On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
> > > On Tue, 25 Aug 2015, Paul E. McKenney wrote:
> > > > On Tue, Aug 25, 2015 at 10:46:44PM +0200, Vlastimil Babka wrote:
> > > > > On 25.8.2015 22:11, Paul E. McKenney wrote:
> > > > > > On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> > > > > >> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> > > > > >>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> > > > > >>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> > > > > >>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > > > >>>>>
> > > > > >>>>>> The patch introduces page->compound_head into third double word block in
> > > > > >>>>>> front of compound_dtor and compound_order. That means it shares storage
> > > > > >>>>>> space with:
> > > > > >>>>>>
> > > > > >>>>>>  - page->lru.next;
> > > > > >>>>>>  - page->next;
> > > > > >>>>>>  - page->rcu_head.next;
> > > > > >>>>>>  - page->pmd_huge_pte;
> > > > > >>>>>>
> > > > > >>>
> > > > > >>> We should probably ask Paul about the chances that rcu_head.next would like
> > > > > >>> to use the bit too one day?
> > > > > >>
> > > > > >> +Paul.
> > > > > > 
> > > > > > The call_rcu() function does stomp that bit, but if you stop using that
> > > > > > bit before you invoke call_rcu(), no problem.
> > > > > 
> > > > > You mean that it sets the bit 0 of rcu_head.next during its processing?
> > > > 
> > > > Not at the moment, though RCU will splat if given a misaligned rcu_head
> > > > structure because of the possibility to use that bit to flag callbacks
> > > > that do nothing but free memory.  If RCU needs to do that (e.g., to
> > > > promote energy efficiency), then that bit might well be set during
> > > > RCU grace-period processing.
> > > 
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
> That's exactly what we want: sounds like we have no problem, thanks Paul.

Whew!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
