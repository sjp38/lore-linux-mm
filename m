Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1411AC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:59:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C828F2070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="U4ft/FAH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C828F2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A0B6B0007; Tue,  6 Aug 2019 11:59:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EB026B0008; Tue,  6 Aug 2019 11:59:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28BB06B000A; Tue,  6 Aug 2019 11:59:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 024556B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:59:19 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id v20so22080955vsi.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:59:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=clwHSPklDLht0xV/j0pRzn5NpoQ0QSZPVxcpj8s526Y=;
        b=EWy8EiPv/tgZqwhY+kcKjcXn9FScrcFkZ2SqMWqiEUerzoQTVZZ77/ENenEx7s9xGp
         IGpDOlBoBRtL2ZSX7mHmtsGXTc0NpGyYOtRDYVhGlJr5QwH7NIEH7Me0eZWRiNF0nNRJ
         PtbptCaA/3FdE1Pt4phG2XVauowRBdiGgiFsncF2xgRZSF6e1S6J1bxsDyUMVIo/Jz6r
         zvRfIy7ZbnC+xO1baANNX6t5KGOrlryL2beUWL+6rS9Pi5tRAvV2FNRCPlwpNFy9Q2G8
         i2cM5W5dqGe/Si02kICcL4/lvuU72GmhCGMch5yjRjjAdepxMaAAyz7PKfNTRG2tGCJU
         saeg==
X-Gm-Message-State: APjAAAUQHY8ZMOUfyHIizjQK1XDFtOFcK1nPtWGogI1Rw91lx+3e62c1
	VSnbiyW7yrT6LV1xvHVykqhRVr6w2llwhfoc/0VdPjEaHVzG8uKpfqJXAHgnhfkqTJUZGqA69tj
	oCJ7NUHrdPb7v8faMmo6b4kc/Xpsf2mSY9SDIwZJtVcI0eczisCkZkluSMEC1pQsdBQ==
X-Received: by 2002:a67:d46:: with SMTP id 67mr2740644vsn.181.1565107158635;
        Tue, 06 Aug 2019 08:59:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMtk8bDXA2+FPkqqABmjchK32//ThZXtcP7v9hCtsTFOhmWYBdfro2Sqt8wxBgFPEem+BR
X-Received: by 2002:a67:d46:: with SMTP id 67mr2740584vsn.181.1565107157570;
        Tue, 06 Aug 2019 08:59:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107157; cv=none;
        d=google.com; s=arc-20160816;
        b=tvJ6bqmclpmhrMO48bLGxc/7DB6A8RvpmS7D0wC9ESWTvyARWwm5qnETDOulhDdY0G
         TAMO6JeJhsCk2LbGaVsdiGuf/97Rtx47D1X7kqaqNjly/rYUkDxhvrdCefeTA5mORBWP
         VhQCCsfrqzNSb+bB/qFrnNcScl3aq/oSiyENnG2RmTb0iwTxeM9fzEn3ZIozQrFpiA9D
         rKjpJHcqgBXb4e6MTs99u0GhPUScx6BDzY229J+ody7kYUx4JZ/r4IEYoSJE1O3GKlzt
         cZpzgWyw6TLcAAADBRKI+wisG8d9glbk6SKr8KQyDT+okLi/xcvsY+tJZ94Vusxh3k5J
         67HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=clwHSPklDLht0xV/j0pRzn5NpoQ0QSZPVxcpj8s526Y=;
        b=TpjBXFI+wLozkoxENkBxpAUYEX8ucieJXd0GdSO2zNv75GVIj+p2ji+E/wUy9kNTUw
         ocCmwsPLNAJBBNpl0RyiO2xGi26BQ4SDqGgVE/GzB8ElG1Jb/7C26zaC6g7wXRNKIaug
         hAj+h9eCe7xHuIh79wCaPteTDiQaHRhLuhQ5Ic2HAfYEAg+CmTCJgYKD+ve6ERlpsgey
         yQBJqB4OzLmBpsJ6YXMOWQfTPIIyMX/Icb0Xu9NG7uBxrx1+5nuXa8g7FGhYseN6oMGE
         R0kQD/c1llXNtIJAz3XduWSPt+cHVlq44mju1WugLtAvU/pkr4bl0oCttVNzomTZMzYo
         ZQxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="U4ft/FAH";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i40si5661200uah.246.2019.08.06.08.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:59:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="U4ft/FAH";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76FrVou096277;
	Tue, 6 Aug 2019 15:59:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=clwHSPklDLht0xV/j0pRzn5NpoQ0QSZPVxcpj8s526Y=;
 b=U4ft/FAHTbOI04nmVl8Mn/IfK9CBWAcDYDdTlRqXfd6uLbkTOiiK6bqz+2mb8N8BcEYK
 ciQWxWvCS6w0skCnFN/IHXZDlMuncaZf3pgs3TNileaFX6FnwbjqV5vo88Ev6IhMIxcZ
 yy4wMgJGd9tccq+Tpg/+mTCgqKGFBZ2OKBWjKzhQddaHH0DDpNIX6u0nMatBJ4SI6lEc
 Ony1KiY6K+YSonf0OXMBACUxZXhysS9yXG9SjI8hXtsbNjpQczkzDB7Yu6QmLGhGvOf+
 RqckJEQTygn/nX47zCdrAeoHCP9DBCsD8nV/lf1zdgjVAQB5bKmIcy2TGW7h2Njm4Tmw kg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2u527pq2k0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 15:59:08 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76Frd6Y089344;
	Tue, 6 Aug 2019 15:59:08 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2u7666pasv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 15:59:07 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x76Fx616026621;
	Tue, 6 Aug 2019 15:59:06 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 08:59:05 -0700
Date: Tue, 6 Aug 2019 11:59:04 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        Christoph Lameter <cl@linux.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806155904.rwd7tmbbpmif4edh@ca-dmjordan1.us.oracle.com>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
 <20190806111459.GH2739@techsingularity.net>
 <CALOAHbCxBdGtTo9SneNtnDKWDNEZ-TcisE9OM9OagkfSuB8WTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbCxBdGtTo9SneNtnDKWDNEZ-TcisE9OM9OagkfSuB8WTQ@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060152
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:35:29PM +0800, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 7:15 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > On Tue, Aug 06, 2019 at 05:32:54PM +0800, Yafang Shao wrote:
> > > On Tue, Aug 6, 2019 at 5:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > [...]
> > > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > > >
> > > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > > path as well?
> > > > >
> > > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > > I haven't check in which commit the shrink_slab() is removed from
> > > >
> > > > What I've had in mind was essentially this:
> > > >
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 7889f583ced9..8011288a80e2 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > > >                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > > >                 .may_swap = 1,
> > > >                 .reclaim_idx = gfp_zone(gfp_mask),
> > > > +               .may_shrinkslab = 1;
> > > >         };
> > > >
> > > >         trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > > >
> > > > shrink_node path already does shrink slab when the flag allows that. In
> > > > other words get us back to before 1c30844d2dfe because that has clearly
> > > > changed the long term node reclaim behavior just recently.
> > > > --
> > >
> > > If we do it like this, then vm.min_slab_ratio will not take effect if
> > > there're enough relcaimable page cache.
> > > Seems there're bugs in the original behavior as well.
> > >
> >
> > Typically that would be done as a separate patch with a standalone
> > justification for it. The first patch should simply restore expected
> > behaviour with a Fixes: tag noting that the change in behaviour was
> > unintentional.
> >
> 
> Sure, I will do it.

Do you plan to send the second patch?  If not I think we should at least update
the documentation for the admittedly obscure vm.min_slab_ratio to reflect its
effect on node reclaim, which is currently none.

