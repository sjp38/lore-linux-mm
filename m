Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29AD1C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E191520C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E191520C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785A16B0007; Fri,  9 Aug 2019 05:28:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 735396B0008; Fri,  9 Aug 2019 05:28:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FC0C6B000A; Fri,  9 Aug 2019 05:28:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 108206B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:28:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c31so59998374ede.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:28:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aptc2LF/zzqfCq3WoHKiATpIya7Ph+iVegpzlEO9b8E=;
        b=kssWZeW6ZmaogF/fx/up7TJZhqWoswozolFny5VMCmXtbaaQYAS2io+oOezj2zzdgI
         hamU1xj6OspMpWxDd1DhnwLImT637eVqR0qKyQ2RG8A1kfuJTfR/C/FEkkliZ922DssA
         CccWkdiIs17EqI9SY7Bspn3HTFIxXEtTUpJTq4V0oI/fb8QV5cPa4Pd2yq77CeEzBLJm
         xQjjHjHA7J/J6+2bXK0a5CC68KF8ks8cdRnTkMYNuhNLb1vt+6R9XgBTdHA+nnOvZ/eE
         POGP4yVH1aCNVgK6QW7+feiLS75P5gCqFfUoojulftjLqa2ueKa91udpWhEdFowBsZ8o
         Acjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAV4Z88e0gSZOS2+ZclU6V9OaYYduycblVkwRuQRnPx1tbH3d/2r
	4T17Bmg/PGCCz0qY1ibtH5DelbQqckOm7R0Cw2HKNUHub6ShI3q9nRMzFbURZWBsbME/AqV5cSm
	iYEOGI27IeYf4uP8Gij4R5PE7432+F71zYcPRRHIK5a7Lt61I+u2EP5QwtZw5BsRFTA==
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr21100458edq.292.1565342889642;
        Fri, 09 Aug 2019 02:28:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe45G/BmyoH9E2H1afgQjShT7No/TyO3iYHUEgILQUcaFZhlU5WV5Dd2VwyqR3bzEOHN3G
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr21100420edq.292.1565342888886;
        Fri, 09 Aug 2019 02:28:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565342888; cv=none;
        d=google.com; s=arc-20160816;
        b=bBeDDg4hW41gqIdF4gjCWcBYsIto2WE74faUaLbNVp7bK71bIXQJecgq6YDPawHQtx
         TDq0xUu8dxK5UWHxtI0JWI0s5LSRPO7YUoIBpJUVx5hznPx+JZ+cWJO7PHY1JKxFiK8q
         UJV0bDVhzK066qsv2W688ecRwPpLn6LzgSPn3pcCN6IPdNwMXJn1htQkeleiluhXaDKG
         kBBVuFNYt3i9O3GIkv/M6Nm76qc7CM5q63i5SeoA4pZMoERvh2nEpwwcSU6GyVD8IdNG
         qXFR+xycUqf0XAzb6bxJim6Eq6HR3YO/Ly6s9neEab3Ssid/rmwx2SRPu5/ZwQn886j2
         hQ9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aptc2LF/zzqfCq3WoHKiATpIya7Ph+iVegpzlEO9b8E=;
        b=GUcb4c2PTbqVT5sd6WS3g/Ck68q+0kIhTjMMC8nsuEPsWK6tz9eUptuGT7qiC0+f1q
         Sxa9RsvAJ+/s7W7OMV/G8xW+1iziRwoEmFJ1H/gEX6iiwZZI9tli/0DmsDBjiDskZ05R
         d2Ccy6LU/v9s8Bq9dkIV7WyWZ9UXThKsiXFVB94g4umOFYzNmLsiXg4ckBg4oxnUBH3D
         HUMZi+/bx/wC9VVvrOyja6P1ItdFQDguQmc3xW6MHPKbwBHv6iETQ+lE8sEmzKWmck/Q
         MaCpKnX6pQzc26kp6faAYdtIvvC4N8e8KZ+ivtyXaSfPKN7+YMiiOjdYRQOhCLsZSCBD
         yKXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g18si33293242ejw.180.2019.08.09.02.28.08
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 02:28:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D4D7415A2;
	Fri,  9 Aug 2019 02:28:07 -0700 (PDT)
Received: from arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EA7C43F575;
	Fri,  9 Aug 2019 02:28:02 -0700 (PDT)
Date: Fri, 9 Aug 2019 10:28:00 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Mark Rutland <mark.rutland@arm.com>,
	kvm@vger.kernel.org, Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, Lee Smith <Lee.Smith@arm.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will@kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190809092758.GK10425@arm.com>
References: <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
 <20190806171335.4dzjex5asoertaob@willie-the-truck>
 <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
 <201908081410.C16D2BD@keescook>
 <20190808153300.09d3eb80772515f0ea062833@linux-foundation.org>
 <201908081608.A4F6711@keescook>
 <20190809090016.GA23083@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809090016.GA23083@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 10:00:17AM +0100, Catalin Marinas wrote:
> On Thu, Aug 08, 2019 at 04:09:04PM -0700, Kees Cook wrote:
> > On Thu, Aug 08, 2019 at 03:33:00PM -0700, Andrew Morton wrote:
> > > On Thu, 8 Aug 2019 14:12:19 -0700 Kees Cook <keescook@chromium.org> wrote:
> > > 
> > > > > The ones that are left are the mm ones: 4, 5, 6, 7 and 8.
> > > > > 
> > > > > Andrew, could you take a look and give your Acked-by or pick them up directly?
> > > > 
> > > > Given the subsystem Acks, it seems like 3-10 and 12 could all just go
> > > > via Andrew? I hope he agrees. :)
> > > 
> > > I'll grab everything that has not yet appeared in linux-next.  If more
> > > of these patches appear in linux-next I'll drop those as well.
> > > 
> > > The review discussion against " [PATCH v19 02/15] arm64: Introduce
> > > prctl() options to control the tagged user addresses ABI" has petered
> > > out inconclusively.  prctl() vs arch_prctl().
> > 
> > I've always disliked arch_prctl() existing at all. Given that tagging is
> > likely to be a multi-architectural feature, it seems like the controls
> > should live in prctl() to me.
> 
> It took a bit of grep'ing to figure out what Dave H meant by
> arch_prctl(). It's an x86-specific syscall which we do not have on arm64
> (and possibly any other architecture). Actually, we don't have any arm64
> specific syscalls, only the generic unistd.h, hence the confusion. For
> other arm64-specific prctls like SVE we used the generic sys_prctl() and
> I can see x86 not being consistent either (PR_MPX_ENABLE_MANAGEMENT).
> 
> In general I disagree with adding any arm64-specific syscalls but in
> this instance it can't even be justified. I'd rather see some clean-up
> similar to arch_ptrace/ptrace_request than introducing new syscall
> numbers (but as I suggested in my reply to Dave, that's for another
> patch series).

I had a go at refactoring this a while ago, but it fell by the wayside.

I can try to resurrect it if it's still considered worthwhile.

Cheers
---Dave

