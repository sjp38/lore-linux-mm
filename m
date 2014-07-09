Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 13B876B0037
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 09:31:47 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so6673509qgf.0
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 06:31:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m3si59731254qaz.59.2014.07.09.06.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 06:31:45 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:31:37 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [patch] mm, hugetlb: generalize writes to nr_hugepages
Message-ID: <20140709093137.5a6ab051@redhat.com>
In-Reply-To: <20140708151113.dd1469faea6177959356620b@linux-foundation.org>
References: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
	<20140702172529.347f2dd2@redhat.com>
	<alpine.DEB.2.02.1407021743340.4970@chino.kir.corp.google.com>
	<20140708151113.dd1469faea6177959356620b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 8 Jul 2014 15:11:13 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 2 Jul 2014 17:44:46 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > > > @@ -2248,36 +2257,18 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
> > > >  			 void __user *buffer, size_t *length, loff_t *ppos)
> > > >  {
> > > >  	struct hstate *h = &default_hstate;
> > > > -	unsigned long tmp;
> > > > +	unsigned long tmp = h->max_huge_pages;
> > > >  	int ret;
> > > >  
> > > > -	if (!hugepages_supported())
> > > > -		return -ENOTSUPP;
> > > 
> > > Shouldn't you add this check to __nr_hugepages_store_common()? Otherwise
> > > looks good to me.
> > > 
> > 
> > Hmm, I think you're right but I don't think __nr_hugepages_store_common() 
> > is the right place: if we have a legitimate hstate for the sysfs tunables 
> > then we should support hugepages.  I think this should be kept in 
> > hugetlb_sysctl_handler_common().
> 
> This?

Yes.

> 
> --- a/mm/hugetlb.c~mm-hugetlb-generalize-writes-to-nr_hugepages-fix
> +++ a/mm/hugetlb.c
> @@ -2260,6 +2260,9 @@ static int hugetlb_sysctl_handler_common
>  	unsigned long tmp = h->max_huge_pages;
>  	int ret;
>  
> +	if (!hugepages_supported())
> +		return -ENOTSUPP;
> +
>  	table->data = &tmp;
>  	table->maxlen = sizeof(unsigned long);
>  	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
