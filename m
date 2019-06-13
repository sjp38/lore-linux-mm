Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8C4BC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D9C6208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:58:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D9C6208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACAC88E0002; Thu, 13 Jun 2019 11:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7D418E0001; Thu, 13 Jun 2019 11:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A788E0002; Thu, 13 Jun 2019 11:58:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4918E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:58:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a21so31354426edt.23
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:58:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NXBR0B0iHgm6Np4eWn/Jhll+jNj1X5ZiicVLyMgmV94=;
        b=DPAB2y8IJ/59y1F8I9bym3hunLbd9NMXzz0Db/moHiimFM42/1Ua/P68fFvcCbpYGO
         DN67WR7A5lGq0Tuf4XGUDpHcm8R2GdMLZpH1Ew/vbq5ROKfYOGOhyjGkLtiMPm4VEn5H
         Kdb/VXCknz34qy/bwDHVopdZPrnojDmgMkQeb8oBRP5uthf9TYeJKkha195LU+iOTFCf
         WLbWUTndun9rXXUjSxqe/P+4lk5rQPrzr7uerKj2b87d9RuvxEa6dku7CUTY55WjixG9
         lrzbWkfydgifzok/za+ZlW+HdEBUQt5x43442iesXedO1uOqS4LhkZ6V0gQMPJOMlAZZ
         rX+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWzQ7CAnBSF/59TNm0LNfCaMoDu9cDkleo3sH2QSVAFmYcP7/RR
	DRVbMVLVLK99flWR8onR9zkheQ+DXbzr2aVetTSYYBe7UKr0OpmEKhOSxwis4PQFECzTPV98Zlv
	Vw00UyZetC1NDM/FfoNZhlaEkDae6Gt8h3+uBxMVvGzgTaCHH+6d0Qr//SRYsEFLTbQ==
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr54800206ejb.283.1560441504840;
        Thu, 13 Jun 2019 08:58:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9P2pAME+Rz6FAUiNYwCuo7L3FH+F7cpMtHhbsYABa/yHJGeBQgbmbTLVL6bMJrs5pG82V
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr54800137ejb.283.1560441503881;
        Thu, 13 Jun 2019 08:58:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560441503; cv=none;
        d=google.com; s=arc-20160816;
        b=Te4pxQrIZrXNAT249NrJT5CgzprhBgXEoaivi+FgFd1WqtN/bQocqOGkJc+xw5yiq8
         S7QjRcF7zoUIzbQoh0RHmYdjGRJMZYKrCRpt3mwqosBqcr7c2wVx1XJtnyEvtv3QjVS+
         0FAhQCiEiUVQkASxWKz0EUSxZ+6tpAmO5qcisW237O6BKH+bju2q/6JpP4A2ub65JusF
         F5tD96uxBCUV4EHuWbUUngXbilrf5zGvRkEbKufpYxMjl3v24ffiyPIK5Nlav7+M9YoW
         gXFYGutrtSXAw0FOP3uikPOD0irOhqJK/ZtxHwkLSzmoxKyb8WsU/cZsRNX2sj5W9umc
         i+dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NXBR0B0iHgm6Np4eWn/Jhll+jNj1X5ZiicVLyMgmV94=;
        b=oQNwwgxTsRW7PDJhK6E+DprE5o+M21lVPsNcdjoTIH3kqlxfFJ0x/siYcwNlKaWq3g
         yXvVFP+gabDhNp+o4jJ/Lr+BGXyq0QG4Nwb6bx/b/V4eS2/iBxVgWib6PQd0TY0T4DX+
         Ph8G3iUIK6oc9kbv38PWF3kXgt3/R+MLZu1/zubrNloPzIZVKRwVCoqyBm5Rp1kTdFkB
         TnEgB5uU1KMUPf3Ihg7GmapNdrehkSrHGUIB7mafQ05A+OKE3A04CMfBs/HVHf8JZYXZ
         WM/u4gkV3/jhMtYEojgClqihGBRhbID3etxpDfY2aLOePqxA9Dkrf5dJOEwqpsdFz0yE
         PmYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w1si218038ejv.339.2019.06.13.08.58.23
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:58:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D2C10367;
	Thu, 13 Jun 2019 08:58:22 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 825ED3F246;
	Thu, 13 Jun 2019 08:58:02 -0700 (PDT)
Date: Thu, 13 Jun 2019 16:57:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Dave Martin <Dave.Martin@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190613155754.GX28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613111659.GX28398@e103592.cambridge.arm.com>
 <20190613153505.GU28951@C02TF0J2HF1T.local>
 <99cc257d-5e99-922a-fbe7-3bbaf3621e38@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99cc257d-5e99-922a-fbe7-3bbaf3621e38@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 04:45:54PM +0100, Vincenzo Frascino wrote:
> On 13/06/2019 16:35, Catalin Marinas wrote:
> > On Thu, Jun 13, 2019 at 12:16:59PM +0100, Dave P Martin wrote:
> >> On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> >>> +
> >>> +/*
> >>> + * Control the relaxed ABI allowing tagged user addresses into the kernel.
> >>> + */
> >>> +static unsigned int tagged_addr_prctl_allowed = 1;
> >>> +
> >>> +long set_tagged_addr_ctrl(unsigned long arg)
> >>> +{
> >>> +	if (!tagged_addr_prctl_allowed)
> >>> +		return -EINVAL;
> >>
> >> So, tagging can actually be locked on by having a process enable it and
> >> then some possibly unrelated process clearing tagged_addr_prctl_allowed.
> >> That feels a bit weird.
> > 
> > The problem is that if you disable the ABI globally, lots of
> > applications would crash. This sysctl is meant as a way to disable the
> > opt-in to the TBI ABI. Another option would be a kernel command line
> > option (I'm not keen on a Kconfig option).
> 
> Why you are not keen on a Kconfig option?

Because I don't want to rebuild the kernel/reboot just to be able to
test how user space handles the ABI opt-in. I'm ok with a Kconfig option
to disable this globally in addition to a run-time option (if actually
needed, I'm not sure).

-- 
Catalin

