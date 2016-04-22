Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4AE6B025E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 14:38:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so165309286pad.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 11:38:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x127si8112571pfb.139.2016.04.22.11.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 11:38:32 -0700 (PDT)
Date: Fri, 22 Apr 2016 11:38:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix incorrect pfn passed to untrack_pfn in
 remap_pfn_range
Message-Id: <20160422113831.6294e65dbc4fe7a2d3421539@linux-foundation.org>
In-Reply-To: <1461321088-3247-1-git-send-email-xyjxie@linux.vnet.ibm.com>
References: <1461321088-3247-1-git-send-email-xyjxie@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongji Xie <xyjxie@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mingo@kernel.org, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, matthew.r.wilcox@intel.com, aarcange@redhat.com, mhocko@suse.com, luto@kernel.org, dahi@linux.vnet.ibm.com

On Fri, 22 Apr 2016 18:31:28 +0800 Yongji Xie <xyjxie@linux.vnet.ibm.com> wrote:

> We used generic hooks in remap_pfn_range to help archs to
> track pfnmap regions. The code is something like:
> 
> int remap_pfn_range()
> {
> 	...
> 	track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
> 	...
> 	pfn -= addr >> PAGE_SHIFT;
> 	...
> 	untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> 	...
> }
> 
> Here we can easily find the pfn is changed but not recovered
> before untrack_pfn() is called. That's incorrect.

What are the runtime effects of this bug?

> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1755,6 +1755,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  			break;
>  	} while (pgd++, addr = next, addr != end);
>  
> +	pfn += (end - PAGE_ALIGN(size)) >> PAGE_SHIFT;
>  	if (err)
>  		untrack_pfn(vma, pfn, PAGE_ALIGN(size));

I'm having trouble understanding this.  Wouldn't it be better to simply
save the track_pfn_remap() call's `pfn' arg in a new local variable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
