Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98C1BC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55FA42084E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:51:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55FA42084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA5406B000A; Tue, 14 May 2019 10:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54C56B000C; Tue, 14 May 2019 10:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1E746B000D; Tue, 14 May 2019 10:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7417E6B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:51:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so23706503edz.3
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gTDcvr1Q9k8wdKdaH/4Ea5VWYFCksZYFaL506Kr62+Q=;
        b=GbneVYpH8MFPQzryNu3nuJ7NhNJZs+2wCULO20e6k5X4cd05L+eHVqRFfuzXNtjXOB
         MNuEbFMG3qOTf1bhlDs2WbwIVfpd/JRsUSmv463dk5nOAZfXzxkjqJJpEGyvvw8tpkDL
         4RXkab8HBY+1t0FEXZWnnV4Ah6KCwELEWonpKEgkD38PXOkVfHkUbxqVUjZNH54QJwhF
         Wmwkalyr9+hqvmOm66tCJLzgjPPo8ikSpbEI55lqCn7hus0Sl1RsxR31ZTbeA6a8Q6v2
         Tit+oBhAtQGT4TX/aUzbFsrdWTm05nOvOdLB8d9QuzPM71lRMiXOuhVN6IKvN8KX/ZAI
         CLvw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVKQgO4ylwZdergmabVTo90bjD43LoOn2HSRN+Kw54A+r+8k2sV
	OkwW7CZJdl3WH6Bo1SFAewVyuefIaJC/xFuIiq227+K0PRFb7Ez6LqVFI2p8duTAcjG/0XfF8CC
	NbAG31aPSqiimJ6XuZGL3scI18uMoXsCsihXxH3LFesuBkW8IH36owCHIjXsFUj0=
X-Received: by 2002:a17:906:2518:: with SMTP id i24mr16349343ejb.169.1557845485031;
        Tue, 14 May 2019 07:51:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNxDgNKZp68fCmyTosKbQQBnfd07j0CXENm97fJiT7njBaW7nyLK0Jj69uAKBwy/iuqlAw
X-Received: by 2002:a17:906:2518:: with SMTP id i24mr16349274ejb.169.1557845484209;
        Tue, 14 May 2019 07:51:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557845484; cv=none;
        d=google.com; s=arc-20160816;
        b=erPNZhZCSQX07cRLVHbyM9V8hgdUFSu9HshtRe/wXY5DiA4P8G6l9hn8PaqAG5/Fgp
         EWYkzn0q9QZXkhRKkawjFuDTdpUulz3DybGCgyBMaM0iSj7XIB8wmaN5L9XlTF3ANbpB
         1wbsk94I2ZseSLwrEdpKGOLjUKbCrRt1RF3JtcwcWaauQtJue0U38Ut4HFKGRnhXN+9k
         fp+v6j4cNhuo1xaZ5jTsWaT4fHKuVxHfA5HJ9bnIFfQf/94dmk45KMaQQ2ZlEgUiNUtd
         b8chFwPWyEfkd0QEaWjRFWWcLs8kCH3aGzHm4SyMtMedAZCuVtqVHsUEGvLHkXADORcK
         JqJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gTDcvr1Q9k8wdKdaH/4Ea5VWYFCksZYFaL506Kr62+Q=;
        b=Chr3n4XXKshOjJkWLPjyOVZcU8tjkgYVmDr1PiUZqhgXKvuHuy4Iann/OMaNP+zJHs
         Lo0sibr651et4lp9xmRjlgtTYAmOph/TMWzwNm1C9Yc2Ufw3JMV2WnIqUbf1HwtSF4md
         vEybODjz0eYbs/+/zPaSxqWhUSz3FMEe3H12huc8aaMphOrZFgBf2Oh87aQMX/UUFIVf
         ntr4W4Ia/yn0KwRQ2b+4gklGAbsHYrcqpCVFyZ2yz0/6WsdZRt71XZcfpAjHB4c3mGDk
         h6WDEqxKojpKP8lAe4G3d9AB+cO8C45ZX0v+YYqB0UQpKlOahSEngoXK6VP2noFfJA8T
         d/Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si6957548ejj.258.2019.05.14.07.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 07:51:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 520E3AF94;
	Tue, 14 May 2019 14:51:23 +0000 (UTC)
Date: Tue, 14 May 2019 16:51:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190514145122.GG4683@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514144105.GF4683@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Forgot Hugh]

On Tue 14-05-19 16:41:05, Michal Hocko wrote:
> [This is adding a new user visible interface so you should be CCing
> linux-api mailing list. Also CC Hugh for KSM in general. Done now]
> 
> On Tue 14-05-19 15:16:50, Oleksandr Natalenko wrote:
> > By default, KSM works only on memory that is marked by madvise(). And the
> > only way to get around that is to either:
> > 
> >   * use LD_PRELOAD; or
> >   * patch the kernel with something like UKSM or PKSM.
> > 
> > Instead, lets implement a sysfs knob, which allows marking VMAs as
> > mergeable. This can be used manually on some task in question or by some
> > small userspace helper daemon.
> > 
> > The knob is named "force_madvise", and it is write-only. It accepts a PID
> > to act on. To mark the VMAs as mergeable, use:
> > 
> >    # echo PID > /sys/kernel/mm/ksm/force_madvise
> > 
> > To unmerge all the VMAs, use the same approach, prepending the PID with
> > the "minus" sign:
> > 
> >    # echo -PID > /sys/kernel/mm/ksm/force_madvise
> > 
> > This patchset is based on earlier Timofey's submission [1], but it doesn't
> > use dedicated kthread to walk through the list of tasks/VMAs. Instead,
> > it is up to userspace to traverse all the tasks in /proc if needed.
> > 
> > The previous suggestion [2] was based on amending do_anonymous_page()
> > handler to implement fully automatic mode, but this approach was
> > incorrect due to improper locking and not desired due to excessive
> > complexity.
> > 
> > The current approach just implements minimal interface and leaves the
> > decision on how and when to act to userspace.
> 
> Please make sure to describe a usecase that warrants adding a new
> interface we have to maintain for ever.
> 
> > 
> > Thanks.
> > 
> > [1] https://lore.kernel.org/patchwork/patch/1012142/
> > [2] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/02417.html
> > 
> > Oleksandr Natalenko (4):
> >   mm/ksm: introduce ksm_enter() helper
> >   mm/ksm: introduce ksm_leave() helper
> >   mm/ksm: introduce force_madvise knob
> >   mm/ksm: add force merging/unmerging documentation
> > 
> >  Documentation/admin-guide/mm/ksm.rst |  11 ++
> >  mm/ksm.c                             | 160 +++++++++++++++++++++------
> >  2 files changed, 137 insertions(+), 34 deletions(-)
> > 
> > -- 
> > 2.21.0
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

