Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8CB6B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 10:51:07 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so31716089pdi.7
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 07:51:07 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id tf7si12345189pab.202.2015.01.18.07.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 07:51:05 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 18 Jan 2015 21:21:02 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id A616BE0054
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 21:22:10 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0IFowan65601698
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 21:20:58 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0IFowU6031513
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 21:20:58 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <1421478959.4903.1.camel@stgolabs.net>
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org> <1421478959.4903.1.camel@stgolabs.net>
Date: Sun, 18 Jan 2015 21:20:58 +0530
Message-ID: <87y4p02il9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Davidlohr Bueso <dave@stgolabs.net> writes:

> On Fri, 2015-01-16 at 16:02 -0800, Andrew Morton wrote:
>> On Fri, 16 Jan 2015 12:56:36 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> 
>> > This make sure that we try to allocate hugepages from local node if
>> > allowed by mempolicy. If we can't, we fallback to small page allocation
>> > based on mempolicy. This is based on the observation that allocating pages
>> > on local node is more beneficial than allocating hugepages on remote node.
>> 
>> The changelog is a bit incomplete.  It doesn't describe the current
>> behaviour, nor what is wrong with it.  What are the before-and-after
>> effects of this change?
>> 
>> And what might be the user-visible effects?
>
> I'd be interested in any performance data. I'll run this by a 4 node box
> next week.


Thanks.

>
>> 
>> > --- a/mm/mempolicy.c
>> > +++ b/mm/mempolicy.c
>> > @@ -2030,6 +2030,46 @@ retry_cpuset:
>> >  	return page;
>> >  }
>> >  
>> > +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> > +				unsigned long addr, int order)
>> 
>> alloc_pages_vma() is nicely documented.  alloc_hugepage_vma() is not
>> documented at all.  This makes it a bit had for readers to work out the
>> difference!
>> 
>> Is it possible to scrunch them both into the same function?  Probably
>> too messy?
>> 
>> > +{
>> > +	struct page *page;
>> > +	nodemask_t *nmask;
>> > +	struct mempolicy *pol;
>> > +	int node = numa_node_id();
>> > +	unsigned int cpuset_mems_cookie;
>> > +
>> > +retry_cpuset:
>> > +	pol = get_vma_policy(vma, addr);
>> > +	cpuset_mems_cookie = read_mems_allowed_begin();
>> > +
>> > +	if (pol->mode != MPOL_INTERLEAVE) {
>> > +		/*
>> > +		 * For interleave policy, we don't worry about
>> > +		 * current node. Otherwise if current node is
>> > +		 * in nodemask, try to allocate hugepage from
>> > +		 * current node. Don't fall back to other nodes
>> > +		 * for THP.
>> > +		 */
>> 
>> This code isn't "interleave policy".  It's everything *but* interleave
>> policy.  Comment makes no sense!
>
> May I add that, while a nit, this indentation is quite ugly:

I updated that and replied here
http://article.gmane.org/gmane.linux.kernel/1868545. Let me know what you think.
>
>> 
>> > +		nmask = policy_nodemask(gfp, pol);
>> > +		if (!nmask || node_isset(node, *nmask)) {
>> > +			mpol_cond_put(pol);
>> > +			page = alloc_pages_exact_node(node, gfp, order);
>> > +			if (unlikely(!page &&
>> > +				     read_mems_allowed_retry(cpuset_mems_cookie)))
>> > +				goto retry_cpuset;
>> > +			return page;
>> > +		}
>> > +	}
>
> Improving it makes the code visually easier on the eye. So this should
> be considered if another re-spin of the patch is to be done anyway. Just
> jump to the mpol refcounting and be done when 'pol->mode ==
> MPOL_INTERLEAVE'.
>


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
