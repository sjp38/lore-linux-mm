Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABF16B02AA
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:38:50 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j28so3290856wrd.17
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 02:38:50 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id o62si796449wrc.99.2018.02.22.02.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 02:38:46 -0800 (PST)
Date: Thu, 22 Feb 2018 11:38:32 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: mmotm 2018-02-21-14-48 uploaded (mm/page_alloc.c on UML)
Message-ID: <20180222103832.GA11623@vmlxhi-102.adit-jv.com>
References: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
 <7bcc52db-57eb-45b0-7f20-c93a968599cd@infradead.org>
 <20180222072037.GC30681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180222072037.GC30681@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, richard -rw- weinberger <richard.weinberger@gmail.com>, Eugeniu Rosca <erosca@de.adit-jv.com>

Hi Michal,

Please, let me know if any action is expected from my end.
Thank you for your support and sorry for the ifdef troubles.

Best regards,
Eugeniu.

On Thu, Feb 22, 2018 at 08:20:37AM +0100, Michal Hocko wrote:
> On Wed 21-02-18 15:58:41, Randy Dunlap wrote:
> > On 02/21/2018 02:48 PM, akpm@linux-foundation.org wrote:
> > > The mm-of-the-moment snapshot 2018-02-21-14-48 has been uploaded to
> > > 
> > >    http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > mmotm-readme.txt says
> > > 
> > > README for mm-of-the-moment:
> > > 
> > > http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > > more than once a week.
> > > 
> > > You will need quilt to apply these patches to the latest Linus release (4.x
> > > or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > > http://ozlabs.org/~akpm/mmotm/series
> > > 
> > > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > > followed by the base kernel version against which this patch series is to
> > > be applied.
> > 
> > um (or uml) defconfig on i386 and/or x86_64:
> > 
> > ../mm/page_alloc.c: In function 'memmap_init_zone':
> > ../mm/page_alloc.c:5450:5: error: implicit declaration of function 'memblock_next_valid_pfn' [-Werror=implicit-function-declaration]
> >      pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> >      ^
> > 
> > 
> > probably (?):
> > From: Eugeniu Rosca <erosca@de.adit-jv.com>
> > Subject: mm: page_alloc: skip over regions of invalid pfns on UMA
> 
> Yes. Steven has already reported the same [1]. There are two possible
> ways around this. Either provide and empty stub or use ifdef around
> memblock_next_valid_pfn. I would use the later because it is less
> confusing. We really do not want memblock_next_valid_pfn to be used
> outside of memblock aware code.
> 
> [1] http://lkml.kernel.org/r/20180222143057.3a1b3746@canb.auug.org.au
> 
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4334d3a9c6a2..2836bc9e0999 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5446,8 +5446,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
>  			 * on our next iteration of the loop.
>  			 */
> -			if (IS_ENABLED(CONFIG_HAVE_MEMBLOCK))
> -				pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> +#ifdef CONFIG_HAVE_MEMBLOCK
> +			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> +#endif
>  			continue;
>  		}
>  		if (!early_pfn_in_nid(pfn, nid))
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
