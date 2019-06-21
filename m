Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC58BC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:55:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6E232084E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:55:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="AKwtxhlE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6E232084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334A76B0006; Fri, 21 Jun 2019 08:55:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E5828E0002; Fri, 21 Jun 2019 08:55:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D40F8E0001; Fri, 21 Jun 2019 08:55:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC5746B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:55:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x17so7411121qkf.14
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:55:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=AmV2+dUM73e06WwcPyFpqf/fAKS1T6gQn0zr0KXsJgU=;
        b=JcAj7rebS0oGTnhZXqwVwHJP5CkVsx11WwLcDhv/Pt2ftEpXNRQF4oawwEYX2k7dF7
         ZY4i1wdVyXVqgdKQVJj3KoXniu1EOuMa2ITxfE7u1Y2ca6DW6LQKidfBbf1UhfkVnHuh
         2nBD9nJmAvXZ9Uh1uz8OA5xCZVsRwZxRC/PqAp3ksXKCFvFGJ/bsqqQKZUjRqW9ivg0l
         O/heFYYx+So79+EI0df/KLDwjffs0+A/dsSv+Sc9R5Hd4tXlrkbGAANqFudAXQ8fWwSC
         A7p1EGZLDYGPhRiiXjv4YlCKV6C1X7a4Y+WqHvDBf/IGo6NCrV+O/ElOTJgzbK7/m15g
         u0Eg==
X-Gm-Message-State: APjAAAUdEK/hXIV+OoMFRN1AAy2namJ4pheTntggLuriGshEopCm5V12
	ntCgk6QcIIbpBzCsLBj4ASVtPHnsoZFIdGyc14YEU9LjuBWfcj+76zlkomhi8gN3kXjptj+a9mz
	CKI279cKDvx3j9nbNRSdh5puFOaYKBbD/AXuGW/sslYNk6xLRiPTXpEEsGYZfhnxwfg==
X-Received: by 2002:a0c:af57:: with SMTP id j23mr45033400qvc.241.1561121748647;
        Fri, 21 Jun 2019 05:55:48 -0700 (PDT)
X-Received: by 2002:a0c:af57:: with SMTP id j23mr45033363qvc.241.1561121748028;
        Fri, 21 Jun 2019 05:55:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121748; cv=none;
        d=google.com; s=arc-20160816;
        b=YSNmM1meZxnRfoCqfU5rXpnmi3U8rB8oIhXuiS+zwbElP2yziyLpinxGHRrqt16bSC
         8WNK9Ay9X/4YOPoTr1M9qS6ebTk5yxH6HI0DiJPltOPEqAsjF0lu0FCrsXkMfyC0Av8Q
         O/1kfTv0yXXqKXyqzqTfarpT9rcg+paHiZ5L/CVyIpYnvviw4iCq9oQT89bvnezv3PfE
         vDEO2xQHZiEg/xHci82qvAH2YTVOsEokVerivrwWRbzdxNXgj5Ffw8EqAXL5FgJFqyfB
         3UwXo1XiBMSyBxlaxfy6lAAeExMSqna/o98l7/56UTrXaZ9ECYs0KDC1bLSftfy6CZ8d
         nU+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=AmV2+dUM73e06WwcPyFpqf/fAKS1T6gQn0zr0KXsJgU=;
        b=e7Dw/ozwbbyI9GlZGwE1wM2hPqshQExGgco/rSORkuaRZZ+On4gAbcwubjbLORdC96
         xcYea00Jm3YL1RlO5VX/XuhVBUKpaHdyDGRxBBEzz5gL2lfiZFIEW/mIhrfU6xCpN1mm
         rqGW6v/MQEFbsfAlcJsnJd/HXqfQ4oJfi78G74q7a53Y6fKMxo7k3NYlxZD/siNu7/Zw
         zxEtGQX7JM8kkE/MvShTrk5fjzm0IBzDPE5meHCuMpQJIn0Yf+ZSnZoZFrFGR4kEpJ3q
         ghavHpcd6lijaRR9W0cczZpucfAl2HcodKKZ+0fsEdVal9Ro2CpFYoOYa2YAh6Wo6rIF
         52cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=AKwtxhlE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor4052588qtp.61.2019.06.21.05.55.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:55:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=AKwtxhlE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AmV2+dUM73e06WwcPyFpqf/fAKS1T6gQn0zr0KXsJgU=;
        b=AKwtxhlES3SluAiJmC4fHfZzQIZr6NUzu5K2S/r8+Waw+ZGRthsBAeI1/X4Gu6crZ4
         JmrOO4AwR4dG9YlWuzlGGy2YsbTZ5bGzbzL75yCIwMHnO6BfWAP99qnS3GgfU0ZYrKU3
         vWMr3E5+Fq6n8AWz3bMC+W8M9NsOrWUpHx+zfGdjPcjEiqnWLlGoDTvJ+7lKdMnzMAI1
         hXGhqSCU/T+DZpcUps3hUkMzUP+Q2QHL6p+rCtNwhLT5ZRCUhoGTfy6Zy4AiRCsxK3mq
         YU/egKBKFASfeIdn/ARK6dxlL5tC3murZmI2bBh8Iq7M/VtjSv6QfohJHzLTWXLmphlk
         4fqg==
X-Google-Smtp-Source: APXvYqwxtg5a6XoYMpMcxIBPOmmfaEaKkS2AWcyFeFyXLLxCpnNs049plHm+A4MWArI+IrDLJ+TCJg==
X-Received: by 2002:ac8:282b:: with SMTP id 40mr86139772qtq.49.1561121747830;
        Fri, 21 Jun 2019 05:55:47 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s130sm1209636qke.104.2019.06.21.05.55.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:55:47 -0700 (PDT)
Message-ID: <1561121745.5154.37.camel@lca.pw>
Subject: Re: [PATCH -next] slub: play init_on_free=1 well with SLAB_RED_ZONE
From: Qian Cai <cai@lca.pw>
To: Kees Cook <keescook@chromium.org>
Cc: akpm@linux-foundation.org, glider@google.com, cl@linux.com, 
	penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Fri, 21 Jun 2019 08:55:45 -0400
In-Reply-To: <201906201818.6C90BC875@keescook>
References: <1561058881-9814-1-git-send-email-cai@lca.pw>
	 <201906201812.8B49A36@keescook> <201906201818.6C90BC875@keescook>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-20 at 18:19 -0700, Kees Cook wrote:
> On Thu, Jun 20, 2019 at 06:14:33PM -0700, Kees Cook wrote:
> > On Thu, Jun 20, 2019 at 03:28:01PM -0400, Qian Cai wrote:
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index a384228ff6d3..787971d4fa36 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -1437,7 +1437,7 @@ static inline bool slab_free_freelist_hook(struct
> > > kmem_cache *s,
> > >  		do {
> > >  			object = next;
> > >  			next = get_freepointer(s, object);
> > > -			memset(object, 0, s->size);
> > > +			memset(object, 0, s->object_size);
> > 
> > I think this should be more dynamic -- we _do_ want to wipe all
> > of object_size in the case where it's just alignment and padding
> > adjustments. If redzones are enabled, let's remove that portion only.
> 
> (Sorry, I meant: all of object's "size", not object_size.)
> 

I suppose Alexander is going to revise the series anyway, so he can probably
take care of the issue here in the new version as well. Something like this,

memset(object, 0, s->object_size);
memset(object, 0, s->size - s->inuse);

