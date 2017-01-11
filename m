Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7826B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:35:33 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id dh1so82293579wjb.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 23:35:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si15223156wmc.3.2017.01.10.23.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 23:35:31 -0800 (PST)
Subject: Re: [patch v2] mm, thp: add new defer+madvise defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
 <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2099d74d-fa2c-e67e-b528-66598d072329@suse.cz>
Date: Wed, 11 Jan 2017 08:35:27 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>

[+CC linux-api]

On 01/11/2017 01:15 AM, David Rientjes wrote:
> There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
> to do direct compaction and reclaim while all other thp allocations simply 
> trigger kswapd and kcompactd in the background and fail immediately.
> 
> The "defer" setting simply triggers background reclaim and compaction for 
> all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
> userspace where MADV_HUGEPAGE is being used to indicate the application is 
> willing to wait for work for thp memory to be available.
> 
> The "madvise" setting will do direct compaction and reclaim for these
> MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
> background for anybody else.
> 
> For reasonable usage, there needs to be a mesh between the two options.  
> This patch introduces a fifth mode, "defer+madvise", that will do direct 
> reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
> reclaim and compaction for everybody else so that hugepages may be 
> available in the near future.
> 
> A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
> regions as part of the "defer" mode, making it a very powerful setting and 
> avoids breaking userspace, was offered: 
> http://marc.info/?t=148236612700003.  This additional mode is a 
> compromise.
> 
> A second proposal to allow both "defer" and "madvise" to be selected at
> the same time was also offered: http://marc.info/?t=148357345300001.
> This is possible, but there was a concern that it might break existing
> userspaces the parse the output of the defrag mode, so the fifth option
> was introduced instead.
> 
> This patch also cleans up the helper function for storing to "enabled" 
> and "defrag" since the former supports three modes while the latter 
> supports five and triple_flag_store() was getting unnecessarily messy.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

alloc_hugepage_direct_gfpmask() would have been IMHO simpler if a new
internal flag wasn't added, and combination of two existing for defer
and madvise used, but whatever, I won't nak the patch over that.

> ---
>  v2: uses new naming suggested by Vlastimil
>      (defer+madvise order looks better in
>       "... defer defer+madvise madvise ...")

OK.

>  v1 was acked by Mel, and it probably could have been preserved but it was
>  removed in case there is an issue with the name change.
> 
>  Documentation/vm/transhuge.txt |   8 ++-
>  include/linux/huge_mm.h        |   1 +
>  mm/huge_memory.c               | 146 +++++++++++++++++++++--------------------
>  3 files changed, 82 insertions(+), 73 deletions(-)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -110,6 +110,7 @@ MADV_HUGEPAGE region.
>  
>  echo always >/sys/kernel/mm/transparent_hugepage/defrag
>  echo defer >/sys/kernel/mm/transparent_hugepage/defrag
> +echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
>  echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
>  echo never >/sys/kernel/mm/transparent_hugepage/defrag
>  
> @@ -120,10 +121,15 @@ that benefit heavily from THP use and are willing to delay the VM start
>  to utilise them.
>  
>  "defer" means that an application will wake kswapd in the background
> -to reclaim pages and wake kcompact to compact memory so that THP is
> +to reclaim pages and wake kcompactd to compact memory so that THP is
>  available in the near future. It's the responsibility of khugepaged
>  to then install the THP pages later.
>  
> +"defer+madvise" will enter direct reclaim and compaction like "always", but
> +only for regions that have used madvise(MADV_HUGEPAGE); all other regions
> +will wake kswapd in the background to reclaim pages and wake kcompactd to
> +compact memory so that THP is available in the near future.
> +
>  "madvise" will enter direct reclaim like "always" but only for regions
>  that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
>  
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -33,6 +33,7 @@ enum transparent_hugepage_flag {
>  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> +	TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
>  	TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -142,42 +142,6 @@ static struct shrinker huge_zero_page_shrinker = {
>  };
>  
>  #ifdef CONFIG_SYSFS
> -
> -static ssize_t triple_flag_store(struct kobject *kobj,
> -				 struct kobj_attribute *attr,
> -				 const char *buf, size_t count,
> -				 enum transparent_hugepage_flag enabled,
> -				 enum transparent_hugepage_flag deferred,
> -				 enum transparent_hugepage_flag req_madv)
> -{
> -	if (!memcmp("defer", buf,
> -		    min(sizeof("defer")-1, count))) {
> -		if (enabled == deferred)
> -			return -EINVAL;
> -		clear_bit(enabled, &transparent_hugepage_flags);
> -		clear_bit(req_madv, &transparent_hugepage_flags);
> -		set_bit(deferred, &transparent_hugepage_flags);
> -	} else if (!memcmp("always", buf,
> -		    min(sizeof("always")-1, count))) {
> -		clear_bit(deferred, &transparent_hugepage_flags);
> -		clear_bit(req_madv, &transparent_hugepage_flags);
> -		set_bit(enabled, &transparent_hugepage_flags);
> -	} else if (!memcmp("madvise", buf,
> -			   min(sizeof("madvise")-1, count))) {
> -		clear_bit(enabled, &transparent_hugepage_flags);
> -		clear_bit(deferred, &transparent_hugepage_flags);
> -		set_bit(req_madv, &transparent_hugepage_flags);
> -	} else if (!memcmp("never", buf,
> -			   min(sizeof("never")-1, count))) {
> -		clear_bit(enabled, &transparent_hugepage_flags);
> -		clear_bit(req_madv, &transparent_hugepage_flags);
> -		clear_bit(deferred, &transparent_hugepage_flags);
> -	} else
> -		return -EINVAL;
> -
> -	return count;
> -}
> -
>  static ssize_t enabled_show(struct kobject *kobj,
>  			    struct kobj_attribute *attr, char *buf)
>  {
> @@ -193,19 +157,28 @@ static ssize_t enabled_store(struct kobject *kobj,
>  			     struct kobj_attribute *attr,
>  			     const char *buf, size_t count)
>  {
> -	ssize_t ret;
> +	ssize_t ret = count;
>  
> -	ret = triple_flag_store(kobj, attr, buf, count,
> -				TRANSPARENT_HUGEPAGE_FLAG,
> -				TRANSPARENT_HUGEPAGE_FLAG,
> -				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> +	if (!memcmp("always", buf,
> +		    min(sizeof("always")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("madvise", buf,
> +			   min(sizeof("madvise")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("never", buf,
> +			   min(sizeof("never")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +	} else
> +		ret = -EINVAL;
>  
>  	if (ret > 0) {
>  		int err = start_stop_khugepaged();
>  		if (err)
>  			ret = err;
>  	}
> -
>  	return ret;
>  }
>  static struct kobj_attribute enabled_attr =
> @@ -241,32 +214,58 @@ ssize_t single_hugepage_flag_store(struct kobject *kobj,
>  	return count;
>  }
>  
> -/*
> - * Currently defrag only disables __GFP_NOWAIT for allocation. A blind
> - * __GFP_REPEAT is too aggressive, it's never worth swapping tons of
> - * memory just to allocate one more hugepage.
> - */
>  static ssize_t defrag_show(struct kobject *kobj,
>  			   struct kobj_attribute *attr, char *buf)
>  {
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		return sprintf(buf, "[always] defer madvise never\n");
> +		return sprintf(buf, "[always] defer defer+madvise madvise never\n");
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return sprintf(buf, "always [defer] madvise never\n");
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> -		return sprintf(buf, "always defer [madvise] never\n");
> -	else
> -		return sprintf(buf, "always defer madvise [never]\n");
> -
> +		return sprintf(buf, "always [defer] defer+madvise madvise never\n");
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "always defer [defer+madvise] madvise never\n");
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "always defer defer+madvise [madvise] never\n");
> +	return sprintf(buf, "always defer defer+madvise madvise [never]\n");
>  }
> +
>  static ssize_t defrag_store(struct kobject *kobj,
>  			    struct kobj_attribute *attr,
>  			    const char *buf, size_t count)
>  {
> -	return triple_flag_store(kobj, attr, buf, count,
> -				 TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> -				 TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> -				 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
> +	if (!memcmp("always", buf,
> +		    min(sizeof("always")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("defer", buf,
> +		    min(sizeof("defer")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("defer+madvise", buf,
> +		    min(sizeof("defer+madvise")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("madvise", buf,
> +			   min(sizeof("madvise")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("never", buf,
> +			   min(sizeof("never")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +	} else
> +		return -EINVAL;
> +
> +	return count;
>  }
>  static struct kobj_attribute defrag_attr =
>  	__ATTR(defrag, 0644, defrag_show, defrag_store);
> @@ -612,25 +611,28 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>  }
>  
>  /*
> - * If THP defrag is set to always then directly reclaim/compact as necessary
> - * If set to defer then do only background reclaim/compact and defer to khugepaged
> - * If set to madvise and the VMA is flagged then directly reclaim/compact
> - * When direct reclaim/compact is allowed, don't retry except for flagged VMA's
> + * always: directly stall for all thp allocations
> + * defer: wake kswapd and fail if not immediately available
> + * defer+madvise: wake kswapd and directly stall for MADV_HUGEPAGE, otherwise
> + *		  fail if not immediately available
> + * madvise: directly stall for MADV_HUGEPAGE, otherwise fail if not immediately
> + *	    available
> + * never: never stall for any thp allocation
>   */
>  static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
>  {
> -	bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
>  
> -	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
> -				&transparent_hugepage_flags) && vma_madvised)
> -		return GFP_TRANSHUGE;
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> -						&transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> -						&transparent_hugepage_flags))
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
>  		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> -
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
> +		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +							     __GFP_KSWAPD_RECLAIM);
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +							     0);
>  	return GFP_TRANSHUGE_LIGHT;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
