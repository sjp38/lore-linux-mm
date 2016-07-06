Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6430D828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:23:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so103661756wme.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:23:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z63si4529545wme.121.2016.07.05.23.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:23:58 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u666IuL5133669
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 02:23:57 -0400
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com [195.75.94.113])
	by mx0b-001b2d01.pphosted.com with ESMTP id 240nbyk0jq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Jul 2016 02:23:56 -0400
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 Jul 2016 07:23:55 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 010412190056
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 07:23:22 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u666Nqet4784516
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 06:23:52 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u665NsXw024593
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 23:23:54 -0600
Date: Wed, 6 Jul 2016 08:23:50 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page
 table entries
In-Reply-To: <014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>
	<014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160706082350.5c56ca40@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 06 Jul 2016 12:03:28 +0800
"Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> > 
> > +void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
> > +			   unsigned long end, pte_t *ptep)
> > +{
> > +	unsigned long nr;
> > +
> > +	if (!MACHINE_HAS_IPTE_RANGE || mm_has_pgste(mm))
> > +		return;
> > +	preempt_disable();
> > +	nr = (end - start) >> PAGE_SHIFT;
> > +	/* If the flush is likely to be local skip the ipte range */
> > +	if (nr && !cpumask_equal(mm_cpumask(mm),
> > +				 cpumask_of(smp_processor_id())))
> 
> s/smp/raw_smp/ to avoid adding schedule entry with page table
> lock held?

There can not be a schedule entry with either the page table lock held
or the preempt_disable() a few lines above.
 
> > +		__ptep_ipte_range(start, nr - 1, ptep);
> > +	preempt_enable();
> > +}
> > +EXPORT_SYMBOL(ptep_invalidate_range);
> > +
> 
> thanks
> Hillf
> 


-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
