Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D2E3C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B8D1206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:43:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K2RPLl6T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B8D1206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E58688E0005; Mon,  1 Jul 2019 13:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E08658E0002; Mon,  1 Jul 2019 13:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF7678E0005; Mon,  1 Jul 2019 13:43:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2EC8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:43:53 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id o16so6819598pgk.18
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:43:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4Ab+2WLxKa6sTxudyHiiBJTaUT/WpEhsKe3EvRMNAaI=;
        b=cOcf4AmuqE+rFe/9J9yjv0kPZJ1pAU/sH5FTe+VOcXJGoE0G2XvL564Sa+QMRI8w92
         Eh6Q+ZqbrmePdQTbP7mmSCrslnLZ7uN6ARfriAxLVr5gDKjNKNDT7zikXCzGjHB1WVcz
         nXeNd0HGTtKSF8PITkBH4mlqsx/J3xm3Xw3CFCTktJ9CTpN90W5uIquuIQpIM+VzXTWG
         lJiQx/n2ghz4yuj+5AyYK/fhpv2cA+4fj3eP9ripgo6jfW3LeAkhWDh+f/3uEayhFuYe
         ORk9mJYUzw17FeAULlOq9dvs5WQdMQxg9STh56VOUpGD57pV0h4O5JNwJFyEzRa2qvCE
         uRXA==
X-Gm-Message-State: APjAAAWKwl/MrEpCrkf3KvU4RappxM9UJbgPfsfqCG6K+d2lO1etIwlF
	aHw9p46scZLeQaDtD5D+gVd+oe/rEQ4WcMpmnzUZhF65MfrCxOKKJtEZAmPyqRLX60Oz78OdkdG
	zFWrfNNNzZxyjuOjK351ZTt7hckfwctkdU+rV8ndOOpW5EJVw8qTsW+KykyxPUmg=
X-Received: by 2002:a17:90a:db44:: with SMTP id u4mr529644pjx.52.1562003033332;
        Mon, 01 Jul 2019 10:43:53 -0700 (PDT)
X-Received: by 2002:a17:90a:db44:: with SMTP id u4mr529600pjx.52.1562003032753;
        Mon, 01 Jul 2019 10:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562003032; cv=none;
        d=google.com; s=arc-20160816;
        b=BBApFYEh+KTBH/899ai9zqjksDSR43rD0dJnwVdWA0ddKhlXF2mEnfCczhBWCJSmO5
         08O4wz5KTAHbIefsFYpAa3F/bWs0orsqYNUBX4V+/47fd1eIRNdNN3dk65rBiJnAga7T
         nosQQzXdfl28XWO63jocjFhhCOZ+5xJdOo6CJ5ILwrtx+jdOOvTaIEwbhFS1h3s8MwSp
         kOtyZc+Q4xD2bT3gOK74MbVNJM8rFH9ecBRbD4Tsq8aDZppwdH61luUmHaHt6XxDPbKQ
         fPuxsaCrivMlquGxzcVbR459ePjhrFYgtHbKMjTCzDvd5jEzBT/gti1hTtw64ZnohzY4
         8WAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=4Ab+2WLxKa6sTxudyHiiBJTaUT/WpEhsKe3EvRMNAaI=;
        b=o/qO+ada6ImTM4rArvdR/2ReiOWEZUlfL+3WFIaJ/E+NROzYnncQD3wOVBgzxqTrb8
         T+TKxQh0BAfWVCmX7i+FGMRXrrrVUyu5JIREGzaW85KrH+W9iAblQDf4Lpz1fcZWIjdw
         ivCHSI+V5248+feKNjjVlsFzBwNaQaVa4GI7XxnX+KUMTqidcsNo32Xw9IPodwBv1uwB
         OxtF4NzdM5vNA4635GTAgOFFzav23gAbPt3oN9vO3XMmgfKuylsH7Ss+LhV0jhCDYVqJ
         KoTU+Muvx0BFItf4D8wwySdsG5IB26AozpA5rTclZkP2r1MBu3qXO1YJBTVd98P361XM
         EY5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K2RPLl6T;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f13sor5178199pgo.9.2019.07.01.10.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 10:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K2RPLl6T;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4Ab+2WLxKa6sTxudyHiiBJTaUT/WpEhsKe3EvRMNAaI=;
        b=K2RPLl6T13anE5AR4Pains2OnguPjEf0HP9RI2xe6PwRE6dBBNyLLCc9hFuEDcbsTx
         erp0Vs+QqvO1AwXZQqpghNcoKB4TY4asm1/KQBOb1E3e3cgIHtUb5zQiHr97n0zz/OMr
         vfdO+NEMA82RYyGO3KULn4yfpE9GtgHNpGMHWjaBHqfSBKfhRkuGTBSl0Al8DliMX3GC
         JH9Nf+eyCC2Xd3aa0r72reEZ+9mz+IHs3SAMRG289GRZgXzQ0BLjCbdtawq9g4+A2fOW
         IBBJFcZgqZO3P0VGV+lxXCoAIdpXnu1+CRdybQ2Aue7wghH4XwwvtRZO0qS42iqyL7/4
         b9xg==
X-Google-Smtp-Source: APXvYqw5mWiLG8IgGXcXSo5PJtCcJK41xioi+PaV9M13xIHT0xLiV7aKc0U8ppKeb5x0epPkS/qOFg==
X-Received: by 2002:a63:5048:: with SMTP id q8mr25679697pgl.446.1562003032456;
        Mon, 01 Jul 2019 10:43:52 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id q63sm21513330pfb.81.2019.07.01.10.43.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 10:43:52 -0700 (PDT)
Date: Mon, 1 Jul 2019 10:43:51 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] MIPS: don't select ARCH_HAS_PTE_SPECIAL
Message-ID: <20190701174351.GB24848@roeck-us.net>
References: <20190701151818.32227-1-hch@lst.de>
 <20190701151818.32227-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701151818.32227-3-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 05:18:18PM +0200, Christoph Hellwig wrote:
> MIPS doesn't really have a proper pte_special implementation, just
> stubs.  It turns out they were not enough to make get_user_pages_fast
> work, so drop the select.  This means get_user_pages_fast won't
> actually use the fast path for non-hugepage mappings, so someone who
> actually knows about mips page table management should look into
> adding real pte_special support.
> 
> Fixes: eb9488e58bbc ("MIPS: use the generic get_user_pages_fast code")
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Tested-by: Guenter Roeck <linux@roeck-us.net>

> ---
>  arch/mips/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index b1e42f0e4ed0..7957d3457156 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -6,7 +6,6 @@ config MIPS
>  	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
>  	select ARCH_CLOCKSOURCE_DATA
>  	select ARCH_HAS_ELF_RANDOMIZE
> -	select ARCH_HAS_PTE_SPECIAL
>  	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
>  	select ARCH_SUPPORTS_UPROBES
> -- 
> 2.20.1
> 

