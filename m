Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 45C076B0255
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:20:01 -0400 (EDT)
Received: by oieu205 with SMTP id u205so39064266oie.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:20:01 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id q81si15842155oig.33.2015.08.25.14.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Aug 2015 14:20:00 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 25 Aug 2015 15:19:59 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9973019D8053
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 15:10:52 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7PLJu2f26411256
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:19:56 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7PLJtjj010436
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 15:19:56 -0600
Date: Tue, 25 Aug 2015 14:19:54 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150825211954.GN11078@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55DCD434.9000704@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Tue, Aug 25, 2015 at 10:46:44PM +0200, Vlastimil Babka wrote:
> On 25.8.2015 22:11, Paul E. McKenney wrote:
> > On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> >> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> >>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> >>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> >>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> >>>>>
> >>>>>> The patch introduces page->compound_head into third double word block in
> >>>>>> front of compound_dtor and compound_order. That means it shares storage
> >>>>>> space with:
> >>>>>>
> >>>>>>  - page->lru.next;
> >>>>>>  - page->next;
> >>>>>>  - page->rcu_head.next;
> >>>>>>  - page->pmd_huge_pte;
> >>>>>>
> >>>
> >>> We should probably ask Paul about the chances that rcu_head.next would like
> >>> to use the bit too one day?
> >>
> >> +Paul.
> > 
> > The call_rcu() function does stomp that bit, but if you stop using that
> > bit before you invoke call_rcu(), no problem.
> 
> You mean that it sets the bit 0 of rcu_head.next during its processing?

Not at the moment, though RCU will splat if given a misaligned rcu_head
structure because of the possibility to use that bit to flag callbacks
that do nothing but free memory.  If RCU needs to do that (e.g., to
promote energy efficiency), then that bit might well be set during
RCU grace-period processing.

>                                                                         That's
> bad news then. It's not that we would trigger that bit when the rcu_head part of
> the union is "active". It's that pfn scanners could inspect such page at
> arbitrary time, see the bit 0 set (due to RCU processing) and think that it's a
> tail page of a compound page, and interpret the rest of the pointer as a pointer
> to the head page (to test it for flags etc).

On the other hand, if you avoid scanning rcu_head structures for pages
that are currently waiting for a grace period, no problem.  RCU does
not use the rcu_head structure at all except for during the time between
when call_rcu() is invoked on that rcu_head structure and the time that
the callback is invoked.

Is there some other page state that indicates that the page is waiting
for a grace period?  If so, you could simply avoid testing that bit in
that case.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
