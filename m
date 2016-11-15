Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76C256B026F
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 03:53:13 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id b66so476602ywh.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 00:53:13 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0045.outbound.protection.outlook.com. [104.47.2.45])
        by mx.google.com with ESMTPS id q11si480753oib.155.2016.11.15.00.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 00:53:12 -0800 (PST)
Date: Tue, 15 Nov 2016 16:52:44 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 4/6] mm: mempolicy: intruduce a helper huge_nodemask()
Message-ID: <20161115085242.GA9119@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
 <87oa1hb7tp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <87oa1hb7tp.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, Nov 15, 2016 at 11:31:06AM +0530, Aneesh Kumar K.V wrote:
> Huang Shijie <shijie.huang@arm.com> writes:
> >  #ifdef CONFIG_HUGETLBFS
> >  /*
> > + * huge_nodemask(@vma, @addr)
> > + * @vma: virtual memory area whose policy is sought
> > + * @addr: address in @vma for shared policy lookup and interleave policy
> > + *
> > + * If the effective policy is BIND, returns a pointer to the mempolicy's
> > + * @nodemask.
> > + */
> > +nodemask_t *huge_nodemask(struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	nodemask_t *nodes_mask = NULL;
> > +	struct mempolicy *mpol = get_vma_policy(vma, addr);
> > +
> > +	if (mpol->mode == MPOL_BIND)
> > +		nodes_mask = &mpol->v.nodes;
> > +	mpol_cond_put(mpol);
> 
> What if it is MPOL_PREFERED or MPOL_INTERLEAVE ? we don't honor node
> mask in that case ?
> 
I suddenly find maybe I should follow init_nodemask_of_mempolicy(), not the
huge_zonelist(). Is it okay?

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
