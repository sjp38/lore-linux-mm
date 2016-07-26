Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2509A6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:50:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k16so34527673qke.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 09:50:45 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id o71si441201yba.280.2016.07.26.09.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 09:50:44 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id j12so21332470ywb.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 09:50:44 -0700 (PDT)
Date: Tue, 26 Jul 2016 12:50:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/memblock.c: fix index adjustment error in
 __next_mem_range_rev()
Message-ID: <20160726165040.GU19588@mtj.duckdns.org>
References: <42A378E55677204FAE257FE7EED241CB7E8EF004@CN-MBX01.HTC.COM.TW>
 <20160725185218.GG19588@mtj.duckdns.org>
 <42A378E55677204FAE257FE7EED241CB7E8EF0C9@CN-MBX01.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42A378E55677204FAE257FE7EED241CB7E8EF0C9@CN-MBX01.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu@htc.com
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, ard.biesheuvel@linaro.org, tangchen@cn.fujitsu.com, weiyang@linux.vnet.ibm.com, dev@g0hl1n.net, david@gibson.dropbear.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhiyuan_zhu@htc.com

Hello,

On Tue, Jul 26, 2016 at 03:03:58PM +0000, zijun_hu@htc.com wrote:
> I am sorry, I don't take any test for the patch attached in previous
> mail, and it can't fix the bug completely, please ignore it I
> provide a new patch attached in this mail which pass test and can
> fix the issue described below
>
> __next_mem_range_rev() defined in mm/memblock.c doesn't Achieve
> desired purpose if parameter type_b ==NULL This new patch can fix
> the issue and get the last reversed region contained in type_a
> rightly

Can you please flow future mails to 80 column?

> The new patch is descripted as follows
> 
> From 0e242eda7696f176a9a2e585a1db01f0575b39c9 Mon Sep 17 00:00:00 2001
> From: zijun_hu <zijun_hu@htc.com>
> Date: Mon, 25 Jul 2016 15:06:57 +0800
> Subject: [PATCH] mm/memblock.c: fix index adjustment error in
>  __next_mem_range_rev()
> 
> fix region index adjustment error when parameter type_b of
> __next_mem_range_rev() == NULL

The patch is now fixing two bugs.  It'd be nice to describe each in
the description and how the patch was tested.

> @@ -991,7 +991,11 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>  
>  	if (*idx == (u64)ULLONG_MAX) {
>  		idx_a = type_a->cnt - 1;
> -		idx_b = type_b->cnt;
> +		/* in order to get the last reversed region rightly */

Before, it would trigger null deref.  I don't think the above comment
is necessary.

> +		if (type_b != NULL)
> +			idx_b = type_b->cnt;
> +		else
> +			idx_b = 0;
>  	}
>  
>  	for (; idx_a >= 0; idx_a--) {
> @@ -1024,7 +1028,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>  				*out_end = m_end;
>  			if (out_nid)
>  				*out_nid = m_nid;
> -			idx_a++;
> +			idx_a--;
>  			*idx = (u32)idx_a | (u64)idx_b << 32;
>  			return;
>  		}

Both changes look good to me.  Provided the changes are tested,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
