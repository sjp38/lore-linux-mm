Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6F1829BA
	for <linux-mm@kvack.org>; Fri, 22 May 2015 11:49:44 -0400 (EDT)
Received: by oihb142 with SMTP id b142so16861606oih.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 08:49:43 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id l191si1575007oig.48.2015.05.22.08.49.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 08:49:43 -0700 (PDT)
Message-ID: <1432308615.1428.10.camel@misato.fc.hp.com>
Subject: Re: [PATCH v9 8/10] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 22 May 2015 09:30:15 -0600
In-Reply-To: <alpine.DEB.2.11.1505220944340.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
	 <1431551151-19124-9-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1505220944340.5457@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Fri, 2015-05-22 at 09:48 +0200, Thomas Gleixner wrote:
> On Wed, 13 May 2015, Toshi Kani wrote:
> > +int set_memory_wt(unsigned long addr, int numpages)
> > +{
> > +	int ret;
> > +
> > +	if (!pat_enabled)
> > +		return set_memory_uc(addr, numpages);
> > +
> > +	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
> > +			      _PAGE_CACHE_MODE_WT, NULL);
> > +	if (ret)
> > +		goto out_err;
> > +
> > +	ret = _set_memory_wt(addr, numpages);
> > +	if (ret)
> > +		goto out_free;
> > +
> > +	return 0;
> > +
> > +out_free:
> > +	free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
> > +out_err:
> > +	return ret;
> 
> 
> This goto zoo is horrible to read. What's wrong with a straight forward:
> 
> +	if (!pat_enabled)
> +		return set_memory_uc(addr, numpages);
> +
> +	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
> +			      _PAGE_CACHE_MODE_WT, NULL);
> +	if (ret)
> +		return ret;
> +
> +	ret = _set_memory_wt(addr, numpages);
> +	if (ret)
> +		free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
> +	return ret;

Agreed.  I will change set_memory_wc() as well, which is the base of
this function. 

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
