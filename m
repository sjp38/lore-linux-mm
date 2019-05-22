Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E57DC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 14:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE88820879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 14:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE88820879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B3C06B0005; Wed, 22 May 2019 10:16:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68AF56B0006; Wed, 22 May 2019 10:16:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 579F56B0007; Wed, 22 May 2019 10:16:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 097D56B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 10:16:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r20so3841229edp.17
        for <linux-mm@kvack.org>; Wed, 22 May 2019 07:16:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=73SuxDyavW+O+7Kca2sOpTx56wKPB8p3EZy2+QcZCD4=;
        b=ilG6N9GU6M4uNsa2Xyp7hIjtNxc1dqtjirif4ldY4PHahveuYUSmyJKoJ+sRGig5FD
         cH3t2VDIZQiuuWJoaeBVTw91lIGOiEN0Drt60hdZNjbwkRu3agvF0p3kDyB2WRgag5qO
         05eySQ1/eER2PC/0/I/p5FxkdipSiS8cCOy8leBRArKxCgZ/6rh07KIxjaTFAC739Qxv
         8RxPCDPFEWujyp1qR3P0vFJFZkVE4yHXlTizvM66UixtVBw5foF7QJRwsJkdImnQYT2I
         sg7E71bm7D+YBBjK0y7zYbCjQZDXeXiaFQ7C3iuyuqyKnv8+R8xzBa2hG+ASWvW1VRAF
         3zTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUB0cuA+QWX3QphAxJM7lZB2WEHlXbMxYaABzdWLYvDJpB3YDlh
	B262vUKQWmtWR7QegRPdAI5i+wdnps7U5wdRoSFfHopfnjCuFPB1EO9r8uoZ4MMOHRzNeNRirEj
	fBGRkmhhVlmw5K7WXsfMSUQa5D5SvY/k3QiiIl0jE0rOIZS6sywsD/Lk5ViHp0OlIug==
X-Received: by 2002:aa7:c0d3:: with SMTP id j19mr58629148edp.179.1558534583597;
        Wed, 22 May 2019 07:16:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy67mWBQ4vk96o1amU8eiHYSTW7zg8LvkOTJ+U8KS/JUAYB5VyROg4F9ScMoklaw0BPSc+k
X-Received: by 2002:aa7:c0d3:: with SMTP id j19mr58629001edp.179.1558534582215;
        Wed, 22 May 2019 07:16:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558534582; cv=none;
        d=google.com; s=arc-20160816;
        b=iUEZscBI3Kwr4WsVRTCYWh9xVis4i6PmaP7/POvduoFe+ROjko3mtE4wQrWPiGoFqm
         9ABAlimOztAVSvP6+sVmacFEWyvSDbxowlOAtRZWP1m7dYeuZqEit8yIqVtAFDDiJ7Ad
         dggIAwT/gG+2NxrSugGh88FntDf18qmx7oh4XfC5sSndqPty7wSa3S7/LctdY5w37n+6
         MXyH+bH32KHPxZYB5BIqS+MdYvPBIa6Pc0pTTCaZ7YrykHhGX0GaZ4eG+NaabgVEJMls
         nL2KX1Ru4qRudt9NEqyaHuNMMb6LTGFzEi8FFz2jTnojlkWsCeTFoQvwM31XCHjZ9fjl
         Y5oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=73SuxDyavW+O+7Kca2sOpTx56wKPB8p3EZy2+QcZCD4=;
        b=u7U9V6itr1cHQ7gkYiZQY3mMMMqVpg2XqX78tSlAPWPeIn2bsfklEHA+cw5CRfk0Vr
         vSR6uUVWdRmjyZOBWuA+spuzKOQrydOpBzKXl5+U1EkZFS8ztuNCSNvF5zfOmzPZ++B7
         cB0OaSJl2LAiD0Bj6LPzVbfwr2CIqowR8Ng5wUbrCzT04JbEGp9DN/9Fg5IK1OlHxfvO
         qnSy8fXT47TOYZVHpIKAXZxrICz7nSzXjEEH36rEtaRrvNthO84bQjxz4dyI/4WdNdx2
         35hYIaraDNtadVCEgHDvOHZ+8CKvOI0Zxs24y5L46k4ybb+9lmcRQGwlSyWVwWtWIqh/
         pUPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 26si3252056ejn.294.2019.05.22.07.16.21
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 07:16:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E408280D;
	Wed, 22 May 2019 07:16:20 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 57C233F718;
	Wed, 22 May 2019 07:16:15 -0700 (PDT)
Date: Wed, 22 May 2019 15:16:12 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 17/17] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190522141612.GA28122@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <e31d9364eb0c2eba8ce246a558422e811d82d21b.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e31d9364eb0c2eba8ce246a558422e811d82d21b.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:31:03PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch adds a simple test, that calls the uname syscall with a
> tagged user pointer as an argument. Without the kernel accepting tagged
> user pointers the test fails with EFAULT.

That's probably sufficient for a simple example. Something we could add
to Documentation maybe is a small library that can be LD_PRELOAD'ed so
that you can run a lot more tests like LTP.

We could add this to selftests but I think it's too glibc specific.

--------------------8<------------------------------------
#include <stdlib.h>

#define TAG_SHIFT	(56)
#define TAG_MASK	(0xffUL << TAG_SHIFT)

void *__libc_malloc(size_t size);
void __libc_free(void *ptr);
void *__libc_realloc(void *ptr, size_t size);
void *__libc_calloc(size_t nmemb, size_t size);

static void *tag_ptr(void *ptr)
{
	unsigned long tag = rand() & 0xff;
	if (!ptr)
		return ptr;
	return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
}

static void *untag_ptr(void *ptr)
{
	return (void *)((unsigned long)ptr & ~TAG_MASK);
}

void *malloc(size_t size)
{
	return tag_ptr(__libc_malloc(size));
}

void free(void *ptr)
{
	__libc_free(untag_ptr(ptr));
}

void *realloc(void *ptr, size_t size)
{
	return tag_ptr(__libc_realloc(untag_ptr(ptr), size));
}

void *calloc(size_t nmemb, size_t size)
{
	return tag_ptr(__libc_calloc(nmemb, size));
}

