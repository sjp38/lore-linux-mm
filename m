Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE5C4C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:21:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC19320665
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:21:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC19320665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BD056B026E; Thu, 23 May 2019 11:21:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 446336B0270; Thu, 23 May 2019 11:21:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6C06B0271; Thu, 23 May 2019 11:21:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1F5F6B026E
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:21:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n52so9560965edd.2
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:21:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fb+sRFUqop/LR09JWznlfcD+auxrcxFlhwW+VrYfGE8=;
        b=dXf6rmGOt9/Gcs/M6Fr2/ZnCdh1C1jZ3a4V83adGLbDW7BT8wiQ2IMEXDYeF3xGeNs
         +7Ri6erk3jZ6sVp0S1ouIacshxnjqMSf/7IoQGkHBan25bebQk3q49oE6eCAnyPoyQNK
         g5ERCFJeh3rdeEPZR4M0F6mi7uAIxMmpbKfPPtIxzQCfQktd8CIuyHU77DmpymvwRyBy
         Osx+eIu7hy5nBfV9HMnLajG62zlOCnq7+UGxvJPoWMfspKzfrq9jfLTA01HpptMZg342
         BPsMNhY+CP4gNHyPreI5hapoUKHS2YukkoNV/UZ1/GLhXQdZI0xWigCRLckEI7h2/Mde
         fJ9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU+xAqslFD4lSN8tu7F3Krc2aHQFj3zuhqTGS6pAI1ipqtFGNBi
	oP+d921mUyBiSraxAMT0kmu2S+G9ADZcHFRMZgzdZ3zfWwgHVv1c/rxEVfovvfgJ+nv/mC1iNdX
	4QEfhjONSC4OMQx/Ligxe6Nx6QGC552Qh5Nx3Y3hMN9oKXmGOyxVWLpsdGs2nhOZCoA==
X-Received: by 2002:a17:906:f848:: with SMTP id ks8mr69927846ejb.165.1558624895338;
        Thu, 23 May 2019 08:21:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcWqJlzmFUyeiv4UkJlpDMJ9NgU4lusAwh4ZiO5TBQTcOu+e8DLS5ODymgkPkxGbmgtLcz
X-Received: by 2002:a17:906:f848:: with SMTP id ks8mr69927655ejb.165.1558624893406;
        Thu, 23 May 2019 08:21:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558624893; cv=none;
        d=google.com; s=arc-20160816;
        b=u58SWtIJ3aSO5/YLFGz8fLA08VsYCFazFbxWWJl+VEB70Td+FRnNs11WMlz09TsjqG
         Ds/aBxbOUEyPfqpBFcN51K+pQDEiGYauV/5mpkWAAr8TX+/Xjw+zEIq3ByFbWCDeTAcA
         Uv4Vcq52nknYcwklZ0K6C5yTpZN8rYDJ9RIWSTsowBvyb91d4zhPMYHcH0PUk1B3GRa5
         UyzjVSqWiSBAPIkYkepuuSGjay22jfgvCxqyPqMVo1qQCdikZedji8AXA6lpqIi5lGBo
         flLq1BsNxgfdobENkkP+pR51qk9+AjuNxL15UQTflql9bZ4coHMrvxOLONN1k6hKLe/L
         OshA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fb+sRFUqop/LR09JWznlfcD+auxrcxFlhwW+VrYfGE8=;
        b=r6LVHiOlmdEdpndeqL1jkrrfcL/xtBR+vyZRFFP0wcqBAG+oyAHTM2oECTL4zY35vd
         NGLsDiyDZjgaPtsgh+LNjY5hBl4IPCKJtxaHvHcXZheVObxKqGunx4T0eAyqcRSriPDC
         205+mePLfifcX9xj70QrPaJVp68X7hVvm1dJzpNfovsTeMya///lVsyoJdDg44LqD/pd
         h/tayqM0RpX4IW6Bsg26JflcGbm0VbXBq4CUrX5eJlFSzh1+eQKoE1ZfcBPkPsENipFO
         3rb0rpjQk8R8+reH5I9Jys1IiDuIpo9/Z2DbhTUU3iwnHQijKXXVfgLq2a8CSX0rSP+j
         fsoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j17si5498688ejv.3.2019.05.23.08.21.33
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:21:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5555380D;
	Thu, 23 May 2019 08:21:32 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3D6CE3F690;
	Thu, 23 May 2019 08:21:26 -0700 (PDT)
Date: Thu, 23 May 2019 16:21:19 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: enh <enh@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523152118.t22z37mpqfwjjtkw@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <CAJgzZooc+wXBBXenm62n2zR8TVrv-y1pXMmHSdxeaNYhFLSzBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJgzZooc+wXBBXenm62n2zR8TVrv-y1pXMmHSdxeaNYhFLSzBA@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 09:58:22AM -0700, enh wrote:
> i was questioning the argument about the ioctl issues, and saying that
> from my perspective, untagging bugs are not really any different than
> any other kind of kernel bug.

Once this series gets in, they are indeed just kernel bugs. What I want
is an easier way to identify them, ideally before they trigger in the
field.

> i still don't see how this isn't just a regular testing/CI issue, the
> same as any other kind of kernel bug. it's already the case that i can
> get a bad kernel...

The testing would have a smaller code coverage in terms of drivers,
filesystems than something like a static checker (though one does not
exclude the other).

-- 
Catalin

