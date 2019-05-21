Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C749C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F8C0217D9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JYscqSP1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F8C0217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2C3B6B0003; Tue, 21 May 2019 14:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDC596B0006; Tue, 21 May 2019 14:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3BB6B0007; Tue, 21 May 2019 14:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5BE6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 14:48:59 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v144so8969470qka.13
        for <linux-mm@kvack.org>; Tue, 21 May 2019 11:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Brh6Wum1Zthj/uQ2mtyHFIq9uQlvrAXKSZbEsVapKL8=;
        b=ddkZ3daKuQHzsE1MNDEtoeHNvYgroUwaUVvSQ9xc8/i8m206XCG8SCMQjZ2XJbwc60
         7IAb2q0p7xKGiOTmCEcMAp9zg6MZHzzMKQJ6g2BOWZoAXZU2rA/XZDJd1m87NblpmSMi
         qi1dYGZ0i/vQfNbEm2qDewlaI45X7Uq0Qgtnq4wpfp/PAi1d/LW1OVVQU7nR0OJFWMYR
         RRO6+t2ic1MSvaX1iem5RSuxKwJAuXP3npb0tFUiXLVaoiWIvYA8rMGn2GpkVVSL0v2H
         AawPVEGqtfVu2tpBoaPi4of4HgtQfqFZF8YDMV7CT8iEXW08iYs6Gp8q/BzGoHVmD04j
         XcYA==
X-Gm-Message-State: APjAAAVMtMlGf0rgBxhqTMQ1RXGSCyWeeI7ACA6UhB5Av6+VVunsHtE7
	Uktc8nAywWa3zr1EKn3sv7fYCz4otNgi+AnUeP/2u3IeIWwQ0fAdBuhO+pMsnQcpgQ97T9NuVPI
	U9yr/6DVdAW32PT4W11j2HPd01H1kYBcMXhFrzcf9t6GSFCOFCjJExeXp6s4yUsa98A==
X-Received: by 2002:a0c:d4ee:: with SMTP id y43mr66943733qvh.26.1558464539410;
        Tue, 21 May 2019 11:48:59 -0700 (PDT)
X-Received: by 2002:a0c:d4ee:: with SMTP id y43mr66943677qvh.26.1558464538902;
        Tue, 21 May 2019 11:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558464538; cv=none;
        d=google.com; s=arc-20160816;
        b=NIS4SO3/OydlNchGnAzLLkzk8mTjzKFN5yl5u2yJoIrAKj/1lVa5UQaGMBFtK9Ph0A
         QiWUwIBpQ26a9EpCn6VjVi+Rs00eZAQ1KEYtYevMuyY1B/icq8uSaNhPxWzAPUpVN916
         bQeohF5D1gUG9ce/5vnIIo2YIUnP4eha7AUt/sESn7tv7bN0XAEYw7p6pMPo9GDx3PGN
         0IaNgo9EKAHuAAibHSS/q+fNGIH5FK380kRSAZBC2MQhmYgUAlaIgbFxjYXuIZyL0mn4
         ITgJCEYpJdu4iIFrLFXEmuxXRIstiXiStB25PA74qdNEwQaFOzIoKXNCPVcttCXH8Gqo
         c4qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Brh6Wum1Zthj/uQ2mtyHFIq9uQlvrAXKSZbEsVapKL8=;
        b=SHHO/3VvPI92O6Negn+yAnIuK0E9aK80mI2WgH5STZwiGj6Kjo+OKe3xG4nxSaIHB2
         RY0ig8OJS5MOhINlLu/mfMQJkV+DIZ0wJrlQaMod/8km2SqnBq4JrmmcBVe+dsWrPLwk
         j1Hh57Kjh8CyyfaxPziNYb1QA7q5gWZxXsddDeGkIYJjrxm3Rvb6AYzU4O3WU4Ilrhpo
         GPdzkSA9hyvfUFgZf81OdQGTy0n9pK4U9lgaD0k8C0S/KlZsJkXjCovYQed/ou8QXXwW
         hnnOR/xpKfBpYkvTHwFeb2DAZ+/GGP+fqYuQ4n8VBdz1IgwKxKWRTQCbtUjGNVRY1coo
         UNoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JYscqSP1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o26sor10658497qkm.24.2019.05.21.11.48.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 11:48:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JYscqSP1;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Brh6Wum1Zthj/uQ2mtyHFIq9uQlvrAXKSZbEsVapKL8=;
        b=JYscqSP1HPPRVqGuMd5owD3l/IDlGmL6FFL67m798Jm2AP4qGcOTqtawfRNo+5kAFu
         iEJ0vUz9qOZ+rvajt/fb76zKILX2m7sPHzCjQLxU/xpu8s+X3lkRy9CgqtNpDaf0XFJu
         m/SIilww4DfdKs62gi8wE4MGevsPrJgDS2TyvhL/7eUtavobHZ7DqCVwKBcDulDJUjVu
         MVt0CUr2fUDTtnd4Vvag66g4rnBT/cZ1xH3t4yZwYbfafoegD76V6HRafoLD0R1dZ62Z
         EbRvObIPEul9wb7eEhcBGsIGomq6YRkOd3NfdawsXW6Hn11cNpJ1sY5CjCpDM4tjfGZL
         aezw==
X-Google-Smtp-Source: APXvYqwU77tWKnZY68/uvl8nI3fxF+k0K8AI67X6RVtQAbCKMK/pPRLs+1/gDbqNIuNCiuScF9EnOQ==
X-Received: by 2002:a37:358:: with SMTP id 85mr63206066qkd.174.1558464538599;
        Tue, 21 May 2019 11:48:58 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id u2sm5545370qtq.45.2019.05.21.11.48.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 11:48:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hT9om-0004QR-Qs; Tue, 21 May 2019 15:48:56 -0300
Date: Tue, 21 May 2019 15:48:56 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
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
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190521184856.GC2922@ziepe.ca>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517144931.GA56186@arrakis.emea.arm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 03:49:31PM +0100, Catalin Marinas wrote:

> The tagged pointers (whether hwasan or MTE) should ideally be a
> transparent feature for the application writer but I don't think we can
> solve it entirely and make it seamless for the multitude of ioctls().
> I'd say you only opt in to such feature if you know what you are doing
> and the user code takes care of specific cases like ioctl(), hence the
> prctl() proposal even for the hwasan.

I'm not sure such a dire view is warrented.. 

The ioctl situation is not so bad, other than a few special cases,
most drivers just take a 'void __user *' and pass it as an argument to
some function that accepts a 'void __user *'. sparse et al verify
this. 

As long as the core functions do the right thing the drivers will be
OK.

The only place things get dicy is if someone casts to unsigned long
(ie for vma work) but I think that reflects that our driver facing
APIs for VMAs are compatible with static analysis (ie I have no
earthly idea why get_user_pages() accepts an unsigned long), not that
this is too hard.

Jason

