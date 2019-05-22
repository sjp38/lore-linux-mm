Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C104AC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 12:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F2EF217D4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 12:09:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F2EF217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F66C6B0003; Wed, 22 May 2019 08:09:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5FA6B0006; Wed, 22 May 2019 08:09:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16ECA6B0007; Wed, 22 May 2019 08:09:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB4C96B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 08:09:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so3366997edi.13
        for <linux-mm@kvack.org>; Wed, 22 May 2019 05:09:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6StKcRdj6zDXHyAH0twr0343ZUZ9bs1CVJn0ddD3Wk0=;
        b=LalKRyprh2AVR2Ex8sjtUK5CwaG+Sw1Zd7PodF0dqo5ocgfBjYoF8etZ8nhi2qDC7i
         led/oRALZZEUm48njzc1i1NfAHw7zXgw8K9nSp7D/A9D7rxF0p8IMRddjTChW6D7NLBl
         COl6o3vv8lLhXPuo6uZRDTwbyasZhJY2sSRHzLgUJVcxfFm77qYZ0w62SxMgrnAHPduf
         dJhxFXiYzSW+SlektO0ahkJwPjk5REBUzgn4oJlt8e+gh9zvTaa4xhlCIoww1/5NzS3u
         vI+ioYFgFimVfbOpnghtDl4K/YyEGRyhaEUkhjwnWV/MsVon+vuM7qin6xD6NcmgutKT
         iGAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU0b3QRapRIn6OPIlokQLQa92AEjQGIp+WrK/lSpecaxa1n+jh3
	USLT+k7NSJCgfeIw6HDG2qInWHCg5NjB8jLP9nUFBEl7E0XoQqXCsYjHgFXqN9h3HbMiVDd5qnk
	pmOYDTlOLewYQzryPJf8X8H6Mwk0yGFmOxa1hJwvUPuNeaMcYw60ILldwIyRVkAkrEQ==
X-Received: by 2002:a17:906:f848:: with SMTP id ks8mr63032613ejb.165.1558526958344;
        Wed, 22 May 2019 05:09:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfZAQwEVUgEcoB5q3OnGt+u3tEayi2xhZp9JdleoQHKqYDLjlZbJNWUL4lXOm+i4zwtjRx
X-Received: by 2002:a17:906:f848:: with SMTP id ks8mr63032534ejb.165.1558526957549;
        Wed, 22 May 2019 05:09:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558526957; cv=none;
        d=google.com; s=arc-20160816;
        b=zs3FRkrf4sGRqs2dGomRax4vXatnSVVMddmilm+5Dwl9a3b8dxLmV/542+xISWpKKX
         B60ggh5zQT/938xniC0efh2Gz7mns3mdYwSEaFDR/+5fJgJkww5fRD+9KSUrP0CL2kGz
         UhalyMF/Pu5idtB39BXI/8qe3m9NRnS5WUmhVQaa79jnpwdA/m0gXbo5NDQXf0qgoOVB
         WsoTjfh6qsOOK5BKEtnoeeURgalGHXq0tdMIjEMy8Lu7QNwJPzTVhtZiJoV3mr21fJkq
         mpv5jHLvmVo6+QUR1TNoC9sh9oYzWoTO6h/KH70oH1cW6NsHm2c+tjeMTEyzrpmJpXrx
         gkTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6StKcRdj6zDXHyAH0twr0343ZUZ9bs1CVJn0ddD3Wk0=;
        b=VWUCJV+uY4ljkYBuMbXcOz7khhSmfdAEqphE7OdmTjsIi/Gr0xW82w33frZQp3ue7b
         6Tg2IFCYGs3dUYCJ7ORUE/aTLxHljiilUb6YerwJT/CpkDM/HuivzbFscMMi4zxY71Ws
         ApcxwDidtM5kBRw6grQqwRWWzyyildc+JsYCvXP9BTmnNjG4wMpD9lAFAWElGNAWUnoC
         z5rnUm3kejNXOwue1HW1QdAdk1uyQOPvfvZ5xLYQTO7OSyzeG84Racjgxp/UOl9H6M4T
         /EZGqGUwCoG3P1Rb88M3p6eZxRB30QNNSAEqdAqk1NVdFQPRiAzJwKhvlWB6/OdoyUFL
         dXXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m45si7611085edm.187.2019.05.22.05.09.17
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 05:09:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 74CBF80D;
	Wed, 22 May 2019 05:09:16 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AA7D73F575;
	Wed, 22 May 2019 05:09:10 -0700 (PDT)
Date: Wed, 22 May 2019 13:09:07 +0100
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
Subject: Re: [PATCH v15 09/17] fs, arm64: untag user pointers in
 copy_mount_options
Message-ID: <20190522120907.tf3tb3h5oxhfokgw@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <ac2ca3454b1ae8856ea2e29a1316fea50a30c788.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ac2ca3454b1ae8856ea2e29a1316fea50a30c788.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:55PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> In copy_mount_options a user address is being subtracted from TASK_SIZE.
> If the address is lower than TASK_SIZE, the size is calculated to not
> allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> However if the address is tagged, then the size will be calculated
> incorrectly.
> 
> Untag the address before subtracting.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

