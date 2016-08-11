Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6676B025F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:53:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so7961063wmu.3
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 05:53:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si2343727wjx.137.2016.08.11.05.53.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 05:53:56 -0700 (PDT)
Subject: Re: [PATCH 4/5] mm/page_ext: support extra space allocation by
 page_ext user
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <43c12773-6ee6-b7c3-6357-67180e5bfd9b@suse.cz>
Date: Thu, 11 Aug 2016 14:53:52 +0200
MIME-Version: 1.0
In-Reply-To: <1470809784-11516-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/10/2016 08:16 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Until now, if some page_ext users want to use it's own field on page_ext,
> it should be defined in struct page_ext by hard-coding. It has a problem
> that wastes memory in following situation.
>
> struct page_ext {
>  #ifdef CONFIG_A
> 	int a;
>  #endif
>  #ifdef CONFIG_B
> 	int b;
>  #endif
> };
>
> Assume that kernel is built with both CONFIG_A and CONFIG_B.
> Even if we enable feature A and doesn't enable feature B at runtime,
> each entry of struct page_ext takes two int rather than one int.
> It's undesirable result so this patch tries to fix it.
>
> To solve above problem, this patch implements to support extra space
> allocation at runtime. When need() callback returns true, it's extra
> memory requirement is summed to entry size of page_ext. Also, offset
> for each user's extra memory space is returned. With this offset,
> user can use this extra space and there is no need to define needed
> field on page_ext by hard-coding.
>
> This patch only implements an infrastructure. Following patch will use it
> for page_owner which is only user having it's own fields on page_ext.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Fine, but...

>
>  static void __init invoke_init_callbacks(void)
> @@ -91,6 +102,16 @@ static void __init invoke_init_callbacks(void)
>  	}
>  }
>
> +static unsigned long get_entry_size(void)
> +{
> +	return sizeof(struct page_ext) + extra_mem;
> +}
> +
> +static inline struct page_ext *get_entry_base(void *base, unsigned long offset)
> +{
> +	return base + get_entry_size() * offset;
> +}

Why _base()? Why not just get_entry?
Also I find it confusing that the word offset here is different than the 
offset in page_ext_operations. Maybe use "index" instead?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
