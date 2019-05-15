Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C6B5C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:41:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0585206BF
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:41:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0585206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B90A6B0007; Wed, 15 May 2019 03:41:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66BC66B0008; Wed, 15 May 2019 03:41:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 558DD6B000A; Wed, 15 May 2019 03:41:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04AFB6B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 03:41:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l3so2524901edl.10
        for <linux-mm@kvack.org>; Wed, 15 May 2019 00:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PpGnbLyCPRayCEAVb6qcecWM7aI0BFGBOUnm3WrZtig=;
        b=G9XZ0Z8Oo8ecxyb5CmZP73dR4rCuQtdHduUht+lqqYXyC1uci2bd230JCsOfYIQjDz
         tV6Vnlrh10HuhD564JlrWNAPlbKOfwsRW69VC1k8nEUVdFd1xYWBcgZQ/szdYISV+KBo
         yRsblavZnu4Do6hOnqZ7S7L9ZBsZ4GdcUH5ibQiCtweGM4yXDN3IoIDG0DbMvq4kocOW
         5/ITvoOQzpsy3CJqJKqOg8rYGE59lGikJlZz8nFReVptO/J8CEEj/KTIlOSQP0SRL5I3
         zgbB2Cza6v2oMH1hESdYW9pKY5X26K0dpMGOwfi0kFSUco2Pf1SjYR2O7f8y9KlxhEIE
         qjFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXzpbd0P1poDFiR2Krp5nEYKc5MAZ0vF85xUiR/SZY4jEl0P4J1
	ZmU/MaRRNxvwNhiwYAbWqUh7YJEf+XrIxdK5Nwob86MyKXkn+JJHcFEJjgWU5l7qr57AMtjT43q
	wk7rNaNGNl3dnzeaYUcgNUi9ywLlRzc1TiB96jVGgEGjIukxDkfvUb3fxtNX72Vs8rw==
X-Received: by 2002:a17:906:1e0f:: with SMTP id g15mr31794772ejj.241.1557906103552;
        Wed, 15 May 2019 00:41:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8/CJZAhvKmHkEe7dVtBGdnsCVx8uG4NZy9bsvjnh+QjQtQqK1DOBjrvet7hJFoRv3MoG8
X-Received: by 2002:a17:906:1e0f:: with SMTP id g15mr31794723ejj.241.1557906102777;
        Wed, 15 May 2019 00:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557906102; cv=none;
        d=google.com; s=arc-20160816;
        b=ex5rvb8cK+V1HRQ5h6aJzmTb0kPpLF6qu8O9OcrEOLhcvBARf34vti2ocwoNDuZW9w
         7I6eSr9wqHFyQWtk67yeaJ4v1lREyT8Ie+5WxLKWSBzYr9NQfoCiRWd5fZfehuqWa8ks
         ObjR6R4aVf+kTFfG1SunRE8Cbz4BDL8HJjvQMaVDo3cJx30uVLk6NcdYQ+6XiHoYY2tp
         vs+17Lp0qNpft4R7clTWNgG3CF3XJk4hJqwHQsLRMN6C7ygGsiPqTH637ujUxnrPbWp0
         EHpv9TsMIPGaPh1f/u8SEMs/xD+H+n/S691HfnOUFbeLfs+tgVVaGiXUAgwBMnBz644a
         6raQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PpGnbLyCPRayCEAVb6qcecWM7aI0BFGBOUnm3WrZtig=;
        b=df4K1wP2BaJTcCk6GLf8TD/pdu/F6wk7t/I9v8ZY0z0vWsFy0qWlAY9L9hBqV99icj
         TeaF6pkxNNY33NBNfdc6Kr2vFo0GIcS1SiqqmtNdN1nYLtRtoNw0npH6R4RvAJy+nmfw
         RosFvyBao5QcK7BAqkrD+y+fmVCkZJoARRqCm8mH8fWSToc7muvakZVevJq/hVO0QHSw
         dr2ZiR5/T3LevMtPvQTqjqCkcQyeNbz5uWHOKPlVUMNZSbNosUm6nF8YPtW/BLo4gxbQ
         YXNKiJ/tr8Ctlb6wva0nShbTqcSzuclYLmCU8a1xDmu6xfZXqUaisKQZj2sEtnlLsV+x
         zSKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f16si769441ede.53.2019.05.15.00.41.42
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 00:41:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 941F1374;
	Wed, 15 May 2019 00:41:41 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5B9F93F71E;
	Wed, 15 May 2019 00:41:36 -0700 (PDT)
Subject: Re: [PATCH] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <20190514235111.2817276-1-guro@fb.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7ad2b16d-c1a3-b826-df4d-6d9ed1d9fc9f@arm.com>
Date: Wed, 15 May 2019 13:11:46 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190514235111.2817276-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/15/2019 05:21 AM, Roman Gushchin wrote:
> __vunmap() calls find_vm_area() twice without an obvious reason:
> first directly to get the area pointer, second indirectly by calling
> vm_remove_mappings()->remove_vm_area(), which is again searching
> for the area.
> 
> To remove this redundancy, let's split remove_vm_area() into
> __remove_vm_area(struct vmap_area *), which performs the actual area
> removal, and remove_vm_area(const void *addr) wrapper, which can
> be used everywhere, where it has been used before. Let's pass
> a pointer to the vm_area instead of vm_struct to vm_remove_mappings(),
> so it can pass it to __remove_vm_area() and avoid the redundant area
> lookup.
> 
> On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> of 4-pages vmalloc blocks.
> 
> Perf report before:
>   29.44%  cat      [kernel.kallsyms]  [k] free_unref_page
>   11.88%  cat      [kernel.kallsyms]  [k] find_vmap_area
>    9.28%  cat      [kernel.kallsyms]  [k] __free_pages
>    7.44%  cat      [kernel.kallsyms]  [k] __slab_free
>    7.28%  cat      [kernel.kallsyms]  [k] vunmap_page_range
>    4.56%  cat      [kernel.kallsyms]  [k] __vunmap
>    3.64%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
>    3.04%  cat      [kernel.kallsyms]  [k] __free_vmap_area
> 
> Perf report after:
>   32.41%  cat      [kernel.kallsyms]  [k] free_unref_page
>    7.79%  cat      [kernel.kallsyms]  [k] find_vmap_area
>    7.40%  cat      [kernel.kallsyms]  [k] __slab_free
>    7.31%  cat      [kernel.kallsyms]  [k] vunmap_page_range
>    6.84%  cat      [kernel.kallsyms]  [k] __free_pages
>    6.01%  cat      [kernel.kallsyms]  [k] __vunmap
>    3.98%  cat      [kernel.kallsyms]  [k] smp_call_function_single
>    3.81%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
>    2.77%  cat      [kernel.kallsyms]  [k] __free_vmap_area
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/vmalloc.c | 52 +++++++++++++++++++++++++++++-----------------------
>  1 file changed, 29 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index c42872ed82ac..8d4907865614 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2075,6 +2075,22 @@ struct vm_struct *find_vm_area(const void *addr)
>  	return NULL;
>  }
>  
> +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> +{
> +	struct vm_struct *vm = va->vm;
> +
> +	spin_lock(&vmap_area_lock);
> +	va->vm = NULL;
> +	va->flags &= ~VM_VM_AREA;
> +	va->flags |= VM_LAZY_FREE;
> +	spin_unlock(&vmap_area_lock);
> +
> +	kasan_free_shadow(vm);
> +	free_unmap_vmap_area(va);
> +
> +	return vm;
> +}
> +
>  /**
>   * remove_vm_area - find and remove a continuous kernel virtual area
>   * @addr:	    base address
> @@ -2087,26 +2103,14 @@ struct vm_struct *find_vm_area(const void *addr)
>   */
>  struct vm_struct *remove_vm_area(const void *addr)
>  {
> +	struct vm_struct *vm = NULL;
>  	struct vmap_area *va;
>  
> -	might_sleep();

Is not this necessary any more ?

> -
>  	va = find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA) {
> -		struct vm_struct *vm = va->vm;
> -
> -		spin_lock(&vmap_area_lock);
> -		va->vm = NULL;
> -		va->flags &= ~VM_VM_AREA;
> -		va->flags |= VM_LAZY_FREE;
> -		spin_unlock(&vmap_area_lock);
> -
> -		kasan_free_shadow(vm);
> -		free_unmap_vmap_area(va);
> +	if (va && va->flags & VM_VM_AREA)
> +		vm = __remove_vm_area(va);
>  
> -		return vm;
> -	}
> -	return NULL;
> +	return vm;
>  }

Other callers of remove_vm_area() cannot use __remove_vm_area() directly as well
to save a look up ?

