Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3025E900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:02:27 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IEtV2L003817
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:55:31 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3IF2BBM123038
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:02:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3IF2Aof032092
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:02:10 -0600
Subject: Re: [RFC][PATCH 2/3] track numbers of pagetable pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110416104456.3915b7de@mfleming-mobl1.ger.corp.intel.com>
References: <20110415173821.62660715@kernel>
	 <20110415173823.EA7A7473@kernel>
	 <20110416104456.3915b7de@mfleming-mobl1.ger.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 08:02:04 -0700
Message-ID: <1303138924.9615.2487.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@console-pimps.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-04-16 at 10:44 +0100, Matt Fleming wrote:
> >  static inline void pgtable_page_dtor(struct mm_struct *mm, struct page *page)
> >  {
> >  	pte_lock_deinit(page);
> > +	dec_mm_counter(mm, MM_PTEPAGES);
> >  	dec_zone_page_state(page, NR_PAGETABLE);
> >  }
> 
> I'm probably missing something really obvious but...
> 
> Is this safe in the non-USE_SPLIT_PTLOCKS case? If we're not using
> split-ptlocks then inc/dec_mm_counter() are only safe when done under
> mm->page_table_lock, right? But it looks to me like we can end up doing,
> 
>   __pte_alloc()
>       pte_alloc_one()
>           pgtable_page_ctor()
> 
> before acquiring mm->page_table_lock in __pte_alloc().

No, it's probably not safe.  We'll have to come up with something a bit
different in that case.  Either that, or just kill the non-atomic case.
Surely there's some percpu magic counter somewhere in the kernel that is
optimized for fast (unlocked?) updates and rare, slow reads.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
