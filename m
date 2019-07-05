Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4E64C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 15:11:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 463F2216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 15:11:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463F2216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCD3C6B0003; Fri,  5 Jul 2019 11:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7D268E0003; Fri,  5 Jul 2019 11:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A45358E0001; Fri,  5 Jul 2019 11:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 893096B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 11:11:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x16so2449897qtk.7
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 08:11:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=omEE/Ty+uaDKe/Fiqu55yd4RwHGWx2ik6s2RdIUN5a4=;
        b=gEJS/Emsh/9ozMKPkEW4zJDzBoOVJnTXyvWTkSeWY7Gbyv/tXFjAXt9gu0HBrJq5Ue
         1fnoyAjIIXMtzoqtTwcntwQz5d1Y7Wq06QpoWgbOv4Y1Bcl2ISOav3odQpZS/Si7LCm5
         8xZSB3f5U92npHRVEvCzbj0RauKC5RFPbZPstM1/6ySVAyBqpkiGe2I/Qziu5rO3qGIw
         qdl5hYUuAwqa5q16sJEDFv+7bIj+q01qtKniT8dH4P7FDKGPPWqhTLD005KOTtXAn1nO
         32QS1J5w0Eq9xP3VmGdmDBOM+CX8qW3lqXorAf14U/BB+WbYq2Rza2kM7nC8g24Xx1XC
         eDyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXhZqq18pR0rporuEULI6yDj0B1NUThTcq5vwE8wrs1hZR95Rm7
	7i1sN1eD/70KEFxx0Ge3xf6reRwEypqjQtVG+GqWOkusZSfpRGrNk+TWYhjJp6YvpsUfYlhh7un
	JABN2Iw6NXMQAJntXqdPAJ/oAaF0BDHh8N2mekjcNLzFaeyECEH5VVEUHbfM0yZ1PNQ==
X-Received: by 2002:a37:7dc1:: with SMTP id y184mr3341287qkc.58.1562339465277;
        Fri, 05 Jul 2019 08:11:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza9QkssdYgB9WZbCuWs1az3JYdV7ve4KlIeGWp6++g0Ci57L/J0hIweP5SBYHT/wLjS8J2
X-Received: by 2002:a37:7dc1:: with SMTP id y184mr3341228qkc.58.1562339464485;
        Fri, 05 Jul 2019 08:11:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562339464; cv=none;
        d=google.com; s=arc-20160816;
        b=Lu+G5X7BJtrAJ+bpX4qBmuf/S6XZcPdP4Br1vacSsaghrAgYTvtVFSKgT0S4kXii77
         PWoOdpRxYxT0DpabXua1tKhBetbIWLBVX/5WfMQZcUfwwvesKnx0WHSAwtyNFin/EJmD
         R0L124Rdjjwx5taFEgEm8GKSKcfiJYFwdqLyJ9LsHmtrHRqfEPETI/bae4c1Y1PnpeUp
         e2ebDx+8+rnfcLuuIkpynh+y3x8r7Jb1T3/iOOqXpftb2S6IuxPagM9hcreIo2XjbklN
         HwNXkwkiEKOdphcuY08lHXiAmDcEh4TflFfUeilOKIc45tDixl7397d/4dHSE63SOCWk
         Cq+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=omEE/Ty+uaDKe/Fiqu55yd4RwHGWx2ik6s2RdIUN5a4=;
        b=D4YSEbE9QSXg+rxWi8auFTnIXzi+hqzkeEUSlw/K/o+X6vAUhCD05IYyY/O0Yt+vLh
         U3dWVOF4cXr0w02HQpuDThqwCMCsJ0YBuMzgjpGBwId8GcaBGyiP1u0uJYgtJQYgPift
         nuQ5QdORGhjwI1qffq243ap3Z7bmuIJDps7OcEe8AT2khjrCrU0QoE0qXHwIVELSg5ip
         pxzMHMSQ4KlEfED0SIvFn+R7ueXMWJ3X7TdAmKFv4IJprPfYG7zTFA0asMv5RRO2dgw/
         PIBzAfTVBtmy7RfvKkIoR3fDoHdMzu0vmrFwfUJg7p7rHX60qqwX1K+Ge3rBRTj68SXd
         PrZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p15si6332696qtk.222.2019.07.05.08.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 08:11:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64BDE2F8BF9;
	Fri,  5 Jul 2019 15:10:48 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 257B980A31;
	Fri,  5 Jul 2019 15:10:47 +0000 (UTC)
Date: Fri, 5 Jul 2019 11:10:45 -0400
From: Brian Foster <bfoster@redhat.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>, linux-xfs@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705151045.GI37448@bfoster>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz>
 <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 05 Jul 2019 15:11:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

cc linux-xfs

On Fri, Jul 05, 2019 at 10:33:04PM +0800, Yafang Shao wrote:
> On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > > Why cannot you move over to v2 and have to stick with v1?
> > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > much, which is unacceptable by our customer.
> >
> > Could you be more specific about obstacles with respect to interfaces
> > please?
> >
> 
> Lots of applications will be changed.
> Kubernetes, Docker and some other applications which are using cgroup v1,
> that will be a trouble, because they are not maintained by us.
> 
> > > It may take long time to use cgroup v2 in production envrioment, per
> > > my understanding.
> > > BTW, the filesystem on our servers is XFS, but the cgroup  v2
> > > writeback throttle is not supported on XFS by now, that is beyond my
> > > comprehension.
> >
> > Are you sure? I would be surprised if v1 throttling would work while v2
> > wouldn't. As far as I remember it is v2 writeback throttling which
> > actually works. The only throttling we have for v1 is reclaim based one
> > which is a huge hammer.
> > --
> 
> We did it in cgroup v1 in our kernel.
> But the upstream still don't support it in cgroup v2.
> So my real question is why upstream can't support such an import file system ?
> Do you know which companies  besides facebook are using cgroup v2  in
> their product enviroment?
> 

I think the original issue with regard to XFS cgroupv2 writeback
throttling support was that at the time the XFS patch was proposed,
there wasn't any test coverage to prove that the code worked (and the
original author never followed up). That has since been resolved and
Christoph has recently posted a new patch [1], which appears to have
been accepted by the maintainer.

Brian

[1] https://marc.info/?l=linux-xfs&m=156138379906141&w=2

> Thanks
> Yafang
> 

