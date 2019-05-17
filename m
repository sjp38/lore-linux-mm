Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E66DC04AAF
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 01:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 312D52082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 01:26:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="QNQxNc5y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 312D52082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 751F06B0005; Thu, 16 May 2019 21:26:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 701476B0006; Thu, 16 May 2019 21:26:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F0786B0007; Thu, 16 May 2019 21:26:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 245356B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 21:26:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c7so3415536pfp.14
        for <linux-mm@kvack.org>; Thu, 16 May 2019 18:26:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=+cJ2gxhZLau5gmuenPlTtxJhsl5TXn8iu9yGe1AQQrg=;
        b=pE7xInGzpjGeGDudnL1crDlydArNvu3vKgjfG1TOYLrj58FAMmo56Qtq2ot4WlRR3j
         I92JSU4TJjEuJx8QO50sN7Q4VgwEWwDN/bXHmMOh+uS/a2NabIdCssRIwQ/Xp9wd2Wjm
         Jb3Q+Cd9vS9yl353gOZX94Kvy/a3JNks35Q+zlM7rTnCBfciSS+3C69Ropvvz2DyVtAx
         ZDkjEufeGNPthllx0rELA7e8GmTKTASzLZcd9yaP+eMNWIVGixvqgIzMnbcnmcyWeUd5
         QApXSM/RfFglYfkw80ZQlWck43kGagP9ss03CG8y9zgT0SWjza2miA+TtySUMnZugFKj
         57jA==
X-Gm-Message-State: APjAAAVYmHUyCGzqsoau2kbQQbrXDcKU2Sn6srsowsvCBLqonEamwm8J
	ROEaClRhaMYD04jN9Dwm4jh8sSqvvUOFOTFwdkfOHeJnzf72tZJqr2CGn+EkmCRoFrXGARcI2/1
	kC5ncKMmjfuVccL84iJDmJc8Ap6M0bBYw5tultqo5SIDg+AWBKc7uaFyuuFArZ5GWdQ==
X-Received: by 2002:a17:902:b10f:: with SMTP id q15mr10497340plr.257.1558056385628;
        Thu, 16 May 2019 18:26:25 -0700 (PDT)
X-Received: by 2002:a17:902:b10f:: with SMTP id q15mr10497223plr.257.1558056384680;
        Thu, 16 May 2019 18:26:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558056384; cv=none;
        d=google.com; s=arc-20160816;
        b=JT9zXFRGY9qjys/jNdQPVjDxpqxliOLn4lDQCdMQOaNy+C01XrhfUqbLfPuhTopZxH
         1s2QbBnpfED8Q8KCRSxM/Q5I2W4zSXShMSEqPF0Q4z+3UitjEWpIldcGKjwMunL4RSnN
         ZxPCzeqRApB0XL3QQr//FwIOqfLKWJldyBfRoekVcWa3dHfaMwATqRlQ+THO+p/52+XZ
         /zf5Y+fDTV0C8zxHKY+uMpiW8p0YYpS66AULbYBAdWmG1UsW9hJooR0BP5wUC+u3A9TW
         DMTk+Zqm1tdngsVbdgcZdUozX5UNZAT8aiFbyyJuaWfF1H9DSpTKizyczT08MCSQHGd+
         iqbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=+cJ2gxhZLau5gmuenPlTtxJhsl5TXn8iu9yGe1AQQrg=;
        b=0pUEdOr61mqs379UpYLSd+RovETYJ3e3KX1w5s+3QtCCFuuXdTABLSeiwi6pLY4GWU
         uQ7nIjDzF5CgZiecVitZX8uuFfxj/hawSp902DdHQa6L0MGLl+zxBLkvju5mLPSHkyD0
         1pJcuH1LVZj5AIY8uh0AaSEuKobomWnKlIDIcvsBwcKkcJXBKyxphK7pc9ZO8vVubd1O
         LD2R5a8MZM22kfYA5onVwSAD7ujdLYLYR9FFdFfAS1aW49iBqFQZuAkkdkp8vtDCLfs5
         H61d9u0usq/P5uqPoy7y2Fujft1C14qs0xCsC2pY7Y4gcQO04LYk9Fy50MU/8D6z+0Hc
         qEfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QNQxNc5y;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22sor7083621pgv.49.2019.05.16.18.26.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 18:26:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QNQxNc5y;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=+cJ2gxhZLau5gmuenPlTtxJhsl5TXn8iu9yGe1AQQrg=;
        b=QNQxNc5ypRwtdFSH6HpSYR0MThc0HpZETeuvrI6NSQk2We0nlIfd3RF8xLG1Ydb5Ni
         C7l69sF2b+zwXTu+27LDKNH02FrrDRkffXWwiX6s9n+JvtV+SEbf828xWCOVEFv3hlWv
         U1gbvwBvIrttUqNQjSQ0XLYWgiKZYmbIip2B8=
X-Google-Smtp-Source: APXvYqz3bg5gRNoTrwMyo5+vXZ7qa4nbJU852Lnd6zCfw82/d5ftsiATgeUm4vLixEXP76pwv/yJLQ==
X-Received: by 2002:a63:1a03:: with SMTP id a3mr54079259pga.412.1558056384345;
        Thu, 16 May 2019 18:26:24 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id u11sm7829530pfh.130.2019.05.16.18.26.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 18:26:23 -0700 (PDT)
Date: Thu, 16 May 2019 18:26:22 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201905161824.63B0DF0E@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-2-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 04:35:34PM +0200, Alexander Potapenko wrote:
> [...]
> diff --git a/mm/slab.h b/mm/slab.h
> index 43ac818b8592..24ae887359b8 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -524,4 +524,20 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
> [...]
> +static inline bool slab_want_init_on_free(struct kmem_cache *c)
> +{
> +	if (static_branch_unlikely(&init_on_free))
> +		return !(c->ctor);

BTW, why is this checking for c->ctor here? Shouldn't it not matter for
the free case?

> +	else
> +		return false;
> +}

-- 
Kees Cook

