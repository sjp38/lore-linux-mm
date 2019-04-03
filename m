Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9034DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:39:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B2AB20700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:39:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N2XKLx6C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B2AB20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72DCC6B000E; Wed,  3 Apr 2019 12:39:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B3A16B0010; Wed,  3 Apr 2019 12:39:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57C406B0266; Wed,  3 Apr 2019 12:39:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14E6C6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:39:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so12718696pfj.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:39:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8IQMSP6P4b510J55TjeGkbsT5/Y/3zEz6PB9bSwT+7E=;
        b=Yqc0n1DlxuN6c5LEJDTcSf2UHnbhsbmEKoYEYWnh4pi2SFsU1tJDiLWFar4efhz8pF
         diAbPS55v9FU3gjFWolStriCcAUjOhki3boWesL607LBMnn4lOvPQ9peaABbvaLeLAj2
         xhvdAT65A/t4qNAmdGL7Z2B/tMelwQ9ELihg8/rxb7S8x1KocHANAOfs5cQZ3N+440Kq
         NhxZ5N6/86AMd36iiXMW4K8hhXNYQn5ske8KM6XRwdLn0LpnJ6w2Mo5L+SKNodf641FG
         KT/hDghI6ImDFwrZy2BFcATMWxZ/P3gVgpHu7u6YNpYeyE0rbVu83MAZdps9o/ta6nm5
         uI3g==
X-Gm-Message-State: APjAAAXgEcdXUAVRBxgfYOEr1+QbVfFiGHT+DN1uvg07Pg4sCC1TWfM3
	Qf7abtQK5MFZ5hi9RyDzpCG4WQFaKhzX9WdsyaImufgaglgA2tmBGJVN3E2H5k1DWPt/F6WbqBj
	qqhH4oKpDZUpua5YgW5XS6xynZlNCvi3q/zcb58uuX3pU01HKtuBLT+/P6IWOd8WIug==
X-Received: by 2002:a17:902:b948:: with SMTP id h8mr935772pls.39.1554309583611;
        Wed, 03 Apr 2019 09:39:43 -0700 (PDT)
X-Received: by 2002:a17:902:b948:: with SMTP id h8mr935696pls.39.1554309582645;
        Wed, 03 Apr 2019 09:39:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554309582; cv=none;
        d=google.com; s=arc-20160816;
        b=D4kTUja9hGPlXf9Dv+W4oRnAD433W5+B8mSwkL8E3sb11Q7Czlw7ZHx88WBrWCOewA
         9zI7r+sAY42+2SVbpxz7YpaaEkH+tSY0A3fe3bhUY3+JZVtEnJJ6D7Hxga4GiqmIsU9v
         96x7tp0KxOfyG0HLnqZehY8cpWKZMNYctjOHwEdV+Mer1O7NKY+pPU0JIpJU+GEb8Ep1
         nTculENetF5OjShYpTuV6XL0ptiIjBgUoFN3pdlCDs7JZlw/B0x1UwvZk7L7ScrbQTii
         n2W6rBdzhiupyXQb/lLrGEtqGs9bqzU+oPhCwzYerAOOk4Z4OGJKO+wKoW4KJphn020L
         cyeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8IQMSP6P4b510J55TjeGkbsT5/Y/3zEz6PB9bSwT+7E=;
        b=tN8oX2FX9VEARrn5nwJzWOSci+JrHzIWy0YrN2w/Ha7WKP9zt1QzqlYGLAb8s+Wh6r
         r36qcHbgJraMAfL1yJ+hLbqAJwK7105/lHyF/SGE2lOjEsJqc/yZULQotzab1C1KN+Yu
         5FNE08r6aEocfjIYnOnRqzG5VIeJdw8dfV3XpQpOpxotjky/odGPUu1TzlmA1rVHzzE6
         MYGHE2r58u4+qpKkkITP2P0oTO/D87thZFhAvWosgrc4tWL8PY9y25QvRL2DZlHnshEf
         YBLUQ+z3xEnZrgcRbUNqXeLzFKOXILPPIN/ZAi1He3ZLx0npfodv6Sk6wI65WAcdVSiW
         aX/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N2XKLx6C;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor17230667pfn.43.2019.04.03.09.39.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 09:39:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N2XKLx6C;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8IQMSP6P4b510J55TjeGkbsT5/Y/3zEz6PB9bSwT+7E=;
        b=N2XKLx6CwqbNgMJ1R23HY44NJ8E5jLkGzjmH3vzavEGsnUhSx5spwjOvDihNdKeHLD
         hiucnujUTZFNi9BJbS5ZZcViGdNdedLO1DTkY0HgdHNPjnDEjOlIghEiUQ3KEtWoEJvb
         hlYn3zfi2x7zS5JY2oyWATaMaUY6BtlFZ3OrTgtB0msmsdiDNfD9pMJ7Ltk5nAXP3yDj
         5W8KOeZ4AhHDF2akw58m3cZJBibsfONnnOUvFKsXUkLzMzlp383ccKE62xg+6tVpOPv5
         QsRci9bzTdkqTq8TAeE+o/0gbVgTOwhzbEc/vxi80Xdn9WHWnkXq8Jj+N3YW288e5CzO
         pzPw==
X-Google-Smtp-Source: APXvYqzYXS80SV0hZJplY4wbQNIVdXhJJqlu6SJclWXyq0z/0V+GPeAi6agt59VEmqpex5O4cxAu8xmIrxGQvFLtTC8=
X-Received: by 2002:a62:a513:: with SMTP id v19mr398736pfm.212.1554309581669;
 Wed, 03 Apr 2019 09:39:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190403022858.97584-1-cai@lca.pw> <CAAeHK+y25S6GYMrGUEQJJ5AU1LZ7T-jWrwoDsLXdxuk_E+q5BQ@mail.gmail.com>
 <1554296870.26196.32.camel@lca.pw>
In-Reply-To: <1554296870.26196.32.camel@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 3 Apr 2019 18:39:30 +0200
Message-ID: <CAAeHK+wB4L9nj+iPf8iHUbuWBCE_FQN4aea4zswEd4bbr49FPQ@mail.gmail.com>
Subject: Re: [PATCH] slab: store tagged freelist for off-slab slabmgmt
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 3:07 PM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-04-03 at 13:23 +0200, Andrey Konovalov wrote:
> > On Wed, Apr 3, 2019 at 4:29 AM Qian Cai <cai@lca.pw> wrote:
> > >
> > > The commit 51dedad06b5f ("kasan, slab: make freelist stored without
> > > tags") calls kasan_reset_tag() for off-slab slab management object
> > > leading to freelist being stored non-tagged. However, cache_grow_begin()
> > > -> alloc_slabmgmt() -> kmem_cache_alloc_node() which assigns a tag for
> > > the address and stores in the shadow address. As the result, it causes
> > > endless errors below during boot due to drain_freelist() ->
> > > slab_destroy() -> kasan_slab_free() which compares already untagged
> > > freelist against the stored tag in the shadow address. Since off-slab
> > > slab management object freelist is such a special case, so just store it
> > > tagged. Non-off-slab management object freelist is still stored untagged
> > > which has not been assigned a tag and should not cause any other
> > > troubles with this inconsistency.
> >
> > Hi Qian,
> >
> > Could you share the config (or other steps) you used to reproduce this?
>
> https://git.sr.ht/~cai/linux-debug/blob/master/config
>
> Additional command-line option to boot:
>
> page_poison=on crashkernel=768M earlycon page_owner=on numa_balancing=enable
> systemd.unified_cgroup_hierarchy=1 debug_guardpage_minorder=1

Reproduced, thanks!

As far as my understanding of how SLAB works goes, this change looks good to me.

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

Thanks, Qian!

>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/1554296870.26196.32.camel%40lca.pw.
> For more options, visit https://groups.google.com/d/optout.

