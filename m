Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8F3E6B0261
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:53:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so10288784pgd.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:53:27 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id h91si3819611pld.258.2016.11.22.22.53.25
        for <linux-mm@kvack.org>;
        Tue, 22 Nov 2016 22:53:26 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz> <20161121215639.GF13371@merlins.org> <20161122160629.uzt2u6m75ash4ved@merlins.org> <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com> <20161123063410.GB2864@dhcp22.suse.cz>
In-Reply-To: <20161123063410.GB2864@dhcp22.suse.cz>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of RAM that should be free
Date: Wed, 23 Nov 2016 14:53:12 +0800
Message-ID: <01a101d24556$4262a230$c727e690$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, 'Marc MERLIN' <marc@merlins.org>, 'linux-mm' <linux-mm@kvack.org>, 'LKML' <linux-kernel@vger.kernel.org>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Tejun Heo' <tj@kernel.org>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>

On Wednesday, November 23, 2016 2:34 PM Michal Hocko wrote:
> @@ -3161,6 +3161,16 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
>  	if (!order || order > PAGE_ALLOC_COSTLY_ORDER)
>  		return false;
> 
> +#ifdef CONFIG_COMPACTION
> +	/*
> +	 * This is a gross workaround to compensate a lack of reliable compaction
> +	 * operation. We cannot simply go OOM with the current state of the compaction
> +	 * code because this can lead to pre mature OOM declaration.
> +	 */
> +	if (order <= PAGE_ALLOC_COSTLY_ORDER)

No need to check order once more.
Plus can we retry without CONFIG_COMPACTION enabled?

> +		return true;
> +#endif
> +
>  	/*
>  	 * There are setups with compaction disabled which would prefer to loop
>  	 * inside the allocator rather than hit the oom killer prematurely.
> --
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
