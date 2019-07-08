Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0289C606AC
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:15:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6174C2064A
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 12:15:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6174C2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8CB48E0010; Mon,  8 Jul 2019 08:15:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3E4F8E0002; Mon,  8 Jul 2019 08:15:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2BA58E0010; Mon,  8 Jul 2019 08:15:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A28B18E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 08:15:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e32so4787985qtc.7
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 05:15:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zuc2UGoulORVltkjy8YEdyUMHEcx1/3ATLZEvtOe3FI=;
        b=QIFij3sZuPd2NmVhB11S3dBMacx7OOFL43XFfl5/EsBxJf8mX3jk+kq0f9DgiJ+Yis
         eMLzNw7IvPH1GG2FxgvlyZZ8S31PxuB/q5kegItElsP4RvoPMSZsVIf35lQqyhj0ABEs
         sx/59UFApiNBQD95hUdTx2lokinwXyYJKiLepq9910oVBmB7l2Vp2c0RhJKwK9vuiZY/
         87AmdIZZq4N8JdGuoxfF9unvMVvVG1ixJaYds22R7IQeCMvDU+750KVExydJyBezqaSj
         6LF/NIfSrRDX9W0QTTsZX2ogSN6Ab88ydXrqdJw1csJ1eNinceKU2Th2l/Won1S7sdVC
         MJwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUnShhTlA1mg5wcsxGJK+LeIh4L9ew2bH/DDHFiV2rdG2e9k3YW
	0R0LLULUbWCfSkg9Ukg5afX8oMJAqQUVnE/wIvW8IHm0luex3ch5wGkl3KUAebGqysaQIIX4OmN
	v0cIciWpWN9kEYZSAQ6KuMD0LCmKy7uMU3o75sswt81JVSZS0Mf7c9hFRJc6ae8O2sw==
X-Received: by 2002:ac8:30d2:: with SMTP id w18mr13841697qta.296.1562588112401;
        Mon, 08 Jul 2019 05:15:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRtK7+YU3L0TPJfdi9uLN4+Hfv1Mz3HPrAsbgG9oYCwBZ22mDg+eZiCmQSPjznDkWsHuze
X-Received: by 2002:ac8:30d2:: with SMTP id w18mr13841623qta.296.1562588111411;
        Mon, 08 Jul 2019 05:15:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562588111; cv=none;
        d=google.com; s=arc-20160816;
        b=FavPLLzPgsgMN8BG5PRzwsxiQg8mVG7wJ/EXrZkiXkBdleiMFqEUybifTv2y219oON
         SsoQhka8cNTsBv0vWJvekhbYQ7s3vMSkPB53cUMWEHd4f3Lewj1Xhs7jjjjpDg+4vTbX
         Pw3tUOeuTV1QSB8euNqh8lbm9yDk+a6w7VP/Myv2Um9K0bB4M+1YAACes2MvY9HgsFfm
         IGp18axOQgSCfB0gzgqPoKikbE/C9zH4v3vMnsXmrcwjRh/MGrkmoR8ibw3RGWER7Ff6
         Uio1f5gXlG8yfLJZGpGajXHzw7/WPcFsiXJTpbobou5Hvy1TywUnyG+rlA/P1zn8D2Fr
         mBqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zuc2UGoulORVltkjy8YEdyUMHEcx1/3ATLZEvtOe3FI=;
        b=egCuTMwrd/iymRqLxtFCeeqftkyciDGXlhL0ACDaID7Xs0aHXbmIq9xcVWCZcTyCvB
         HfQOhYFlwXA+/JWS29mfWS8Qa+wV/fUy+SL1ISxJobO+zfa9byTuk7tIJtYlcl1MUfi2
         5cY4mej/WF0G5zR+inc/JN5xUqbhxT99VuI2f/K2FyoeyVuT8T6ZUTZXIUq8AmJcn8VZ
         JSDXmzvZHA9cnBfRQWtQBs4iNaXIiKnRITiQeuZFCXyWXtw/+ehiXpk10beDTYL9FC82
         8LQT+iLtdSvPWgUfhQLNYZMtkLLUvBaiwB9+soTBfC+2kRWt1xvnwLEWOW9qMz1/vcjB
         NPbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j24si9978789qtj.383.2019.07.08.05.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 05:15:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44BE57CBA0;
	Mon,  8 Jul 2019 12:15:05 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C53E75D9E5;
	Mon,  8 Jul 2019 12:15:01 +0000 (UTC)
Date: Mon, 8 Jul 2019 08:15:00 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>, linux-xfs@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190708121459.GB51396@bfoster>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz>
 <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
 <20190705151045.GI37448@bfoster>
 <20190705235222.GE7689@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190705235222.GE7689@dread.disaster.area>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 08 Jul 2019 12:15:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 06, 2019 at 09:52:22AM +1000, Dave Chinner wrote:
> On Fri, Jul 05, 2019 at 11:10:45AM -0400, Brian Foster wrote:
> > cc linux-xfs
> > 
> > On Fri, Jul 05, 2019 at 10:33:04PM +0800, Yafang Shao wrote:
> > > On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > [...]
> > > > > > Why cannot you move over to v2 and have to stick with v1?
> > > > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > > > much, which is unacceptable by our customer.
> > > >
> > > > Could you be more specific about obstacles with respect to interfaces
> > > > please?
> > > >
> > > 
> > > Lots of applications will be changed.
> > > Kubernetes, Docker and some other applications which are using cgroup v1,
> > > that will be a trouble, because they are not maintained by us.
> > > 
> > > > > It may take long time to use cgroup v2 in production envrioment, per
> > > > > my understanding.
> > > > > BTW, the filesystem on our servers is XFS, but the cgroup  v2
> > > > > writeback throttle is not supported on XFS by now, that is beyond my
> > > > > comprehension.
> > > >
> > > > Are you sure? I would be surprised if v1 throttling would work while v2
> > > > wouldn't. As far as I remember it is v2 writeback throttling which
> > > > actually works. The only throttling we have for v1 is reclaim based one
> > > > which is a huge hammer.
> > > > --
> > > 
> > > We did it in cgroup v1 in our kernel.
> > > But the upstream still don't support it in cgroup v2.
> > > So my real question is why upstream can't support such an import file system ?
> > > Do you know which companies  besides facebook are using cgroup v2  in
> > > their product enviroment?
> > > 
> > 
> > I think the original issue with regard to XFS cgroupv2 writeback
> > throttling support was that at the time the XFS patch was proposed,
> > there wasn't any test coverage to prove that the code worked (and the
> > original author never followed up). That has since been resolved and
> > Christoph has recently posted a new patch [1], which appears to have
> > been accepted by the maintainer.
> 
> I don't think the validation issue has been resolved.
> 
> i.e. we still don't have regression tests that ensure it keeps
> working it in future, or that it works correctly in any specific
> distro setting/configuration. The lack of repeatable QoS validation
> infrastructure was the reason I never merged support for this in the
> first place.
> 
> So while the (simple) patch to support it has been merged now,
> there's no guarantee that it will work as expected or continue to do
> so over the long run as nobody upstream or in distro land has a way
> of validating that it is working correctly.
> 
> From that perspective, it is still my opinion that one-off "works
> for me" testing isn't sufficient validation for a QoS feature that
> people will use to implement SLAs with $$$ penalities attached to
> QoS failures....
> 

We do have an fstest to cover the accounting bits (which is what the fs
is responsible for). Christoph also sent a patch[1] to enable that on
XFS. I'm sure there's plenty of room for additional/broader test
coverage, of course...

Brian

[1] https://marc.info/?l=fstests&m=156138385006173&w=2

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

