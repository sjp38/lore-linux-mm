Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E2BDC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12A922084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:14:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uc2yay6i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12A922084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A86128E011F; Fri, 12 Jul 2019 03:14:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A37818E00DB; Fri, 12 Jul 2019 03:14:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94C9E8E011F; Fri, 12 Jul 2019 03:14:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 765B48E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:14:38 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s83so9613098iod.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:14:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=K5n3a7TJ151mj+RG+TNKnMDdVQiUdsCXzAQupdItK+k=;
        b=CN53mLvEznPn5CVY+KyV7C9VwdzeUX18GHIBUHlKZICKh8s/ZEkIGSK/Ko5mk7uAtN
         CcMqkuqryZtUy6l3kCAAWQVoTMzjyl6eJRIzCLdgi3QckB9xGhuTDA9aVBEsIPF991Fd
         Xvk4g4sWK4p3Ale+8U7PMm2ipBcIIVsDSgaJU6K7os6TP9B4GZe+HZlqYd5WE2Pv0+J6
         4sKFiOEXbzHo+tkIzJ9mUg4cgWS90DVyJxn+xzRzLfbusA11RHtqh2Padndy9waqzxy5
         yI5Wy1yVQRlAaqvVQss3TWF4bjCEbIMMaHFWhfUoQJ4PZHihMM39mlPiOAmLhSqEU8A/
         7CDg==
X-Gm-Message-State: APjAAAV+sqA5Y0obT12QxTWEvREDgeRNeg73+5n30NhJLPu4IEMS6KAd
	TS5Cn1rKRjykjKf5CVcZl7XaVKQy54O3GkILLIq/QSHa2t2ZWNf+rn89hy/qoeDDk2FsYBeoxtX
	ZpJSahNxmxUUR7b6ovQqVnNdYIkz7MLkwlDK9fNH25uYhYUEMIVrd8Kq56YTzlSQGmA==
X-Received: by 2002:a5e:8e4a:: with SMTP id r10mr9376250ioo.100.1562915678192;
        Fri, 12 Jul 2019 00:14:38 -0700 (PDT)
X-Received: by 2002:a5e:8e4a:: with SMTP id r10mr9376205ioo.100.1562915677555;
        Fri, 12 Jul 2019 00:14:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562915677; cv=none;
        d=google.com; s=arc-20160816;
        b=m0kqKR+7KnLOcI6V3Bsx46xcN+J4bVq0l+DVzzJ5X06+21O3kT9/P2+C76xZSNH+ra
         hnNQuATISIzdUN7bnoCd0eeBuiq99FMssnAVJ9YD1n45fEulBE1cYZ6MKdjP9VuNI13f
         7Gci1KCtO1fCXMv/0nOIhdgq6fldnYAva0+gYdryaA9+x3Yt3cEVFvvb8nw/JwN2cK+O
         EYncImbx5bUvl8pOw+UBJdw+kjAW6UTlqE1Uu5KDwBY14uCetzhus1Ccl+6nlxXgbSUm
         X2wY7+Gt3L+w7p4LsLILB+okfWGZ16+yjiV0Dgj0QnKe2u3nJxYXcNuylX//1zgHxgHj
         ekaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=K5n3a7TJ151mj+RG+TNKnMDdVQiUdsCXzAQupdItK+k=;
        b=Eqcv01FK2UpCl6jHQsbYOpy1oB7D2KlmoUaqOoQpHwh81guPlJr5KJTK5eTO1yCr21
         yXngaErswonmID25CRoVtmF9jFk1YdlbeECQDOMsN0krAMPLEAt/NYJq44dZxn2zqha7
         53hj4x2OufCaUUNKoYPCHY7mTPioI9gjvOzc1yebSkVZ4dpijkHOTuYQCOVqv6026Qb9
         V4D1qzTagB6d58Xl26tuP5MvjzHwxodlVulqw9XMz4P8uuG5oSyflYnItj2uHddUtVhW
         gzyZHQ2y/0InyRnphpGgnd0D7o0V2COll3DPSMC8OuuL1IUALe46mwnIIkvCsCsXZW2P
         5fUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Uc2yay6i;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t20sor6443434ioj.102.2019.07.12.00.14.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 00:14:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Uc2yay6i;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=K5n3a7TJ151mj+RG+TNKnMDdVQiUdsCXzAQupdItK+k=;
        b=Uc2yay6ixkrnG3XBDyRCmy9Y0EvBObfQysCmY0xaYgSM8VUk2PCEBblSRJ63Umo7u9
         erx9uVAcNXgeNwf1Sh75oyJgx87lV7zg/9FSfxY/vUKNvOeAgQtUUJBRXsCy3vC74BYR
         83YotCiw02QTh2shjRzEiQ5ZG5MEwBqb9uBmHpNiZOrg1CPC6QMBfJhjGRIsIdI+1BRI
         dVDBIn5o5OG6O4I1AwFgIW7a6wrIWK/aAuuOgJCPKovwPBIEUc12p2nhgilAq9r8ct/0
         qsKdu9VMgoM4pmCYHgemOPdF0eKLTuw09gHfBuh5+vLPvoGppt9ZG2MEVpoe6LmLWAal
         KFRw==
X-Google-Smtp-Source: APXvYqyE6z6d3vX9ip7Er1hGO/jMbMtPMD0KV6WfCdeCy54EzHJeWPxO3p5ci9ccNlJV1teQRv8tOWKQL/PkHVeCuoE=
X-Received: by 2002:a5e:9404:: with SMTP id q4mr9419801ioj.46.1562915677230;
 Fri, 12 Jul 2019 00:14:37 -0700 (PDT)
MIME-Version: 1.0
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
 <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
 <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
 <20190712052938.GI29483@dhcp22.suse.cz> <CALOAHbCt7b-AMDtK6FmAfYnYSMiB=UhKbBVKt7CzFFazzrKeVQ@mail.gmail.com>
 <20190712065312.GJ29483@dhcp22.suse.cz>
In-Reply-To: <20190712065312.GJ29483@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Jul 2019 15:14:01 +0800
Message-ID: <CALOAHbBBMWhyWybRv+vDvP4XLu5TOLaf2NOyoNe6zQ1D3sJQMw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with the
 hierarchical ones
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 2:53 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-07-19 14:12:30, Yafang Shao wrote:
> > On Fri, Jul 12, 2019 at 1:29 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 12-07-19 09:47:14, Yafang Shao wrote:
> > > > On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> > > > >
> > > > > > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > > > > > the local VM counters is not in sync with the hierarchical ones.
> > > > > >
> > > > > > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> > > > > >       inactive_file 3567570944
> > > > > >       total_inactive_file 3568029696
> > > > > > We can find that the deviation is very great, that is because the 'val' in
> > > > > > __mod_memcg_state() is in pages while the effective value in
> > > > > > memcg_stat_show() is in bytes.
> > > > > > So the maximum of this deviation between local VM stats and total VM
> > > > > > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > > > > > great value.
> > > > > >
> > > > > > We should keep the local VM stats in sync with the total stats.
> > > > > > In order to keep this behavior the same across counters, this patch updates
> > > > > > __mod_lruvec_state() and __count_memcg_events() as well.
> > > > >
> > > > > hm.
> > > > >
> > > > > So the local counters are presently more accurate than the hierarchical
> > > > > ones because the hierarchical counters use batching.  And the proposal
> > > > > is to make the local counters less accurate so that the inaccuracies
> > > > > will match.
> > > > >
> > > > > It is a bit counter intuitive to hear than worsened accuracy is a good
> > > > > thing!  We're told that the difference may be "unacceptably great" but
> > > > > we aren't told why.  Some additional information to support this
> > > > > surprising assertion would be useful, please.  What are the use-cases
> > > > > which are harmed by this difference and how are they harmed?
> > > > >
> > > >
> > > > Hi Andrew,
> > > >
> > > > Both local counter and the hierachical one are exposed to user.
> > > > In a leaf memcg, the local counter should be equal with the hierarchical one,
> > > > if they are different, the user may wondering what's wrong in this memcg.
> > > > IOW, the difference makes these counters not reliable, if they are not
> > > > reliable we can't use them to help us anylze issues.
> > >
> > > But those numbers are in flight anyway. We do not stop updating them
> > > while they are read so there is no guarantee they will be consistent
> > > anyway, right?
> >
> > Right.
> > They can't be guaranted to be consistent.
> > When we read them, may only the local counters are updated and the
> > hierarchical ones are not updated yet.
> > But the current deviation is so great that can't be ignored.
>
> Is really 32 pages per cpu all that great?
>

As I has pointed out in the commit log, the local inactive_file is
3567570944 while the total_inactive_file is 3568029696,
and the difference between these two values are 458752.

> Please note that I am not objecting to the patch (yet) because I didn't
> get to think about it thoroughly but I do agree with Andrew that the
> changelog should state the exact problem including why it matters.
> I do agree that inconsistencies are confusing but maybe we just need to
> document the existing behavior better.

I'm not sure whether document it is enough or not.
What about removing all the hierarchical counters if this is a leaf memcg ?
Don't calculate the hierarchical counters nor display them if this is
a leaf memcg, I don't know whether it is worth to do.

Thanks
Yafang

