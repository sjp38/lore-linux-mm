Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0768E6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:29:18 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id b66so136940546ywh.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:29:18 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id u98si14911661ybi.279.2016.11.28.07.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 07:29:17 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id s68so10058945ywg.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:29:17 -0800 (PST)
Date: Mon, 28 Nov 2016 10:29:15 -0500
From: "tj@kernel.org" <tj@kernel.org>
Subject: Re: Kernel Panics on Xen ARM64 for Domain0 and Guest
Message-ID: <20161128152915.GA7806@htj.duckdns.org>
References: <AM5PR0802MB2452C895A95FA378D6F3783D9E8A0@AM5PR0802MB2452.eurprd08.prod.outlook.com>
 <420a44c0-f86f-e6ab-44af-93ada7e01b58@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <420a44c0-f86f-e6ab-44af-93ada7e01b58@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julien Grall <julien.grall@arm.com>
Cc: Wei Chen <Wei.Chen@arm.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Kaly Xin <Kaly.Xin@arm.com>, Steve Capper <Steve.Capper@arm.com>, Stefano Stabellini <sstabellini@kernel.org>

Hello,

On Mon, Nov 28, 2016 at 11:59:15AM +0000, Julien Grall wrote:
> > commit 3ca45a46f8af8c4a92dd8a08eac57787242d5021
> > percpu: ensure the requested alignment is power of two
> 
> It would have been useful to specify the tree used. In this case,
> this commit comes from linux-next.

I'm surprised this actually triggered.

> diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
> index f193414..4986dc0 100644
> --- a/arch/arm/xen/enlighten.c
> +++ b/arch/arm/xen/enlighten.c
> @@ -372,8 +372,7 @@ static int __init xen_guest_init(void)
>          * for secondary CPUs as they are brought up.
>          * For uniformity we use VCPUOP_register_vcpu_info even on cpu0.
>          */
> -       xen_vcpu_info = __alloc_percpu(sizeof(struct vcpu_info),
> -                                              sizeof(struct vcpu_info));
> +       xen_vcpu_info = alloc_percpu(struct vcpu_info);
>         if (xen_vcpu_info == NULL)
>                 return -ENOMEM;

Yes, this looks correct.  Can you please cc stable too?  percpu
allocator never supported alignments which aren't power of two and has
always behaved incorrectly with alignments which aren't power of two.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
