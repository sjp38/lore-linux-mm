Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53810C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18CC620862
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:18:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m6r2swPC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18CC620862
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 944DC6B0005; Mon, 20 May 2019 13:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F5556B0006; Mon, 20 May 2019 13:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E46A6B0008; Mon, 20 May 2019 13:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46BAA6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:18:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 123so10141612pgh.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=PX3SK8wlBrqBu7wO9d/mgUry+iQ7KlUhXOd5Ab/YVwQ=;
        b=It3/xMyf3lpRCZHjEJBQi5+Q1wWORyx8bXPDe+4vS9gZbVCZ22qfHSzCx80LqwgixU
         wdUAwre2TkoWUUGl1qTccabVa4lh0l00wC4uJBXXXq8Ff9eqxQlovyAs1ORBO/oI18g1
         Sum6nPUZRC8tg+f7WJOl9rbtoGEhBJ/HB02UgU2Lb89+J7G6HORtBjMF1F28CJOY830X
         GOQ+IlrsD7Mf4+v+JVj2DwMhmQ4ja///y2ob240oaSUsdVE1fribw2tiyWMiL0u/0vcC
         pa0fl9lSetQc5YJbpiXI5uSHUF7el06nkhLDDAnaZqlLSJLqgUavgBz9NxlRxnEw/LSB
         mn+Q==
X-Gm-Message-State: APjAAAXY+ZehbzcdMdaLXcMJwlb/EGBU9pHnIuQSEqPXx8Pz+3siTwbD
	PCgeauO2wgFUY9lBQzp3Efu44zTh47Ib+vT9M/C+XnTwiEGdOSgYjwJI2Iv50mk98tTlKuxrIV9
	4lPscMB7x9fLmpEp1duOr1jb1MZ3FiFWbc08+rGDn/AZXU/cuLFU652USvcBLLxivpw==
X-Received: by 2002:a63:2bd1:: with SMTP id r200mr14159758pgr.202.1558372688970;
        Mon, 20 May 2019 10:18:08 -0700 (PDT)
X-Received: by 2002:a63:2bd1:: with SMTP id r200mr14159673pgr.202.1558372688257;
        Mon, 20 May 2019 10:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558372688; cv=none;
        d=google.com; s=arc-20160816;
        b=TesEniDTia305dUm4zcp9qUMgfNu3PLXHHGBq/4htUflZ4IHk2tQdJTRYwHR5A8303
         OWVAIV/W1k4BSFoLwLKznbOMs9ZjPndHKtcu48K8h/8tvNiZ9wJC+UJQr5XLIrWh04iC
         cMknv+iZa5/DeXt3Z4ESs8isu3tO8pHEnKpMYeQOI/sVrrCzR2NYqg/JVE0WOw96TDj+
         VbvDYGeitxYBHpQIY5sqyRARnLanGPrWW0R+FmRaoQvUloqICVjnJNY+cTNOb7PnYJkf
         dW6Evpl6/vj+AM2O+MsP3q9zFOjL/pAz+4MJI23bgnsHwdUhPHECgfVF/dq3binc9gvf
         oulA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=PX3SK8wlBrqBu7wO9d/mgUry+iQ7KlUhXOd5Ab/YVwQ=;
        b=fTBoB8ZIgQzlVW2fvzm7JKCy3L77DGwASOh9MyhxGDfA0FVYayjkxBq4bgFGAAeWUA
         /LkFtahv3GTn83+GEt+vbc/nfIpX4OdY1ukj+LzsXyHaSxWdt7d7LcJHL0ahwpoIEcZd
         Tr9dtbBZNF2bzgk2u0CeOJnBqdzN9n0vbkcFeTGtahKty+b/bQ1xfS35Y56woGXQu6BN
         LT94gSBmYRz/H9OH2lWg/ASk2z0XWJy9TPvmQC2ythRmhNt0TJ/12j0RdQtJT0chUu4u
         X6waS664ZnV1VAeuNiuvU/UY+ZRQidOqGdSzgRk1zq0McM8gvg/xUxT0R0dZjObsopDU
         mclg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m6r2swPC;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor9124372pgr.68.2019.05.20.10.18.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:18:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m6r2swPC;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=PX3SK8wlBrqBu7wO9d/mgUry+iQ7KlUhXOd5Ab/YVwQ=;
        b=m6r2swPC5kWUMMSAtMK4/783ntjwFjvDijgj6mgQt/YUrZSGOuM/YgVgSFWibmljXv
         RXfsjZnHPT3yHeamwmF0aUZwHhV0SaAOxMo1hY10visSNA8P31lITP+EKpQ/wAOI4pQY
         dJwKT+XBEkcG0TQmUjrzBt9O3gI4QVhWBXsiYWqg8y6onNfcvhTKN3iTdAtqj/OZ6HJO
         6/wJrAlR+dg1irA6W8KYlzGHFpTl3aH08bTjYdgyLUSbmoz7vEFbdawl+n+Ou0UlTEdF
         db3iFpcXEAKx/iiMwpWPf5JQx5EfIbdyWWwWzeWI8KyKw/8Z0VuJlc2UWs+K7wH6p0kH
         Rypg==
X-Google-Smtp-Source: APXvYqy3liAXBoXBna1vQrQA3a+41azQeKFrkkEh+b97s623lHqxninIVBzsI9Krsk3batRc+c3EVw==
X-Received: by 2002:a65:5886:: with SMTP id d6mr76297081pgu.295.1558372687639;
        Mon, 20 May 2019 10:18:07 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id s134sm28571578pfc.110.2019.05.20.10.18.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 10:18:06 -0700 (PDT)
Date: Mon, 20 May 2019 10:18:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, 
    iamjoonsoo.kim@lge.com, catalin.marinas@arm.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH] slab: skip kmemleak_object in leaks_show()
In-Reply-To: <20190514144741.39460-1-cai@lca.pw>
Message-ID: <alpine.DEB.2.21.1905201017420.96074@chino.kir.corp.google.com>
References: <20190514144741.39460-1-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 May 2019, Qian Cai wrote:

> Running tests on a debug kernel will usually generate a large number of
> kmemleak objects.
> 
>   # grep kmemleak /proc/slabinfo
>   kmemleak_object   2243606 3436210 ...
> 
> As the result, reading /proc/slab_allocators could easily loop forever
> while processing the kmemleak_object cache and any additional freeing or
> allocating objects will trigger a reprocessing. To make a situation
> worse, soft-lockups could easily happen in this sitatuion which will
> call printk() to allocate more kmemleak objects to guarantee a livelock.
> 
> Since kmemleak_object has a single call site (create_object()), there
> isn't much new information compared with slabinfo. Just skip it.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

I assume this is now obsolete since commit 7878c231dae0 ("slab: remove 
/proc/slab_allocators").

