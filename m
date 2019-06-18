Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ED7BC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:19:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 192182133F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:19:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zpPILBBC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 192182133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A58108E0003; Tue, 18 Jun 2019 01:19:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A079B8E0001; Tue, 18 Jun 2019 01:19:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F64A8E0003; Tue, 18 Jun 2019 01:19:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A70C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:19:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w31so9151387pgk.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:19:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qwHIIGGVG4aydMeLILDpLbrlLeDQ3UePfyX1VlwOqW8=;
        b=r5c0vRnpSDKmvSEzIYUx+jRr7ce1SxoGZ6Ip5tMEmw/F+7EfLwvUaPnSo90EwSLF16
         p9tDdFIXy/cw3nSOimzrmITz9jO99TrFnqAfPBLOKJIwUIDerdloQx2sVVJZ9U9WDa6L
         Dj+keyBT01JWq1yse8Rfxw1lka818+rCzSSu79JDwWSrcqUaiWV6gRSdAQ4rICgzI54T
         /eK57JVYcTMTCEAkABWtW6l+03hmJFUx31+UY7x1EkBbBzGP09MaBDDUzWTHegt85Fc8
         Eg4s34aC87EjrpKVMt/4zRpacUEM4fswcSnJ7ccn/XfTmHW9+Qgbm0s1Pc6k5xhkLGdq
         Iycg==
X-Gm-Message-State: APjAAAXYrPPz6p7c6/JN4r8JfU/LIj98Li175iXN4n6+bNT/3ONnZnKy
	j/mky1o5fpfqGw1k4rDYB+4u4wHoEdbXVTaUV2F9A3tx+pYlLYmVqJNRsp0B2EgGDLRwF5b0LEH
	ao1FnDu9LhYPKqy8K8HtYnOO21Oy9iwx/VpLKkB5e9wc0Ft3bQ4cyK7sHI4GndTsPrQ==
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr3075204pjq.64.1560835174861;
        Mon, 17 Jun 2019 22:19:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwg5luDh9Gg1KqKXz9gyE7j/GRwLeEFXhFnZCiRFh2u7vdOVb5QuuStx2rC9Tf07OxuNjt4
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr3075176pjq.64.1560835174233;
        Mon, 17 Jun 2019 22:19:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560835174; cv=none;
        d=google.com; s=arc-20160816;
        b=kDMipbaK8eEK2W/oyFEeOi+BQz2ik9btta1iNBs3Q7WsJvKwblDZM5xuVr46BlFJjz
         H7Ms40Yc0ihsQ263b7clw1pvYkEhKzYZnILftLotyHTB5Igu5+QrtG46w2eXcSoR8oEW
         Ad24VX5N6lhAcov6giDifX2OztWOCNzzaC+PGTvHKFn5MebVjn5iFE716qJhGBPh5K4b
         s6l8Hg0+Rsk5MZHSVSrEi6u+ncF7tXIErqYg36+HAFmJ2Nj4vA04Rw0fSzUUbHKPZIw+
         /2dN9OmuWJ5rGLkkSQrLJDKDcdeIid2f5eN7lnZujNdcnnxu70F24aNwDLNbscSp+kMM
         c0cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qwHIIGGVG4aydMeLILDpLbrlLeDQ3UePfyX1VlwOqW8=;
        b=LwzboIEppjSqe0h0whwULRv3zd1CPzehCW6cyoaD6YMBNMx1KTfUz02iy6SpOiRe7k
         /N5GjMrMKbPZ/S0VtJqu4O7aIBpvG1VPqXW9oY25uxbMAIl4ZFPtm727QLJeLVefVgtJ
         X2RttCVy5tLYwOTZM/pEkpS3itIxgYq4krFBX2sP5hzvMxuS/49b/5RRhPgnFynHtzZf
         IgSSsMWfsGEa+kO4L/6iJAsYg8tUEZaDGkSnsBS3uN00uDexruMhsj14S91Krg2Pz8sS
         EFo2cyaL0D7LI8CLccFFX0Lz8nuqKe+nBptQFM13LuYr0D0rV4TJY3Kbs4IKixfb9nCc
         oMxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zpPILBBC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m12si9463004plt.413.2019.06.17.22.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 22:19:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zpPILBBC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 097272084D;
	Tue, 18 Jun 2019 05:19:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560835173;
	bh=D6idtN2vuJNZSoRrBJEbsCDVqnmpSZdTylzmezC3ViA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=zpPILBBCAqMR9mMbYvimRhFwP9kZjL2AU5MfjZJzY+WvSEkteYVoW+sbq7pdcFPzw
	 7gcuAso+EV/aRtthzZDjhBmjrmxqfdLWq9frm+edibB8kMEZifuHcKNvThHI+539eX
	 cWp7GyxgMkZgpW/SDbOJ6lRDGCDBgF5xmFGDc2Io=
Date: Mon, 17 Jun 2019 22:19:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Christoph Lameter
 <cl@linux.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal
 Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers
 <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, Dmitry
 Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, Laura
 Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann
 Horn <jannh@google.com>, Mark Rutland <mark.rutland@arm.com>, Marco Elver
 <elver@google.com>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-Id: <20190617221932.7406c74b6a8114a406984b70@linux-foundation.org>
In-Reply-To: <201906172157.8E88196@keescook>
References: <20190617151050.92663-1-glider@google.com>
	<20190617151050.92663-2-glider@google.com>
	<20190617151027.6422016d74a7dc4c7a562fc6@linux-foundation.org>
	<201906172157.8E88196@keescook>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 22:07:41 -0700 Kees Cook <keescook@chromium.org> wrote:

> This is expected to be on-by-default on Android and Chrome
> OS. And it gives the opportunity for anyone else to use it under distros
> too via the boot args. (The init_on_free feature is regularly requested
> by folks where memory forensics is included in their thread models.)

Thanks.  I added the above to the changelog.  I assumed s/thread/threat/

