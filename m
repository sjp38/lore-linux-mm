Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4TCZZG1018331
	for <linux-mm@kvack.org>; Thu, 29 May 2008 08:35:35 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4TCZYVR040364
	for <linux-mm@kvack.org>; Thu, 29 May 2008 06:35:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4TCZYI4026413
	for <linux-mm@kvack.org>; Thu, 29 May 2008 06:35:34 -0600
Subject: Re: [patch] hugetlb: fix lockdep error
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080528201929.cf766924.akpm@linux-foundation.org>
References: <20080529015956.GC3258@wotan.suse.de>
	 <20080528191657.ba5f283c.akpm@linux-foundation.org>
	 <20080529022919.GD3258@wotan.suse.de>
	 <20080528193808.6e053dac.akpm@linux-foundation.org>
	 <20080529030745.GG3258@wotan.suse.de>
	 <20080528201929.cf766924.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 29 May 2008 07:35:37 -0500
Message-Id: <1212064537.12036.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-28 at 20:19 -0700, Andrew Morton wrote:
> On Thu, 29 May 2008 05:07:45 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > >  mm/hugetlb.c |    2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > Index: linux-2.6/mm/hugetlb.c
> > > > ===================================================================
> > > > --- linux-2.6.orig/mm/hugetlb.c
> > > > +++ linux-2.6/mm/hugetlb.c
> > > > @@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
> > > >  			continue;
> > > >  
> > > >  		spin_lock(&dst->page_table_lock);
> > > > -		spin_lock(&src->page_table_lock);
> > > > +		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
> > > >  		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> > > >  			if (cow)
> > > >  				huge_ptep_set_wrprotect(src, addr, src_pte);
> > > 
> > > Confused.  This code has been there since October 2005.  Why are we
> > > only seeing lockdep warnings now?
> > 
> > Can't say. Haven't looked at hugetlb code or tested it much until now.
> > I am using a recent libhugetlbfs test suite, FWIW.
> 
> I don't believe that it's possible that nobody has run that test suite
> with lockdep enabled at any time in the past three years.

I have to confess that I have seen this from time to time.  Since it was
clearly a false positive, it was easy to get distracted by other things.
I'll go and update all my default kernel configs to turn on everything
all the time so things like this annoy me until I fix them.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
