Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6618C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:37:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D36E208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:37:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="UgJtjkuA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D36E208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD7C76B0005; Thu, 20 Jun 2019 21:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A87998E0002; Thu, 20 Jun 2019 21:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94F048E0001; Thu, 20 Jun 2019 21:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2336B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 21:37:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so3286908pfj.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 18:37:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=+BBLwZtK559RusCbv05GmPVwa01R9tY1N/TrVS8kF/s=;
        b=XM+yPRpMFLh8ZxIe0l3vTMftzB9yiWZVwkYVqoQIegw8ULZdnp7UGjNid6c/ZgafDt
         3Z+fgJOIo0BYsIvFy+q/a7XZ1EyTMXX/4bwzIyNZiqSX74NEFdkVYbpKGseDs0gRQWF8
         e4OKalrBgvG3E4GjgE2332mwS3ySKWStIxj5mnB0h99WRyWUUdKF5lqI0tvEDYQ7nuCO
         uAMfGCCkymOpHNmY87ThrWcRIcgcb1UcbIzI57As9ccyrdKoDzt+HJ+8VPQHFACJLVtB
         vdcXtRPFDY1/fN0auDTW62MW3BWD3C2exGT/TfDS2/zKQFuVwPBMAcMI0FOBzIesXL21
         uFqA==
X-Gm-Message-State: APjAAAUQzbCiM8JRdVSG//lMhwkPymPp5Hh5lvb7rX7hGaaSidBgijMn
	uFiqF79rCMWUxlcC7H9QZ6DCr+WUHC3qdDnixZHKF34IkD3H7IcmrDmkbPTxLLnxCahygWaEqsC
	pRDN1Lh7oGZINXUyzabTHwKz3IXqdA569LdOGwohvqdHvxZHOr4jBkw7BhaDnBOP3EQ==
X-Received: by 2002:a17:902:121:: with SMTP id 30mr122386916plb.314.1561081053984;
        Thu, 20 Jun 2019 18:37:33 -0700 (PDT)
X-Received: by 2002:a17:902:121:: with SMTP id 30mr122386862plb.314.1561081053308;
        Thu, 20 Jun 2019 18:37:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561081053; cv=none;
        d=google.com; s=arc-20160816;
        b=IctE9xIwVu6iGpqjGRCVmJ3u3/1NwPMO0UsUe9rQCj7mBVodCpkt2OXXi2r1G8atsu
         mSpqQLUzS+LAO1t0LTUqDmQBj/zUqWVF7/QTlBjBuSGhzT1egd0z/1ArUBkJzmyozf+k
         iM0/vORJjspjjUybz9cPVpfcFG00IV5ZhPPQIxfl/hlr0SLVUq6Or6d/re3Iu9QavWjL
         NKYAw0Ue13Ck2Gtcib4HEOUXxQ/p/s7/oPad+GTbEVTgfl0RgBWZKfB4e//gpKwPA2m8
         1GDmrRJVX6y1m7dVtr9yD2RHl4qU65U2htcJDIL7wDutssGOYh5vkc0WsCSFTs1aFXlq
         nbrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=+BBLwZtK559RusCbv05GmPVwa01R9tY1N/TrVS8kF/s=;
        b=xnOTY0KUOx6QV+wsOtRgf9WuGiXS14EJQA3rWiIv/ujPu4oKkD+E4YTFymuGNITUDn
         rSYVS1hHlImj0uDJVRf5oKyNwXIfh3s+VtCeGDVPs3HIquuIYRkqM/UPDccP+C+eY0JC
         xU14wlBqrh6wGwqYmxy5gtWV/F2L4//gUcdP4YAQHftSpDThcKrpcwX+rZtz6LLhWOt3
         vwDzVkkBm9JUxtbWjAAXKuKkNL2N5M+pnMYtm8r9+40mLyvmpCfy67D9cY5Y4HywMrMU
         OJDkY0kVxf+JCw9EtpWFulka6CxxATSuZYRmD/34r2TIuL8acyf2aMddQBUgHkOIl180
         SFHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=UgJtjkuA;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z21sor1146756pgl.47.2019.06.20.18.37.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 18:37:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=UgJtjkuA;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=+BBLwZtK559RusCbv05GmPVwa01R9tY1N/TrVS8kF/s=;
        b=UgJtjkuAPfCnrYv5/+nT3DgmraBLhmyJlPrB/1R/HP+7xj5HMoOxBowzAxJKYuhXal
         TUXR4AliTFs+xAYskx4xEjwkCvPnV5s/p3VitrZPdgdQ+pzqZ4eC+e5HFC1HQ72WpDov
         PdJmAQwmEYv2XrO5loF/BkZSQVzjTeTg7Sv8c=
X-Google-Smtp-Source: APXvYqz96MlZh/gHUsZQiQrw95Tphw+Mau0IgtUkGB4/+lWwwoAdzVWZRWZFmnOth83mrBsvYd712g==
X-Received: by 2002:a63:60d:: with SMTP id 13mr10624086pgg.272.1561081052880;
        Thu, 20 Jun 2019 18:37:32 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id o14sm821876pjp.29.2019.06.20.18.37.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Jun 2019 18:37:31 -0700 (PDT)
Date: Thu, 20 Jun 2019 18:37:30 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v6 1/3] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201906201821.8887E75@keescook>
References: <20190606164845.179427-1-glider@google.com>
 <20190606164845.179427-2-glider@google.com>
 <201906070841.4680E54@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906070841.4680E54@keescook>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 08:42:27AM -0700, Kees Cook wrote:
> On Thu, Jun 06, 2019 at 06:48:43PM +0200, Alexander Potapenko wrote:
> > [...]
> > diff --git a/mm/slub.c b/mm/slub.c
> > index cd04dbd2b5d0..9c4a8b9a955c 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > [...]
> > @@ -2741,8 +2758,14 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
> >  		prefetch_freepointer(s, next_object);
> >  		stat(s, ALLOC_FASTPATH);
> >  	}
> > +	/*
> > +	 * If the object has been wiped upon free, make sure it's fully
> > +	 * initialized by zeroing out freelist pointer.
> > +	 */
> > +	if (unlikely(slab_want_init_on_free(s)) && object)
> > +		*(void **)object = NULL;

In looking at metadata again, I noticed that I don't think this is
correct, as it needs to be using s->offset to find the location of the
freelist pointer:

	memset(object + s->offset, 0, sizeof(void *));

> >  
> > -	if (unlikely(gfpflags & __GFP_ZERO) && object)
> > +	if (unlikely(slab_want_init_on_alloc(gfpflags, s)) && object)
> >  		memset(object, 0, s->object_size);

init_on_alloc is using "object_size" but init_on_free is using "size". I
assume the "alloc" wipe is smaller because metadata was just written
for the allocation?

-- 
Kees Cook

