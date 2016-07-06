Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18EB6828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:42:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so491797087pfa.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:42:33 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id u80si2631836pfi.227.2016.07.05.23.42.30
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 23:42:32 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>	<014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com> <20160706082350.5c56ca40@mschwide>
In-Reply-To: <20160706082350.5c56ca40@mschwide>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page table entries
Date: Wed, 06 Jul 2016 14:42:16 +0800
Message-ID: <015301d1d751$8973de50$9c5b9af0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Martin Schwidefsky' <schwidefsky@de.ibm.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > >
> > > +void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
> > > +			   unsigned long end, pte_t *ptep)
> > > +{
> > > +	unsigned long nr;
> > > +
> > > +	if (!MACHINE_HAS_IPTE_RANGE || mm_has_pgste(mm))
> > > +		return;
> > > +	preempt_disable();
> > > +	nr = (end - start) >> PAGE_SHIFT;
> > > +	/* If the flush is likely to be local skip the ipte range */
> > > +	if (nr && !cpumask_equal(mm_cpumask(mm),
> > > +				 cpumask_of(smp_processor_id())))
> >
> > s/smp/raw_smp/ to avoid adding schedule entry with page table
> > lock held?
> 
> There can not be a schedule entry with either the page table lock held
> or the preempt_disable() a few lines above.
> 
Yes, Sir.

> > > +		__ptep_ipte_range(start, nr - 1, ptep);
> > > +	preempt_enable();

Then would you please, Sir, take a look at another case where
preempt is enabled?

> > > +}
> > > +EXPORT_SYMBOL(ptep_invalidate_range);
> > > +
> >

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
