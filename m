Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7633E828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 04:48:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so106126244wme.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 01:48:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id uv1si2141322wjb.295.2016.07.06.01.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 01:48:00 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u668i69C032359
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 04:47:59 -0400
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com [195.75.94.113])
	by mx0b-001b2d01.pphosted.com with ESMTP id 240k6wjs7m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Jul 2016 04:47:58 -0400
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 Jul 2016 09:47:57 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3E55317D8066
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 09:49:18 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u668lsm06947244
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 08:47:54 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u668lsgw019648
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 04:47:54 -0400
Date: Wed, 6 Jul 2016 10:47:53 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page
 table entries
In-Reply-To: <015301d1d751$8973de50$9c5b9af0$@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>
	<014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>
	<20160706082350.5c56ca40@mschwide>
	<015301d1d751$8973de50$9c5b9af0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160706104753.74daeaa2@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 06 Jul 2016 14:42:16 +0800
"Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> > > >
> > > > +void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
> > > > +			   unsigned long end, pte_t *ptep)
> > > > +{
> > > > +	unsigned long nr;
> > > > +
> > > > +	if (!MACHINE_HAS_IPTE_RANGE || mm_has_pgste(mm))
> > > > +		return;
> > > > +	preempt_disable();
> > > > +	nr = (end - start) >> PAGE_SHIFT;
> > > > +	/* If the flush is likely to be local skip the ipte range */
> > > > +	if (nr && !cpumask_equal(mm_cpumask(mm),
> > > > +				 cpumask_of(smp_processor_id())))
> > >
> > > s/smp/raw_smp/ to avoid adding schedule entry with page table
> > > lock held?
> > 
> > There can not be a schedule entry with either the page table lock held
> > or the preempt_disable() a few lines above.
> > 
> Yes, Sir.
> 
> > > > +		__ptep_ipte_range(start, nr - 1, ptep);
> > > > +	preempt_enable();
> 
> Then would you please, Sir, take a look at another case where
> preempt is enabled?

You are still a bit cryptic, are you trying to tell me that your hint is
about trying to avoid the preempt_enable() call? 

The reason why I added the preempt_disable()/preempt_enable() pair to
ptep_invalidate_range is that I recently got bitten by a preempt problem
in the ptep_xchg_lazy() function which is used for ptep_get_and_clear().
Now ptep_get_and_clear() is used in vunmap_pte_range() which is called
while preemption is allowed.

To keep things symmetrical it seems sensible to explicitely disable
preemption on all ptep_xxx code paths with cpu mask checks, no?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
