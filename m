Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4654A6B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:04:17 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so18144489wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:04:16 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id nb13si10314545wic.58.2015.08.26.08.04.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 08:04:15 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so18188409wid.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:04:15 -0700 (PDT)
Date: Wed, 26 Aug 2015 18:04:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150826150412.GA16412@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825211954.GN11078@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Tue, Aug 25, 2015 at 02:19:54PM -0700, Paul E. McKenney wrote:
> On Tue, Aug 25, 2015 at 10:46:44PM +0200, Vlastimil Babka wrote:
> > On 25.8.2015 22:11, Paul E. McKenney wrote:
> > > On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> > >> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> > >>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> > >>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> > >>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > >>>>>
> > >>>>>> The patch introduces page->compound_head into third double word block in
> > >>>>>> front of compound_dtor and compound_order. That means it shares storage
> > >>>>>> space with:
> > >>>>>>
> > >>>>>>  - page->lru.next;
> > >>>>>>  - page->next;
> > >>>>>>  - page->rcu_head.next;
> > >>>>>>  - page->pmd_huge_pte;
> > >>>>>>
> > >>>
> > >>> We should probably ask Paul about the chances that rcu_head.next would like
> > >>> to use the bit too one day?
> > >>
> > >> +Paul.
> > > 
> > > The call_rcu() function does stomp that bit, but if you stop using that
> > > bit before you invoke call_rcu(), no problem.
> > 
> > You mean that it sets the bit 0 of rcu_head.next during its processing?
> 
> Not at the moment, though RCU will splat if given a misaligned rcu_head
> structure because of the possibility to use that bit to flag callbacks
> that do nothing but free memory.  If RCU needs to do that (e.g., to
> promote energy efficiency), then that bit might well be set during
> RCU grace-period processing.

Ugh.. :-/

> >                                                                         That's
> > bad news then. It's not that we would trigger that bit when the rcu_head part of
> > the union is "active". It's that pfn scanners could inspect such page at
> > arbitrary time, see the bit 0 set (due to RCU processing) and think that it's a
> > tail page of a compound page, and interpret the rest of the pointer as a pointer
> > to the head page (to test it for flags etc).
> 
> On the other hand, if you avoid scanning rcu_head structures for pages
> that are currently waiting for a grace period, no problem.  RCU does
> not use the rcu_head structure at all except for during the time between
> when call_rcu() is invoked on that rcu_head structure and the time that
> the callback is invoked.
> 
> Is there some other page state that indicates that the page is waiting
> for a grace period?  If so, you could simply avoid testing that bit in
> that case.

No, I don't think so.

For compound pages most of info of its state is stored in head page (e.g.
page_count(), flags, etc). So if we examine random page (pfn scanner case)
the very first thing we want to know if we stepped on tail page.
PageTail() is what I wanted to encode in the bit...

What if we change order of fields within rcu_head and put ->func first?
Can we expect this pointer to have bit 0 always clear?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
