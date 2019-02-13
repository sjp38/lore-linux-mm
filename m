Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2C3CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC38222AA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:28:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mTaZh0Lq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC38222AA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 144638E0002; Wed, 13 Feb 2019 16:28:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD118E0001; Wed, 13 Feb 2019 16:28:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAFC08E0002; Wed, 13 Feb 2019 16:28:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A96848E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:28:24 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 38so215653pld.6
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:28:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QmQjCLKll0HK84X/6EadtAaXsCgicqazfQEbsU1cSjs=;
        b=aDgYGEq6OoLSFAkOHfwI3W2pYSCtgt95Lfi241aTmn2sadGZijk8YqVmy+mY6lYnlW
         SwMn8DCaqMeSJs75wUKkoqyI+RK2ML5zJ3ViPwH+7KxCw0xu/8vLPHf4EFPW2LjrkbEs
         NaQdqZWRW9VufLl+9lSs93EzN/k4hB009+sh+vH30M5tof7RNtUr7D93NgWVmCE/1hYQ
         +vCUJvCXRFkt1KW0Pd4/FdSX8g9mNmTerfaH94R5jctG+Jx0LGrZAuFYqBY4Fd+pG5TQ
         Y4SkAeQJFOj2Wkk+PWPzW7DLB0nn1eU+8JpUrkcUNoRq0f/YwHa28X2MOu1T1lYWpYFF
         i5cA==
X-Gm-Message-State: AHQUAuaMZMnUIosFJblJShh2mOjTWhqNfWIKFavc7nMW7x3vh/eZMtby
	hSU7MISfhg3GOUr6KOER7AojvWCvKb2yPXxpn6ZUccdT5eq+9lzgrubRFTaaDfWQtqT2nvujhK7
	DyN9goemB8LEYll4L0KxVkEqSPrEYSPgZR0uKFWDeHINHBJejOeokFkUdI3y2QCCKZmPuawaL1P
	w8jHgK/L2Ter11X16ez21ShFkYOxbaBME6YLq4OnP5YiGdRyDoGg9c9ObLWgoO+Ey+GUoB2tCdk
	AuF/vNfUkjo6XdPT7tPvK0fTV8Zi8HPeljrVtvlRmrgueC27XvljAkRkN5eRIdc2rROg7dOUdkk
	WXplRvcG9zyUDyBAtHGHJAZXeGennT+52jiiVeo4bBxq0OXw4YuBoKLGGUxsmBfg4jEDN2x2Qgb
	l
X-Received: by 2002:a63:6881:: with SMTP id d123mr275906pgc.10.1550093304337;
        Wed, 13 Feb 2019 13:28:24 -0800 (PST)
X-Received: by 2002:a63:6881:: with SMTP id d123mr275875pgc.10.1550093303612;
        Wed, 13 Feb 2019 13:28:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550093303; cv=none;
        d=google.com; s=arc-20160816;
        b=qDq7goX4M6DpnF+XOu6p3BOAiY8HUoyj/NT2QDehkhMA0sm7Y8Hncy9ML/kPTAzXLy
         1LgvW/kS2A8r2+pMsGkpY11XiWIr/MmbHWUP4pnuPde50D/JznztG3LU/6+Rj5193WyN
         sHbpGeg6I9Z69C4tZGCREK5r8V+legHIFZrhR55YMZUffZo1XCDDMsNF2sOyoYl483LA
         G2Jvo/n991Le+DrsOWHApsGfhxpiZOiiEIUpSdMnLTao0hX/uL+vOoKsZWo4jZsNisSC
         4GV0zIoDjbF0IGjzK1CZVNs2xcLqZ5JQJCXs0aZ+vixxjp06AaGOdIZc2eDnskjVqwuw
         Ya+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QmQjCLKll0HK84X/6EadtAaXsCgicqazfQEbsU1cSjs=;
        b=fvYLwASXLpX/ycna15398jXKo+DtXG3uB14aBpFLeCYj7G3hsVQCX9BG1E5W+B0Ac6
         /mL3migtfinjEsKazLp2mWoILIlPxcNdYFToclkEdZJxDCokQzwOZTFRyFxIrUCYv7J5
         KJbDt/aGpsEn7NgQupfNRY6wnlGYw7KgJcIhuKpA8SDAmAl380uhWxI3EGVzWeVCSDbE
         3q4HvJu7ZuZ1Gd8DNKDFbOr8xTQmduoRrm5vAx7kzzco+ENj8esfY7nHpAGJHmkxirGH
         +WgS8sW9ft+rB6e/tZBe80jxWeDtVveRTu+5LeqYU84TjlvNEHlL6QXEcVLRoWS/xbBH
         C3eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mTaZh0Lq;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k196sor673895pga.61.2019.02.13.13.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 13:28:23 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mTaZh0Lq;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QmQjCLKll0HK84X/6EadtAaXsCgicqazfQEbsU1cSjs=;
        b=mTaZh0LqJ9dy1I6SMciTBHhhYGYrNfaRewmTso8DrpkkJlJqpthKHo7+B5+GUo0sa3
         okYnjXoYvozsPw+oUPHg4VWnN0BCl/ovW9EG/T6jvzLXo82+kGuwalmW8vP/J8DrnP5+
         /LuSNoU0Wf1GsZg55eImGsBvZ7Ao6pp55NVV0fsg0RyBtIfaoG/xuspwjCujLs6h5Xzk
         8tprRR2cwbMqKtbBiRIOmgHC5sT8A4GWJRzx5KLLRVX1n1jeii82/vx95OEjcU2yginY
         WkUdDg4Rq2dkxXKMY4I4K7k5LRdlOhFkFHMQOflhySUMTtPF5Kkd2ldO/FaX5PwefTaW
         CsnQ==
X-Google-Smtp-Source: AHgI3IaqfAFAHULRCkhj18lAICwu4iljtEaal/xdgw3FkxfzCxymHkc7FtydVVb8D1mItBL9amRlrw3t9qwX7656iK8=
X-Received: by 2002:a63:4706:: with SMTP id u6mr214977pga.95.1550093303008;
 Wed, 13 Feb 2019 13:28:23 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550066133.git.andreyknvl@google.com> <20190213124159.862d62fd5dba54da7b46e3ea@linux-foundation.org>
In-Reply-To: <20190213124159.862d62fd5dba54da7b46e3ea@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 13 Feb 2019 22:28:11 +0100
Message-ID: <CAAeHK+yc1ka8YttKu86LCedFPcGn_8RtRRzsS+v4MOe=vLRenA@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] kasan: more tag based mode fixes
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Qian Cai <cai@lca.pw>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 9:42 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 13 Feb 2019 14:58:25 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > Changes in v2:
> > - Add comments about kmemleak vs KASAN hooks order.
>
> I assume this refers to Vincenzo's review of "kasan, kmemleak: pass
> tagged pointers to kmemleak".  But v2 of that patch is unchanged.

I've accidentally squashed this change into commit #3 instead of #2 :(



>
> > - Fix compilation error when CONFIG_SLUB_DEBUG is not defined.

