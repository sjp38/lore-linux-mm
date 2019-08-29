Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4620FC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C6C2189D
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:18:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C6C2189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE6896B0003; Thu, 29 Aug 2019 12:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A96F26B0005; Thu, 29 Aug 2019 12:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985EE6B0008; Thu, 29 Aug 2019 12:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 74F226B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:18:03 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1BA54180AD801
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:18:03 +0000 (UTC)
X-FDA: 75875972046.21.ice48_4641342b7b60a
X-HE-Tag: ice48_4641342b7b60a
X-Filterd-Recvd-Size: 2468
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:18:02 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 22AACAFF9;
	Thu, 29 Aug 2019 16:18:01 +0000 (UTC)
Date: Thu, 29 Aug 2019 18:17:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190829161759.GK28313@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
 <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz>
 <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <20190829071105.GQ28313@dhcp22.suse.cz>
 <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
 <20190829115608.GD28313@dhcp22.suse.cz>
 <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 08:03:19, Edward Chron wrote:
> On Thu, Aug 29, 2019 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > Or simply provide a hook with the oom_control to be called to report
> > without replacing the whole oom killer behavior. That is not necessary.
> 
> For very simple addition, to add a line of output this works.

Why would a hook be limited to small stuff?

> It would still be nice to address the fact the existing OOM Report prints
> all of the user processes or none. It would be nice to add some control
> for that. That's what we did.

TBH, I am not really convinced partial taks list is desirable nor easy
to configure. What is the criterion? oom_score (with potentially unstable
metric)? Rss? Something else?
-- 
Michal Hocko
SUSE Labs

