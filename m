Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D0B9C606CF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 11:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D261520665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 11:54:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gqBRh0w4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D261520665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41CE98E0072; Wed, 10 Jul 2019 07:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CC358E0032; Wed, 10 Jul 2019 07:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BD458E0072; Wed, 10 Jul 2019 07:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E69638E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:54:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j22so1208659pfe.11
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 04:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qFJc4VUzZ7eA+4lKweDf3cU5NLHS16RVicSZWgcgKek=;
        b=qmqSgbK6PnBQFmNk0mRr994+ybBg0CsMWP2vhsm0yy5yUMHVWR8qZHKqTBDyczMw9W
         AMD1/gZc7pgRYyUP3+PmzPa5DKa1R/Jm+OxifBPWs7UKuF/yzkYWTtA6JpDaNf1RDox4
         Q54sVcgjIShtCTFdsRNfGsYNECRP+ma0xIg2G+O54yYPiSEqIlFBblQxrt9fRWG7iZzl
         YFD2zFz7wPfmLq1UKvEBBzj2SLBGwdrTkT2OzGyuXeBcssZR6jHnBwuSIeCe3oEirepl
         sjHvnw5UB7wL+MC+IYJ8FiZhYQzD+Yrbg7ACDyt5nTy63WD+OivSkFgGtcS99XghVPkI
         M4sg==
X-Gm-Message-State: APjAAAWYRiAso1YVYnzLDDL4wcbH6elcQB3gFTbGQkBQMcRClTSsNvi3
	kB1lf3SbUBRP8wIbIQhxnTfVUPogjagCnC+graKvYK2IOjQiCgclrLN8veOYBgUo3XELMCBN9K5
	dfQ7+/zlh+pAjULe6DwWDpIdQyZbUF7kIELAwCvpvLW4ldZOlaXAiXL+xjse11Io=
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr38257002plt.152.1562759645495;
        Wed, 10 Jul 2019 04:54:05 -0700 (PDT)
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr38256952plt.152.1562759644841;
        Wed, 10 Jul 2019 04:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562759644; cv=none;
        d=google.com; s=arc-20160816;
        b=nP1q33hfi8NV37EEOH6aJVEyPAZ1N/8o4B7nW6Zzn3pCVRqRTmYbQlNi7r1yYYnN6X
         Av9dQd0gGOIgcHgbmAsuuWa9c/VseuaZyGDn0D5+EtlHBgv9vGxJhbFJCkYO+IBcxaJG
         /ONR1tHZ7e1xCWVEieoy66kL4JXhCH2aT5Wn1Qkwsk5Xs7qBBt+vSf43G8mKPGC5Kkx4
         2RcN/+VOrZqDySlTRg14znlclY9kogKnUmk2yuwixfvgNBkO08MUVSQw1BL7bkbIgn2D
         Kcw2J3zQLfC0JqwZ/eX9SzHyDqdlNyOwlcxT4nT7o5opDPBXlPxd2Z8LtCKB7UpU7Op0
         X9WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=qFJc4VUzZ7eA+4lKweDf3cU5NLHS16RVicSZWgcgKek=;
        b=f8jLrL8B486WAjm8CpslJFyqI1oRWZlL8A0MVuKqgAhE5ln50bNYisNJTNQwND9W4o
         lIkIIgRiehDio8ERx7LH9UE3FFBz+XhLZ5O+mDnJJ/EvOqmUHJVvht8uYBPC02bn5ZVW
         HrOnJpKR4vcIQkanhViPjqynLzL7KiocGUWMtpSo+Lk00A8AKvvGT34QmUKCMFSpt+yS
         De0LBWFCmKx74imA07RyA7BAWb+TdZQ8KEGmXlRKnyHOdfBOHRigHDyIt2WmXyeswhfD
         EdrIPrru5whgT0ZJTTDPcVVk/7RsjXKmtJaUGGrKCVc+4cKqGzHs9sphtGS9qoX18+Qv
         37ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gqBRh0w4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor2593576pjv.18.2019.07.10.04.54.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 04:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gqBRh0w4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qFJc4VUzZ7eA+4lKweDf3cU5NLHS16RVicSZWgcgKek=;
        b=gqBRh0w42sxcB+7dw45Xx2hl7SVOoiJ+xuufT+1HnDzjJdfuzBm+yH2jqPyYJQX70Y
         hLRZntmWDekvprvhpBpbQuKBTyAFznaoXdkg+VQL/xAju/jqu+kOtnM2A/0mVV/JntNK
         MBGlw2yxVrEbSCpSHEXnsCdlzcepVEMGKFY1l2IDplLmLFUFNmnkTeLjoYifTBen2GvZ
         Mg9T0f0+sfdtDdSioIpIsg32h+lWoNNe98mVJY/NYg3W3rrMy/TIZ/HQgEgZrSPssiRp
         v9aKccmK4MNGbmrXoX4kSYZEyNnkSHKKqJhWCwBVUasIQmtOpcRAfXmuukPsiOI9cgQK
         TXrg==
X-Google-Smtp-Source: APXvYqxraK6JSVjvhWTndFlIaj5ecwxAEgR9vgrrnmiOU9Tos1QNunQTBS6eWi9kPiiiB1EXmxbYFA==
X-Received: by 2002:a17:90b:8d8:: with SMTP id ds24mr6392025pjb.135.1562759644195;
        Wed, 10 Jul 2019 04:54:04 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x14sm3012026pfq.158.2019.07.10.04.53.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 04:54:02 -0700 (PDT)
Date: Wed, 10 Jul 2019 20:53:56 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190710115356.GC186559@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
 <20190709095518.GF26380@dhcp22.suse.cz>
 <20190710104809.GA186559@google.com>
 <20190710111622.GI29695@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710111622.GI29695@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 01:16:22PM +0200, Michal Hocko wrote:
> On Wed 10-07-19 19:48:09, Minchan Kim wrote:
> > On Tue, Jul 09, 2019 at 11:55:19AM +0200, Michal Hocko wrote:
> [...]
> > > I am still not convinced about the SWAP_CLUSTER_MAX batching and the
> > > udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
> > > Sure you can have many invocations in parallel and that would add on
> > > but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
> > > the batching for now and think of it only if we really see this being a
> > > problem for real. Unless you feel really strong about this, of course.
> > 
> > I don't have the number to support SWAP_CLUSTER_MAX batching for hinting
> > operations. However, I wanted to be consistent with other LRU batching
> > logic so that it could affect altogether if someone try to increase
> > SWAP_CLUSTER_MAX which is more efficienty for batching operation, later.
> > (AFAIK, someone tried it a few years ago but rollback soon, I couldn't
> > rebemeber what was the reason at that time, anyway).
> 
> Then please drop this part. It makes the code more complex while any
> benefit is not demonstrated.

The history says the benefit.
https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=d37dd5dcb955dd8c2cdd4eaef1f15d1b7ecbc379
With the history, rather than proving it's worth for upcoming new code,
need to try to prove no harmful any longer if we want to remove(or not
consistent with other reclaim path). It's not the goal of this patch.

