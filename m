Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0657C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF11C229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:26:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF11C229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169B66B0003; Fri, 26 Jul 2019 06:26:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1192B6B0005; Fri, 26 Jul 2019 06:26:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24686B0006; Fri, 26 Jul 2019 06:26:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A83E06B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:26:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f16so25328136wrw.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:26:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0wNYkdHC/9JLBYd6vNd/C3Zk994Z0t9x1daeBHW/qm4=;
        b=m/rCBYYpuCQQOAdDQd8NV8qt1Grqo+9rfE6k9Dl1ajpwHr5wgfolpeBBlUaakDe9gF
         BcZFhVvWsaghNqy5Zq4IPeeR4U+h7G/ImfZuRSuyDP0N9VNo44Vf3mcMjXLmjMEq+xUR
         YS0jEb47gE4PvSSj9G/YWasNFKa1QP6GsUWZJtMWqZfT1EP4qcDX/fLc0ZGvG4ze7Ode
         VM7BML7sUdxQFxcX6kd0LWFRTe3QRmFyf+WriR/MBbwiD7bW1LKHTeGsGaiwMhYZqPkl
         mZGMa6d/xMXbdgTu4suyriBixUod6Z4v7pOm49HYQrHRSRtTtynfQb6Kuth0I5PYlQnc
         vElA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.220 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUuasVuaOEbI2RRwXGYhCtApLqnGz2JDAkl+cY+bgFpyjTOloQt
	M3hluedN206Jy2gZyCm2VvRsRDWZ2Lg6GZWNjMbsO5aFEjAlwpAKR4v5aLw/Dn+AdaVzUvoES2a
	7xDAEsdz4HzGnKmREM1zpsfZjqiyCDY6HbkjAI8tvynhUr9ITq3AZLn8v71/1CvS3mA==
X-Received: by 2002:a1c:e109:: with SMTP id y9mr49444748wmg.35.1564136766171;
        Fri, 26 Jul 2019 03:26:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU+MD+RwMpMcNdZzoDIY5WUQqbbr0mAQEIbv6Rwh4DjDM+eXNOMhy6PScVf5BTAb3O5ncB
X-Received: by 2002:a1c:e109:: with SMTP id y9mr49444671wmg.35.1564136765237;
        Fri, 26 Jul 2019 03:26:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564136765; cv=none;
        d=google.com; s=arc-20160816;
        b=sWQjn7eFJSKUk/8fRKLdulrxG1Nm77yhp7/DhoRI+SdfhLr3MbM9xKrAyvWzHEC6l1
         OcwomygyCwXJDLrVbfhjOrcE6fI1wGGyssnuXsv2EDq2fRkYDgBp7LW2ojUL2vNjWoHU
         064+t8W4gjHItNyG9GWBzq6MdiBlb4Rld3TwEmUIsb1dI4+xnov6SCxg35OCKH/MEpBR
         VXYcJZflm9zTnErtjovUmDWfi6oSEIRBI7mtcRdlplDhfUBi4KKZlMrkYhcfL7ynSrvE
         7L99KeQ3/G3/lqTs75EqU1P4HzAFzXWTG/q6NVNuVC+FxpaHZb8B7Wqk7f6K5b/0q1CV
         PV4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0wNYkdHC/9JLBYd6vNd/C3Zk994Z0t9x1daeBHW/qm4=;
        b=y0g+ahxG7oBcNYVLGanBuJaUMV1yVcL1hSJoK+0dqtyeFm4OyPpxFkivwVpSDWDPZg
         lBY/+NROZFb4fjKJAI67H6dOeXcCU/j0exRfx5WhFNmw23hqUFr/AchWr6Wtc2p3AojU
         7mbnjCyQkUwJZ7yctC1Sbu2N95o17FMNYZQtYDJ9Rz//3SOPPzchw2kXTmHGTuUkVTlH
         lf8JoYpNfZe7B/e2k2mUNYA3CdVQczTwtfPqZQwowKiWca5cBthDREPnOw431KGExMDf
         oxSOlywqlb1Em6617YFQ0weN2dCArrPDNd0lV7FTgaJDslTbbKoWilGhMBsL9Rp6DH1/
         wy7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.220 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp37.blacknight.com (outbound-smtp37.blacknight.com. [46.22.139.220])
        by mx.google.com with ESMTPS id r132si17617476wma.63.2019.07.26.03.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 03:26:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.220 as permitted sender) client-ip=46.22.139.220;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.220 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp37.blacknight.com (Postfix) with ESMTPS id BADC193B
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:26:04 +0100 (IST)
Received: (qmail 16510 invoked from network); 26 Jul 2019 10:26:04 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.19.7])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 26 Jul 2019 10:26:04 -0000
Date: Fri, 26 Jul 2019 11:26:02 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>,
	Arnd Bergmann <arnd@arndb.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Rik van Riel <riel@redhat.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: use proper zoneid for
 compaction_suitable()
Message-ID: <20190726102602.GD2739@techsingularity.net>
References: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com>
 <20190726070939.GA2739@techsingularity.net>
 <CALOAHbA2sHSOpZXE6E+VjdJENa-WCZCo=-=YOqyVYAhkpf+Lrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALOAHbA2sHSOpZXE6E+VjdJENa-WCZCo=-=YOqyVYAhkpf+Lrg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 06:06:48PM +0800, Yafang Shao wrote:
> On Fri, Jul 26, 2019 at 3:09 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > On Thu, Jul 25, 2019 at 09:50:21AM -0400, Yafang Shao wrote:
> > > By now there're three compaction paths,
> > > - direct compaction
> > > - kcompactd compcation
> > > - proc triggered compaction
> > > When we do compaction in all these paths, we will use compaction_suitable()
> > > to check whether a zone is suitable to do compaction.
> > >
> > > There're some issues around the usage of compaction_suitable().
> > > We don't use the proper zoneid in kcompactd_node_suitable() when try to
> > > wakeup kcompactd. In the kcompactd compaction paths, we call
> > > compaction_suitable() twice and the zoneid isn't proper in the second call.
> > > For proc triggered compaction, the classzone_idx is always zero.
> > >
> > > In order to fix these issues, I change the type of classzone_idx in the
> > > struct compact_control from const int to int and assign the proper zoneid
> > > before calling compact_zone().
> > >
> >
> > What is actually fixed by this?
> >
> 
> Recently there's a page alloc failure on our server because the
> compaction can't satisfy it.

That could be for a wide variety of reasons. There are limits to how
aggressive compaction will be but if there are unmovable pages preventing
the allocation, no amount of cleverness with the wakeups will change that.

> This issue is unproducible, so I have to view the compaction code and
> find out the possible solutions.

For high allocation success rates, the focus should be on strictness of
fragmentation control (hard, multiple tradeoffs) or increasing the number
of pages that can be moved (very hard, multiple tradeoffs).

> When I'm reading these compaction code, I find some  misuse of
> compaction_suitable().
> But after you point out, I find that I missed something.
> The classzone_idx should represent the alloc request, otherwise we may
> do unnecessary compaction on a zone.
> Thanks a lot for your explaination.
> 

Exactly.

> Hi Andrew,
> 
> Pls. help drop this patch. Sorry about that.

Agreed but there is no need to apologise. The full picture of this problem
is not obvious, not described anywhere and it's extremely difficult to
test and verify.

> > > <SNIP>
> > > @@ -2535,7 +2535,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> > >                                                       cc.classzone_idx);
> > >       count_compact_event(KCOMPACTD_WAKE);
> > >
> > > -     for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
> > > +     for (zoneid = 0; zoneid <= pgdat->kcompactd_classzone_idx; zoneid++) {
> > >               int status;
> > >
> > >               zone = &pgdat->node_zones[zoneid];
> >
> > This variable can be updated by a wakeup while the loop is executing
> > making the loop more difficult to reason about given the exit conditions
> > can change.
> >
> 
> Thanks for your point out.
> 
> But seems there're still issues event without my change ?
> For example,
> If we call wakeup_kcompactd() while the kcompactd is running,
> we just modify the kcompactd_max_order and kcompactd_classzone_idx and
> then return.
> Then in another path, the wakeup_kcompactd() is called again,
> so kcompactd_classzone_idx and kcompactd_max_order will be override,
> that means the previous wakeup is missed.
> Right ?
> 

That's intended. When kcompactd wakes up, it takes a snapshot of what is
requested and works on that. Other requests can update the requirements for
a future compaction request if necessary. One could argue that the wakeup
is missed but really it's "defer that request to some kcompactd activity
in the future". If kcompactd loops until there are no more requests, it
can consume an excessive amount of CPU due to requests continually keeping
it awake. kcompactd is best-effort to reduce the amount of direct stalls
due to compaction but an allocation request always faces the possibility
that it may stall because a kernel thread has not made enough progress
or failed.

FWIW, similar problems hit kswapd in the past where allocation requests
could artifically keep it awake consuming 100% of CPU.

-- 
Mel Gorman
SUSE Labs

