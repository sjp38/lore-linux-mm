Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0328C6B0038
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 12:38:59 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so129687619qge.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 09:38:58 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id t83si1373583qki.51.2015.08.26.09.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Aug 2015 09:38:58 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 26 Aug 2015 10:38:57 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 44B923E4003B
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:38:54 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7QGbqwQ55443616
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 09:37:52 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7QGcq6w026320
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:38:52 -0600
Date: Wed, 26 Aug 2015 09:38:51 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150826163851.GF11078@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <20150826150412.GA16412@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150826150412.GA16412@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, Aug 26, 2015 at 06:04:12PM +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 25, 2015 at 02:19:54PM -0700, Paul E. McKenney wrote:
> > On Tue, Aug 25, 2015 at 10:46:44PM +0200, Vlastimil Babka wrote:
> > > On 25.8.2015 22:11, Paul E. McKenney wrote:
> > > > On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> > > >> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> > > >>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> > > >>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> > > >>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > >>>>>
> > > >>>>>> The patch introduces page->compound_head into third double word block in
> > > >>>>>> front of compound_dtor and compound_order. That means it shares storage
> > > >>>>>> space with:
> > > >>>>>>
> > > >>>>>>  - page->lru.next;
> > > >>>>>>  - page->next;
> > > >>>>>>  - page->rcu_head.next;
> > > >>>>>>  - page->pmd_huge_pte;
> > > >>>>>>
> > > >>>
> > > >>> We should probably ask Paul about the chances that rcu_head.next would like
> > > >>> to use the bit too one day?
> > > >>
> > > >> +Paul.
> > > > 
> > > > The call_rcu() function does stomp that bit, but if you stop using that
> > > > bit before you invoke call_rcu(), no problem.
> > > 
> > > You mean that it sets the bit 0 of rcu_head.next during its processing?
> > 
> > Not at the moment, though RCU will splat if given a misaligned rcu_head
> > structure because of the possibility to use that bit to flag callbacks
> > that do nothing but free memory.  If RCU needs to do that (e.g., to
> > promote energy efficiency), then that bit might well be set during
> > RCU grace-period processing.
> 
> Ugh.. :-/
> 
> > > bad news then. It's not that we would trigger that bit when the rcu_head part of
> > > the union is "active". It's that pfn scanners could inspect such page at
> > > arbitrary time, see the bit 0 set (due to RCU processing) and think that it's a
> > > tail page of a compound page, and interpret the rest of the pointer as a pointer
> > > to the head page (to test it for flags etc).
> > 
> > On the other hand, if you avoid scanning rcu_head structures for pages
> > that are currently waiting for a grace period, no problem.  RCU does
> > not use the rcu_head structure at all except for during the time between
> > when call_rcu() is invoked on that rcu_head structure and the time that
> > the callback is invoked.
> > 
> > Is there some other page state that indicates that the page is waiting
> > for a grace period?  If so, you could simply avoid testing that bit in
> > that case.
> 
> No, I don't think so.

OK, I'll bite...  How do you know that it is safe to invoke call_rcu(),
given that you are not allowed to invoke call_rcu() until the previous
callback has been invoked?

> For compound pages most of info of its state is stored in head page (e.g.
> page_count(), flags, etc). So if we examine random page (pfn scanner case)
> the very first thing we want to know if we stepped on tail page.
> PageTail() is what I wanted to encode in the bit...

Ah, so that would require the page scanner to do reverse mapping or some
such, then.  Which is perhaps what you are trying to avoid.

> What if we change order of fields within rcu_head and put ->func first?
> Can we expect this pointer to have bit 0 always clear?

I asked that question some time back, and the answer was "no".  You
can apparently have functions that start at odd addresses on some
architectures.

That said, there are likely to be reserved bits somewhere in the function
address, perhaps varying depending on architecture and/or boot, in the
case of address-space randomization.  Perhaps some way of identifying
those bits with architecture-independent ways of querying and setting
them?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
