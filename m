Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9C85C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86177204FD
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86177204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243A56B0003; Thu, 27 Jun 2019 02:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F4208E0003; Thu, 27 Jun 2019 02:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BC028E0002; Thu, 27 Jun 2019 02:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEC286B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:15:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so5210137eda.6
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:15:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HS5i53Hat81fRjUsVulXEOB2b8vHNdtbUcLw5grdKPE=;
        b=R1QGT4lGDt+gfoSpKtU8QoRS1SH0c8G7UxsnNRafGBsRHEQKDJDHPNOm3B8GdrQacY
         04L8rAGuJ33ruBBLT4H94g5giInGzF336qQyiGpovgKXSKSrkAmQFqJ4jxkttKlqhRLa
         MMj+4YB8FdUkhjdDagFpi0zEM+rXdWdsMjW25U12Ug9QqTOQxvaqYGNWz1gp/zR0C8qY
         bSwy9fn4M1vVDBO0l7dFUbUwLZuvCZDzrfO4pYHwOHUc0+UZmqD98Bo70SWQygTC5kYh
         wUrj9PK2ViBZTFauF1M2M+PM1gdpsAoxJBQVdBDBhWSAPXBQXUH3H0yFZiZ1CcC0M781
         ZJHQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUcVrR58nVa0YAmCN3zDliHDP6Galhew0Qb89YzefYLf0jIxvGh
	5mB6dPjgfEoHVJGAyiH/rleTzdYbaao+yfL0X3SyAJVQcFKlov2yEkzmshMAyy9SMLH9bEJjg9C
	ErUnjCaiuM/3Kag7IvLo/taPCvT1u3zisJ4oP/axJqjt8RwDY/t6+qxvSMf6Rito=
X-Received: by 2002:a50:f599:: with SMTP id u25mr2008988edm.195.1561616138273;
        Wed, 26 Jun 2019 23:15:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGTMVL8RATHBRXkC4EWSPNkaTUCmxh+/J2VfxBZceEpB6qujfhtOLU/dwEdL0+OTo8Gtgl
X-Received: by 2002:a50:f599:: with SMTP id u25mr2008926edm.195.1561616137428;
        Wed, 26 Jun 2019 23:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561616137; cv=none;
        d=google.com; s=arc-20160816;
        b=wfkXjqwKcOtyiYzJMy3K1w+wkssWnMnykAaiLePiE6rcrBICgjhUyhiGvs0SBdJwaI
         8DaTcygtuqapOMVYK9vAUspUuVGCtfZgSjuxhCnMA4DYRuoQHwBK1XoomYx3C81RsHxc
         Nw52OyiwEwFnHTLMOTwt4EVE0+uBbgDPWxXjRZTQdmLdFs3/mk2l0fjRKP/TgVHR2BeB
         4fToH2v+UrQbMycge4ttsMzPfTUu1jba4RSGNedHzgCVsU444M1u3jK7Z8gU/HU67hXh
         yfbvC2I0028cYx3CV2PkSXoSfjy3hwRosBje6jlkp7ZNmEGtNKZD+W+XSbhA7Vr//Ey2
         c7fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=HS5i53Hat81fRjUsVulXEOB2b8vHNdtbUcLw5grdKPE=;
        b=t2TSXohsO7ZMuU+5rTHQ5Bp4TsC8Jg1E2Wo04M6QZypufxYWrNvtkj4vV59kbEcpqU
         FhyOPhTpn+/vERFFYzIDYS3Hsxuwz0FCAN3iPyAqJTTWiEhMV/muMZWmYWcLANkaTDZg
         cbda6gHbP8ucB0dZc6n6t22qr5t01XHgze/UVczTbHODGwrx2Oc9VUdRlOxr5el1UwPm
         IPqGshPuY+ybAGHi8ChU78uUIv1fXu2leZSasMgw/I7bh7BzDpaoCoBIZombFn86oTsF
         p4GPzaESS3CODLsp1Kx5V7EHsy8RMhaMenTqPtFsLVvmlbidfqPDHZM+7Y1o0KKfytLl
         DDzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si998760eda.220.2019.06.26.23.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 23:15:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21908AEB8;
	Thu, 27 Jun 2019 06:15:36 +0000 (UTC)
Date: Thu, 27 Jun 2019 08:15:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kees Cook <keescook@chromium.org>
Cc: Qian Cai <cai@lca.pw>, Catalin Marinas <catalin.marinas@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	clang-built-linux@googlegroups.com
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190627061534.GA17798@dhcp22.suse.cz>
References: <20190626121943.131390-1-glider@google.com>
 <20190626121943.131390-2-glider@google.com>
 <1561572949.5154.81.camel@lca.pw>
 <201906261303.020ADC9@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201906261303.020ADC9@keescook>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 13:23:34, Kees Cook wrote:
> On Wed, Jun 26, 2019 at 02:15:49PM -0400, Qian Cai wrote:
> > On Wed, 2019-06-26 at 14:19 +0200, Alexander Potapenko wrote:
> > > Both init_on_alloc and init_on_free default to zero, but those defaults
> > > can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> > > CONFIG_INIT_ON_FREE_DEFAULT_ON.
> > > [...]
> > > +static int __init early_init_on_alloc(char *buf)
> > > +{
> > > +	int ret;
> > > +	bool bool_result;
> > > +
> > > +	if (!buf)
> > > +		return -EINVAL;
> > > +	ret = kstrtobool(buf, &bool_result);
> > > +	if (bool_result)
> > > +		static_branch_enable(&init_on_alloc);
> > > +	else
> > > +		static_branch_disable(&init_on_alloc);
> > > +	return ret;
> > > +}
> > > +early_param("init_on_alloc", early_init_on_alloc);
> > 
> > Do those really necessary need to be static keys?
> > 
> > Adding either init_on_free=0 or init_on_alloc=0 to the kernel cmdline will
> > generate a warning with kernels built with clang.
> > 
> > [    0.000000] static_key_disable(): static key 'init_on_free+0x0/0x4' used
> > before call to jump_label_init()
> > [    0.000000] WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:317
> > early_init_on_free+0x1c0/0x200
> > [    0.000000] Modules linked in:
> > [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-rc6-next-20190626+
> > #9
> > [    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)
> 
> I think the issue here is that arm64 doesn't initialize static keys
> early enough.

This sounds familiar: http://lkml.kernel.org/r/CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com
-- 
Michal Hocko
SUSE Labs

