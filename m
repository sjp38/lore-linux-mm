Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72BC36B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:50:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k71so10576197wrc.15
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 13:50:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 32si4715030wrn.5.2017.07.19.13.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 13:50:18 -0700 (PDT)
Date: Wed, 19 Jul 2017 13:50:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: add vm_struct for vm_map_ram area
Message-Id: <20170719135014.fdc882d1e28fd130104eff5d@linux-foundation.org>
In-Reply-To: <1500461043-7414-1-git-send-email-zhaoyang.huang@spreadtrum.com>
References: <1500461043-7414-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

On Wed, 19 Jul 2017 18:44:03 +0800 Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:

> /proc/vmallocinfo will not show the area allocated by vm_map_ram, which
> will make confusion when debug. Add vm_struct for them and show them in
> proc.
> 

Please provide sample /proc/vmallocinfo so we can better understand the
proposal.  Is there a means by which people can determine that a
particular area is from vm_map_ram()?  I don't think so.  Should there
be?

>
> ...
>
> @@ -1173,6 +1178,12 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
>  		addr = (unsigned long)mem;
>  	} else {
>  		struct vmap_area *va;
> +		struct vm_struct *area;
> +
> +		area = kzalloc_node(sizeof(*area), GFP_KERNEL, node);
> +		if (unlikely(!area))
> +			return NULL;

Allocating a vm_struct for each vm_map_ram area is a cost.  And we're
doing this purely for /proc/vmallocinfo.  I think I'll need more
persuading to convince me that this is a good tradeoff, given that
*every* user will incur this cost, and approximately 0% of them will
ever use /proc/vmallocinfo.

So... do we *really* need this?  If so, why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
