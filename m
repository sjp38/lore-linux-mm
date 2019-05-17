Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6799DC04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FC620873
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:04:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FC620873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA8086B0006; Fri, 17 May 2019 10:04:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B589E6B0007; Fri, 17 May 2019 10:04:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A47166B0008; Fri, 17 May 2019 10:04:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 552166B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:04:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so10867281edi.13
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:04:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1EyqEw0IRsZ2VZI5uuJ81ls0WZbTfJjxH5LRFLJDxSo=;
        b=m3JKt3W2+F0K7xb5hR51YuEIjzsqYdb1FVLUS4df1DWcDKSL7+YKge2lEQZPAEXUyd
         oUL876G+M+TLSSmSX0bYUze8qBc839hcGbqJYKNcq8OEqmHJCpfkmhXJqhMi+OCYSKUl
         Pk0cNGn7PGhliCKCsjSSIqc7YjhdSe8GyBocOzPof4vbjKTpUarCxMmmnwhLkFR6Ttz8
         gUjfFKRIdsLX6UVoMP4+it6uuuqHcdaAuyKtVJEaeh6JjBCFORySgO7jpnh9JeYUFujs
         YTe0zFMTlXimRdIMNHhtE9vyFKuJf3GjSnDY12zbPRg14fjgOrQ0hi4keo6E71eeKosr
         3OLg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXdjbubxuWmh1MNYON0up0QBDFZiFVB7HsioukriDSjWzt3FGT1
	Kje1a4tFaVLWtrFrjc1emkoRjD2KiiIRBaKOSlw9Ni/bxbjg2Z9Hp6MZPQbVTNr6UU1SSuS4A7V
	w5Pv4bY82o8vW2RTXyaR2YDk+Gq78gG+W+MQIPRF7KQkJF4clEbvvHTjK7vxzMx0=
X-Received: by 2002:a50:f706:: with SMTP id g6mr7106786edn.187.1558101887890;
        Fri, 17 May 2019 07:04:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydSbUeq/FyYt5JWaA9Jf3wrYuEqAH092CV0X6Nuul0+ixRGxJNrcXDB2xwxlsInrGO+nsr
X-Received: by 2002:a50:f706:: with SMTP id g6mr7106685edn.187.1558101887028;
        Fri, 17 May 2019 07:04:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558101887; cv=none;
        d=google.com; s=arc-20160816;
        b=lwSqNtEjyKYGL285IfZP72gTi7AwPHmD6hJ2q3IhW0Z/xoOtqYV6gvrVbA2rvjZCKx
         9/HGgMesNQq9FSOXoA5nwT/hNSlwCmMtx2zmfv33wai0vyF3WMxY/ld1sz9TEJUJA5os
         rrjC4FxAOOrmoCFNDz6yG/Mut9zsRFjr5UF+/hYD0FhYzGtMvI4x2PTGkrqiO2870MMJ
         xzATEQ8E7SM9j5nrB/KRbcbhCwam4+vAsjwxAUq4e1XuzHv8RkBa/NiquiVNdo4Qgxok
         EZAfyxjb08tUplbmjTnLw9XQja288qjKZvuHDGjadfWdg0Bm3rbHeWYTGN5PNUgkdT4S
         e3CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1EyqEw0IRsZ2VZI5uuJ81ls0WZbTfJjxH5LRFLJDxSo=;
        b=Bh16dsrTjLIIaBTF+Lbu+HN6M1PmtB4ZWAHgKJL/rW9qw14JyYcciTjW6WY9JTRD+z
         RrygkVIbTpi2vzi/1u0y+Sv/1oOHsMEH4XndyrWijVx3Bv+2PSpphMBZBydYMt9EcMUZ
         Hh+CVgXwWaF3KRcAfRoP+HuWyqUQmtG2YSD79EETJPneTqs/lYUsb5/zWAyjQ6hbwak9
         YGbwEyvhJVLAxmD6dGBDSZYyjw6NbLv2sQ9bJBWzxbpgMrDgux2ixpwl3wpyF1w1vAhO
         7eoy1JKBoY0EnxB64f79EAq/JapACT+EPoGNLRsKFv9I9K5TWvDH+IcPPsaBmH2UedLL
         NQVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si1329328ejp.82.2019.05.17.07.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:04:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 91A89AC38;
	Fri, 17 May 2019 14:04:46 +0000 (UTC)
Date: Fri, 17 May 2019 16:04:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190517140446.GA8846@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-2-glider@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 14-05-19 16:35:34, Alexander Potapenko wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.
> 
> init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> objects with zeroes. Initialization is done at allocation time at the
> places where checks for __GFP_ZERO are performed.
> 
> init_on_free=1 makes the kernel initialize freed pages and heap objects
> with zeroes upon their deletion. This helps to ensure sensitive data
> doesn't leak via use-after-free accesses.

Why do we need both? The later is more robust because even free memory
cannot be sniffed and the overhead might be shifted from the allocation
context (e.g. to RCU) but why cannot we stick to a single model?
-- 
Michal Hocko
SUSE Labs

