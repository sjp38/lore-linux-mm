Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A3CC04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AE302087E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:59:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AE302087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91B5B6B0271; Fri, 17 May 2019 08:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CADD6B0272; Fri, 17 May 2019 08:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 793A46B0273; Fri, 17 May 2019 08:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4046B0271
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:59:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h12so10518801edl.23
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:59:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NxiIX4pkvmTErLEIlvSENAMKbb+My/ngwjfRnrWH1ds=;
        b=kE+bOGYtrjkJhos1xOxkbyAXjgS6zf9dsycaEmeTOghfDDSbF/bXujUc+9C9cvB89D
         lHslH+H8yocZ97cUdI0jqdUk3zXK4gQVUaSJk4KKWSh2PaTicVC4oaiHljxguiHMz6uS
         r2Seqij79QXYmO6KdVapAn5BmD53aXrPKxxAYS+BGyVwrR37ysUu3mcaFNK2Fd48/YMp
         z9SJLEQzfV2a+fX7oLyI2SfTgtR0V9pMHjZ3YA1Bb7iVtfPCh3oXoDkY4nQ9UrfK3cWP
         vIO3EHRy5LlLURPn0Jra7jZcYx/nuU7XBVvJISVELzYIdTzfhdy9oJXxa3wrKCz8bob0
         7ueA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX++7lvjyROvX/nRtytxCB4nMt5BzY3cdp9CLgp/uduuVHOBBq5
	guXt1mNkK3D8hjwXNJsAYRrNSZSprZm2y5NT3QCdv5RxVu8BjxbLX1eEHuv/TgDH+SwF4jLSj97
	EFaYOJTlgMJCNuFjuOzwzI9GOj6cqfu4o+7VeC0f28ZfRRcG/dZ5faTkpjw/aKVg=
X-Received: by 2002:a17:906:7c3:: with SMTP id m3mr43483597ejc.145.1558097959765;
        Fri, 17 May 2019 05:59:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+vVLNnn2SYt/QOYibnniq0ZynaHBwp5LB1GKfOf6AkWi8OBWO1D2OTO/ENLaTNUx2jkDY
X-Received: by 2002:a17:906:7c3:: with SMTP id m3mr43483557ejc.145.1558097959063;
        Fri, 17 May 2019 05:59:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558097959; cv=none;
        d=google.com; s=arc-20160816;
        b=NouNAsRg4VY+3aYn26htl61AarDwMKmISVqlAdIDskevzzsQH3I5lfqtFM+nNb1XOz
         GGCRVKlvrhTCHuzl7VTTs/wIKXqEAWKrzjJsVN9paJnfb+l9J3d5DL6O3wC9XIYpUZLq
         18e/JLXftX4jD5dKOAfA5y7i0X4jPEwTyoofQEKpgdfkKLvvI6Gn0l1wGil9RoC8bgic
         TLrsrUdtf6IVhqOLXtZCozdbPWoLw5OOkU2pCuxCFR2Cq2v7v3LUo62efXHBsbhVg8N7
         GGB/WmTd0Izju/V0Ik29hKfCI2gpemUcK+EbglpANvKCPhtWikauwrjhaaQ9BSsmr/1J
         rt+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NxiIX4pkvmTErLEIlvSENAMKbb+My/ngwjfRnrWH1ds=;
        b=KIagcQ8zlqbRPhPBg7rDvULRUYXpuNLoEDo25DKlsonoyItYpO9xUjZqc17pNn99wf
         c4GT164A2uyHAsA5inSIqq9joAxrNfS1zkqf7k+eIOqG5qQw3QbstGF99Ldf97rjaUGy
         /9x+HKBoOKZ2OExYmBlKVy7ITEsg8nttkjiHPMRnij0Tvnat1XDP/K5D75lkZtx1AO3v
         6hTbxyVp6LbEUagl2OiBDe1XjgDWM2suAKptabO20wffUQfJWKU2K37eucRvwCLXN46Y
         CsTmBLOLe3hiAplb9FkUxkW8MykPz1ku0nGZqAuVHAO8OAzAyn8qjrrpibX122pYnxWj
         vwyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ka15si5588408ejb.266.2019.05.17.05.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:59:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5168EAB92;
	Fri, 17 May 2019 12:59:18 +0000 (UTC)
Date: Fri, 17 May 2019 14:59:16 +0200
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
	Mark Rutland <mark.rutland@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
Message-ID: <20190517125916.GF1825@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-4-glider@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[It would be great to keep people involved in the previous version in the
CC list]

On Tue 14-05-19 16:35:36, Alexander Potapenko wrote:
> When passed to an allocator (either pagealloc or SL[AOU]B),
> __GFP_NO_AUTOINIT tells it to not initialize the requested memory if the
> init_on_alloc boot option is enabled. This can be useful in the cases
> newly allocated memory is going to be initialized by the caller right
> away.
> 
> __GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for SLOB,
> where init_on_free implies init_on_alloc.
> 
> __GFP_NO_AUTOINIT basically defeats the hardening against information
> leaks provided by init_on_alloc, so one should use it with caution.
> 
> This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL[AOU]B.
> Doing so is safe, because the heap allocators initialize the pages they
> receive before passing memory to the callers.

I still do not like the idea of a new gfp flag as explained in the
previous email. People will simply use it incorectly or arbitrarily.
We have that juicy experience from the past.

Freeing a memory is an opt-in feature and the slab allocator can already
tell many (with constructor or GFP_ZERO) do not need it.

So can we go without this gfp thing and see whether somebody actually
finds a performance problem with the feature enabled and think about
what can we do about it rather than add this maint. nightmare from the
very beginning?
-- 
Michal Hocko
SUSE Labs

