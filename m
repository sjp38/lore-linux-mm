Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B095FC76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74D7A2054F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DYrtLb7s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74D7A2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 003616B0006; Mon, 15 Jul 2019 11:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECF0C6B0007; Mon, 15 Jul 2019 11:01:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D970F6B000E; Mon, 15 Jul 2019 11:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B77736B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:01:03 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so19860699iom.18
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:01:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=9illoX/lgZgRmB149QSdUSTaY6vK5Drr6t7JdhNt6/U=;
        b=MvdTin5K1m6UKX9MVi18FxM2N8YzgeGT0A/3l2mVFlljsv5sTkE2B/2Q1SS5PG2i3Y
         tUNB83A0EVCPlXV0GQqp0qsAevfWIyFpRxOb1xy7HsSVfgIJWTwpafE6YwPI3VBBbutu
         k8HKCXOuZIzNduGfiwzHExcQlMKLN0+q+eVRj2FY6H32VgCgMBUk7iuGWM8Q4l1+JEGw
         BPgEq+60sJlDkta43WaktKk8MMeTEX/omzVhp6PvHGCueaDbbAlGv28n8ug8f8SsI6S4
         +7qlJurMhUtrjqjVKCBJhxKIb4emjQ9IwKouKjcmlhugiXkwHaSwbdOfVAW443nXeUPX
         6RWA==
X-Gm-Message-State: APjAAAUM47HkiwpPp/BsHQ0IgTlTND7x0vsPU77vp1M8XKeY/y0vQmuS
	AOVyI9wXNADMwiBIitYux5UdIMhi0dKdF2K4uAQl7IvKZW4Li2hzJwU6IC6rY/5+4Rr7BcukCyV
	vlDc9eShtg6LRPX8ZaDkrz//LUa+b13LjU5Ik557aaHYL+Sj1t/veiKXDFPGSL1tSBg==
X-Received: by 2002:a05:6602:98:: with SMTP id h24mr25649891iob.49.1563202863457;
        Mon, 15 Jul 2019 08:01:03 -0700 (PDT)
X-Received: by 2002:a05:6602:98:: with SMTP id h24mr25649822iob.49.1563202862777;
        Mon, 15 Jul 2019 08:01:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563202862; cv=none;
        d=google.com; s=arc-20160816;
        b=VcmjMpjlVIQdKueCQbjxD2xnmWTou7MzwXFeOsf3pjzh6TUx0Bk8BzIMRTeBejudho
         2YHiPr79Vl1iB7QXEVN0bCHtYk2OmTTvOo58xna1gjKMSbFsRrXndd+fQJL12sK9KfK0
         hOP4xo6pV9m/6qZnd8lLkF+oYCk4fNhSs9YQBAKNfXzCzj8Dd6MEpaAJ8/1p0uWj5oIg
         5yFW1JstNHFYPViKVATn/XmP17/51Fv91+EGY02vZjrkG/zHqukYIMPc8ehx/m90XYWg
         6C7KsFIMhIAZczt1+oYk1VVvL7Zpfe13heZYezfjuwH66FHIUid5jY1omiYaWDG/1DAL
         NMzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=9illoX/lgZgRmB149QSdUSTaY6vK5Drr6t7JdhNt6/U=;
        b=y/CkLIHhTqnNqkgSbtjd/bQOBF+w0OhpEAhryD75ClhKfTXeOStQxDo87TUZ9SVVJY
         2Z3ESC8ZygzeZhaN5VRVisuCuB2RORL2xwAqA5LOlJKhy47f96lP7La5sqT+grbGadk+
         SLrzSeK4RBSBbOMrHWSW5vpiK7GAfdOLS2g3i9vr5D/XneK5HHa98v82mkwhM/6UoEz4
         xo3h07nl0CP8gyid5TLGCYqM+EIs0VpBuolO+T9Mnojdg+b/PuJ3ac0ACi+hNa/cy79L
         pfmvqJP97vz3JYir6VzAwjZ0tzfsBZ/5UdneOsooGWI6DOY8fH9I28Do/rPoEctbqpNG
         9Epg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DYrtLb7s;
       spf=pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=catalin.marinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor12593903ioa.6.2019.07.15.08.01.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 08:01:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DYrtLb7s;
       spf=pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=catalin.marinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=9illoX/lgZgRmB149QSdUSTaY6vK5Drr6t7JdhNt6/U=;
        b=DYrtLb7sMB46zxNRJnG85/ftn6zE7TFfjTN+5wQYTnY+QHAqScIXon2svnkersHAFM
         1Xt023H9TNITyB9es+v0i3uxdSBQs7k/aSgH77UYwxi+alo1MNWQswVKqQ6eopKF1LIZ
         NT8URj+mVL/DFnYl/Muz3CQgjN2adCpdRSD5HnjTDZV6yQNc0gnUu5nr7umVAlbVymQI
         csKl3kN6GiwinqBddVagShTG9XJfDZupWVw3FPLpe3iCiJsqmuOMxAVttKeN4Xmw0gE4
         gG8FPB2e8OvvZYz4/qQ9JYMCpEkbX4+WHPbgqrdMjGi6V80YGO6hytcCGvr356uZf0fh
         Rz8Q==
X-Google-Smtp-Source: APXvYqw5kBdwEgrkIu0ycndJ5NQWWHs1lfEtl9tiXRzValvEj283Zhs4c5zmyc8yumSoqEQ1yFRoWA==
X-Received: by 2002:a5e:c803:: with SMTP id y3mr25041911iol.308.1563202862289;
        Mon, 15 Jul 2019 08:01:02 -0700 (PDT)
Received: from [192.168.1.249] ([67.167.44.43])
        by smtp.gmail.com with ESMTPSA id m25sm10511707ion.35.2019.07.15.08.01.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 08:01:01 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable __GFP_NOFAIL case
From: Catalin Marinas <catalin.marinas@gmail.com>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <20190715131732.GX29483@dhcp22.suse.cz>
Date: Mon, 15 Jul 2019 10:01:00 -0500
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
 "dvyukov@google.com" <dvyukov@google.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com> <20190715131732.GX29483@dhcp22.suse.cz>
To: Michal Hocko <mhocko@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15 Jul 2019, at 08:17, Michal Hocko <mhocko@kernel.org> wrote:
> On Sat 13-07-19 04:49:04, Yang Shi wrote:
>> When running ltp's oom test with kmemleak enabled, the below warning was
>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>> passed in:
>=20
> kmemleak is broken and this is a long term issue. I thought that
> Catalin had something to address this.

What needs to be done in the short term is revert commit d9570ee3bd1d4f20ce6=
3485f5ef05663866fe6c0. Longer term the solution is to embed kmemleak metadat=
a into the slab so that we don=E2=80=99t have the situation where the primar=
y slab allocation success but the kmemleak metadata fails.=20

I=E2=80=99m on holiday for one more week with just a phone to reply from but=
 feel free to revert the above commit. I=E2=80=99ll follow up with a better s=
olution.=20

Catalin

