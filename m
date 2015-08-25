Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6666B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:11:19 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so167555466ykd.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:11:19 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id e52si35131483qge.94.2015.08.25.13.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Aug 2015 13:11:18 -0700 (PDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 25 Aug 2015 14:11:16 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D5C923E4004C
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:11:14 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7PK8NJK44826776
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:08:24 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7PKBDAu023099
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:11:14 -0600
Date: Tue, 25 Aug 2015 13:11:13 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150825201113.GK11078@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825183354.GC4881@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
> > On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> > >On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> > >>On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > >>
> > >>>The patch introduces page->compound_head into third double word block in
> > >>>front of compound_dtor and compound_order. That means it shares storage
> > >>>space with:
> > >>>
> > >>>  - page->lru.next;
> > >>>  - page->next;
> > >>>  - page->rcu_head.next;
> > >>>  - page->pmd_huge_pte;
> > >>>
> > 
> > We should probably ask Paul about the chances that rcu_head.next would like
> > to use the bit too one day?
> 
> +Paul.

The call_rcu() function does stomp that bit, but if you stop using that
bit before you invoke call_rcu(), no problem.

								Thanx, Paul

> > For pgtable_t I can't think of anything better than a warning in the generic
> > definition in include/asm-generic/page.h and hope that anyone reimplementing
> > it for a new arch will look there first.
> 
> I will move it to other word, just in case.
> 
> > The lru part is probably the hardest to prevent danger. It can be used for
> > any private purposes. Hopefully everyone currently uses only standard list
> > operations here, and the list poison values don't set bit 0. But I see there
> > can be some arbitrary CONFIG_ILLEGAL_POINTER_VALUE added to the poisons, so
> > maybe that's worth some build error check? Anyway we would be imposing
> > restrictions on types that are not ours, so there might be some
> > resistance...
> 
> I will add BUILD_BUG_ON((unsigned long)LIST_POISON1 & 1); 
> 
> > >>Anyway, this is quite subtle and there's a risk that people will
> > >>accidentally break it later on.  I don't think the patch puts
> > >>sufficient documentation in place to prevent this.
> > >
> > >I would appreciate for suggestion on place and form of documentation.
> > >
> > >>And even documentation might not be enough to prevent accidents.
> > >
> > >The only think I can propose is VM_BUG_ON() in PageTail() and
> > >compound_head() which would ensure that page->compound_page points to
> > >place within MAX_ORDER_NR_PAGES before the current page if bit 0 is set.
> > 
> > That should probably catch some bad stuff, but probably only moments before
> > it would crash anyway if the pointer was bogus. But I also don't see better
> > way, because we can't proactively put checks in those who would "misbehave",
> > as we don't know who they are. Putting more debug checks in e.g. page
> > freeing might help, but probably not much.
> 
> So, do you think it worth it or not after all?
> > 
> > >Do you consider this helpful?
> > >
> > >>>
> > >>>...
> > >>>
> > >>>--- a/include/linux/mm_types.h
> > >>>+++ b/include/linux/mm_types.h
> > >>>@@ -120,7 +120,12 @@ struct page {
> > >>>  		};
> > >>>  	};
> > >>>
> > >>>-	/* Third double word block */
> > >>>+	/*
> > >>>+	 * Third double word block
> > >>>+	 *
> > >>>+	 * WARNING: bit 0 of the first word encode PageTail and *must* be 0
> > >>>+	 * for non-tail pages.
> > >>>+	 */
> > >>>  	union {
> > >>>  		struct list_head lru;	/* Pageout list, eg. active_list
> > >>>  					 * protected by zone->lru_lock !
> > >>>@@ -143,6 +148,7 @@ struct page {
> > >>>  						 */
> > >>>  		/* First tail page of compound page */
> > 
> > Note that compound_head is not just in the *first* tail page. Only the rest
> > is.
> 
> Right.
> 
> -- 
>  Kirill A. Shutemov
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
