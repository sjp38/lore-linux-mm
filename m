Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6795DC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2946E21849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:24:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zh9lxgNm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2946E21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5B726B0005; Wed, 17 Jul 2019 17:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE50B6B0006; Wed, 17 Jul 2019 17:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95EBF8E0001; Wed, 17 Jul 2019 17:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8996B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:24:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so15228047pfz.10
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BDYaDDEpZl5dhKjtHMXSxKfIqom9MNnmnk9wKfgulQA=;
        b=fftrUj3TEHac1X9dDhrDY/3a9yQUgDt7diEC/9cGI1MWB5OFoulbQ/EdIa+8pIKxvD
         rLMOLMf0j6GXCSO2W9f5+46AuOzL2JBBWSSu+mdvWWAeNbptbYy+orO82F/u5R0ieY6v
         rvNG8kZ83EMcfJwdXFR3g6ly0hFljLU97rgzl9Wrbu/HOkAu7tfv+tyIJFTTB5qaDKlS
         UI8cAM3VP+gZE7EuRTKXnJu97TnKIEDtAZcmLQKMCYjUYneH0LYlNsPMvegZ/FZMTr17
         7aQKSTeIRovMiXVdMznyaRPtdgxdWuuLwDdEaD1ZZNY4XmWSMhojASc7bWf5RVeK6WGc
         xnnA==
X-Gm-Message-State: APjAAAXq8e4eEzpVbp8Oh7ocGiPrBQUZmPlQ3YdIL0GMtPpCxJ7f4YDx
	m/mIPzUiopNtVEPq3nVW8VSdRzwjgrznpPQMnnS1LRvixWWwrE6kbM+0JT9JnUokFcCCBmwXjxl
	uAiFHl5nXb28WM1H7vpVk18aCB8e4TcuL4pMFcNKnVOxqBbEE4qEOLftVjBK1UIQP7w==
X-Received: by 2002:a63:7245:: with SMTP id c5mr29256812pgn.11.1563398664750;
        Wed, 17 Jul 2019 14:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybjq+EZaywTgmzqv5Fu9E/9M9VUH2UBX+HDv75Gzx5d9fxU6Bd0lrdfqFhzMBMDqWFh3wn
X-Received: by 2002:a63:7245:: with SMTP id c5mr29256745pgn.11.1563398663822;
        Wed, 17 Jul 2019 14:24:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563398663; cv=none;
        d=google.com; s=arc-20160816;
        b=PVL4yaz+GDtE1L5NmFUKVnDgiGsl3UjXvOuG5cwbevR+KAJsM4tb6lTQ/VJHb6MXmZ
         ttPsdI7qwFiFNlOgICNPvQPqB9XzyZkoRWVWx77fwGzSFukx8P7z8L+/kgvG68QCd4Bl
         Snm7Pur3GAThResY+f4Vn6EM+6VyD2OuJX7nMSLvtlF9PT8imKHINRyQtMtD5X4NFahR
         Z2vEhdqviJGNlXx9o/VzkpVm65uGz5+1bzRf/7DWCofo2jYuqjcvfIB2Uj7n3TeEPHSL
         GkoyFi1zFQ1mPQxJkA7W9pxGB54+S0sj5MtzU1Vr12pi3tJtePA06I6hjaqxcAE1MNny
         eOHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BDYaDDEpZl5dhKjtHMXSxKfIqom9MNnmnk9wKfgulQA=;
        b=fxIBxPE6hwKEyrZk2Xc0qZeDLYPkW/nzBf6GH+8w5Ko+GY5mGNqCqA1aSP+7JLirV0
         V2764dGWB9yVT/xrazbwdCDeCOB4tPteqRDK3wcg54HCtqSuc2E6bqYI7ROItF3wkqEM
         q70T1mMbLhPqeIZnH5NhC8/xWG1crdRa5/2x+XMKzyMo4BeCwpubfr6gh1XCZFT3ORVw
         IasT1Z4f8lUQAB7nfmOedh8SrnPfiw58Kym46WnHsBK47Xo10bnM80Jf+1Y5axfs72sK
         tK5P33E48tixksQmpkSn2YqlSqjurmy33/Y3DZ1C9KQEBjOk+7n6DzYde7nxcMn5yJC6
         wTpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zh9lxgNm;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g32si418132pje.38.2019.07.17.14.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:24:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zh9lxgNm;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3DCBC2187F
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 21:24:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563398663;
	bh=Ap5TwhmtuWKZyNppq7kyJPabjyvLMUE9Mf8WiDtOxmc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=zh9lxgNm+6nlUVTZWtDHx+bxjyrLvGvPKR7+3Qj2ZiB7xCtjTgsfuX3LelkkwhWiE
	 939QnXVowCyRxqHZvppFJ44+uvHEp72rB58KK16GnDyDwbc9VtGuMz/1hMzWlf286V
	 14enB4y9gGoq8PGbGRiqsTA0FC7vu4gonvUFFEPo=
Received: by mail-wr1-f43.google.com with SMTP id n9so26413319wru.0
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:24:23 -0700 (PDT)
X-Received: by 2002:adf:cc85:: with SMTP id p5mr42310193wrj.47.1563398661732;
 Wed, 17 Jul 2019 14:24:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-4-joro@8bytes.org>
In-Reply-To: <20190717071439.14261-4-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Jul 2019 14:24:09 -0700
X-Gmail-Original-Message-ID: <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
Message-ID: <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
To: Joerg Roedel <joro@8bytes.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Joerg Roedel <jroedel@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 12:14 AM Joerg Roedel <joro@8bytes.org> wrote:
>
> From: Joerg Roedel <jroedel@suse.de>
>
> On x86-32 with PTI enabled, parts of the kernel page-tables
> are not shared between processes. This can cause mappings in
> the vmalloc/ioremap area to persist in some page-tables
> after the regions is unmapped and released.
>
> When the region is re-used the processes with the old
> mappings do not fault in the new mappings but still access
> the old ones.
>
> This causes undefined behavior, in reality often data
> corruption, kernel oopses and panics and even spontaneous
> reboots.
>
> Fix this problem by activly syncing unmaps in the
> vmalloc/ioremap area to all page-tables in the system.
>
> References: https://bugzilla.suse.com/show_bug.cgi?id=1118689
> Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  mm/vmalloc.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 4fa8d84599b0..322b11a374fd 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -132,6 +132,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
>                         continue;
>                 vunmap_p4d_range(pgd, addr, next);
>         } while (pgd++, addr = next, addr != end);
> +
> +       vmalloc_sync_all();
>  }

I'm confused.  Shouldn't the code in _vm_unmap_aliases handle this?
As it stands, won't your patch hurt performance on x86_64?  If x86_32
is a special snowflake here, maybe flush_tlb_kernel_range() should
handle this?

Even if your patch is correct, a comment would be nice

