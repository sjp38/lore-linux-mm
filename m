Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FF27C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C956D25E2F
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:15:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C956D25E2F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FEDF6B000E; Thu, 30 May 2019 13:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0256B026E; Thu, 30 May 2019 13:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 478576B026F; Thu, 30 May 2019 13:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9E586B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:15:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so9493849edi.20
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:15:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5ePg/QOJdz+LgfndhGhdzpIZLCS0EdvG3KfIddKvX8k=;
        b=bqei5aTC0qqXRIhpZ6xzQCxw36SlDxuNAgws3kksa6ogY8MbnrYpxAWmJj1DZp2QFs
         7J4O4AhGx2jbN1YfxBHYf4QoHcx3NpKwhDAU25J0hLI9QfYxCHz2l0bP+ASkSq8GLg7V
         w46NuTMIfrYjN+M7fZMkQlPFyewTOWXGSaNM8VfgKgzdT1J16Gu4dfZdJ7C+07cHeWQ7
         w+M9AugMLN0aTcWLScqYBcrKKo2vOyJT4SnqtHR+QojPsnesuHM5PvGq3x9QM/TU21l7
         RPIJFb/FFkwtMFWM500yn022E0cwKt2aUECzdRI0Iip93SYr3pf9rb+YOZT4AYIjf2rn
         8npA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAW71okhHjzKfFW8aqVN0B1BzcP5yDqlgnzqfObOM9ikJokXRIaX
	s2cqNw8CbawZtGD4cqsMnb5j1bkmbvxraPuhMLXtNg21a+RknmfmbhDR/UpBh35sWAlrDbigWfW
	ChSvg3TkWLPXPv+yfist6jZjBvJscfk29eGLOf0iqQBgrwF7GrWCHMnydHxMYO+MOJA==
X-Received: by 2002:a50:90e7:: with SMTP id d36mr6066981eda.202.1559236551535;
        Thu, 30 May 2019 10:15:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIM0xEaNhdSqG/v7ntfckaBnuXSMP/zBdmLq+L9rOOnUS6Tkfm660U7ukO0Sjtut9SO/lB
X-Received: by 2002:a50:90e7:: with SMTP id d36mr6066869eda.202.1559236550358;
        Thu, 30 May 2019 10:15:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559236550; cv=none;
        d=google.com; s=arc-20160816;
        b=mMvuryGOaEube+V30nni7p9I/ul1N49ruEaML0uhQZ79VJXzUAqOXNqLMHwahVQo3y
         K+3diZU2xrS3MjLO96OxuiwqnUrsF2h2YbhPkfRBmBJRUm3KVSJdFDiIR8zzplrTxxLc
         SL8V8/e4u0oxUc1Fhk1rAOiniuKfrukZe0cPacW1OJv3Iapv2Mv07tv60jLtSOCKDwNs
         BSQ3SMf+pUk7gexgfnbYmbMgzRaRIl94S1bm5Oujbwt7Qf3FzfPsudZ5zFAOaE+pTSfr
         HxVpGAZRD+VMURKk2I8w/yAPmgIuEhVuddqgUZLwykvTQL/fdyW8b7q/qYZikB8TQzfk
         VShg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5ePg/QOJdz+LgfndhGhdzpIZLCS0EdvG3KfIddKvX8k=;
        b=c0vyRX6jgSU9T5snRREw1WfC3NId4ysaCkXalE9wZcOT5cgjGkS7RqraGM31mloNGw
         9I9JsSOjPb+JkfWFswT0IpnJ+BVGsq/k0VA2KNtt0Dxu2ySiTftqdOKraOlnyt3ZgM9x
         DfwkG4GOMWmhi/vxj3FJ7vNzjD2cvnw4yaRvXfk+JBnjEgGpERmmzEm8fyIOfBZc0FgC
         5dI/vIlwQOC9ggwSlCD9iLAb3QoDrvxGoFAnmxg9s8VWp6se/+b4+2foGp0NE/b++9pi
         eM4CgoN56V9QnNlABI2tyDwj9c1b1tkZLKdMfubobiKB1p7cIJjxsCcqTlSU/yK/NPmY
         ASkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k39si2237129eda.333.2019.05.30.10.15.49
        for <linux-mm@kvack.org>;
        Thu, 30 May 2019 10:15:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E146341;
	Thu, 30 May 2019 10:15:49 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 32A333F5AF;
	Thu, 30 May 2019 10:15:43 -0700 (PDT)
Date: Thu, 30 May 2019 18:15:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
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
	Elliott Hughes <enh@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190530171540.GD35418@arrakis.emea.arm.com>
References: <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
 <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> Thanks for a lot of valuable input! I've read through all the replies
> and got somewhat lost. What are the changes I need to do to this
> series?
> 
> 1. Should I move untagging for memory syscalls back to the generic
> code so other arches would make use of it as well, or should I keep
> the arm64 specific memory syscalls wrappers and address the comments
> on that patch?

Keep them generic again but make sure we get agreement with Khalid on
the actual ABI implications for sparc.

> 2. Should I make untagging opt-in and controlled by a command line argument?

Opt-in, yes, but per task rather than kernel command line option.
prctl() is a possibility of opting in.

> 3. Should I "add Documentation/core-api/user-addresses.rst to describe
> proper care and handling of user space pointers with untagged_addr(),
> with examples based on all the cases seen so far in this series"?
> Which examples specifically should it cover?

I think we can leave 3 for now as not too urgent. What I'd like is for
Vincenzo's TBI user ABI document to go into a more common place since we
can expand it to cover both sparc and arm64. We'd need an arm64-specific
doc as well for things like prctl() and later MTE that sparc may support
differently.

-- 
Catalin

