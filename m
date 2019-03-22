Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D853C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:01:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDAC721900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:01:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDAC721900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80A826B0006; Fri, 22 Mar 2019 12:01:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7699A6B0007; Fri, 22 Mar 2019 12:01:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60BD36B0008; Fri, 22 Mar 2019 12:01:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6916B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:01:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so1133741eda.16
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:01:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sZXQlk+DxBnMATLaN1dKjyebPt1qOGABypFk+3vFsYg=;
        b=pXcifjFwPGeUy9TeQL6EB3ymJwcikjn+9bnqm20HJETZgj6tVAwvazIgU94K19LEZ/
         h51s8NqvHhHaeY5R3kkqV7aAkm1AzkquWfJQ9HC6oeRaqnNxawmlhS2OvrQvW5keLnf3
         Oc3BMr0b+rVID7XTqB/tGvmkbDmFhQMh3tpl3nuU9KNDKRQ08BHmeSL1YfBwOEKo812u
         xSl/npbc2jidGTTjskBUQqaEvQAXwWKkcSj5LeutMwq8SOJG1DgbLAm0DD5UbvG1UbWv
         5QWdlq/bdZCKj08//JBRPX/pPwlPwJ0x4hHHjstPXbLoZsXYBJTZBOl9iFn55fYmxfii
         zcpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUJp+F3w09XQ2JjbYRxeElerwOGhJ4EGw1u9L8NYnx7++3Zjjth
	KomjRfrrMjVbSndFpTubp0SGjqWY++87O4UkPyYlRL49YPwDN0mqnDnErwpeeWhGUCo9I11s4bb
	Qv0sDmSL1o83gBEK3jZ5dKn/5F98bAYF1zYIKyU+nrvaMGl7svV1Qaa9w+c+HleVxXQ==
X-Received: by 2002:a50:b1d4:: with SMTP id n20mr6673408edd.108.1553270470636;
        Fri, 22 Mar 2019 09:01:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfdmaJbuG1eavfVhUC7e2MLh+1bn+3QzTKWe+St9oGCR3HmKrOyQ9K4lJNSNvebYBDxAM/
X-Received: by 2002:a50:b1d4:: with SMTP id n20mr6673335edd.108.1553270469572;
        Fri, 22 Mar 2019 09:01:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553270469; cv=none;
        d=google.com; s=arc-20160816;
        b=Cgcm7M0RmaNZ9O2sKEogJ+KDBvehCXpMru4ngkTbQ/cITm9YS2yY7l+FJP8hRtiOBB
         FuWmxRQU/qaagvN0EOAeZe7cVQUjdbjRA0Ap9h4khWkdMXvBiHEApt5hxcv/UO9sqIhj
         TDWaJoolC6+UzLJCFK9Kt8Z4ecBhFn7D+RZYh4XFiPSNNpUWduuqbL9tSQNx/3rleGjL
         5i9ngg/V7pXEGsN2aiA9uiwAAbOLv5oxlZZhQAALjRZ46mJC3G+iIsWyMHvU8PobiPkO
         Uf69gJ702ahVCIn1GbsqaYq4FgSBjXdZ6Ylg6oA4/wYFJYrEpFQk2E75f13zYsAgYJCt
         EEfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sZXQlk+DxBnMATLaN1dKjyebPt1qOGABypFk+3vFsYg=;
        b=yfAFUhy7IKQrRvQq3s//UrQhqwLznP/ri3wMYHaTaSK62aXMsvxkclUgk8B1Wl+vzz
         P9kL3eb5YPOcrZ9hM5IkGuIlhRfQ0+qFDtwKw6vah5vNUAo14Pb2NwlaBDWTzwgQ9Iyo
         g83SbFBDsaZb4CIhgmskLseFrH3TLsMhEMmCTUxK1jyBF2AlXBvJTjiODt/Pak9+n+1i
         qxTsJcKhDhClsNDj/Na5x4t2mHn8XbsqswaDNQ85x0wCqa0szVHyp0tuahF4u4luPIb5
         RW4IY8jmIIMO1sr+JXB+mFyVGOfBrm4hhwKqRvA/ubJ739IgjKXxRqanX3zYE0qP49CS
         73Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a20si76726edd.353.2019.03.22.09.01.09
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 09:01:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 46CAB1650;
	Fri, 22 Mar 2019 09:01:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6102C3F59C;
	Fri, 22 Mar 2019 09:01:00 -0700 (PDT)
Date: Fri, 22 Mar 2019 16:00:57 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 15/20] drm/radeon, arm64: untag user pointers in
 radeon_ttm_tt_pin_userptr
Message-ID: <20190322160057.GU13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <038360a0a9dc0abaaaf3ad84a2d07fd544abce1a.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <038360a0a9dc0abaaaf3ad84a2d07fd544abce1a.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:29PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> radeon_ttm_tt_pin_userptr() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/gpu/drm/radeon/radeon_ttm.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
> index 9920a6fc11bf..872a98796117 100644
> --- a/drivers/gpu/drm/radeon/radeon_ttm.c
> +++ b/drivers/gpu/drm/radeon/radeon_ttm.c
> @@ -497,9 +497,10 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
>  	if (gtt->userflags & RADEON_GEM_USERPTR_ANONONLY) {
>  		/* check that we only pin down anonymous memory
>  		   to prevent problems with writeback */
> -		unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
> +		unsigned long userptr = untagged_addr(gtt->userptr);
> +		unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
>  		struct vm_area_struct *vma;
> -		vma = find_vma(gtt->usermm, gtt->userptr);
> +		vma = find_vma(gtt->usermm, userptr);
>  		if (!vma || vma->vm_file || vma->vm_end < end)
>  			return -EPERM;
>  	}

Same comment as on the previous patch.

-- 
Catalin

