Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47DF7C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:41:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D84820B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D84820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 697B66B0273; Tue, 28 May 2019 06:41:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 622BC6B0274; Tue, 28 May 2019 06:41:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E8826B0275; Tue, 28 May 2019 06:41:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 023286B0273
	for <linux-mm@kvack.org>; Tue, 28 May 2019 06:41:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so1452885ede.0
        for <linux-mm@kvack.org>; Tue, 28 May 2019 03:41:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gksd89347YQP8h40owAO8ZPk7NT56rVFZiRRVryAoXI=;
        b=ZCaelAKjXDMAfgj+ryZX3sMcOI5mG2+c/UkyV+HHZk+bpmPfbGfwkSIC5q0O3TxDPh
         OrBFhfUlaghYFZINlgAv2twAgPxIPkHp7vaFKUIHFFLTGdj9xg0V32M4hWQl36fTgnH5
         McX4m/l3FZ0zIylCaL/QdDrPBgBbiAjKLT/Qe/uMdwe19R6lh6zymeFPUUGZodzW3dtb
         3KUUUFeKLr1JmVgq7ev07oLLhDduTPLSw58Tzye/P/Ykd1iDrSUV6GxyB2SLJ8fGQAXP
         JhbNtkGO/MgZh338UnVaJmgg+9Hf8Z+MhkYH9O3wc5JD9wBK4/aI9xvm1VGsx6OzMPkL
         e4jQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWniWlg9gxWba/O2dEOClLAKYZVBNu7UReyywejOEAw3gHQ1hEz
	2CFW0Tti95yrmZwBRqyF+wPmQnDBTtvR4E1SXydA4kls3hhky5QmfxkFFnSdacV71EXigtmEWVw
	9wp7ZXhYmkouwII17EhrlLDcCHg+rrkRl42B6Zm2F9fjM58KglwZKOHZ8gKPFUJ4=
X-Received: by 2002:a17:907:10d0:: with SMTP id rv16mr63546249ejb.138.1559040080578;
        Tue, 28 May 2019 03:41:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3b9WyrdkzxTgAtRlk0sdeduNPP0jRoTIr4mvyeHkdEgE8FTdTjog6XvkJM0GaYC/BSL9i
X-Received: by 2002:a17:907:10d0:: with SMTP id rv16mr63546158ejb.138.1559040079445;
        Tue, 28 May 2019 03:41:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559040079; cv=none;
        d=google.com; s=arc-20160816;
        b=K2iSGy90J4gbW2jZJ/StJh0UZXwbxvWM1VBxdLHlSnyuDV4Zxa+iGhb27MOXFwtdaP
         rFSFkHwy7LHosUitkI9uY29yHDvfc7WvgUgPaM1e6YauO8HsdfqcEdJGDuc1lBNaPyb3
         EkevfHTwMh+lvXXPjn1leuXZ8oTpgsEUgCMO5+8bzWCpBqxnx6tL4eY2OWCGfhVVbcLl
         4z8CX/G/Tj2TVOaHToOICRYWlLFRkxKKA94DQmcoUGMRnnMHwGN4sGyTyvbYGtrRzzWT
         qOmUjmwJOPUBg3twt0WZQS0cFrKZkbHrjt6mAlSJzw+17YJGSSkVuvUJxN8Y9/JieSzt
         RIrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gksd89347YQP8h40owAO8ZPk7NT56rVFZiRRVryAoXI=;
        b=tgEZCM0xlFXlkVMvQYLrqwbwKn4v8JJ97YVVI0SmvNB6+31cx2gIi5lV3XEdPlyZ7+
         QwsTQAj6aDvmisdPRFcSOSR4TQY53P0ZLpkmGXA7+5Id7rGudVBunidwddP0T6qmiDu5
         N9YVod7YOY9J/TWPL3INU/6Vt8poK5HbUTyL11wjif+bg2yg+jmSjWGx8PmlXM71co5J
         d/mn2THCdDjNX/sqWFsldpRbCpLaqlyRifFd/IwCkUeh+HaGPkBzPvAMo4DmwwsLnX9v
         W0R+v1rWKBKcIfvVlNfaFRALQ9yWgPGsoS5ooy14H/Eg3mlf9aIkwG/u1RKgiJnkPu2v
         2VwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z16si10539540edb.381.2019.05.28.03.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 03:41:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7A0CAEC8;
	Tue, 28 May 2019 10:41:18 +0000 (UTC)
Date: Tue, 28 May 2019 12:41:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528104117.GW1658@dhcp22.suse.cz>
References: <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528103256.GA9199@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > if we went with the per vma fd approach then you would get this
> > > > > > feature automatically because map_files would refer to file backed
> > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > >
> > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > so map_anon wouldn't be helpful.
> > > > 
> > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > to suggest that providing an efficient binary interfaces for pulling
> > > > memory map information out of processes.  Some single-system-call
> > > > method for retrieving a binary snapshot of a process's address space
> > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > reduce complexity and increase performance in a variety of areas,
> > > > e.g., Android memory map debugging commands.
> > > 
> > > I agree it's the best we can get *generally*.
> > > Michal, any opinion?
> > 
> > I am not really sure this is directly related. I think the primary
> > question that we have to sort out first is whether we want to have
> > the remote madvise call process or vma fd based. This is an important
> > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > so far unfortunately.
> 
> With current usecase, it's per-process API with distinguishable anon/file
> but thought it could be easily extended later for each address range
> operation as userspace getting smarter with more information.

Never design user API based on a single usecase, please. The "easily
extended" part is by far not clear to me TBH. As I've already mentioned
several times, the synchronization model has to be thought through
carefuly before a remote process address range operation can be
implemented.

-- 
Michal Hocko
SUSE Labs

