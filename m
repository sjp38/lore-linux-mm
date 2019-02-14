Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06291C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:49:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B715E2147C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:49:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="lLQgQe9B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B715E2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 408F18E0002; Thu, 14 Feb 2019 15:49:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B8228E0001; Thu, 14 Feb 2019 15:49:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CEC28E0002; Thu, 14 Feb 2019 15:49:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E25198E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:49:48 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so5743424pfj.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:49:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:subject:in-reply-to:cc:from
         :to:message-id:mime-version:content-transfer-encoding;
        bh=65fCph2wVQLYLbAYl3Kh/IhOwVLd3uOG3Na/8tJTTl0=;
        b=IMPBoo5dcKTH7XSsbsnzbXLs2l16gvulNACjlh3U66YxqpZzTk3G5JYs4KgNI46zB9
         xkBVakZEO9JpL/Wio7/wLXH7j3nFa8Je4balYFV0NU6VTdgrGUN/s4mQoESt8xZcs6Nc
         UFIo6wgYL2cfXLnS6cjlsEv5P7um+pP/peff8xVBbpLpjDwXx/SUpjVPkcNpaA6LktBm
         GE9VO1ATaecPeeLMAYcHhhI7+SdRWOK7SMFLJA1TFX/Jg1ycLexrBZNCEwlAiMgfg1sm
         gzunmxEKZFp6Ue+M2Vdj3B0d3gAyrzA60zc7p/jzQN8bRHOxFukuuapa2/a+z+ZMAWlH
         GSdg==
X-Gm-Message-State: AHQUAuZpBQGqMOOMyBqYwRCszP0vAo/YSFCDwfgKQuYS2N1a8NqPli3Y
	sRNujC8b1cY+P5YmdhOhOeVdTdX+NMPvEo4BK0KcyHuOAw/WAwDE2NDj3GNgRD5R1+4MtkAtfwX
	FA42TRMaSpyfF9b9XI/rU3t3ICTeO4Qd0PQbwdayVwhKFjeGZwjUeBhLAt1X6ZZOE6m3pncO0YF
	YSvwAFlX0O7nzjRGqc8cRVJwLjCrtMdKrzB3On47A7IAAN6ClXVthuXUW/W2AbvgwHSt9IYlSbc
	/orjzf2oBq0/ozb3i5i3VNLws4SDF90U5xF0SpUsqCxmS8GCDUSwIACdtiSkb/DsPN121Il4hZO
	oRK4MtWJpYPb/3rt71V6wDt/TFw7Sms0YCSvvHHcOAEy4vxwWXywaNxmldSzfVvG0qbiHHpPhYr
	9
X-Received: by 2002:a17:902:8498:: with SMTP id c24mr6367840plo.265.1550177388555;
        Thu, 14 Feb 2019 12:49:48 -0800 (PST)
X-Received: by 2002:a17:902:8498:: with SMTP id c24mr6367795plo.265.1550177387791;
        Thu, 14 Feb 2019 12:49:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550177387; cv=none;
        d=google.com; s=arc-20160816;
        b=r8phbjpMXqiPhuYeb0shWWX9mol15+/SOR31CZ0weq9DKmBJmmyHQVElsLjLEwXs2W
         DxXCcIc7W2hzEeiYEk9vn0GqtNqrtbMgEaXxqrXNZ9vJMQ13oN4E7pGZKkHX4D0yFqBb
         BPU2nw/4iSVviEC47Jhyv2LadrSo5iZG6T4Wa6hgaNQ2UCchP+V5y+QH/S1p+YpAqJIz
         qqOu5aQtmOFeOc3YDDyu8gjzUatzCBWNpMZQuxrzZYpAVgqiMwBHSOHjtA4Q4PwIpHk0
         SyWFMQP3D75zEPkwmlsFWAksugVj8gc0VH8JWY6u5e4I/VpSvJcyPxk54fbhaGB1I2vR
         DQaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:to:from:cc
         :in-reply-to:subject:date:dkim-signature;
        bh=65fCph2wVQLYLbAYl3Kh/IhOwVLd3uOG3Na/8tJTTl0=;
        b=xeh1bA4+D4hl/E+WnJnJWEfYlROgFNF/DdTotsxzAz3CsdcKip7s40J65XaSanikOu
         DZflMAifJQhUl3r1uEOs0ZobUzHwOGSpGs5ItZhTuDzn3xSXtfrgAv6KLjspIkY/2NOt
         wufDj9RPKtQfdT9h6k4fSUtcgLcbKC7h8u6Urknse0qxirda65APJ2J7rbs9Zd7s66U2
         ZZkpvluaYOytEsBNjpZnkkqB7XakIz7YTjl0lEtiQvsCR3EtHxKLr8XrXDFwyuS+3LFz
         NWj6q5lp5DTSNDCncKtH32bJQdDsFUb597v37UAGMZRkInquSl/LmTBa+K5DqAjEqLVT
         8gpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=lLQgQe9B;
       spf=pass (google.com: domain of palmer@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor5695872pga.30.2019.02.14.12.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 12:49:47 -0800 (PST)
Received-SPF: pass (google.com: domain of palmer@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=lLQgQe9B;
       spf=pass (google.com: domain of palmer@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:subject:in-reply-to:cc:from:to:message-id:mime-version
         :content-transfer-encoding;
        bh=65fCph2wVQLYLbAYl3Kh/IhOwVLd3uOG3Na/8tJTTl0=;
        b=lLQgQe9BdP6L/KKozxCy89gHttaXJ4MA/yuhOBLCl/O1eO8ekEikoBlRb07TggKmfT
         VEnZJpuB+R0alfezZ07DaC4KjxaWVhFw87+QptUw3Qfceuu+A4AqmvxsZpbt9TUicHg0
         pIp0nAUSBY9GINxAhjuu7lkJv4M3cJfYaDkCYM+E7KxXxeADn7bOhq3P6BdJtOi9Set7
         geGOodJQ42skGi7BhAPn2OSrGFUbhESwVHmVG7K3mUc/QqnryZ1A1g4gvHOsa+GHi8Wr
         7v0wAKu9AsvGvisJ9miN0oRC+7goN7MaAvA0WXXEqzHznU5rKaZN10qjHoUKTWZ9V4Qs
         vxxQ==
X-Google-Smtp-Source: AHgI3IbLxG6jNbV4WqQPwhjvqV2Ffx3+iOXl0AxSnfqcM2rbVcz5nyD0wlnlMZsqhHytPuQm2K5IYw==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr1788701pgr.333.1550177387393;
        Thu, 14 Feb 2019 12:49:47 -0800 (PST)
Received: from localhost ([12.206.222.5])
        by smtp.gmail.com with ESMTPSA id l12sm3035910pgk.40.2019.02.14.12.49.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:49:45 -0800 (PST)
Date: Thu, 14 Feb 2019 12:49:45 -0800 (PST)
X-Google-Original-Date: Thu, 14 Feb 2019 12:47:37 PST (-0800)
Subject:     Re: [PATCH 4/4] riscv: switch over to generic free_initmem()
In-Reply-To: <1550159977-8949-5-git-send-email-rppt@linux.ibm.com>
CC: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, rkuo@codeaurora.org,
  linux-arch@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
  linux-mm@kvack.org, linux-riscv@lists.infradead.org, rppt@linux.ibm.com
From: Palmer Dabbelt <palmer@sifive.com>
To: rppt@linux.ibm.com
Message-ID: <mhng-e6dedfc5-937e-42e5-90d6-4ce400cbc6fb@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 07:59:37 PST (-0800), rppt@linux.ibm.com wrote:
> The riscv version of free_initmem() differs from the generic one only in
> that it sets the freed memory to zero.
>
> Make ricsv use the generic version and poison the freed memory.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/riscv/mm/init.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
> index 658ebf6..2af0010 100644
> --- a/arch/riscv/mm/init.c
> +++ b/arch/riscv/mm/init.c
> @@ -60,11 +60,6 @@ void __init mem_init(void)
>  	mem_init_print_info(NULL);
>  }
>
> -void free_initmem(void)
> -{
> -	free_initmem_default(0);
> -}
> -
>  #ifdef CONFIG_BLK_DEV_INITRD
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {

Reviewed-by: Palmer Dabbelt <palmer@sifive.com>

I'm going to assume this goes in with the rest of the patch set, thanks!

