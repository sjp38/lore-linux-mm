Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C65BC31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E478820833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="H48R91d0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E478820833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C5BC8E0002; Mon, 17 Jun 2019 18:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 776998E0001; Mon, 17 Jun 2019 18:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63C4B8E0002; Mon, 17 Jun 2019 18:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF188E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:10:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v62so8592650pgb.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:10:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jI04jBYMNTBh5tIaHpUZSwoLLRQfG6CVjh1NE4vfmF8=;
        b=QDAicI2jHfEKYsTJ/FjeGWL3Rzcogt01FeJHhTy7zb8W682+PCAs48D4xpyqtilpwm
         r+7dbQPC2uFaviBEbLI5bqtd74TN8DkCZ/yZDaUj3Y91omGLl8cN0v5/empmOQM1hmOg
         L6uCX234TkncLrsGm4gvImM5cDXL1AVGUcBSPBynnDx1AGJjssly4+r+CvmdXblpNeMt
         eDsDs6/xleCq0w0tD+uP0rN1J2fOJkraHGNN6/5ecFU8npj0fdOmThRr/t3aORQ9r/Ev
         GHcNIpWsbiVoNkbojuDKfmqFoUEGbwpTGW2wKmfJGoZyh6xtUPVhphPodBIYcNI5wgSj
         UcAQ==
X-Gm-Message-State: APjAAAU+tIH2Jcic+lnNJz4WUOFalkDTVXuxKfHyMqgSanYW5flv8lGU
	8p7iZ1ECC0KOYo9pBfeWnLZb20LxDYtZcrhDEvmJ4Y1hOe4Ctd0fTU7iptgzapmXbdyeyFaJuJL
	m4Ejj4FK8AcfK+hzdccQExjxcoBIBhRJrf5yTj/URXjLGf2nt6wSdWJdALxg74Qhhrw==
X-Received: by 2002:a62:b40a:: with SMTP id h10mr117647472pfn.216.1560809429794;
        Mon, 17 Jun 2019 15:10:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJeErNu/S3cmAXbdKhP4KIW9xqVli8FMozNlIdxSkHcddJIvYFySzoMfVUgGguLI5elvNB
X-Received: by 2002:a62:b40a:: with SMTP id h10mr117647412pfn.216.1560809429211;
        Mon, 17 Jun 2019 15:10:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560809429; cv=none;
        d=google.com; s=arc-20160816;
        b=fHBv1xR00Yrx0zpCSEwnm/Mv4LjrBIPagrv/oaRbl+1R3TpJEbz9xvWEy2b0fOM4/o
         g57142bBMK2brwP3gSbM61X2W9o1U6TW/ux+vx5/lFZIPnyuJaFXlvgzLoGviR9A9S2N
         RmfmQzCyPtqpsoGvVG39redV9rLHgigxamVNBc5TGd8rZNbqP4TZ57kFRfcCYeTFrUO5
         bPitT4uXkdXA1s50uYEEEJ5mZTiJ61vVYUsmQaFHIhY8P4nv2ZgoB0aXI+MDCtiTEIPh
         zulNUnwZmKQgrX9TiEBMa77ilsLspQY2PV+mRphM1z/VDgdapxZDBt5ZEzCYMZYBQhOp
         bx+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jI04jBYMNTBh5tIaHpUZSwoLLRQfG6CVjh1NE4vfmF8=;
        b=qvK5dj5/iLy62MWA5vAZW7hGN0/xc1rU8l39R+eGvzCHxf3qHHt2OYY7wzx7LRgKAV
         v+BEHjJo1naclvfTD/PKYtmNn/cCrlU8/m4ULcEjtwEw+k0mnXPQOtGQXGXIt4hKPvn3
         JTnwtPIRSR3RuO0EB+N/hPA9Z4c2HUGLkTO1Mt5PlPsqKz9kCip4w2HOdBs64RC41NiG
         XvTc9opT5sFyN4bN3xpuZme+7rBaCKhB4iqvbAfDhkg/hZCkTpAJHvmcWoXQ7HOufUFi
         SG3Q2SUcE1getdU69Hruhgv8aKnnSyXJG9iwvQqtC+Cojspvw8X4wHmoPEtdxGKy1cwH
         TR/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=H48R91d0;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u38si11807153pgm.538.2019.06.17.15.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 15:10:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=H48R91d0;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1C63C2063F;
	Mon, 17 Jun 2019 22:10:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560809428;
	bh=6hk1cXgfeLMtsbZeOg0ZmMrTcg85OizuNzmzx7hw5Qk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=H48R91d0qMOGPYc36iLZLmJlRYEKAuboBC6PlZ9ejBJSJze08FWJ9JVor9FNIsA7u
	 lYq2c89IGdozntcAfBaEyx4Rd8jMHeGcEzDqBs2fxtvbpqhd0ZqIb3uoby3nU4r+NA
	 QC6TyqKkmVl9RQzC6UReWmI4QGQ4j6deJdV8sc14=
Date: Mon, 17 Jun 2019 15:10:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko
 <mhocko@kernel.org>, James Morris <jmorris@namei.org>, "Serge E. Hallyn"
 <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, Kostya
 Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep
 Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, Randy
 Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, Mark Rutland
 <mark.rutland@arm.com>, Marco Elver <elver@google.com>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-Id: <20190617151027.6422016d74a7dc4c7a562fc6@linux-foundation.org>
In-Reply-To: <20190617151050.92663-2-glider@google.com>
References: <20190617151050.92663-1-glider@google.com>
	<20190617151050.92663-2-glider@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 17:10:49 +0200 Alexander Potapenko <glider@google.com> wrote:

> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)

Sanity check time.  Is anyone really going to use this?  Seriously,
honestly, for real?  If "yes" then how did we determine that?

Also, a bit of a nit: "init_on_alloc" and "init_on_free" aren't very
well chosen names for the boot options - they could refer to any kernel
object at all, really.  init_pages_on_alloc would be better?  I don't think
this matters much - the boot options are already chaotic.  But still...


