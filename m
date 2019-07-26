Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D613AC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:14:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A83121852
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:14:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jl78jgis"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A83121852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CCA56B0005; Fri, 26 Jul 2019 07:14:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27E4B6B0006; Fri, 26 Jul 2019 07:14:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 195128E0002; Fri, 26 Jul 2019 07:14:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE76B6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:14:21 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id m26so58383301ioh.17
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:14:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0M/nUeAr2qrx9NG9JsIDfA6wIkuEQwVlnlogMGXV4+U=;
        b=EfLTCflG+RIfQ00w1SqyZ8hGu5QuDmqeY4TMobxBb9xFosbTPEAbH6zHmRsgtZjAIZ
         G+qOsFF6LnPTUQ7epZ3w2A2rkEIZhvvKIPIqz3gJiIZFk5S/8Q6PVS2y+9pntx1jRHE6
         pG2K03+hyrIa5OBwBOK6+IpGOPPzkflnXpbyecZPFniv9tTK4AqPZgog9JshPc2ep32j
         iU0Var4WZ/TukBmWtJdacZrAiT8pxT3VYX/TKoeDiwjVWok1nMFzRyNFsyWpPHq9oSHd
         RO8eBlUsiHNiwTeoh2mIMqoRBIo6dWix8K5Z0nygZlezPVimBpFZJxqOjdxgw/IDySNj
         Rkzw==
X-Gm-Message-State: APjAAAVvswZghRhMkrM1QvIC+bbP3c/XE6HJGApsDdWMwuGPE8fg1hb4
	7ZU9DWA1f8J2PYuQpiyYsvuSVSiG5AZYYdmZYsTCby2ial+dPmn1Eb6b2pSYm6UMoQnq1tAUeow
	efTVWd/tZEstVnEuyoFkLTUQF2Wo5FWitkINppOYGN/ytTsvs8s+6z8u/sUhN6D9w+Q==
X-Received: by 2002:a6b:b756:: with SMTP id h83mr56146208iof.147.1564139661685;
        Fri, 26 Jul 2019 04:14:21 -0700 (PDT)
X-Received: by 2002:a6b:b756:: with SMTP id h83mr56146162iof.147.1564139660971;
        Fri, 26 Jul 2019 04:14:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564139660; cv=none;
        d=google.com; s=arc-20160816;
        b=HA0n11vsUi14qJevtUn7jsE0F8/SQCragtIYgfOBRdtF9SdQ/QYdgPhW7X8bb1m6GN
         4hx4qcJODQDSXrDn7XPGyMY+ZOIpqpBwvepAtOrPDxDjoUt2WALyp6k91IPzeYm6OmUg
         DFAlGjZCHR1dFV7GaL82ByhS24jkyzmRRh78Vlb3G2DSV2imaKEUBGP16QZOsyUdQKMU
         lfgV6MkRsdoA+kyzgTiGzUr1FOr0sunz5ZZZsZe2W90FvTc4D86o4OvRiOpwLpNNFbLu
         U/Q9R9fCG5/2MK/RTMRA6N72cHFbzc+ZxIujZrYsp1JKx1lMlBcvGaWma4/tT8imTnw8
         7p2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0M/nUeAr2qrx9NG9JsIDfA6wIkuEQwVlnlogMGXV4+U=;
        b=LOms+tCmDK6vkdQRdbyHmBEm+aUCMMouXoJeLerFVqnazI4g3Xt5rMW9ZzTO3UhjHf
         HaakUuN7XYWR+2yp6RA/Oo2UM4qjZMsQlz5GY+Cm3O779t9EESeIkjqHkLBTrpLGyl9s
         iIfUZ9jLL7HZOkK47x2ZiBUk0cODQqTy8a4DVEXtL8+LqryUEKS3m1Shsg9dCFhJWWMw
         2v8R++zFMYzQ9si4b07EJGDpberNP9FZ/8tLZjS8q/OEENcibF8PGcS2Gak1tF57Qfd7
         iYoKvtBJLsgtjn/Nlarjo1latHTEHWHIBliHvtOpIF7tuPHy3zTom/cXQtNaLnVx0cyz
         AWZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jl78jgis;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor35435449ioi.76.2019.07.26.04.14.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 04:14:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jl78jgis;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0M/nUeAr2qrx9NG9JsIDfA6wIkuEQwVlnlogMGXV4+U=;
        b=Jl78jgiso93/UWkVlpJ5eliZFMc9f07NxG849KOus/B5u6xfRuQnbHvRzRUSl7ZZYQ
         MAMgJ06w/D9axwTahEPAR5aFj/pCwsMixasMe4/dLvCxUJiv5w+g4D51D2nq6wPMfUG4
         zSJ/2FREFpfYfIPaiaIAgWDkOSNBO2gYmJyKVG0NifEPdcWTZx58c+oH8yPTsXEJwAHd
         DqG30Z8wHizAQYH8V0Ro8RUwvMnAWS6zijshPYRj5rtb5Wob45HSvY4nkseDG2/1ksII
         whnhg19KsShuMSSg0LvOVInprfzRi7BDs7f7bSN6/lg92v7T8asFEptmp915uLEhEuyM
         syew==
X-Google-Smtp-Source: APXvYqwufydvBFzz0T6sFGc+h4Nnb+rhugA7ryrnmNMvnAyhSYGTO7f0tGAMQ6XCj/7XmXCMMBkjgO/zE/7q7g7JUTo=
X-Received: by 2002:a5e:9e0a:: with SMTP id i10mr21774410ioq.44.1564139660605;
 Fri, 26 Jul 2019 04:14:20 -0700 (PDT)
MIME-Version: 1.0
References: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com>
 <20190726070939.GA2739@techsingularity.net> <CALOAHbA2sHSOpZXE6E+VjdJENa-WCZCo=-=YOqyVYAhkpf+Lrg@mail.gmail.com>
 <20190726102602.GD2739@techsingularity.net>
In-Reply-To: <20190726102602.GD2739@techsingularity.net>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 26 Jul 2019 19:13:44 +0800
Message-ID: <CALOAHbDxUENTiPm18Ntd=sOAakxbQaZRnktOY9Jok-0+RTwG5g@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: use proper zoneid for compaction_suitable()
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Arnd Bergmann <arnd@arndb.de>, 
	Paul Gortmaker <paul.gortmaker@windriver.com>, Rik van Riel <riel@redhat.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 6:26 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Fri, Jul 26, 2019 at 06:06:48PM +0800, Yafang Shao wrote:
> > On Fri, Jul 26, 2019 at 3:09 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > >
> > > On Thu, Jul 25, 2019 at 09:50:21AM -0400, Yafang Shao wrote:
> > > > By now there're three compaction paths,
> > > > - direct compaction
> > > > - kcompactd compcation
> > > > - proc triggered compaction
> > > > When we do compaction in all these paths, we will use compaction_suitable()
> > > > to check whether a zone is suitable to do compaction.
> > > >
> > > > There're some issues around the usage of compaction_suitable().
> > > > We don't use the proper zoneid in kcompactd_node_suitable() when try to
> > > > wakeup kcompactd. In the kcompactd compaction paths, we call
> > > > compaction_suitable() twice and the zoneid isn't proper in the second call.
> > > > For proc triggered compaction, the classzone_idx is always zero.
> > > >
> > > > In order to fix these issues, I change the type of classzone_idx in the
> > > > struct compact_control from const int to int and assign the proper zoneid
> > > > before calling compact_zone().
> > > >
> > >
> > > What is actually fixed by this?
> > >
> >
> > Recently there's a page alloc failure on our server because the
> > compaction can't satisfy it.
>
> That could be for a wide variety of reasons. There are limits to how
> aggressive compaction will be but if there are unmovable pages preventing
> the allocation, no amount of cleverness with the wakeups will change that.
>

Yes, we should know whether it is lack of movable pages or the
compaction can't catch up first.
I think it would be better if there're some debugging facilities could
help us do that.

> > This issue is unproducible, so I have to view the compaction code and
> > find out the possible solutions.
>
> For high allocation success rates, the focus should be on strictness of
> fragmentation control (hard, multiple tradeoffs) or increasing the number
> of pages that can be moved (very hard, multiple tradeoffs).
>

Agreed, that's a tradeoff.

> > When I'm reading these compaction code, I find some  misuse of
> > compaction_suitable().
> > But after you point out, I find that I missed something.
> > The classzone_idx should represent the alloc request, otherwise we may
> > do unnecessary compaction on a zone.
> > Thanks a lot for your explaination.
> >
>
> Exactly.
>
> > Hi Andrew,
> >
> > Pls. help drop this patch. Sorry about that.
>
> Agreed but there is no need to apologise. The full picture of this problem
> is not obvious, not described anywhere and it's extremely difficult to
> test and verify.
>
> > > > <SNIP>
> > > > @@ -2535,7 +2535,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> > > >                                                       cc.classzone_idx);
> > > >       count_compact_event(KCOMPACTD_WAKE);
> > > >
> > > > -     for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
> > > > +     for (zoneid = 0; zoneid <= pgdat->kcompactd_classzone_idx; zoneid++) {
> > > >               int status;
> > > >
> > > >               zone = &pgdat->node_zones[zoneid];
> > >
> > > This variable can be updated by a wakeup while the loop is executing
> > > making the loop more difficult to reason about given the exit conditions
> > > can change.
> > >
> >
> > Thanks for your point out.
> >
> > But seems there're still issues event without my change ?
> > For example,
> > If we call wakeup_kcompactd() while the kcompactd is running,
> > we just modify the kcompactd_max_order and kcompactd_classzone_idx and
> > then return.
> > Then in another path, the wakeup_kcompactd() is called again,
> > so kcompactd_classzone_idx and kcompactd_max_order will be override,
> > that means the previous wakeup is missed.
> > Right ?
> >
>
> That's intended. When kcompactd wakes up, it takes a snapshot of what is
> requested and works on that. Other requests can update the requirements for
> a future compaction request if necessary. One could argue that the wakeup
> is missed but really it's "defer that request to some kcompactd activity
> in the future". If kcompactd loops until there are no more requests, it
> can consume an excessive amount of CPU due to requests continually keeping
> it awake. kcompactd is best-effort to reduce the amount of direct stalls
> due to compaction but an allocation request always faces the possibility
> that it may stall because a kernel thread has not made enough progress
> or failed.
>
> FWIW, similar problems hit kswapd in the past where allocation requests
> could artifically keep it awake consuming 100% of CPU.
>

Understood. Thanks for your explanation again.

Thanks
Yafang

