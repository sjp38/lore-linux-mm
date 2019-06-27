Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 536C8C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:02:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 203272084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 203272084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E5DC8E0013; Thu, 27 Jun 2019 10:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 995F68E0002; Thu, 27 Jun 2019 10:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AC768E0013; Thu, 27 Jun 2019 10:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB378E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:02:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so6102707edb.1
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:02:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5evardzCej1bq6zyAukWC4pdE/DbwaM7BMTGtpbMaZ8=;
        b=sVl/VFL013RqD/9L9CAExTUluTRN4eSlYgyUlFzFHMxdewl9yLl7Es/eotgx6yb3p6
         ujpygJT6375hCh7IX+MymThPg7maZWGqDQghREzegHmeqbAooe7xrfcWFoG0wKMsvx61
         GqohTZho7VPTK23XrK1VjID5cb2hYAlWcOnKlWlspdY3dDI2+6V0mKR8MaumQ7AGPjn2
         E4y3KyBW46Fu1SoDiN0DMxOaPQ7yEUVmRLQcLO7AsMsqaBNcp3iP0gOv8fWAUpUA3G6u
         uprxM6TL9eMeTlzVFLfyDJ7j3NGkXGDlCgDrg1roOWQOyawGdHgRQChOz0BiTZaTfuaQ
         Fmjg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVjsDEKXiNdabbAJxUgKh5Kr71qzZEUYDCqQrEHi9ON+SZIXJav
	SmXeFrZLg7rx/7xahkxkIR7Q1ANDopy08mUMhCXapIxh21IeiFQGrCanq/Atx3AKyO4tPamnA0W
	5nJE2bBcGtZ1GlP3eerIxXVC7uYiKBrORRj0k7saSapTF2dnUc3E67rCN5Ss0TEs=
X-Received: by 2002:a50:ac07:: with SMTP id v7mr4406849edc.205.1561644126827;
        Thu, 27 Jun 2019 07:02:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWdHsohwNvxDmAgclKXyFD+swVXoi0judNVdfk6CpYtvkGqy+utnf6lWfYPFhu5QCLKmXh
X-Received: by 2002:a50:ac07:: with SMTP id v7mr4406760edc.205.1561644126181;
        Thu, 27 Jun 2019 07:02:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561644126; cv=none;
        d=google.com; s=arc-20160816;
        b=1EHOQSf19PiU+ae5vnmrGa+xOV3bwK4TI9ipwJgZUEx2VLe/FRIs4ws/5EilJj+bnO
         RfR4uknlCiuE7QZRYqEuLbxoJbSZfyXtZ8JumJdVOhmmB8maYD0xnAGj+ghlzyyVa0S6
         DarjdH+cykoI1EmBQ/jjy6Og9XdOCuIuTkC0T8Z4pnix2U8ItsqIxOayRX6K8n9suIPk
         L5BRc2WijMu7s99GHeLc6V6ldwIA1sTYPbc/0piNQQtTR/t7y/mHuQH3Sr1tHDZ0p46K
         TaD2r662eIiinydAZuvn1+Q4iK9ZWxH5ERBgyrV3fyBww7zee3YcV8+GRV9i7iw6qPBc
         +gqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5evardzCej1bq6zyAukWC4pdE/DbwaM7BMTGtpbMaZ8=;
        b=wrZaXAdZS3aZ9EYl2V7Wd/7orq5FRLjXHJYa/NlFD49jRDuyx//egBdSLSPLAZ375m
         hdx8EyASmnehmA9HE2thwHOhGpF1oahwhgXledPCKxERXp48M2bFlCd+xt6CzkN1VWNj
         CCI1enOCXdGjnhdl1n5TegaJkZanid5Cv2yAu+eXjXifMHNKcXcKJ78biWTclpIWoP7F
         jFK4Uo4CFxP+Ri6HNzmPzBx9ggnPSblwVBhRRor2+JwIRPcukTY9d6pLad1b9v4+oYql
         1TBScy1KZbe9qfLUaFQz6+2hJu6KrSllKSfmc1bghLbSVtgbGuMvyYt24sdpRBQ44yoC
         C9tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w27si2087210edc.327.2019.06.27.07.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 07:02:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A49B6AF6A;
	Thu, 27 Jun 2019 14:02:05 +0000 (UTC)
Date: Thu, 27 Jun 2019 16:02:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
Message-ID: <20190627140203.GB5303@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 06:13:36, Dave Hansen wrote:
> On 6/27/19 4:54 AM, Minchan Kim wrote:
> > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > MADV_COLD can be used by a process to mark a memory range as not expected
> > to be used in the near future. The hint can help kernel in deciding which
> > pages to evict early during memory pressure.
> > 
> > It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> > 
> > 	active file page -> inactive file LRU
> > 	active anon page -> inacdtive anon LRU
> 
> Is the LRU behavior part of the interface or the implementation?
> 
> I ask because we've got something in between tossing something down the
> LRU and swapping it: page migration.  Specifically, on a system with
> slower memory media (like persistent memory) we just migrate a page
> instead of discarding it at reclaim:

But we already do have interfaces for migrating the memory
(move_pages(2)). Why should this interface duplicate that interface?
I believe the only purpose of these two new madvise modes is to provide
a non-destructive MADV_{DONTNEED,FREE} alteternatives. In other words,
pageout vs. age interface.
-- 
Michal Hocko
SUSE Labs

