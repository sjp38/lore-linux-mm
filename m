Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0EE2C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:51:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 802F92173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:51:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 802F92173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CA3B6B0003; Wed, 22 May 2019 07:51:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154B96B0006; Wed, 22 May 2019 07:51:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01BD66B0007; Wed, 22 May 2019 07:51:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A420E6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 07:51:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so3338174edc.4
        for <linux-mm@kvack.org>; Wed, 22 May 2019 04:51:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=82kxZBE9XKYhRGhRhK3AAQ01oS7eW/T5oRTAiq8N5nA=;
        b=QjIIfZmSQCj/+XhZBOE/uOep7QeppoArnUpYCvv3tUkk/2N9reO9yCFnlwoZDW9uTF
         haqPxW3oBEEUn7vkXm9SaR1MPpbYK/iNWNWzHx7wR/hTbR0yH3RKfbAWfVsuWpF9yciL
         kfRnIkHZxtnxYIrAKDwIUFbk5BYtes0YYazR8d0ucvtYsV9XXoH2s6RujnHZAV0yNGZp
         +vd70mBO+V9+FGFHwn8HT/D0L76iN3ViSi6xqG36Ku7p05cKVQlyx5T26mfO4+jM9lCh
         TeD/3iU4oMDrm479sh7DOly3+cC9+kJqQWeshmUBZvDfQ2ehna0HOKdw4bREkzyQrCkN
         NGjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUeGAvM9LE7fY8JGl50FSAnINAMhVgsnknGfbfD0YB6HGpos+pi
	o3pUPykkgO+6vP4E4VaUTM4QhlGyBPrkWj2amYtsAm6XgWt7MSVv0NuXHOOMDYIRxJShP3a/+eW
	mjvzyzxEuPH6+Gay1Su294JAEtXsXVtEODYJ3mJRF8vEulkag7RXKLkQypvSKTe126A==
X-Received: by 2002:a05:6402:1358:: with SMTP id y24mr83997911edw.207.1558525909261;
        Wed, 22 May 2019 04:51:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdzQamr3nK/VNw0AKLqjLUlz2V8AVAqcEfU1ZqMtVZ5347TVQiGdktVUzB+8X1Mhl9LRy0
X-Received: by 2002:a05:6402:1358:: with SMTP id y24mr83997860edw.207.1558525908518;
        Wed, 22 May 2019 04:51:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558525908; cv=none;
        d=google.com; s=arc-20160816;
        b=b1mE2nF6Yr/nyzagBsCXvpn25Do/cl6llqURWV/TLz0d25yDAF1C+JAWZdD1HJHmOD
         gaGcEzqrzFiza4d0qO2hpCvLnDeEcgizVHGzs/yCv/QZ2nkvtmkYm/gEKQviBSOOqKhM
         fK0rvYux3BwqdJIlsegUK7+h6HxhNPVB2RrG+nARI1HsJEvHyDMSfznicZmeOSkRMdpR
         vlVl+3nkuGbdrB6/6Uei+OvTc3l2BNzAn1rj5IoWQVYYqwrauyKWxyo05itDI52ZDXmV
         UU3GFzBUhifgjoJVrmrPF1ady/Qw7/914Juch2ewdEVTzLE78s4P3OBmo7filQe6W/a+
         BuHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=82kxZBE9XKYhRGhRhK3AAQ01oS7eW/T5oRTAiq8N5nA=;
        b=nAzrJStOc5+SNIijLGv3i0yreDQ+W8zwIblmhV9kCECUTdHyS5ejR8KCfyxk3HWK7E
         iVFi67N/zmY5zbBPxmf0eQykPwA+CnHMW9Hfx/Jxlek4sYemgx4KV/6we2rS2ZGIisOO
         uRA41EAEvDLzJgiK0AUt5OeiOMvHigo+UWHyFEfmtcg0Ig9OfuKbJtFKI46rJmjYas0W
         LIR83hXQbdHKXnH2STjPswZc5LMF3eCCUzR7WbepTUUKBXuCTSU8kHfBmv902OwjGI8h
         hmEuuMvpTnJLRKp4D9ac0774gG2LkHZqeAKhht0LuzmNhJD0lNbG0pqkUA4rfYByJdsO
         6MbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z9si4878414ejb.282.2019.05.22.04.51.48
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 04:51:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 73C4E80D;
	Wed, 22 May 2019 04:51:47 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A731F3F575;
	Wed, 22 May 2019 04:51:41 -0700 (PDT)
Date: Wed, 22 May 2019 12:51:39 +0100
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
Subject: Re: [PATCH v15 06/17] mm: untag user pointers in do_pages_move
Message-ID: <20190522115138.52ew2totjd6i4aaq@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <474b3c113edae1f2fa679dc7237ec070ff4efb70.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <474b3c113edae1f2fa679dc7237ec070ff4efb70.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:52PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> do_pages_move() is used in the implementation of the move_pages syscall.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

