Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 114A2C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 20:11:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C83DD2175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 20:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C83DD2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40B9B6B02B0; Thu, 23 May 2019 16:11:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E2166B02B2; Thu, 23 May 2019 16:11:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F80B6B02B3; Thu, 23 May 2019 16:11:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3FC56B02B0
	for <linux-mm@kvack.org>; Thu, 23 May 2019 16:11:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f41so10626128ede.1
        for <linux-mm@kvack.org>; Thu, 23 May 2019 13:11:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tGZdjRfN+djsESiy9Z+nSDGaUKVu5TG4mVV244gbZ3k=;
        b=Jdh33iEOIJF+vI7ec9yZgl2l98VonP9tZH48SNCeI/PGG0Vufq4DObgyxo8Mf96Emw
         8sizicgnG8kI5ZEvsLorKft3QvqQjXqrXsb73yHLAQADJjiAobxT4KmhEAGi2klHPGNd
         /OZdSnQh9Qc0c6gA3yAohtXFnU1mQdb73+WPcjTm0PBTSy8mJ6z7GDvj2QepihmRP8M+
         Zs99zZXz78xcJnC9fvPYx7x5a10Awfd6n6SIRhi/NdgmujU81hZSdMqUfpasUCjcyavJ
         vkfHyMPz5+pdhMg1gCINu7y1X38YTafww6F8fwmkYT4qA5Dai/xd15FRkqbvTpe93868
         J2dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAURpbwHHsydIxnsYpEFicInYFiGRrbfeKEOFNO8+LfJTNf2Z+E+
	yixnp9oVjKcLt4zp+nZcuLoAF1JguBoqK+o0IF0ZMApHN5LI6LjANGYjBmaESbqf3jbX5TrgNKo
	KuVqqHNyC2IwctAFs0m0NGY/5yU+VOjjAvC2Ryc6J6gcvQJ2vR+BXe7DVoi9yHxUlmg==
X-Received: by 2002:a17:906:5390:: with SMTP id g16mr71174910ejo.12.1558642281366;
        Thu, 23 May 2019 13:11:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIISzAta02J+9Bjbqcnt2X5EcKQAi+QPEBbcnxs1jwQ6YUHSGsejPOKWx5KhI3xyhmw1uk
X-Received: by 2002:a17:906:5390:: with SMTP id g16mr71174828ejo.12.1558642280331;
        Thu, 23 May 2019 13:11:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558642280; cv=none;
        d=google.com; s=arc-20160816;
        b=e2YOILkK1XKwlDn/MRJR2q8mdP3PvoQkQEYS+K2ZQ61GZf9UmEwBtzB5gWz0dNrEgA
         icwGkPfsT78VfYKCXMoYTvf9d4MDWgqiEWgRw4oeZClHmCZSvH9QCzBP5Gjih0prs0CB
         MZS7iITKSQbPtL5sYNudRWKu7RSsvWMq6+hpuOk6hNkfR19cqQ0OSsHIJ6c+gE4Xd3K/
         F7KjwMZ02Q+qOk261MIcSg5QiU+XoM+wQy9J3b57yx9R2FK02ZV6K5nTNTiAFMUKILdX
         +ai8iPpRDWbn1mEhhx2cKi8aOHUjza9lVHGNdCbQUUKsFQzJaJC2ewmnBRxDbXrd9/IP
         teoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tGZdjRfN+djsESiy9Z+nSDGaUKVu5TG4mVV244gbZ3k=;
        b=Qf9sOu2eRj3ooYN3dDdkP39TRXMSM8PKXGMVXWD7V8coK6YgKgpliVfZf90jawK6ZL
         3Tn8ejKOmIb5Mo5YPqt8SyjVU/BAcs6wZeuf7UMoV1metKdYWZZwesUnM01gGl4kIvDm
         JgwJyP7jG3yoPgGT9CvZbzQGUjALFK9jXXBC3jXEWh2VeK0nz05gzGA5xhpTaKnqpifn
         QkawOrBbONeYs6R4kdbXzMYYvNdNYVQnlEC5H4Bd044H0rAXpdo6j7tabJ8ImJTjkIS/
         2FIxkAUMtty03EO0anyRzkaF3PkUz10hy8ftWVF0/Khaf/R/T1JAd7Eb9V6orV869gTc
         znVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f58si209378edf.183.2019.05.23.13.11.20
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 13:11:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1A48EA78;
	Thu, 23 May 2019 13:11:19 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BBB143F690;
	Thu, 23 May 2019 13:11:12 -0700 (PDT)
Date: Thu, 23 May 2019 21:11:05 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523201105.oifkksus4rzcwqt4@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Khalid,

On Thu, May 23, 2019 at 11:51:40AM -0600, Khalid Aziz wrote:
> On 5/21/19 6:04 PM, Kees Cook wrote:
> > As an aside: I think Sparc ADI support in Linux actually side-stepped
> > this[1] (i.e. chose "solution 1"): "All addresses passed to kernel must
> > be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI
> > for kernel code.") I think this was a mistake we should not repeat for
> > arm64 (we do seem to be at least in agreement about this, I think).
> > 
> > [1] https://lore.kernel.org/patchwork/patch/654481/
> 
> That is a very early version of the sparc ADI patch. Support for tagged
> addresses in syscalls was added in later versions and is in the patch
> that is in the kernel.

I tried to figure out but I'm not familiar with the sparc port. How did
you solve the tagged address going into various syscall implementations
in the kernel (e.g. sys_write)? Is the tag removed on kernel entry or it
ends up deeper in the core code?

Thanks.

-- 
Catalin

