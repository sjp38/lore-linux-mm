Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B065DC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 778CA20880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 778CA20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C7A76B0003; Fri,  2 Aug 2019 06:50:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079676B0005; Fri,  2 Aug 2019 06:50:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5BE16B0006; Fri,  2 Aug 2019 06:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99F976B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:50:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so46733229eda.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rqeIBpVoEZA+mlsj09N5LDYm1PHoFezq9EsYluLQ5mc=;
        b=eCjO6QvMHL/e0UfBkH/Bw9wlhxbpMMO7Wgb4VXYdDvbAr/WtkyY4oxPRKVAWiw274A
         ps7XnRcEdRrXgoBl1xciWz0MLoljSgnlMbV9hbVMp66Wfec8nrgcU+NQ9Gwv3Dg2fzui
         MdxqxhRbY/jmFuwByHiTWC0m6+ULXwNxuMF4Qtdr0qryfUPTbCwac/TzX0irO4rTTQru
         K3a4rMD1TGO8QL+Chq4b0KPYjgTfx36H388sdNTdXfYDNq0kQQ7W9JPjFvst+iqvJf4C
         /3aCRR/tqxEi0zuEx0rqDltQya6RzmVks7AotFF1kvNbHt2ryX/d5/SAS173AA0zaCN8
         kffg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVLFDDX0gaaWv2i3rhFI+wKV7c8K/3HlReYXCiD0VB4jrM4qhRr
	74f/MOCSfKdaOpGZCEZGM4vGQWbzoTfXk7NgcVOl8DpuFLev9chhVQb5iV6MsGsLO3eG5TaLBzL
	tKNROw5ulRlzJycwpsSxOt0V+uTqZ8eEP+651M6yNbCS/wzCAycQ6w6jdVotFHckVlQ==
X-Received: by 2002:a50:b4cb:: with SMTP id x11mr120621268edd.284.1564743047203;
        Fri, 02 Aug 2019 03:50:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzItyEpM0QmYeMLabS6NEW08sHYJKw3GbHaLcNe30jWaIjxILOBuHhd1evcXpHWC4Er+fCn
X-Received: by 2002:a50:b4cb:: with SMTP id x11mr120621217edd.284.1564743046397;
        Fri, 02 Aug 2019 03:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564743046; cv=none;
        d=google.com; s=arc-20160816;
        b=jeXpyjAb9xK6JhNLLwMmIfTLzXaIiHvZqtlAPQSk5h7rPQ2cXsX8JmTAe+zJBjClu+
         3ebo7Hl35Sp1AeIOmWlGzwQTbGVgNZ8lYN9DV4ftwxOSajC6p3wGlNEQy72cztIKhrDG
         qUOPnzAtXFD3bhOitSj/ydyInL5dE9BEDUNRVjdcqHzNPV15HAi4C8lbKjGLpQxyOkd7
         RVJF+dkKJhF+4b4BRnHbQ9zGOKcTee1mXI/0IWb0ZZAwxIJ1FxPKUUTxfqNSiSj8hDt3
         M4ycfI/fwZxowxB2UQRDg12Fu5iZN6XqS73H9vnDR6A7ON0tBJEwhr0xsniQPk5EciRm
         3tJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rqeIBpVoEZA+mlsj09N5LDYm1PHoFezq9EsYluLQ5mc=;
        b=BPPX88l+tWkzFdQvlgs+n2tBHjlnB5QIq5iQWEB/ZH51G+s9PZzmj70gk1dxJzqgqw
         RMKXEHLVCnQXmt74FcjBbTe7mFrp0AzZ3h5y7X/wzCix/Y2neWviadtNzOHr7Chf6adZ
         n3OByd/2bjwBT9mSbzAubleZ0L3+6coB0erhDcbwxSBa6EusApGun/LGdGBYKpUDXIQl
         zbr5kajpnwS7P5ygCuH1+tX6IYQuwQiTz0j1zITrBlC69fo+4l1Zx1/VAEbXoyvxsZsD
         nl3TxEbDmMrEogQ11YmeJ7muKyyQ/2ZGFxgy7wkwub/xVZyi8lanesNzG8sRfgOIXS1Z
         792Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j24si21887908ejt.212.2019.08.02.03.50.46
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 03:50:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6CBE3344;
	Fri,  2 Aug 2019 03:50:45 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9FF973F71F;
	Fri,  2 Aug 2019 03:50:40 -0700 (PDT)
Date: Fri, 2 Aug 2019 11:50:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Kevin Brodsky <kevin.brodsky@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v19 02/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190802105038.GC4175@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <1c05651c53f90d07e98ee4973c2786ccf315db12.1563904656.git.andreyknvl@google.com>
 <7a34470c-73f0-26ac-e63d-161191d4b1e4@intel.com>
 <2b274c6f-6023-8eb8-5a86-507e6000e13d@arm.com>
 <88c59d1e-eda9-fcfe-5ee3-64a331f34313@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88c59d1e-eda9-fcfe-5ee3-64a331f34313@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 09:45:05AM -0700, Dave Hansen wrote:
> On 8/1/19 5:38 AM, Kevin Brodsky wrote:
> > This patch series only changes what is allowed or not at the syscall
> > interface. It does not change the address space size. On arm64, TBI (Top
> > Byte Ignore) has always been enabled for userspace, so it has never been
> > possible to use the upper 8 bits of user pointers for addressing.
> 
> Oh, so does the address space that's available already chop that out?

Yes. Currently the hardware only supports 52-bit virtual addresses. It
could be expanded (though it needs a 5th page table level) to 56-bit VA
but it's not currently on our (hardware) plans. Beyond 56-bit, it cannot
be done without breaking the software expectations (and hopefully I'll
retire before we need this ;)).

> > If other architectures were to support a similar functionality, then I
> > agree that a common and more generic interface (if needed) would be
> > helpful, but as it stands this is an arm64-specific prctl, and on arm64
> > the address tag is defined by the architecture as bits [63:56].
> 
> It should then be an arch_prctl(), no?

I guess you just want renaming SET_TAGGED_ADDR_CTRL() to
arch_prctl_tagged_addr_ctrl_set()? (similarly for 'get')

-- 
Catalin

