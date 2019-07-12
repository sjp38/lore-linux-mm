Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0F31C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:54:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82F2C2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:54:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82F2C2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204B48E0124; Fri, 12 Jul 2019 03:54:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F198E00DB; Fri, 12 Jul 2019 03:54:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 056428E0124; Fri, 12 Jul 2019 03:54:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9B298E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:54:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so7059528edx.10
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:54:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uL4uHZ/i4EUOK8mKbXNEKWDSmpNw+8b2HeM25bjTZlE=;
        b=k4iJ5Mo1rfgCZP3n6OzxXzsfxYeZksdzyKdVa0JP+muNG1IjuBXv91rVFm5a1xXPY8
         R6S1KfI1fYTxYJPxSp9iqUoxcU/lrSd96O0AzA0q/ZcRbi6xNwoHI/0qRhOrEj10eV5A
         ussHCRQGoHPvoB08b29XZXCAfZ63SEV43BQeisQ4uxIh40IpwgRlSFrINB+ilxsI//q0
         XFAnu/LQeYjz0395hgY1T1AfaUJU5bgK4tTRLDm9rO/Szg4xmYjed07Do4aHILTOnK3/
         ip7zSoZdUksYF8lJSGwwE0ICzbzrc9yFISXSI0y6QIvXALSyMpq8cxPiHKo0SaAJy2yH
         BGjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXa6B+iIJ2e9jQcoG7rKJOfixEbQ4ktWLa3p0WfGwSfzt8ar+AU
	nxVN6BS0RMAOotD6RBMwpWtSycFsmdNjfftN/uHicjCDCbStE/vCMo5B9MTp+qKb/9N8ifVCGAr
	9DJZZv1k1JMzEw742ihw9vS6okaijBQk1n+kMYj1lKBXomZTZKjSwX8aHYndYVy8=
X-Received: by 2002:a17:906:b6ce:: with SMTP id ec14mr6812219ejb.81.1562918044250;
        Fri, 12 Jul 2019 00:54:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/ATKdHjlI+R8ubXNXS82IhqtVx1KkE316TV/0Z54njrMP5kP+8sRFoQQMHPBA0aHlsBst
X-Received: by 2002:a17:906:b6ce:: with SMTP id ec14mr6812184ejb.81.1562918043493;
        Fri, 12 Jul 2019 00:54:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562918043; cv=none;
        d=google.com; s=arc-20160816;
        b=PKWQdcHam2zXxdkMiobxZULSLcuZgryyEJ5wcDqQgCAEYeho+zf3EAkE3TP1kjDNdn
         g3edb24dbefy0hqhQtop5LGHupF/RdQH+Zu6vaXz6ABKbuI1j6zEGMlWFUv9SKkf6yMJ
         59h9joY96cykZ7Mvvn90ff6PrtWS3nRzCGFb3BpFRf1z83hxMym1hiVv/4Kw7dBSB/kR
         OQ81XA7ILHIfn2ggEMR1BL0xKwkOZwHVEsrHNAbpGCLMWzs0GV7K5isWz3JARrOhzIJg
         Kchs1O6LnSzVqMlKbarO95sVVpO36Kw805ZDmRNXdubWQe9jF2MLCymJ+SiDH0rH8Z9p
         NFCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uL4uHZ/i4EUOK8mKbXNEKWDSmpNw+8b2HeM25bjTZlE=;
        b=qcKRURWfNxfUS1x8Dk1wR578gkQ+9Via6/26sV9hzetFh2dX0S5sqakbf2Q3Rmv2bB
         Z7MqeLkSzYj1rbNC+Oqsx8I8YCLk5W3WFUNzVwfOSZ1NVleEJm/p2FHGRtXh/xSTNmhP
         MRrC2Uk6NfTTuYKe8kyUiE7hTATW0HJFT874gYuNf2X4IBNo+vO8ZMcy8Q1ekyW5P4SV
         Xv6juW6n6GjWO1Us5RJAt23RG7XN5PaCOn6a4PHbbf7lLl0QMeTdfl5N/fZzFcJxKh7O
         g3Gz9LH4oIO4F0IhbIxov0O3ehSWIzHsKF+GyGJbxYwY2EvQNP2JHmFQDsxWsse3FE24
         v/KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l31si5776130edc.248.2019.07.12.00.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:54:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AABB0AC8C;
	Fri, 12 Jul 2019 07:54:02 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:54:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with
 the hierarchical ones
Message-ID: <20190712075401.GQ29483@dhcp22.suse.cz>
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
 <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
 <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
 <20190712052938.GI29483@dhcp22.suse.cz>
 <CALOAHbCt7b-AMDtK6FmAfYnYSMiB=UhKbBVKt7CzFFazzrKeVQ@mail.gmail.com>
 <20190712065312.GJ29483@dhcp22.suse.cz>
 <CALOAHbBBMWhyWybRv+vDvP4XLu5TOLaf2NOyoNe6zQ1D3sJQMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBBMWhyWybRv+vDvP4XLu5TOLaf2NOyoNe6zQ1D3sJQMw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 15:14:01, Yafang Shao wrote:
> On Fri, Jul 12, 2019 at 2:53 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 12-07-19 14:12:30, Yafang Shao wrote:
> > > On Fri, Jul 12, 2019 at 1:29 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Fri 12-07-19 09:47:14, Yafang Shao wrote:
> > > > > On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > > >
> > > > > > On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> > > > > >
> > > > > > > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > > > > > > the local VM counters is not in sync with the hierarchical ones.
> > > > > > >
> > > > > > > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> > > > > > >       inactive_file 3567570944
> > > > > > >       total_inactive_file 3568029696
> > > > > > > We can find that the deviation is very great, that is because the 'val' in
> > > > > > > __mod_memcg_state() is in pages while the effective value in
> > > > > > > memcg_stat_show() is in bytes.
> > > > > > > So the maximum of this deviation between local VM stats and total VM
> > > > > > > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > > > > > > great value.
> > > > > > >
> > > > > > > We should keep the local VM stats in sync with the total stats.
> > > > > > > In order to keep this behavior the same across counters, this patch updates
> > > > > > > __mod_lruvec_state() and __count_memcg_events() as well.
> > > > > >
> > > > > > hm.
> > > > > >
> > > > > > So the local counters are presently more accurate than the hierarchical
> > > > > > ones because the hierarchical counters use batching.  And the proposal
> > > > > > is to make the local counters less accurate so that the inaccuracies
> > > > > > will match.
> > > > > >
> > > > > > It is a bit counter intuitive to hear than worsened accuracy is a good
> > > > > > thing!  We're told that the difference may be "unacceptably great" but
> > > > > > we aren't told why.  Some additional information to support this
> > > > > > surprising assertion would be useful, please.  What are the use-cases
> > > > > > which are harmed by this difference and how are they harmed?
> > > > > >
> > > > >
> > > > > Hi Andrew,
> > > > >
> > > > > Both local counter and the hierachical one are exposed to user.
> > > > > In a leaf memcg, the local counter should be equal with the hierarchical one,
> > > > > if they are different, the user may wondering what's wrong in this memcg.
> > > > > IOW, the difference makes these counters not reliable, if they are not
> > > > > reliable we can't use them to help us anylze issues.
> > > >
> > > > But those numbers are in flight anyway. We do not stop updating them
> > > > while they are read so there is no guarantee they will be consistent
> > > > anyway, right?
> > >
> > > Right.
> > > They can't be guaranted to be consistent.
> > > When we read them, may only the local counters are updated and the
> > > hierarchical ones are not updated yet.
> > > But the current deviation is so great that can't be ignored.
> >
> > Is really 32 pages per cpu all that great?
> >
> 
> As I has pointed out in the commit log, the local inactive_file is
> 3567570944 while the total_inactive_file is 3568029696,
> and the difference between these two values are 458752.

And that is less than 1% right?

> > Please note that I am not objecting to the patch (yet) because I didn't
> > get to think about it thoroughly but I do agree with Andrew that the
> > changelog should state the exact problem including why it matters.
> > I do agree that inconsistencies are confusing but maybe we just need to
> > document the existing behavior better.
> 
> I'm not sure whether document it is enough or not.

Well, the fact is that numbers will always be a snapshot of a single
counter at a specific time. So two different counters might be still
inconsistent. Caching just adds on top of this fact. If that is too much
then we should think about reducing that - especially for machines with
many cpus.

> What about removing all the hierarchical counters if this is a leaf memcg ?

Removing them would make parsing more complex because now the userspace
code has to special case leaf and intermediate memcgs. If we want them
to do that then we could also let them calculte hierarchical numbers if
they need them.

We could also special case leave memcgs and print normal counters for
hierarchical values. But I am still not sure this is really necessary.
-- 
Michal Hocko
SUSE Labs

