Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70811C46470
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42B6F25DD8
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:57:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B6F25DD8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12A76B0272; Thu, 30 May 2019 12:57:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE89F6B0273; Thu, 30 May 2019 12:57:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1C36B0274; Thu, 30 May 2019 12:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFF26B0272
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:57:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so9445656eda.11
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B2oydY6EDLW2e8l1QPp/UzpS1nz+Me/Whfpt/lxI2zA=;
        b=k16nmmira+BKgtLeb/6yeaVTWL4HbF1JhpuVniBCVKctOHjEUjlUGH6R+ENcKpKYa3
         lFoeH961yzdZoogrNXb/hF3OPxUSp7UBzVVA2Sb/W/mxZQoHDiYMjZdGpQ8+TGRGpmhZ
         DRmK1HSYrXONDoNXR6USWyoZTU1bE5hYxYElQ3s7lBeuveA9ez3ILvmeIiTWzszIXewW
         C574E2UTokBSIhAtvBAMS2ZXX8txnzZVVNrwgV/imWYI/mmLq0sqV3fjfua4Ce9idOtw
         llmeuSdicJsw/XxU/nFeoBCGBV8oNOFKc5yTKqxr8+9KIuogH6BcU0UxJs4DlXz7kX7Z
         z2Vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVZY1XdwN+3H3JAlkVQGGHOzcEZxLTkIyJghAIHbp5FyIB+RL17
	q14THzVsNXGlC98zGNXsQ21c2qDyThKqFrduGoe35L6P0epeOWbPSVSPUrLGQTJCZ+umR86KxB6
	82/NJmuhnWlqXaMyQXu/4NroCbOBZ+hZ+BW1D/QGfOMGHX8sGAy2ivNKC4Z9sy2Phng==
X-Received: by 2002:a50:918b:: with SMTP id g11mr5891004eda.24.1559235449046;
        Thu, 30 May 2019 09:57:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmUcOUnAhcV74i9C0t8nw2NAH8Z3J+GeSW6DRlVy7DF/QOHYyBKjd/jDIpY+yk6Ao/6Gi4
X-Received: by 2002:a50:918b:: with SMTP id g11mr5890912eda.24.1559235448002;
        Thu, 30 May 2019 09:57:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559235447; cv=none;
        d=google.com; s=arc-20160816;
        b=IbQpPyw52q2BGTn/A8K4OzWSycmgMESwFfkUMUo7ImX94xO34CDPuJeckRy9tBoJrY
         uZTx28fyWOyFeoqROQ/g0S7vuU+Cz5Gca3IO+mmiOAl6JRq7OtYlSlUtAcwnybDKJXN6
         oyWZB3Q+Xpx71Mzq/ER5Aln3dFHzmaejtQMW/QUio+4FjyymD5lYyKBepFaQliEMHx5G
         jLwaaQmP7RNqnV9VXMcuzd4L5df9kLo1qRuGSngFOa40y9HFVbq4rvQ5sfJuhOHZ1oD3
         Ahqawr4wL3iobXgLbh8upwBi9H9pZBqusCpM71+QqD4E75pkHDqSk0LNHk7BHM2Axl24
         LcNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B2oydY6EDLW2e8l1QPp/UzpS1nz+Me/Whfpt/lxI2zA=;
        b=X/QJHRAhzKFVtTlvY3o1vAI+jqTG1jQ2KBdI6mIOp3Y7HOpvweFGBPJXsM4Ab1g3AC
         LW//JGz+HeoQDqahu916ISFEAmjdCbov13WBXBRQbA/4VMiKUo8Ir0kGD5hhvsBwEf5A
         i/kuhPKMkXO8k4YrELGrFRLz3dLAu7D7fZF+to4KmxAz73F9TZbdbV5PXw5/05BI4Iww
         zZQcoX4rouB1qhhlejSRlphms8k9yst/wkIsn2zA5T9O5J0p43sBfTDSe1s57YrvPrSl
         rMdtgTDdSog1JulRBHfvs1E/dsDR/i3WTX5c99dY0qf0Bps2VQbQD3TV7FIdP1FZ+MkL
         b1qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a39si567253edd.216.2019.05.30.09.57.27
        for <linux-mm@kvack.org>;
        Thu, 30 May 2019 09:57:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B60E3341;
	Thu, 30 May 2019 09:57:26 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D9E133F5AF;
	Thu, 30 May 2019 09:57:20 -0700 (PDT)
Date: Thu, 30 May 2019 17:57:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andrew Murray <andrew.murray@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190530165717.GC35418@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <11193998209cc6ff34e7d704f081206b8787b174.camel@oracle.com>
 <20190529142008.5quqv3wskmpwdfbu@mbp>
 <b2753e81-7b57-481f-0095-3c6fecb1a74c@oracle.com>
 <20190530151105.GA35418@arrakis.emea.arm.com>
 <f79336b5-46b4-39c0-b754-23366207e32d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f79336b5-46b4-39c0-b754-23366207e32d@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 10:05:55AM -0600, Khalid Aziz wrote:
> On 5/30/19 9:11 AM, Catalin Marinas wrote:
> > So if a database program is doing an anonymous mmap(PROT_TBI) of 100GB,
> > IIUC for sparc the faulted-in pages will have random colours (on 64-byte
> > granularity). Ignoring the information leak from prior uses of such
> > pages, it would be the responsibility of the db program to issue the
> > stxa. On arm64, since we also want to do this via malloc(), any large
> > allocation would require all pages to be faulted in so that malloc() can
> > set the write colour before being handed over to the user. That's what
> > we want to avoid and the user is free to repaint the memory as it likes.
> 
> On sparc, any newly allocated page is cleared along with any old tags on
> it. Since clearing tag happens automatically when page is cleared on
> sparc, clear_user_page() will need to execute additional stxa
> instructions to set a new tag. It is doable. In a way it is done already
> if page is being pre-colored with tag 0 always ;)

Ah, good to know. On arm64 we'd have to use different instructions,
although the same loop.

> Where would the pre-defined tag be stored - as part of address stored
> in vm_start or a new field in vm_area_struct?

I think we can discuss the details when we post the actual MTE patches.
In our internal hack we overloaded the VM_HIGH_ARCH_* flags and selected
CONFIG_ARCH_USES_HIGH_VMA_FLAGS (used for pkeys on x86).

For the time being, I'd rather restrict tagged addresses passed to
mmap() until we agreed that they have any meaning. If we allowed them
now but get ignored (though probably no-one would be doing this), I feel
it's slightly harder to change the semantics afterwards.

Thanks.

-- 
Catalin

