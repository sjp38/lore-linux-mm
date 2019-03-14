Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5576EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 06:27:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16C5C217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 06:27:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16C5C217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9AD58E0003; Thu, 14 Mar 2019 02:27:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2F158E0001; Thu, 14 Mar 2019 02:27:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9FF8E0003; Thu, 14 Mar 2019 02:27:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 328918E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:27:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 29so1905812eds.12
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:27:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mzc6pbxcSJQszXQFog3cCAWyyvvom4y0xCmDdMVWH/Q=;
        b=qgzT2SLF+p6OamJgzOURNgbGS48nxV9lXkP0VVslXDkDYU+9Tbwv5363wrV9bra66x
         gna3V2vgkP3QNK/giXAvZwxcsJOvbT6HJRNz1uBvi+WKVDQhcTDWgtzIq/I51fOOlS2a
         flkRTSNV5dJaZ72r5/3S0aHPA2XQl5fI8Lk2dgtENAFyZMMgrAUBFYlnDx9TfkPTr75e
         XD89bpbgGXV8VxcAzMFzh1sLDTY2AbSo+tmmy34UF8K/0x9i5u1f7JH6uwSO4NUeRa2n
         raLcc1kA/sPgzTvw1dQ9ZqUVzBELLC/kM9pX+qXgJ/n9c2B1XRP89ViCgbF3te/pF6/+
         4i4g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUt2+DNhZ//Gh2zu75EKvo6WXSA1GXoJp8QPwJJH5m3ckl1GZsn
	GWfwGiB5D3dwAGuarkL2xUB2zqfJ4hjR1jVX0Rj3eI0DrhUWMOCHzvaOVWowDsJKEaC6fAsyoW1
	8Z8Vo2nB5jHmkaTKta+s4+aGrZ0awH+Eu2yBtpQlgr3msjH/fdTJIOqe/ozPMgkQ=
X-Received: by 2002:a17:906:5809:: with SMTP id m9mr11370509ejq.153.1552544832778;
        Wed, 13 Mar 2019 23:27:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCNmVcIe2YcW0A5yZu7wUePD3RwJmLPUHJODwjCjxpob/am2ekSoD43jhS/gQI2gUARdzx
X-Received: by 2002:a17:906:5809:: with SMTP id m9mr11370455ejq.153.1552544831694;
        Wed, 13 Mar 2019 23:27:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552544831; cv=none;
        d=google.com; s=arc-20160816;
        b=sI7IzY68p+oLRX4Cpop4CeSuNfb9Hyxhlwk+oUjToNUJjLOgCvcLwIIdMtOOhGKk6Q
         xdSOD4+opzTevwZzxG0dB8j4Nz9vElQlaDwKa7dmj3EotNR4nG1mE8uaIWEu9wB03YFC
         PH8/z/WWX6FNDDlx5y9kCObks8dnFeuWqxkxHITuHETKsREUZGGlyPExanLt8HgQkFFa
         guKwz8OCPbh0d4v4AA87903st6MbYjq2tTe2utfOvbPPQTA+juXlNzsnS9VNySDT/0Tj
         CjIGP4rKdA3Tw1+OKIZm3lQf0RNJWGbFQ1jIm8Own5RDiycClUHs7UThJdA6RFD3WQTb
         TjmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mzc6pbxcSJQszXQFog3cCAWyyvvom4y0xCmDdMVWH/Q=;
        b=QfL+KVfiwAWHanGa+MeGjuDXPGS4q33oL7Nw+DyswWtYIj0ycSP8urqVHuL5Bl/H6Y
         XrX2G7lCXpymQkJ+VpVrCx1qkN4fvp+gkO9qYUFPybFtxu8/61YjC28eyBY6j5QyZt/6
         bkVA9DLeo2HPrpFSgjv96Kp9lwd+NumwIQKJ2DspHd8qQ/7d7XzRPOBCnPuU9mUd+PAl
         CsrtMxT42cn/FPPt1DeCM4QsHb+a2QPUxFbBvnnIgh/+ihPBmr+K82AD0nzVM7bwSyvU
         0H2CX1DwpWERQIXVs9sVTyl2IrUQgA4xVYb9SzTNn1s6WbJDrLV+8mYrruWaNoOWjThX
         aDYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d22si443742edy.229.2019.03.13.23.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 23:27:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 31485ACC6;
	Thu, 14 Mar 2019 06:27:11 +0000 (UTC)
Date: Thu, 14 Mar 2019 07:27:10 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: fix a wrong flag in set_migratetype_isolate()
Message-ID: <20190314062710.GA7473@dhcp22.suse.cz>
References: <20190313212507.49852-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313212507.49852-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 17:25:07, Qian Cai wrote:
> Due to has_unmovable_pages() takes an incorrect irqsave flag instead of
> the isolation flag in set_migratetype_isolate(), it causes issues with
> HWPOSION and error reporting where dump_page() is not called when there
> is an unmoveable page.
> 
> Fixes: d381c54760dc ("mm: only report isolation failures when offlining memory")

Cc: stable # 5.0
> Signed-off-by: Qian Cai <cai@lca.pw>

Very well spotted!

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_isolation.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index bf67b63227ca..0f5c92fdc7f1 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -59,7 +59,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
>  	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
>  	 * We just check MOVABLE pages.
>  	 */
> -	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype, flags))
> +	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
> +				 isol_flags))
>  		ret = 0;
>  
>  	/*
> -- 
> 2.17.2 (Apple Git-113)

-- 
Michal Hocko
SUSE Labs

