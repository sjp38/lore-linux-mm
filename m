Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3293C6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 18:08:54 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so11791747pdj.6
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:08:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fl2si30857979pad.233.2014.12.01.15.08.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 15:08:52 -0800 (PST)
Date: Mon, 1 Dec 2014 15:08:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 185/397] mm/nommu.c:1193:8: warning: assignment
 makes pointer from integer without a cast
Message-Id: <20141201150851.019d6a8aeaf269af3f94354a@linux-foundation.org>
In-Reply-To: <20141127051311.GB6755@js1304-P5Q-DELUXE>
References: <201411270833.w1auTAKD%fengguang.wu@intel.com>
	<20141127051311.GB6755@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 27 Nov 2014 14:13:12 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> @@ -1190,7 +1190,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
>  		kdebug("try to alloc exact %lu pages", total);
>  		base = alloc_pages_exact(len, GFP_KERNEL);
>  	} else {
> -		base = __get_free_pages(GFP_KERNEL, order);
> +		base = (void *)__get_free_pages(GFP_KERNEL, order);
>  	}

__get_free_pages() is so irritating.  I'm counting 268 calls, at least
172 of which have to typecast the return value.

static inline void *
someone_think_of_a_name_for_this(gfp_t gfp_mask, unsigned int order)
{
	return (void *)__get_free_pages(gfp, order);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
