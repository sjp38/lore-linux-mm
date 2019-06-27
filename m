Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7278EC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:57:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 355932084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:57:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 355932084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B487B8E0012; Thu, 27 Jun 2019 09:57:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF8868E0002; Thu, 27 Jun 2019 09:57:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E7798E0012; Thu, 27 Jun 2019 09:57:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D54D8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:57:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so6021874edx.12
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:57:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fIOfIHcnikQ/TlYD838QZqXjboKob8PhQ1t+hiWlKvg=;
        b=VWo0ODvglsIb1FO0zVR/WFY3Fho8DLksBuVPoVF6WjLulawbaiMA/YQZ1eAXnAy8RL
         5dh4DX2S5oJNgP8PBOJvIsRiz13dqN4JXrCtlrl7EBkaItu6iR8+DvzuAckjkQoiOtmC
         ulbn8W84diunMkH3PazAAaotFF+2AqQfcrFisBbfXUOuQ7xQ3yWPvOaQsnH15GHFWw9P
         iLa5k2pr8QvGLE/BWUfV43I3wgunKbYCUK1H1IpKOASBqnfGIaf8i86Su/O0I5x+k9Hz
         XKWV6YePYrP/J1Yof7EJ8xr6SDoYHLi6XhXXqMGUqkahIFFoC1JMCBPgIMqH1n4PtVVC
         0hBA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX0aEpf3vRxFjasFTKdS9+poZ/nf01YHehIH4zf++OqA+Zr7xYt
	IIeIH/iEoNWY9KnqMNOndSVJN5URYl0Xpc273B4N7eiAG726L8uyQ6dSMhZlUB3QHaUk18mspxL
	WcVIPXq2XQEXUjyumVJx7bvOPIXVtMc/M5RSBPH6RBggf7E38zLXPYx9U7L1hD6k=
X-Received: by 2002:a17:906:4ed8:: with SMTP id i24mr3277141ejv.118.1561643860676;
        Thu, 27 Jun 2019 06:57:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl6pk16cVltB/9OYHXziQNbxwE0JbVMFWnjo8ytMCBEV3aXHmghd+vvnWNyMg8o1Jd1tiE
X-Received: by 2002:a17:906:4ed8:: with SMTP id i24mr3277088ejv.118.1561643859869;
        Thu, 27 Jun 2019 06:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561643859; cv=none;
        d=google.com; s=arc-20160816;
        b=p+IeQ2jLFSjDuu1hV3/BGa7wN8/LTqQeSjDxR5SxLls8WA6vqk0WjHc7vRg72DHkNj
         +AGfUTx+BVacaA5NVKvKZo+7WT7Shn+fg6/H0onOSW2KprtCBG/pUQngP832nY4JOyoT
         poiQadM7bSq2dPvR1Py9c6YFotK6Bd5BVOYC8WtboDE0F36jljzq9rN8PYDl5kAOOwbk
         qO2GJkGRiyevmAXnd1dKVaQM8Bv2K3JBr7uDaR4fz/zepjHSOb3NrawXX0qg/VMRj8O5
         9CER7+O+EkMZ41zh5PMk1eKzfjGWbpaLxgeBkBvQY6BsgN2XOKIaankVpaPimUgTgBJa
         6N/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fIOfIHcnikQ/TlYD838QZqXjboKob8PhQ1t+hiWlKvg=;
        b=KqDvRddZx3xRfKX7qnjjw+L+AwjncVf3ZDipISzRkrfe7C3wtausohDl3T468uIfm7
         v1olNMtilBinJfzth7IMkhUFZ/3YfBrgd90qQ2hGDJqc17gd3N6l2qF6E5Eq5GTWSPoG
         GxJrgbqmA99epe6qU6eyvFhZii6WjmNKLCv/3pt8FpKD1S1EEHCHX1Uell6nk+ZkyQ0D
         5Ti8n1z+zxKLEf1KHak5SEfw8Zpj+/k8ipLnRt/ESXiUIT6f8QQXyHzBSEQXNzj6yrDN
         ivE3W1Vhjd/J08Nji8aiNnkgkVFqBJagslZl8/U+ZIqOn3Uvc0OZu0gqOc0Zy2UQk9wc
         9g0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b32si1707592eda.254.2019.06.27.06.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:57:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A2CDEABE7;
	Thu, 27 Jun 2019 13:57:38 +0000 (UTC)
Date: Thu, 27 Jun 2019 15:57:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
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
	Qian Cai <cai@lca.pw>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v9 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190627135736.GA5303@dhcp22.suse.cz>
References: <20190627130316.254309-1-glider@google.com>
 <20190627130316.254309-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627130316.254309-2-glider@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 15:03:15, Alexander Potapenko wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.
> 
> This is expected to be on-by-default on Android and Chrome OS. And it
> gives the opportunity for anyone else to use it under distros too via
> the boot args. (The init_on_free feature is regularly requested by
> folks where memory forensics is included in their threat models.)
> 
> init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> objects with zeroes. Initialization is done at allocation time at the
> places where checks for __GFP_ZERO are performed.
> 
> init_on_free=1 makes the kernel initialize freed pages and heap objects
> with zeroes upon their deletion. This helps to ensure sensitive data
> doesn't leak via use-after-free accesses.
> 
> Both init_on_alloc=1 and init_on_free=1 guarantee that the allocator
> returns zeroed memory. The two exceptions are slab caches with
> constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> zero-initialized to preserve their semantics.
> 
> Both init_on_alloc and init_on_free default to zero, but those defaults
> can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> CONFIG_INIT_ON_FREE_DEFAULT_ON.
> 
> If either SLUB poisoning or page poisoning is enabled, those options
> take precedence over init_on_alloc and init_on_free: initialization is
> only applied to unpoisoned allocations.
> 
> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)
> 
> Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)
> 
> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.
> 
> The new features are also going to pave the way for hardware memory
> tagging (e.g. arm64's MTE), which will require both on_alloc and on_free
> hooks to set the tags for heap objects. With MTE, tagging will have the
> same cost as memory initialization.
> 
> Although init_on_free is rather costly, there are paranoid use-cases where
> in-memory data lifetime is desired to be minimized. There are various
> arguments for/against the realism of the associated threat models, but
> given that we'll need the infrastructure for MTE anyway, and there are
> people who want wipe-on-free behavior no matter what the performance cost,
> it seems reasonable to include it in this series.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com> # page and dmapool parts
-- 
Michal Hocko
SUSE Labs

