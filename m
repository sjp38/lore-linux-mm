Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F980C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:22:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BAAF20843
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:22:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BAAF20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16B2A6B0003; Tue, 14 May 2019 08:22:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E356B0006; Tue, 14 May 2019 08:22:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00C3D6B0007; Tue, 14 May 2019 08:22:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB8866B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 08:22:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k18so9890509wrl.4
        for <linux-mm@kvack.org>; Tue, 14 May 2019 05:22:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qayVS96zY1J0R6Jc99pitHz7f8TygGhnMtrO6wAoCLY=;
        b=XKQORgVmm/6z1XUwH/7O++DlQBBN9M/3Q85emRgRYcmMGWh6WpkMx369WX+f0sT7QX
         RD8srNDAsb7/BCBkMBpGiXkwDqraRWew0VcyFH+ufmmNx/PNnx5J9LIbDx8nAyWZ8wsd
         OI5KBV5TgWwDoUTX+FzA/tfpZaPFmAaErYkSBJX9p6P8vfZx+qKwwubz/HX9D0endkuw
         2CIotX+Pe73IfRxaasrv2aB/DKL9SAo5/RDtaGHWBQLwFspnhbcsjSRKW208oXpYEsGD
         yZejGcTSnZfFqvtB6/Vdh2G4e4ytfaIxAc6u/5sCgNmmtT4H0LxGXUySR2EKRfRwCyou
         j5vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW1woQ4ZSQRDBjomuTZGDDmzvG0QdsrV+Lw9AYo9zDTg2ntaVYJ
	9UlZNndeOyuQy+3mBjDhPvIU4W/t1VWibti4j4NQJOyXb92nwFichu3SAVpKNnyNUIEHZb38jgs
	Ta8XqyZDIJDZr1FKLYi6hFKhNN/AYhKT2CocnVzocObmpROYLLS/p37wk2LOdTM3aRA==
X-Received: by 2002:a5d:5544:: with SMTP id g4mr14264356wrw.327.1557836527309;
        Tue, 14 May 2019 05:22:07 -0700 (PDT)
X-Received: by 2002:a5d:5544:: with SMTP id g4mr14264286wrw.327.1557836526179;
        Tue, 14 May 2019 05:22:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557836526; cv=none;
        d=google.com; s=arc-20160816;
        b=cBKJrW9s186tA/UrQPhkQtL1X1yLZrsmCOTTDK/DkkLipoEW3JndZx2m1EYeXuRpZG
         H+ES+96yPBHB88alwIbSm+i01Nj7YIWzxz/K4FPSwsWlsM3ecBcOwXAhjgupJ/NfzI3B
         xLKX3/h/hcW8t/a930kJhF8+M8FtL4xm5UEpjH04OzCfoyTp6edrcSp3O93TRG4sXgr0
         ZlBiKGCTHd0nhIDpqIgnZBpR5UGVN46NLiIbYZW6xjPPo0MBJXCUQbIV2cE6n7Yvvv9j
         lvPIO9Ub4p6ZyaT7TiddGJ86oA4CaOgmCWtB6kcpvQRfzHnAndL08f+aRqGWg7eifJc4
         Kbeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qayVS96zY1J0R6Jc99pitHz7f8TygGhnMtrO6wAoCLY=;
        b=x8+0u65bDPCB6Vyd4J+kvtKRs6GDO4+iW5iYdqrmDdMVhVsRwvzsBfEzMt9FNip6FO
         Cx8C35ZTVlaGrIcGpFYn0Hh5VcdprwADALcwy7RqSDBOwecMs76biLrps81j2ZD2/vCu
         pb4HxZaU67Rc4maVburgg26K2YjRgR7s7Ok3YCsQzBhtR5i6IikiOkejapD7cWChXL4O
         skblO8xYve4QYUyYLJZ4nC8Lodk5HzxaEsvfNc0b8nLctdVXV38TKb1Adp8GazDxwfM2
         PQ1wPeA/yUkGSXWrvy38uBZbLMVP1t2Hzylv6PTLWnFyAdslcTMPwD/t7LaWtfhosqxs
         YZmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor3060766wru.40.2019.05.14.05.22.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 05:22:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzsCEp7VbrRb6Vl8WtA7IteENteanfdFIhbcZA5iRmul1ICxBd3alvROKgMfbRA3KyhviSxLA==
X-Received: by 2002:adf:9bd8:: with SMTP id e24mr16595634wrc.1.1557836525782;
        Tue, 14 May 2019 05:22:05 -0700 (PDT)
Received: from localhost (cpc111743-lutn13-2-0-cust844.9-3.cable.virginm.net. [82.17.115.77])
        by smtp.gmail.com with ESMTPSA id a128sm2874817wma.23.2019.05.14.05.22.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 05:22:04 -0700 (PDT)
Date: Tue, 14 May 2019 13:22:03 +0100
From: Aaron Tomlin <atomlin@redhat.com>
To: Yury Norov <yury.norov@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yury Norov <ynorov@marvell.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slub: avoid double string traverse in
 kmem_cache_flags()
Message-ID: <20190514122203.xvgxi4poajcs5lgx@atomlin.usersys.com>
References: <20190501053111.7950-1-ynorov@marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190501053111.7950-1-ynorov@marvell.com>
X-PGP-Key: http://pgp.mit.edu/pks/lookup?search=atomlin%40redhat.com
X-PGP-Fingerprint: 7906 84EB FA8A 9638 8D1E  6E9B E2DE 9658 19CC 77D6
User-Agent: NeoMutt/20180716-1637-ee8449
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 2019-04-30 22:31 -0700, Yury Norov wrote:
> If ',' is not found, kmem_cache_flags() calls strlen() to find the end
> of line. We can do it in a single pass using strchrnul().
> 
> Signed-off-by: Yury Norov <ynorov@marvell.com>
> ---
>  mm/slub.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 4922a0394757..85f90370a293 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1317,9 +1317,7 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
>  		char *end, *glob;
>  		size_t cmplen;
>  
> -		end = strchr(iter, ',');
> -		if (!end)
> -			end = iter + strlen(iter);
> +		end = strchrnul(iter, ',');
>  
>  		glob = strnchr(iter, end - iter, '*');
>  		if (glob)

Fair enough.

Acked-by: Aaron Tomlin <atomlin@redhat.com>

-- 
Aaron Tomlin

