Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A36C5C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:10:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F23327ABC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:10:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mcwoSVCk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F23327ABC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED6F66B0008; Mon,  3 Jun 2019 10:10:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E87A86B000A; Mon,  3 Jun 2019 10:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9EC56B000C; Mon,  3 Jun 2019 10:10:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A10796B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:10:56 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so13716834pfn.6
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:10:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aqr2nSKe8ekislLVigui3mzwW+3e9nhwTC7BWuQq3Pg=;
        b=oFScq27cCFWnXTOrfjob/Mr2kgdx1lkxFmjabWZt+ZTDYHAjcBx4iRbX7QA4fmCd1y
         1mOYsUeQLK7b4pLb4G8xWfjZse4ixLL4cxP1E1khIdMSXNdd5VlAh6UVBzJlReBAbWnS
         UFpak9n9sDJU26r6b3I4Pja0O2YffEyX/a7NnYbe3mJ9XgQcQEbGur2QpE8O83YZ9csA
         LYpxgOZuJ6qY3DucSx8LLSytK24mo8FbdNWWwKo+a6kmQL4xD6AFmw9oh3f1jIKnXH5j
         Pk6mE56r1ioPOFPfn4JRkqPbyfDxRD5PE+HFRoKWiQF/830+evbx7ZIktBjwwnEO0tI5
         wSrw==
X-Gm-Message-State: APjAAAWE0CS6Ql7QFjYpXXSwp4e3bijRlwh1G158u9RrrUTqE5DDb0km
	KAWFlBTLsOJWjnlYxZyaLtCEsNOrVBcMw8V1lHkoVGF21Xn+aTy43IWC+yavMsUCvT9YhBXGPTQ
	7o1rp9d9chl8m8y7RdIwLFp0iJOOQwIN4115LVnLst5UogUAk0H73XTIOUaw7212GLA==
X-Received: by 2002:a17:90b:d83:: with SMTP id bg3mr15926328pjb.63.1559571055927;
        Mon, 03 Jun 2019 07:10:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsxm6N02oRTNxzWtPZuex/3mtfE0b7BsB5X/NH59jdtfXeE+wVCvfFznnS+RevVM4ePxxl
X-Received: by 2002:a17:90b:d83:: with SMTP id bg3mr15926187pjb.63.1559571054870;
        Mon, 03 Jun 2019 07:10:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559571054; cv=none;
        d=google.com; s=arc-20160816;
        b=Ml0UHl1jQRtONoYMX8/6ZDBNGlYvQ2uv8hREBx0nfHO/qy+6klEKBUqEB070kX/YhH
         tGR3VIszzBgQ1IXBtQvRwHxUPyxgGae8taTDyPfJgG1d5sl8xGlQshiKVS6Kr3pdS5rN
         JQcqz93Iq/ih3crIpHRIqpNZgAlajIO2swcbhWN6EFOHguXV4uaTPd9xo5ZvhUxRtvSI
         wwu9Fv7WzfRx/GJTwQktm8kVfDrjNj3fPqHhEUv1XfzLtDxPUv66wy0jx4nGmGmiLc25
         /S3CNmTFq2P9sm8oHIDxGyk7TZSkq/X8GQHtinZpqx0v734HPnjV6iS/PduMQZ2qTIgF
         yGAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aqr2nSKe8ekislLVigui3mzwW+3e9nhwTC7BWuQq3Pg=;
        b=yZNTUxDBB1DBTuE6XhrbZXsDe1yLEu/xgz4QhJDsd/Ged1/nu5yJF/UTfwjE+k0pEB
         XHmPJvqpNDjfEQNkVnulEuQlGUHjTvGECwWoda3sMK2ZgXA8DjbL9QXKsYUL2FWVaBKt
         prt18T32FFILMXkk9ioO1956LzTolnF2CiQQez7cXbY/hdP7Oi+SmbmBLEJVqHqFz7Ez
         5Wo1EsHGrQxoi+Uq6egL/g+PqUmThRezJW77TyjQnczBrfxwFlxQB9fVE48FngqZnD5P
         EVRmJJxSb6RPO4Nx0gPFE9e0D/cdPSNwOre/7UnPkAmn5osOIxjvI9/zDRt3K6iM8cvr
         pxiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mcwoSVCk;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a133si13207593pfa.110.2019.06.03.07.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:10:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mcwoSVCk;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com [209.85.167.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 25A3727AD3
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 14:10:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559571054;
	bh=DTEl1S9/WHP6uuMXaF6ALTUCnTGHtBY7UQFPnpvsYUM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=mcwoSVCkk7LtwsFLg6jdfNP+o4HaywLn6eCcix9yDN0dSmR/7tEsIarkiW7pZ3EtG
	 FgpyxaGwqfUdBNUpJUdxWsv9KDAevfo4zaG88QMmWowjI1rIiCYHwcaTJfouNezkfc
	 LbkUhEViJ2XDHhnKldyJwDgVc1TpHb/G8Wl6nu5g=
Received: by mail-lf1-f45.google.com with SMTP id b11so13735410lfa.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:10:54 -0700 (PDT)
X-Received: by 2002:ac2:43c2:: with SMTP id u2mr781039lfl.159.1559571052305;
 Mon, 03 Jun 2019 07:10:52 -0700 (PDT)
MIME-Version: 1.0
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
 <20190603135939.e2mb7vkxp64qairr@pc636>
In-Reply-To: <20190603135939.e2mb7vkxp64qairr@pc636>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 3 Jun 2019 16:10:40 +0200
X-Gmail-Original-Message-ID: <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
Message-ID: <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
To: Uladzislau Rezki <urezki@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, linux-kernel@vger.kernel.org, 
	Hillf Danton <hdanton@sina.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, 
	Andrei Vagin <avagin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jun 2019 at 15:59, Uladzislau Rezki <urezki@gmail.com> wrote:
>
> Hello, Krzysztof.
>
> On Mon, Jun 03, 2019 at 11:07:46AM +0200, Krzysztof Kozlowski wrote:
> > Hi,
> >
> > On recent next I see bugs during boot (after bringing up user-space or
> > during reboot):
> > kernel BUG at ../mm/vmalloc.c:470!
> > On all my boards. On QEMU I see something similar, although the
> > message is "Internal error: Oops - undefined instruction: 0 [#1] ARM",

Indeed it looks like effect of merge conflict resolution or applying.
When I look at MMOTS, it is the same as yours:
http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=b77b8cce67f246109f9d87417a32cd38f0398f2f

However in linux-next it is different.

Stephen, any thoughts?

Best regards,
Krzysztof

> >
> > The calltrace is:
> > [   34.565126] [<c0275c9c>] (__free_vmap_area) from [<c0276044>]
> > (__purge_vmap_area_lazy+0xd0/0x170)
> > [   34.573963] [<c0276044>] (__purge_vmap_area_lazy) from [<c0276d50>]
> > (_vm_unmap_aliases+0x1fc/0x244)
> > [   34.582974] [<c0276d50>] (_vm_unmap_aliases) from [<c0279500>]
> > (__vunmap+0x170/0x200)
> > [   34.590770] [<c0279500>] (__vunmap) from [<c01d5a70>]
> > (do_free_init+0x40/0x5c)
> > [   34.597955] [<c01d5a70>] (do_free_init) from [<c01478f4>]
> > (process_one_work+0x228/0x810)
> > [   34.606018] [<c01478f4>] (process_one_work) from [<c0147f0c>]
> > (worker_thread+0x30/0x570)
> > [   34.614077] [<c0147f0c>] (worker_thread) from [<c014e8b4>]
> > (kthread+0x134/0x164)
> > [   34.621438] [<c014e8b4>] (kthread) from [<c01010b4>]
> > (ret_from_fork+0x14/0x20)
> >
> > Full log here:
> > https://krzk.eu/#/builders/1/builds/3356/steps/14/logs/serial0
> > https://krzk.eu/#/builders/22/builds/1118/steps/35/logs/serial0
> >
> > Bisect pointed to:
> > 728e0fbf263e3ed359c10cb13623390564102881 is the first bad commit
> > commit 728e0fbf263e3ed359c10cb13623390564102881
> > Author: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > Date:   Sat Jun 1 12:20:19 2019 +1000
> >     mm/vmalloc.c: get rid of one single unlink_va() when merge
> >
> I have checked the linux-next. I can confirm it happens because of:
>  mm/vmalloc.c: get rid of one single unlink_va() when merge
>
> The problem is that, it has been applied wrongly into linux-next tree
> for some reason, i do not why. Probably due to the fact that i based
> my work on 5.1/2-rcX, whereas linux-next is a bit ahead of it. If so,
> sorry for that.
>
> See below the clean patch for remotes/linux-next/master:
>
> <snip>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 650c89f38c1e..0ed95b864e31 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -719,9 +719,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
>                         /* Check and update the tree if needed. */
>                         augment_tree_propagate_from(sibling);
>
> -                       /* Remove this VA, it has been merged. */
> -                       unlink_va(va, root);
> -
>                         /* Free vmap_area object. */
>                         kmem_cache_free(vmap_area_cachep, va);
>
> @@ -746,12 +743,11 @@ merge_or_add_vmap_area(struct vmap_area *va,
>                         /* Check and update the tree if needed. */
>                         augment_tree_propagate_from(sibling);
>
> -                       /* Remove this VA, it has been merged. */
> -                       unlink_va(va, root);
> +                       if (merged)
> +                               unlink_va(va, root);
>
>                         /* Free vmap_area object. */
>                         kmem_cache_free(vmap_area_cachep, va);
> -
>                         return;
>                 }
>         }
> --
> 2.11.0
> <snip>
>
> Andrew, i am not sure how to proceed with that. Should i send an updated series
> based on linux-next tip or you can fix directly that patch?
>
> Thank you!
>
> --
> Vlad Rezki

