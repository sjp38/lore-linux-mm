Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB8F3C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 597DE21473
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:03:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bJWdlpRR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 597DE21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9FDB8E0003; Fri, 14 Jun 2019 01:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A50FF8E0002; Fri, 14 Jun 2019 01:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9661A8E0003; Fri, 14 Jun 2019 01:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6299B8E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:03:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so909848pfv.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:03:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=vzWNfLLLAeGdx7iHT9n2mvQxcG6bp4wZCUilrxRaOBg=;
        b=rT+d6PpTBVmfqu68+0nQnmfme88CKjs16jX0OnVJtVBUlJUGJ6lthqph5UwPED6Tgl
         jkOdyW1uMNLO03z4PQIJ9p05QjED9IrYYLa7SZgUSfeRAoCBeVlpeywmMkHd7gLUENbM
         QzkkZMX3YUj3F5eG53N7QezuGpVpZu46HQgmTqai/o7WGTTceYJiyPuucPGg81MIKbQ1
         9vh13XEOOJIJ4APj2PxltbEqndCXi360mVMh+eqZhgwir0hISb0zbYbKKAPOCJpSBGPN
         CBrlBHFToWyEzD1TWmgePQlANmPY/k3WpKiXSszGj2gay/kxFziEaL7DmJ7A0qXKrHLB
         3z1g==
X-Gm-Message-State: APjAAAWnOzP3zobKRx32itpGuufZJjut5LogAevSxAcbcSmyZTvVjrX5
	zdIVQ72OXfgGRf1kstglwiCRCfpvp4b74hAsZDkOiB2Oteaz7IH0tpvsiz5ErWoGWA9L8aBMLPp
	nZkgUzGGf6eQByya+t0arieX9h1rD9jfAupk4FrHkK38tISCl3nRJRKCYFg18d9WRQw==
X-Received: by 2002:a63:161b:: with SMTP id w27mr33505740pgl.338.1560488628833;
        Thu, 13 Jun 2019 22:03:48 -0700 (PDT)
X-Received: by 2002:a63:161b:: with SMTP id w27mr33505676pgl.338.1560488627852;
        Thu, 13 Jun 2019 22:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560488627; cv=none;
        d=google.com; s=arc-20160816;
        b=V5jHfE8U0PyGKM0INrI9/MJmL6ywiQI5n/Q+TqWEUBiT8Gwk+YJuEFvIxAclOZZFkd
         UuOFpYYVJsBT33LtdcQQvZkVda+MELtz/AALkCtDnlWQNYCJMV0eaaSOJJopI8zrXhf4
         f7ry66U8tbcrUAnHRl90MZ2413jqthA8jAQs+UiGffQQ+sb1dDJ0jsNT1pSFazXcbWOm
         lE6ZRvFpz+QN+37S42ok2Q8MJTxJlTCorF3GdQsUmrlCCJgh8WpXAn8B0xW2EY9Oy3Jj
         z4duEWpJS7XsRMeW1a2hp0qQPDzdLQ/peQiXMHDPDzx5I8+d85tKxPbmAYbGPJirzdBK
         Cfqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=vzWNfLLLAeGdx7iHT9n2mvQxcG6bp4wZCUilrxRaOBg=;
        b=IPnW//c/FSjwc/iE524Yvv3UlvgPXBSWhYWik3PHT8ARm+0cZnxdEeiJ1rr3ErJaLa
         y7x4i8OTLltHikzH1p7F04PXUiVktorTN5CB8dSI+oWIgz2+KoF1KBMB1zXII3FIe2ad
         RKCalX1Act/PbqhiI7JcHj8NR6hFSBfxjJjBCiU+P3Qs0mH9InPRK9APLphA7d3hUp8v
         qS6xmuBeZr8cPFV3NpKxVGgxjs46ttReNyH91ZgHA2yo+wuWc9BdFbrKYiQAVew4F9BW
         Uk88UoXJtps260C6hKjzFQ3eOoqWxUX7ST7fbfVs3ciGpmla2ewQt7x5/OVCoTK/unQs
         CZxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bJWdlpRR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor2270166plo.57.2019.06.13.22.03.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 22:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bJWdlpRR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=vzWNfLLLAeGdx7iHT9n2mvQxcG6bp4wZCUilrxRaOBg=;
        b=bJWdlpRRGB15JzNuxSkj/0RPEWaKqcPRrFrQ3ai2ojLMIPqYEmt/4pm+l2yin+tUio
         jBug4MBdWstbYkD7RGKZf4N2VB4qY9sUdsxTHweadmHZD1aL/kiWCXzcnum364N04VKt
         FAIw+kKyYpxZALIoSQEwLjdUTDEzlcJs84i0A=
X-Google-Smtp-Source: APXvYqxfIpUPwU4twV+O8Jh78bNwx/c5+KBI1WBnJePmnmvrugbVR3lAaJt7s9ANLBo10/AmsAypzw==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr22780924plq.144.1560488627524;
        Thu, 13 Jun 2019 22:03:47 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id d123sm1521005pfc.144.2019.06.13.22.03.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 22:03:46 -0700 (PDT)
Date: Thu, 13 Jun 2019 22:03:45 -0700
From: Kees Cook <keescook@chromium.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] mm/slab: restore IRQs in kfree()
Message-ID: <201906132202.9BF49E6B@keescook>
References: <20190613065637.GE16334@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613065637.GE16334@mwanda>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:56:37AM +0300, Dan Carpenter wrote:
> We added a new return here but we need to restore the IRQs before
> we leave.
> 
> Fixes: 4f5d94fd4ed5 ("mm/slab: sanity-check page type when looking up cache")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Oh yes! Thank you for that catch! Andrew, if you haven't already, can
you pick this up?

Thanks!

-Kees

> ---
>  mm/slab.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 9e3eee5568b6..db01e9aae31b 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3745,8 +3745,10 @@ void kfree(const void *objp)
>  	local_irq_save(flags);
>  	kfree_debugcheck(objp);
>  	c = virt_to_cache(objp);
> -	if (!c)
> +	if (!c) {
> +		local_irq_restore(flags);
>  		return;
> +	}
>  	debug_check_no_locks_freed(objp, c->object_size);
>  
>  	debug_check_no_obj_freed(objp, c->object_size);
> -- 
> 2.20.1
> 

-- 
Kees Cook

