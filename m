Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB5D4C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:24:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85DBC2133F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:24:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="gSaPGz9S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85DBC2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DA8C6B0003; Thu, 27 Jun 2019 12:24:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1649A8E0005; Thu, 27 Jun 2019 12:24:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 003F58E0002; Thu, 27 Jun 2019 12:24:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE08B6B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:24:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so1870446pfb.20
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:24:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=/8WNz6km09cjJozBXv1ttJOzdwKWqBjOCAwXZrmYZQY=;
        b=Mh34PvSckwiKDoEi4NIZV2mPPbgxRg7NwQ0E4B0rJ4rH9SUDUXta+JDhLSleOHc0nS
         PFQgFh0gx/9J/xJiG090jgDYqzIkeI48uGDxwsAu/8OhHvDLQg+f6b/De4WYm9mvW8Iy
         AT6aVxHC4eF0wIU4lo+merjZ7/H6kMSqAx2So/O+xLxP1IomCCeiCNCvzIW1IsjhIDb9
         eUi1AdX5t47iez5D1fzcjQeO1x2UGM1ZfYWVvdWG2YVKNgw5V7sj4HbWobyICMOury6Z
         WJPYwk3XMelSr13f+7tDkI3joFrlr+Vvtr+xPw5PTWLQUQGQOtbxP1Gb22i3kBwVV2SL
         UeqA==
X-Gm-Message-State: APjAAAVqGs9BGz8jwV5yYbsNGlJc8SZnocF2m6esT0vJ7jG1qCr4eS+5
	/G+0y6Gan7tuXlkLeRPlMZEtwdmOeW6R5FK4vP++pUFErVgBIkG8XXICKGLhUMBW05yKAyom3NU
	qcGgOJ7B6MQ/SWk91NJ4uwLziVi22/tff90s4DeZSDgt9q0RTHmKMukgyHy4189Dw5Q==
X-Received: by 2002:a17:90a:2743:: with SMTP id o61mr7027137pje.59.1561652640413;
        Thu, 27 Jun 2019 09:24:00 -0700 (PDT)
X-Received: by 2002:a17:90a:2743:: with SMTP id o61mr7027091pje.59.1561652639817;
        Thu, 27 Jun 2019 09:23:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561652639; cv=none;
        d=google.com; s=arc-20160816;
        b=zN9Ml+PphMTLEDqyRUoNJmvM6FbU1Ft9UNH2KO2EMB8Vjq3Ygww8wwl2Hjg0ODOTQb
         5kK+lX7ot4+fTZhzxkPVH6zLocYjNq8YvnEJ06ane+fEak/TQpdFuRU4dwAxdNO/hc3m
         ALQhNwiGg71si4ypMHCbL2TDyvXdQK+U0TeBOXrZl2Q2nIYKJdxfbzS39Uc4noaHOj91
         EBxG1fxeUnEh0CQa4iyeFC9jamLnK/4Y0o4pnShRFXujAaSXYrCqT5gw5qufni24YFAR
         MRCe7uiHlsON8BZSy2PEM0nt66o5ShY6jgam19GHed1U9VrN/kV45hPcy6Tt1dsq2p5X
         A5+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=/8WNz6km09cjJozBXv1ttJOzdwKWqBjOCAwXZrmYZQY=;
        b=mlwdaeraj1tv/wzyU3B4++M7tCZ17CX9qQSaah0u70C4kbs7rMS0PjjMGJST4qG9dj
         xqwInO1ZCLzQ1GiOxR8iF9XvT7wdr1BfLJLHDk2utERvreCxb0w4WVsYPco+CTZLcTej
         /aLjANCsTB2BNDFtIVBwMgi6iUeT+6bWVNiZ5Y2idLvyBhEitOqY49ra769u+wnyeQf/
         gueownldeVRH7GEx2k8ZMHnShS7Wov681Ws8MkPvUuoT2npH5vIgJBStNJAVP4QBDOQY
         2WNXBx0ucp1tzosY/JiHv/5ViZMg/jwgCm6UJdeYcxUOGyYtWLntP7BghZ8oKkOf0oJx
         wlLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=gSaPGz9S;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor2989946plr.24.2019.06.27.09.23.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 09:23:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=gSaPGz9S;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=/8WNz6km09cjJozBXv1ttJOzdwKWqBjOCAwXZrmYZQY=;
        b=gSaPGz9S5mfM2IyW50EIddVjXzosJmFwIvLy5/3d96Mmi9TwrjccATn1f1RZjIlMFe
         g6G3RU+uVrFmGFVIUCd9KSLCraVscKPuB43D5SpFa4Cv14trV2iOCfUw1w+dnm1He+No
         Zzm+bbolLanUL6IWtcmRDluyh9DqPXsyiUfrY=
X-Google-Smtp-Source: APXvYqzwszuLB5KUZT0GR9HWRZ7xGjWVY5pOYkuBOrrtrH5Vd2d27l5XG9aT2UNpuYPJaeE7Xhvg+A==
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr7015152pju.63.1561652639486;
        Thu, 27 Jun 2019 09:23:59 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id a3sm6766104pje.3.2019.06.27.09.23.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jun 2019 09:23:58 -0700 (PDT)
Date: Thu, 27 Jun 2019 09:23:57 -0700
From: Kees Cook <keescook@chromium.org>
To: Michal Hocko <mhocko@kernel.org>
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
Message-ID: <201906270923.C73BAD213@keescook>
References: <20190626121943.131390-1-glider@google.com>
 <20190626121943.131390-2-glider@google.com>
 <1561572949.5154.81.camel@lca.pw>
 <201906261303.020ADC9@keescook>
 <20190627061534.GA17798@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627061534.GA17798@dhcp22.suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 08:15:34AM +0200, Michal Hocko wrote:
> This sounds familiar: http://lkml.kernel.org/r/CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com

Your memory is better than mine! I entirely forgot about this and it was
only 2 months ago. Whoops. :P

-- 
Kees Cook

