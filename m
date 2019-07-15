Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 862D2C742D2
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 408BE20C01
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:34:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="QrISUnxC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 408BE20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB99C6B0003; Sun, 14 Jul 2019 22:34:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6A9E6B0006; Sun, 14 Jul 2019 22:34:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B31836B0007; Sun, 14 Jul 2019 22:34:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACEB6B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 22:34:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e95so7679105plb.9
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:34:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=j1D3jAEemUPemgo3Jj5nb6GS6101sWhcpLMgfsoNq8g=;
        b=DXPd+G0J6laqRmR0ryckkXwfZ9vtplr+q7keu7YlNlX8Bu07oyDf++X1NeuT4TcOeD
         VC8QJIdLH9aIU7J92cEEvR9AzCX9guw2kk7PCWAOVWhZqtTofkNvDH+EdHdsAvxOPKmQ
         A7iMHFJWOhKj455ep06P19CquvMI0ojSkW4+uuR1wWbN1WEpEpKfInB+MwovNxUCOG1q
         do/f6eluANNSNI4DvNSbzt2mY1fqHI3gTG85Z3MZYyN9lsLH5j5/EGHDRpnmbuDB8amQ
         JzOa0pNlp4wVtl7KmS+dgh+GE7mCrD8sRcgKkNfDCaByHQgXE97uo/QWucVeP1HcM5/9
         SRug==
X-Gm-Message-State: APjAAAUHWgNbZgw8zyNexa1T/vxexM4QdtCNhSOwY81EMEIA+GT2A9i/
	1gqzKOlIt4kZk6TiQWL+//giLun9d3l7fldR0H9FsBoTqqd7uF5dp8yQgW505z/zONN77fM2n19
	wgNVrAC48ur0t26t+MHlOf2dYoMf3jjIDiKhR+mumYhQOGRs5QaSlVsEq32Gw8mo21A==
X-Received: by 2002:a17:90a:3463:: with SMTP id o90mr27198134pjb.15.1563158044080;
        Sun, 14 Jul 2019 19:34:04 -0700 (PDT)
X-Received: by 2002:a17:90a:3463:: with SMTP id o90mr27198093pjb.15.1563158043368;
        Sun, 14 Jul 2019 19:34:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563158043; cv=none;
        d=google.com; s=arc-20160816;
        b=PD2duqyiflP0zGkq/xGezmTLlLv/RPO8r2A3VEpwPELLDjho7tfELkeAdLw1iqiOT8
         Cm6ysVBvWfFb3TJtMctdr2J3im8FWVu/VsWyQ+m/2/zq4PsLrsmumXzDAsJCDiwRNkzM
         UYyx8Lq6+XhlJT0fHAiRilJ07nWI69/lwSq5H2Mn/3yG56GEEKqIGF0FMOUb93K558gd
         AxfNK1nKTOt3NFjrSKK1hbFICeJKZnYq7An+H5lQBdQa6RJMIbEuyQe49+ZjbX/LbbWm
         EUaeei/aUVhQkBzqgAiYFu+YWTV4JEq4qL2kmADw6+9N0RMdvjy1iLFdCAmtHhNyinXn
         C5xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=j1D3jAEemUPemgo3Jj5nb6GS6101sWhcpLMgfsoNq8g=;
        b=oG09V6OiAaYHG6VcC0XhQTmkWg91z97wSvCM+F/p2j6qVYMxuNm2I7nf4DVG9fSSnX
         2XJHXddriE4fvkYHh7mQXl9OouQrFOeXg1ABvdCpgj//82h2gssxREbfCVQKm3Bjl/yQ
         xOvQK7g1pMjwwO2DS3yxE80+wY6TSKB7TemsJA0uRTEKd+J1W0WiCdiMFAPePZchCuLn
         cIiWJ6cmuUt5dEiw9/RdGREVZzWGKW785Z7WXZwyJo0ro95tBgkdeYDh9inr2ndr+Eu6
         LDlWoMpdbpQp5+ucnWFIOeYKd8QRv47HL4qaE2X3e5o92RrQ9sRkSyYn/8WssXKclyYT
         bxkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=QrISUnxC;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6sor8111822pgp.76.2019.07.14.19.34.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 19:34:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=QrISUnxC;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=j1D3jAEemUPemgo3Jj5nb6GS6101sWhcpLMgfsoNq8g=;
        b=QrISUnxCSscxlNiF2KqrOgYSELv84+I/OVPUsZDhEuEi4r7R8YUKcUPEfdayuPSfK0
         wrQ3Q089jqbmouyR+NoH07yfRGBgepPs66CHFe5siqBvErBCrBMbICucDPWVzgWos38b
         Wf2Rms1UOmhDfsHeziRBcVVeqhPowRnyQF6ZIirk9sqy61+7brb3XjH5WSXDOqEwMkq3
         q0U1QstYRjrFeTUkIvslQ7dopjLzTMUk5/MTR7wo3HmTm88DIkL2jdeSCkahHTIsS0XU
         2mC5wBJ5eaM50hskzzZTjH7Ed3Xloa++ONtGgIN+sj2f13lAUYZHfj/Zj0wydtFoffX+
         bJXQ==
X-Google-Smtp-Source: APXvYqwy96VWEm0MA4ILQTD2TtjFzmkAMeu1HQIcFyR05bl5hBBOCB7OmlKryt9SnBNgiGdMCiKl3g==
X-Received: by 2002:a63:7a01:: with SMTP id v1mr25024594pgc.310.1563158042768;
        Sun, 14 Jul 2019 19:34:02 -0700 (PDT)
Received: from [192.168.1.121] (66.29.164.166.static.utbb.net. [66.29.164.166])
        by smtp.gmail.com with ESMTPSA id d129sm16418490pfc.168.2019.07.14.19.33.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 19:34:01 -0700 (PDT)
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, akpm@linux-foundation.org,
 ira.weiny@intel.com, jhubbard@nvidia.com
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
 Dimitri Sivanich <sivanich@sgi.com>, Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Cornelia Huck <cohuck@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
 Magnus Karlsson <magnus.karlsson@intel.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Jakub Kicinski <jakub.kicinski@netronome.com>,
 Jesper Dangaard Brouer <hawk@kernel.org>,
 John Fastabend <john.fastabend@gmail.com>, Enrico Weigelt <info@metux.net>,
 Thomas Gleixner <tglx@linutronix.de>,
 Alexios Zavras <alexios.zavras@intel.com>,
 Dan Carpenter <dan.carpenter@oracle.com>, Max Filippov <jcmvbkbc@gmail.com>,
 Matt Sickler <Matt.Sickler@daktronics.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Keith Busch <keith.busch@intel.com>, YueHaibing <yuehaibing@huawei.com>,
 linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@driverdev.osuosl.org, kvm@vger.kernel.org,
 linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, bpf@vger.kernel.org,
 xdp-newbies@vger.kernel.org
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <018ee3d1-e2f0-ca12-9f63-945056c09985@kernel.dk>
Date: Sun, 14 Jul 2019 20:33:57 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/14/19 1:08 PM, Bharath Vedartham wrote:
> diff --git a/fs/io_uring.c b/fs/io_uring.c
> index 4ef62a4..b4a4549 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -2694,10 +2694,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
>   			 * if we did partial map, or found file backed vmas,
>   			 * release any pages we did get
>   			 */
> -			if (pret > 0) {
> -				for (j = 0; j < pret; j++)
> -					put_page(pages[j]);
> -			}
> +			if (pret > 0)
> +				put_user_pages(pages, pret);
> +
>   			if (ctx->account_mem)
>   				io_unaccount_mem(ctx->user, nr_pages);
>   			kvfree(imu->bvec);

You handled just the failure case of the buffer registration, but not
the actual free in io_sqe_buffer_unregister().

-- 
Jens Axboe

