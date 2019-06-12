Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2652C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75DF5208C4
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:05:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75DF5208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AE106B0006; Wed, 12 Jun 2019 07:05:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E8A6B0007; Wed, 12 Jun 2019 07:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025856B0008; Wed, 12 Jun 2019 07:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4F376B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:05:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l53so25350393edc.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JJut+oAsqjk41nufLC+ytCD9vUIoM5qAnVOJ79RxIX4=;
        b=tnvY9N1GenQuFmEidEbWCsAxLjp1RumGHpngbzuI1d4H+WsY/WbcTb0XiYm+DnCWMK
         HFFZpP9IXbfVDakExqg/sJyHkJqxFMqeLQ0vwK4pHXQ0ubOdNqSTw/jFBbt7gOMfkfwN
         TKJX6zRWPy2ta4sUEjHiW5vXJ+cVIRbPNLc3cIbHVzZq6Qfg7stySW/Q/hgZCs28slyK
         fwQ9kj4/R1NbO1x2wyI80BvD9GbRBElcSw0oEPhKnI3b5Oe7oKjKGxS63o4Gujs2KCnm
         VJt8+ozWciaLvgcldrIfIWEtW1Y5z/YzAPtjn9O8i1bUgX9VUNtMEx3dV3W7YOQUG1Bd
         IIig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWJZbhYoaAegq6U0kaGgqCt7nW156grOey/inOEJ0Pr0xFwN7db
	Q8oD4XNBkLt7iWK8Il5MZyFAUUeQy6KFgE/iRaFpXjJCdT0J7fWjxXtqew/aKOZqqbt+i1SOw3Z
	7c9gsqFKRWG95yKPU5y9eW2Foy/s/e/adaoge02+PUiuYARRHZheRsnQTJOVYFOYrog==
X-Received: by 2002:a50:f385:: with SMTP id g5mr6039341edm.14.1560337517162;
        Wed, 12 Jun 2019 04:05:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxZrhsEbCSRxMWK2YXqrM3neTDrZY2gVgUK3x+UBDdxwMrgOFixLx16+9mb3pNxWm5mWjY
X-Received: by 2002:a50:f385:: with SMTP id g5mr6039258edm.14.1560337516404;
        Wed, 12 Jun 2019 04:05:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560337516; cv=none;
        d=google.com; s=arc-20160816;
        b=zBoXNXlWHQ6k05OvFRVwJSYR4zzK0sJzozB0YrXlv0ixGUeyZc7gkPe8FPh8KA0n8A
         CZ3Vcl5OYtUlpOyLhjqnAL0d9qndlzFr0jF0RS8wNz2URhuQzRUQgwjkBYyr0OlUO9kL
         he7ucqsSekTM/f6E4WLUERwS/v2krwqqXXEaocfbLjLgP1UoTI6mw04Eqx2a8Vb308j4
         50rNnYlBFanX6IGQ3hWjxdpIe7hvCRAn3VeGL9Ze1zeLJG8/RH+XxDP3BRwIl42Mn6Pk
         IEFaeeY+Dl9ePgVZjrFxazeSZN30oLaBSJdCcuIFCtVRi3zVqpfBwSehXogkuUF99+ry
         jMvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JJut+oAsqjk41nufLC+ytCD9vUIoM5qAnVOJ79RxIX4=;
        b=A8PGfPCAoR0Uzp9s+sQj5t99zDH0+q2gpWBKKeLzbGB9rvzrkM8zL4W6rS0pDE+Bbf
         lgZ5FnuddAuX+V02srCV3ZTBuitVgd9TBm9lramWAOUjrfzfBMPmFK8i0HyosZvphTgA
         RsP0S9OIsAXADrjNf78z0cjI6XrlRsdcOqYpq5WDXrht3dZCP1T6hC8oqSfqsUwskPt6
         Jgzl4Cc4LwVzAGkVE749F3iwoys1Z/VoNKiExtBle34qWSHSbjse/WdT6U/1oD8x0+Cb
         Svhk485837DUiCRHD5WTi0gtTtVYY4BN6JDE3B4hSuHO+F/dMnMHd/csG302pueexkS+
         917g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j2si2887721ejm.114.2019.06.12.04.05.16
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 04:05:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 67D1428;
	Wed, 12 Jun 2019 04:05:15 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 74A1E3F246;
	Wed, 12 Jun 2019 04:06:34 -0700 (PDT)
Date: Wed, 12 Jun 2019 12:04:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <20190612110443.GD28951@C02TF0J2HF1T.local>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <20190611145720.GA63588@arrakis.emea.arm.com>
 <CAAeHK+z5nSOOaGfehETzznNcMq5E5U+Eb1rZE16UVsT8FWT0Vg@mail.gmail.com>
 <20190611173903.4icrfmoyfvms35cy@mbp>
 <CAAeHK+ysoiCSiCNrrvXqffK53WwBMHbc3bk69uU0vY0+R4_JvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+ysoiCSiCNrrvXqffK53WwBMHbc3bk69uU0vY0+R4_JvQ@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:03:10PM +0200, Andrey Konovalov wrote:
> On Tue, Jun 11, 2019 at 7:39 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Tue, Jun 11, 2019 at 07:09:46PM +0200, Andrey Konovalov wrote:
> > > Should I drop access_ok() change from my patch, since yours just reverts it?
> >
> > Not necessary, your patch just relaxes the ABI for all apps, mine
> > tightens it. You could instead move the untagging to __range_ok() and
> > rebase my patch accordingly.
> 
> OK, will do. I'll also add a comment next to TIF_TAGGED_ADDR as Vincenzo asked.

Thanks.

-- 
Catalin

