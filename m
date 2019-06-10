Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A75C31E72
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:29:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19875207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:29:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19875207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6D9C6B0269; Mon, 10 Jun 2019 10:29:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1E296B026A; Mon, 10 Jun 2019 10:29:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90E206B026B; Mon, 10 Jun 2019 10:29:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42E3C6B0269
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:29:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so15673240eda.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:29:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9iDSIidXEtaLzuys3OmbjuCZ3PdApKCG5ooCupKyT+w=;
        b=sqJI82h4ho+21UMKl/m0dPK1PBUgPMiJBDChFtRrCIU91I4s24lsCMzbIrhGxaEojW
         x+22jp89FjI73WGjNrXKdRBYFsbNIZN8ZtvHAJ+27H3keQSxWN7J4IuhXkouKagDaGh8
         YcDlAk6DEOgu1fRCvk4cPPpWDwUedbghYlVmlORMbZQOryfX4jxk6JEiKCb3CDSjEYSI
         31HiEnTCpFUXwghGGlGONlPchJqvWenIx7BE/94ZpcgoV29KQC295Y0l7fBgEWjcq7XH
         S5P2MH5kP1YF2S3QcsVTeJq+jyfWQx0JrPOrqRmrLNrWwVmKDC7VR4/365OhXyH77u/d
         i2+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWvq4FzpQGfO6qXjBJyFR0Yw5k0t/zUsSzAL5eNpEVoh2e0Lu5X
	+lmcvMhSRALe8JitogDQANX3gEQbIHQSgA1zggPaQ2AQBHOyPcOH3q9beWolO4azWsilGSxAawp
	kRDaPOgseaZfYeHl1fF9+DaSLQCj2qRrUjm9DqrK4zbNEpmJbRbWa6VF8CbyP3RXhgQ==
X-Received: by 2002:a50:8eb6:: with SMTP id w51mr73723284edw.34.1560176985852;
        Mon, 10 Jun 2019 07:29:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYlSrlk3bmyfYccf7ypchh0vYzyWdoVZm5N1kY9zTzEdu/bWKvvGBfxErmkCaEr1Eyn7cq
X-Received: by 2002:a50:8eb6:: with SMTP id w51mr73723233edw.34.1560176985183;
        Mon, 10 Jun 2019 07:29:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560176985; cv=none;
        d=google.com; s=arc-20160816;
        b=QRadSKb4QY3AI37hBG8hB4B6dT1oCHKqL8C0BEMGdr0gNxeZrmCJ/HfvAHPu7VgVfN
         6qa8prncZSaXmPoYqWpAtQSrphH9EWC3jfXyD43j7zkGmCFjZrWcOaWAbYr2OvilruAJ
         d9+vzGw2GIL0iZ40jRg69Tk3jw2vC2NMNPMrqR03cEzXCVT56QhUMwU48N4dS8wH3pds
         FeVAxy+mtLUfMtkuoqHGLX2P7YmoB+YIeQoV4rEu1reJa+ASeN879Yp0BZKg4Acu2yJO
         fvBWTwNyqenZPXoNu0x+MO1jUpj44VXsiFynCHyVO6UX7E2RM0kyzUZgfxOk6CA6+AQd
         S2cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9iDSIidXEtaLzuys3OmbjuCZ3PdApKCG5ooCupKyT+w=;
        b=b5RCxKIFhSAm70pTEndlXFufM55HJCC49iOhhEpgl3YRuKikaGFa09zxm7vZKU7A3a
         kt7mIpbd89sr6gVJQxjnZtCyJcvRa4FV2/CcOFtwHsl5yGmjXmJHFpleXI4Yii9dr6Rj
         iS8G5Zdx1AEWO2v5TYVpXq0/l7yEAJSs/qEhA+rfyVbhNLrDiqxTAR7qViEp7/71UZrM
         T29stjdiuGso6l42XxUu8izn68CMcZRFeZW+rnx8XxlTa517DeqADmXsoIoXDBCyICBM
         ftFR/Me1vfwqml0HcoVY5CzdLeK0SronbGd8y2oFGaQjafXB2A+6Nyjjca02z0iXa+Z/
         3FBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v11si499941eju.325.2019.06.10.07.29.44
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 07:29:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5041F346;
	Mon, 10 Jun 2019 07:29:44 -0700 (PDT)
Received: from c02tf0j2hf1t.cambridge.arm.com (c02tf0j2hf1t.cambridge.arm.com [10.1.32.192])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 22B503F73C;
	Mon, 10 Jun 2019 07:29:36 -0700 (PDT)
Date: Mon, 10 Jun 2019 15:29:34 +0100
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
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 07/16] mm, arm64: untag user pointers in
 get_vaddr_frames
Message-ID: <20190610142933.GC10165@c02tf0j2hf1t.cambridge.arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <da1d0e0f6d69c15a12987379e372182f416cbc02.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <da1d0e0f6d69c15a12987379e372182f416cbc02.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:09PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> get_vaddr_frames uses provided user pointers for vma lookups, which can
> only by done with untagged pointers. Instead of locating and changing
> all callers of this function, perform untagging in it.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

