Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3C84C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E11F21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:20:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P5rfIt3/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E11F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FC0D8E0004; Thu, 28 Feb 2019 05:20:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC188E0001; Thu, 28 Feb 2019 05:20:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDD7E8E0004; Thu, 28 Feb 2019 05:20:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C979C8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:20:53 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j127so7862905itj.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:20:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MjGnjBgV2B9O5KOqeVNbZng4ad3gxLYTc32AkGT0Pp8=;
        b=uKyjAZHVi8dDjLjzriDQOwlNr+2uL5xcckrEGgUW+UMVQB9cld2TEay9gwq6tkN+0S
         G7oCjobC9cEWxZB0jyr3rCKgrQEYJg+Azv0fEdaN6F29bjH6IhoW8DY6CszxomCFCfsS
         QK0OD6aGMY80A9z8k9HKAxCVAPZbyeCaGjZ+E+PPY7jWgBiG4k7AMUXS682BKns+ng0R
         hyFKs+URhHmZpOuDJgFo0x+W1Hkdy3a4y7Q+PqMXVX114ZsZvJsEmCH03o6S/Erx4wvR
         REacg6miooc613RsiAPSHfUf1y4U05s7ljIhqM4M8oTJF5YP2o/39GtkvYhLTy+d8ccd
         myNw==
X-Gm-Message-State: APjAAAWXZa5DccoTgD2UlRxiV2+eCHZshosMUCPgiDWL6Y8pk6hn3wVT
	9qFbCmAjxBm2DJ/TjZJDWv9kiFPoXCMWB9LueTSSbsgUsztx1BCm7DTAbWHuisarwBYJvkqEkte
	DkgX+zjps7fS+WWytItAQNq4G+1+3E2uA6xeBcPxB9oW6Y0Hr+g0QItfjBCLqAWRDruUpwLeOuO
	4d0DtSQVpOCUquMnd1Mkkx11gQREr9CDLDCjmAp+4EI6ZRj28d5FS6JSEosZp1dhjj6cQ0/bU3w
	SN2CJqX0FzHEyUg/TRkf1U6X0/dLpk4YKYtAkdzn1r7e0KR99JdfoqSCLxLWBPgSmCKkm+Vi5jD
	7lfPAsZVzmdaxJKze8ddnXbC4rIy8E+8SK2PjXlbrpFEPLiWTGSkU5Oozob7bC5NSmyi51PEq+Q
	j
X-Received: by 2002:a6b:ee02:: with SMTP id i2mr4526549ioh.294.1551349253538;
        Thu, 28 Feb 2019 02:20:53 -0800 (PST)
X-Received: by 2002:a6b:ee02:: with SMTP id i2mr4526532ioh.294.1551349252793;
        Thu, 28 Feb 2019 02:20:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551349252; cv=none;
        d=google.com; s=arc-20160816;
        b=F4dhRcwV36iH/vrJ84Q0PfImX77wr2njC+iMDDWYyALsiPBAuu+XcJH5btkVPotBhV
         j+2DUtA2PQ/OD25uy60bP9/Rg3WxqnPo5UQRVNE4vnRXvR80C8or/a96tqAvtfH/0W3W
         60q2ly1E7r9rLlXcv6dfTiOMM+l6y0BV/VF70XYNA11z6efnVOluQOiYtmKWJq12qy6A
         3zlvwGrrPpP6oEmnn6b5cXhhV13jeYIr7ugi5i65Aj+iSS7+0NN9VmIxvmqkNQAIDpkQ
         axI0r6fWRW4SGMyQ1T/4UQJ0WFpNj2w4QfeaAsSexcYWoB+1YTY8ZFtho5em4cM6aJXG
         UyKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MjGnjBgV2B9O5KOqeVNbZng4ad3gxLYTc32AkGT0Pp8=;
        b=qGf05ownJz1/Ts/7qN/qgzMg9vUMwTsVvtqgzdQ94bxojTl+6iesy0Ade9PwCadFG4
         6XZddfzmWmP135ZBg0x0DgXN0vwOX2vhajTcPrZV4kDEbjUiND6z0pq9WWZGVWEuo+68
         OwDOPBVTmoi+RwNx4zT3odUItwbhONy6kWuHBC0CHaHO+uj0f5ctbnPPmAikEeCjfQa3
         1tCjZKv+QKUitrE5Gp0H2QRRu3qYymCFmLXBX9rzy49hFB/847oK2fTm4sQ+Pb0gy937
         jJNglJ1wUApyF0ZC0levrgTZanDeCF4Whi5MZ67UbCWOwB1sVQ/w5CFVZ1L8KzNX8osk
         VxqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="P5rfIt3/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p126sor5561372itb.36.2019.02.28.02.20.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 02:20:52 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="P5rfIt3/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MjGnjBgV2B9O5KOqeVNbZng4ad3gxLYTc32AkGT0Pp8=;
        b=P5rfIt3/COYq1Sp9w2lKvRuhIo4eecHPoxZWSvqH0LGYGHqcJD5W1snDwJGNy5Rqi2
         BQZ7zAx2aJieUUZ9Y31zf8yrLa8lkQRc75/y6UqDQ8snooR9KE0fWHMX5rm5TRAuOnXF
         s6TL8n4xzDyCeTUXtaf87+Y1sh51jzeJVK8yFSIOzZWsfZPqttfwMHmHTtgpbPlUra6g
         m0wJ7bOpSJXqNnL+rEoYEaBq4FYx9MzuF/wXaG9pcKOlV9OxIKVL7vLor/k++lAfiVFH
         WCWwhPpstFd2Qc9gAS73k3OMfOYd8LZ45DXmjZ4l25HexSa+S+O+4coUtB3xoQ3QB9Q2
         /4Rw==
X-Google-Smtp-Source: APXvYqzDKGzFyZDcgnDQb+lfmz/GJ/dd0hfC7kLMFbCIgyxdQMQOG4Imsh/GNowJl1ZyBqOSUAbcZxa5JF+VOePz03A=
X-Received: by 2002:a24:c043:: with SMTP id u64mr2364085itf.59.1551349252447;
 Thu, 28 Feb 2019 02:20:52 -0800 (PST)
MIME-Version: 1.0
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com> <20190228101730.GY10588@dhcp22.suse.cz>
In-Reply-To: <20190228101730.GY10588@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 28 Feb 2019 18:20:16 +0800
Message-ID: <CALOAHbDAUFndukjQykK5zwU7XEBbdVj5eGqTW4NTwp8er4Rs4A@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, ktkhai@virtuozzo.com, broonie@kernel.org, 
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 6:17 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 28-02-19 16:14:24, Yafang Shao wrote:
> > In the page alloc fast path, it may do node reclaim, which may cause
> > latency spike.
> > We should add tracepoint for this event, and also mesure the latency
> > it causes.
> >
> > So bellow two tracepoints are introduced,
> >       mm_vmscan_node_reclaim_begin
> >       mm_vmscan_node_reclaim_end
>
> This makes some sense to me. Regular direct reclaim already does have
> similar tracepoints. Is there any reason you haven't used
> mm_vmscan_direct_reclaim_{begin,end}_template as all other direct reclaim
> paths?
>

Because I also want to know the node id, which is not show in
mm_vmscan_direct_reclaim_{begin,end}_template.

Or should we modify mm_vmscan_direct_reclaim_{begin,end}_template to
show the node id as well ?

Thanks
Yafang

> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
> >  mm/vmscan.c                   | 13 +++++++++++-
> >  2 files changed, 60 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..9310d5b 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -465,6 +465,54 @@
> >               __entry->ratio,
> >               show_reclaim_flags(__entry->reclaim_flags))
> >  );
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> > +
> > +     TP_PROTO(int nid, int order, int may_writepage,
> > +             gfp_t gfp_flags, int zid),
> > +
> > +     TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> > +
> > +     TP_STRUCT__entry(
> > +             __field(int, nid)
> > +             __field(int, order)
> > +             __field(int, may_writepage)
> > +             __field(gfp_t, gfp_flags)
> > +             __field(int, zid)
> > +     ),
> > +
> > +     TP_fast_assign(
> > +             __entry->nid = nid;
> > +             __entry->order = order;
> > +             __entry->may_writepage = may_writepage;
> > +             __entry->gfp_flags = gfp_flags;
> > +             __entry->zid = zid;
> > +     ),
> > +
> > +     TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
> > +             __entry->nid,
> > +             __entry->zid,
> > +             __entry->order,
> > +             __entry->may_writepage,
> > +             show_gfp_flags(__entry->gfp_flags))
> > +);
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_end,
> > +
> > +     TP_PROTO(int result),
> > +
> > +     TP_ARGS(result),
> > +
> > +     TP_STRUCT__entry(
> > +             __field(int, result)
> > +     ),
> > +
> > +     TP_fast_assign(
> > +             __entry->result = result;
> > +     ),
> > +
> > +     TP_printk("result=%d", __entry->result)
> > +);
> >  #endif /* _TRACE_VMSCAN_H */
> >
> >  /* This part must be outside protection */
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ac4806f..01a0401 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               .may_swap = 1,
> >               .reclaim_idx = gfp_zone(gfp_mask),
> >       };
> > +     int result;
> > +
> > +     trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > +                                     sc.may_writepage,
> > +                                     sc.gfp_mask,
> > +                                     sc.reclaim_idx);
> >
> >       cond_resched();
> >       fs_reclaim_acquire(sc.gfp_mask);
> > @@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >       current->flags &= ~PF_SWAPWRITE;
> >       memalloc_noreclaim_restore(noreclaim_flag);
> >       fs_reclaim_release(sc.gfp_mask);
> > -     return sc.nr_reclaimed >= nr_pages;
> > +
> > +     result = sc.nr_reclaimed >= nr_pages;
> > +
> > +     trace_mm_vmscan_node_reclaim_end(result);
> > +
> > +     return result;
> >  }
> >
> >  int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
> > --
> > 1.8.3.1
>
> --
> Michal Hocko
> SUSE Labs

