Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5791C6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 18:28:48 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so1700294pac.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:28:48 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id g4si178344pdh.107.2015.08.26.15.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 15:28:47 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so1627439pac.2
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:28:47 -0700 (PDT)
Date: Wed, 26 Aug 2015 15:28:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
In-Reply-To: <20150826212916.GG11078@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1508261526260.2585@eggly.anvils>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com> <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com> <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org> <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz> <20150825183354.GC4881@node.dhcp.inet.fi> <20150825201113.GK11078@linux.vnet.ibm.com> <55DCD434.9000704@suse.cz> <20150825211954.GN11078@linux.vnet.ibm.com> <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, 26 Aug 2015, Paul E. McKenney wrote:
> On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
> > On Tue, 25 Aug 2015, Paul E. McKenney wrote:
> > > On Tue, Aug 25, 2015 at 10:46:44PM +0200, Vlastimil Babka wrote:
> > > > On 25.8.2015 22:11, Paul E. McKenney wrote:
> > > > > On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> > > > >> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> > > > >>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> > > > >>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> > > > >>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > > >>>>>
> > > > >>>>>> The patch introduces page->compound_head into third double word block in
> > > > >>>>>> front of compound_dtor and compound_order. That means it shares storage
> > > > >>>>>> space with:
> > > > >>>>>>
> > > > >>>>>>  - page->lru.next;
> > > > >>>>>>  - page->next;
> > > > >>>>>>  - page->rcu_head.next;
> > > > >>>>>>  - page->pmd_huge_pte;
> > > > >>>>>>
> > > > >>>
> > > > >>> We should probably ask Paul about the chances that rcu_head.next would like
> > > > >>> to use the bit too one day?
> > > > >>
> > > > >> +Paul.
> > > > > 
> > > > > The call_rcu() function does stomp that bit, but if you stop using that
> > > > > bit before you invoke call_rcu(), no problem.
> > > > 
> > > > You mean that it sets the bit 0 of rcu_head.next during its processing?
> > > 
> > > Not at the moment, though RCU will splat if given a misaligned rcu_head
> > > structure because of the possibility to use that bit to flag callbacks
> > > that do nothing but free memory.  If RCU needs to do that (e.g., to
> > > promote energy efficiency), then that bit might well be set during
> > > RCU grace-period processing.
> > 
> > But if you do one day implement that, wouldn't sl?b.c have to use
> > call_rcu_with_added_meaning() instead of call_rcu(), to be in danger
> > of getting that bit set?  (No rcu_head is placed in a PageTail page.)
> 
> Good point, call_rcu_lazy(), but yes.
> 
> > So although it might be a little strange not to use a variant intended
> > for freeing memory when indeed that's what it's doing, it would not be
> > the end of the world for SLAB_DESTROY_BY_RCU to carry on using straight
> > call_rcu(), in defence of the struct page safety Kirill is proposing.
> 
> As long as you are OK with the bottom bit being zero throughout the RCU
> processing, yes.

That's exactly what we want: sounds like we have no problem, thanks Paul.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
