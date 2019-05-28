Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5020BC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0E2221670
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:56:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0E2221670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D14A6B0276; Tue, 28 May 2019 11:56:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5824F6B0279; Tue, 28 May 2019 11:56:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470BF6B027A; Tue, 28 May 2019 11:56:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC5EF6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:56:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so33714616eda.11
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:56:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C3+5BBmNX4X5/DRGnpChH3EXghr2AQxcbvXeXN6F5Kw=;
        b=VSNdYGU/WbyVoAAg2TvS1mDc+Dzl6k7vx8s7JXfilkmm3nqPYZ5YD6UufAk5IvhBoX
         bIp+ptIDtmMVbNZW0c7vfMl4L0DfmYVD11DWLN6ScpZfda8hF8JUB3B3onVCX85SzSZZ
         g6/4ocoRXzzCZVVEP339roFLpMIdSkg0N60/75J4gdxOnNHCKVzi+sHiVSKwPCVMslEt
         a9/ThHkdNyLM/eNofL05QRlNl2RXXFqEd4DZLJi+vdhu4wiXXtLmFzQ37cRzQ0C9HBoE
         F2vft8jpTdBY01Ug/c5aHZMPgcvUcXGmKWwV1julTg9yEa7kd0tIfdedZE70xrb1XSN/
         4X8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAW/eVE+rKzrQaj0yVQEn02NReBeB9+OiD2mJyNuCHn939YWVQXE
	PL+n5aDv6DmoqqbiZptu412VapbV6hNsihi16jlNBWzifH3j6vNGGsHecFKtO24QhAwIws/SehK
	vOhY6+LMtR55T3TWDiKiTcZ4H7GlTTSlLlDkFCm7uJEzFns0LZynbeca9ll3RBs3miw==
X-Received: by 2002:a17:906:af57:: with SMTP id ly23mr70230527ejb.98.1559059015488;
        Tue, 28 May 2019 08:56:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuG0vcOUWylPnGo8hOLbUyNYFzGWJP/gFxmNjU5UBI9dAPUZ0sMqWIo1nDKuWisyHB/5PR
X-Received: by 2002:a17:906:af57:: with SMTP id ly23mr70230458ejb.98.1559059014597;
        Tue, 28 May 2019 08:56:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559059014; cv=none;
        d=google.com; s=arc-20160816;
        b=rfDWfodoIdRZRYSpqAovVn1EC834h8guVZKZeOcWxaV0sE1WY/OLd+CD5crFfFwRrA
         0kTILkUcDzH4u/rKr3Sf6foprimuamqF6ZjQyT8IcfVKWnCOMZR4N7l4bLZzjzqohnzA
         DGGUqdeU9v4MKtgnc//+S1Omrj5mewK+D8lehX/KRvtnjsQ7/8BuVMRdFfZI69VZPEeC
         9+HFaHyIG2a0+CwSctv1WstCl3ceWx+RUzvQEPFrHsqQe33PEv7J+yrG6PdvkieZHjfI
         6QUFMg90JMrC562Kc2JFxw/SZ6J9MFbYX5wj82i7SEkcuYw8LiWUd1dV0xKoszrW7Rig
         S++Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C3+5BBmNX4X5/DRGnpChH3EXghr2AQxcbvXeXN6F5Kw=;
        b=ivuyDp/3+3Jtt+cZgLRlAN77ivbn9gabosBHFvQ6ef3qsE4MWTH8VcaNLgwBywfLac
         MWU+5JsxTl+MnOMWF8gxn6ZyKX+oVz6ZkAKX2udBhtdgzE/HjST58TsC73aghhPHqYIn
         g5sw2JbycFAWx196RNNFuwdJ8JQwPDuGCsYdaBEwtEKvCeUI6uFPl7gtS7L5S4TBH7CR
         1QWL9DIUg8pbi80Su7RXDfTonmPfpzLprhGldqISDF9jF+ZzKpk1npnnC5l9F6gL6fBG
         UAG3B/IP0UmWG0fST7nzuB60g8bAdzjY3zV4OP5rD3z8tWHvDf23AMAPLG0Obbwl7jMd
         ZwWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p48si11779330edc.373.2019.05.28.08.56.54
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 08:56:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8540E341;
	Tue, 28 May 2019 08:56:53 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C9F273F59C;
	Tue, 28 May 2019 08:56:47 -0700 (PDT)
Date: Tue, 28 May 2019 16:56:45 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Murray <andrew.murray@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Lee Smith <Lee.Smith@arm.com>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190528155644.GD28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528154057.GD32006@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:40:58PM +0100, Catalin Marinas wrote:

[...]

> My thoughts on allowing tags (quick look):
>
> brk - no

[...]

> mlock, mlock2, munlock - yes
> mmap - no (we may change this with MTE but not for TBI)

[...]

> mprotect - yes

I haven't following this discussion closely... what's the rationale for
the inconsistencies here (feel free to refer me back to the discussion
if it's elsewhere).

Cheers
---Dave

