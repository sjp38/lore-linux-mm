Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 954D4C468BC
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465B4208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:00:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SIGHIuBb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465B4208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB23F6B027B; Sat,  8 Jun 2019 00:00:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D895F6B027C; Sat,  8 Jun 2019 00:00:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C52766B027D; Sat,  8 Jun 2019 00:00:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A50D6B027B
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 00:00:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w14so2537866plp.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 21:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=YJBSSsNH8TcUO3Ycp4J72yQtEEm/T/jL9xlaGf6pvZI=;
        b=nMrBiZI3u4h/GFAPYzX/tVCyVaJ0cV/eEnVAvltGUyzV6rTZYKhheDKIR+Sasva/Kv
         ICiHBEFIW2Afe10fXHEIfgqjLhXzyP/c5vB4Hi3p9UGYfJN9In+S/aRsOxlkOlyAgAW6
         kJc8yn+YbzdzInb0RQ7C8DGgo3/PJR8Pei1ATHXwARakVMAWZ5ojG3kXn0P3XptwZzyX
         xs6nfgf1JxeTx5cDkqhjiHRrKmP3o1EhgViDHWYqLlWuW0ndJKCc7Y/75GMCV3i9jIhY
         Mi0vgkDXDkhDuUNNZhHNyxA9U7DTwyQzsqRn3P+OGdNlKaeD0I+Ae8IkEcyyYXJj4NKQ
         ne4g==
X-Gm-Message-State: APjAAAXzqLCH2ED7s5pW8Mip+IUBRDGfZXQ3aNIy64VVW9nOBj45lEqV
	ak73/X97o2CaVSqReVKQ31brQIJn242rX5IcFPfOmh9E1ww41a5ELBi+GieT+TZqWRnNN/nDETN
	0V3Wjpe8p1ewPugC0zcFlMhjLNpLp+LAOSUVT5w8HW3nfhcjVyyCOllQj6YKfXjH7EA==
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr5732955pgm.433.1559966429000;
        Fri, 07 Jun 2019 21:00:29 -0700 (PDT)
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr5732910pgm.433.1559966428238;
        Fri, 07 Jun 2019 21:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966428; cv=none;
        d=google.com; s=arc-20160816;
        b=OHIs3HbUaMpcIpusEI+Ft53TqVKNDouYcUHSIGmAj2+/hpcFr0qGB2W6+S9EEMBDml
         9m7nmddIp6NItMVLgeDdPjY2P+G6qOMgaoBwAgJQCVkS1QyRSkXUWzbTtg+tn8B6J/WL
         5JILudyTPbVILsMxRrkRza3Zk0FrWLHRSu4b/jL+UDZide/pIBcBqrphi6KlelGj8l5q
         mjJw+22u6KhUSDMm+A1x0WT43wQZMjoX4VSJwJg/Ry5rPVAs+cAhbuRV89IHD2meNIQ0
         hQXV8oGLge0bQWJC/5gXHznvfUFL7ed/1kWZNNVLx84mMyXTgEPUg4bhYGuKUDEsDauC
         8zQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=YJBSSsNH8TcUO3Ycp4J72yQtEEm/T/jL9xlaGf6pvZI=;
        b=iuuN2FcAIVsUNui9T7j8lw1Ztps6S95b7TpgTgS3OncajuM5Aj0m79a+asHtDpj7kx
         Rn+nKf4EQW+wd8+ZTyr8c0MFNoOUnxbEfGn+1XYjlt6PXa37mGdJtVnwuGYgyslY9xgo
         4VVXxfka4Et5VszpSbDXj/m3BxKNc81+O7FNX3omcGrJGpU5yRRtIgs62PQ3cdipE4+2
         qzGzB49PgJIbDv6RJkMRQSPK+66d4XpkKYAaSJMVoOC4V+DEAkn/bw5Ne1mbgAdCi9yk
         tO5GAmwbi6MqP/kUc8ujhvkJ83S+jTmrP+44+WWfWqfyyDQA84/3RBzAyze5PoJ/X0R6
         FPJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SIGHIuBb;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor4730323plr.31.2019.06.07.21.00.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 21:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SIGHIuBb;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=YJBSSsNH8TcUO3Ycp4J72yQtEEm/T/jL9xlaGf6pvZI=;
        b=SIGHIuBbHjdFD2NYvbt1juZyNlfYo8T13G3oRQwScPFyvz27E5QmOWxjQJHoK99WBn
         Ze60epVcGs+lOMqYkRKqCgC9UKlerLVaaZ1FhvQY+1i8DraNj5oIlnKwiTKses761SQn
         gTwBZBGZ3BV+37p5XRC1XuqiURHbiOTUskj5E=
X-Google-Smtp-Source: APXvYqzHeK0TqpcqthfQS0PvnOaTM79D0qX0jOvsUb1vmxMb45KBYDAyFtX8G3vNYgX7ILuQ8oms2A==
X-Received: by 2002:a17:902:a516:: with SMTP id s22mr20509311plq.178.1559966427983;
        Fri, 07 Jun 2019 21:00:27 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q1sm6873405pfb.156.2019.06.07.21.00.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 21:00:27 -0700 (PDT)
Date: Fri, 7 Jun 2019 21:00:26 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v16 07/16] mm, arm64: untag user pointers in
 get_vaddr_frames
Message-ID: <201906072059.69C8284A0E@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <da1d0e0f6d69c15a12987379e372182f416cbc02.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <da1d0e0f6d69c15a12987379e372182f416cbc02.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:09PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> get_vaddr_frames uses provided user pointers for vma lookups, which can
> only by done with untagged pointers. Instead of locating and changing
> all callers of this function, perform untagging in it.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/frame_vector.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> index c64dca6e27c2..c431ca81dad5 100644
> --- a/mm/frame_vector.c
> +++ b/mm/frame_vector.c
> @@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>  	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
>  		nr_frames = vec->nr_allocated;
>  
> +	start = untagged_addr(start);
> +
>  	down_read(&mm->mmap_sem);
>  	locked = 1;
>  	vma = find_vma_intersection(mm, start, start + 1);
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

