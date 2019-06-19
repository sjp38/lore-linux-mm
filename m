Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CA76C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:45:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F4E214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EvIEznAc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F4E214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAF946B0005; Wed, 19 Jun 2019 10:45:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E86D08E0002; Wed, 19 Jun 2019 10:45:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9D078E0001; Wed, 19 Jun 2019 10:45:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A533E6B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:45:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h15so11861370pfn.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:45:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8fT/vuEA7OU0dJVEYE3r7kPp1EiCp3ty74wiME2Ad6k=;
        b=QbWilVzInBlpTXHS+iakhvMS87my0UKqaBzTy9gQnQ5LJkLQhpxcQo/SktN3ghbHe4
         kuZeBNj9DHBY20dgC/HNbolq07v0PgsGem7I2mQixXndif4UrLmkZXVxkqxIESete1us
         gaMRXSV8sYBjJJxprsRq+9hR9wWrtBxGfVdlOlPzqN31/dpLRtWBsthBistgssKOa0Cj
         IeTJ1Cgge1vcHU2F5P7kaUC+VpuB/gyfsdtT8zVrwNpccb4RYi0fB0hjG4Gf4C4dhs11
         8AvthKKY3Un71hwlSZPzMStETk0DS6UhqCpw52KyVxLj69uN8W3QaS5w1K0Zf9TPwHdN
         o8xQ==
X-Gm-Message-State: APjAAAWcD8Iu/kNIItW1FunAkPQT2PPG1O7FUR4IxRdT97B8jO0Nfv71
	AEvvBVj/jhlrqvyonUlIjDElZ4WEdMGuuIxb65ndo+vz7+sbaAaL1VmzcnJpbzaU3juXujfW2fy
	3oTKBtGLhuX+BY13/Z4pRRAOPHDWzbUpqgtUvXCQDwFSt4o0sqKQ4ZvjJi6U0c7a8YQ==
X-Received: by 2002:a17:90a:9f08:: with SMTP id n8mr11718013pjp.102.1560955515298;
        Wed, 19 Jun 2019 07:45:15 -0700 (PDT)
X-Received: by 2002:a17:90a:9f08:: with SMTP id n8mr11717956pjp.102.1560955514571;
        Wed, 19 Jun 2019 07:45:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560955514; cv=none;
        d=google.com; s=arc-20160816;
        b=xLLQkKlPOgSO34uWRIMXBjC1vqkZxjKTaI234RoBNHm//T+iaFMap95fiKzkn9fglr
         wtBDL7McOwbOgyLXA7TSBirD8naHi/2N9lqMM7lh3iX8t3mNrrqPpzyUbJTQCqAf6tp7
         5yqgQA8ywoD7gRaaCMhixjjVAjocUdWfgHugZbWKkbaQSPXeFLaBw106RG8LxKX7jDzy
         hTYLVxqqpPDzRX2XEvzIHNsO+sSbA3fEXUe4FLycXe3pVPnPrQopUfP5oO7qBC6GOXPk
         sCkAXECRZna4dnh9BFjtPItbULT08ESm38iWJdKZt+PDFhhju5Bs36EeJK8//QZkyKWc
         ULDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8fT/vuEA7OU0dJVEYE3r7kPp1EiCp3ty74wiME2Ad6k=;
        b=BNSZ8Wp9qzRVJYRZO928K6cv+mynfM8TLCeaO4UE1Ha3Fl6tVF9ELxfgIi3MxmliLA
         aEzdie0n8T6Tvd09ZI1o8jOqJZ9qqjgSc/fEzbbSLQywmAJ8FJ9zedCGgdS2a1luShLq
         bY0wRVHvmWnaQOt0q0T/Ll2FxmszzGuV24U0XsgthgHPPC7QY+utNNrLoq2pjt54k25d
         MgaNo4y9iPeAjg58/74GF42fh7x36ERBmkcN8lJaQm0DJeMKDaG0vVa31BAnjIpFnT6z
         5ruoVuEKnhTIHjXV/vxXyUrK8bN8iF60C++GhqIFaSaOWHLH4vWL3fAIgqnuMd3PtJjY
         ezyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EvIEznAc;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f17sor2271901pjq.4.2019.06.19.07.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 07:45:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EvIEznAc;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8fT/vuEA7OU0dJVEYE3r7kPp1EiCp3ty74wiME2Ad6k=;
        b=EvIEznAc2XDTlXpBOjY12Pc2q1rIxcWk6U40JWRUJTQeG8doG5XM7cV9g4/aAvpAbm
         r3Vk1xob0ZSfzJTTT+FaHc9R0h1eLHkawgh+Y2HeR9XjGIs5zVJz5vVbm53lpriaFfb7
         WLyV/uAQNAYVDSY/FjIXmEn/qRI4X4yYKhErVQMtfpicAASkyevJQubb5nypERO8S2Td
         5b/ik5O20WuHwXvtTFgmOoa0CziwFqCIOtcjre2VZ/5fgyUl+9VVN5r0dUvXPdBUWYAX
         74ptz4qqjfqvUzObFkRm/Ek6sICgg7UMvCYbjzj6hCVv3sQaFa6vMFhwyadaNP4W/A/J
         GtIg==
X-Google-Smtp-Source: APXvYqxml1AJCp6VXxhzIr0ScKXgidc4P55u7fkRG0uKH1TmixS7V2epvHYKLjz4L0moJR3Tz7zj8BeYkr14oUMqT1c=
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr11521374pjp.47.1560955513903;
 Wed, 19 Jun 2019 07:45:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com> <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
In-Reply-To: <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 19 Jun 2019 16:45:02 +0200
Message-ID: <CAAeHK+xvtqALY9DESF048mR17Po=W++QwWOUOOeSXKgriVTC-w@mail.gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
To: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 1:43 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> From: Catalin Marinas <catalin.marinas@arm.com>
>
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve().
>
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Catalin, would you like to do the requested changes to this patch
yourself and send it to me or should I do that?

