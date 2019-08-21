Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2DE2C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 02:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9839522DD6
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 02:00:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9839522DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46E126B027F; Tue, 20 Aug 2019 22:00:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 420136B0280; Tue, 20 Aug 2019 22:00:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30ED56B0281; Tue, 20 Aug 2019 22:00:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0017.hostedemail.com [216.40.44.17])
	by kanga.kvack.org (Postfix) with ESMTP id 0E05E6B027F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 22:00:40 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 958E7A2CA
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:00:39 +0000 (UTC)
X-FDA: 75844780998.22.meal86_7a03b6f71bf3e
X-HE-Tag: meal86_7a03b6f71bf3e
X-Filterd-Recvd-Size: 2319
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:00:38 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0Ta0UEVw_1566352833;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta0UEVw_1566352833)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 21 Aug 2019 10:00:33 +0800
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Shakeel Butt <shakeelb@google.com>, Yu Zhao <yuzhao@google.com>,
 Daniel Jordan <daniel.m.jordan@oracle.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <20190820104532.GP3111@dhcp22.suse.cz>
 <CALvZod7-dL90jwd2pywpaD8NfUByVU9Y809+RfvJABGdRASYUg@mail.gmail.com>
 <alpine.LSU.2.11.1908201038260.1286@eggly.anvils>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <e9ac9c8c-15c1-8365-5c39-285c6d7b07a6@linux.alibaba.com>
Date: Wed, 21 Aug 2019 10:00:33 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1908201038260.1286@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E5=9C=A8 2019/8/21 =E4=B8=8A=E5=8D=882:24, Hugh Dickins =E5=86=99=E9=81=93=
:
> I'll set aside what I'm doing, and switch to rebasing ours to v5.3-rc
> and/or mmotm.  Then compare with what Alex has, to see if there's any
> good reason to prefer one to the other: if no good reason to prefer our=
s,
> I doubt we shall bother to repost, but just use it as basis for helping
> to review or improve Alex's.

For your review, my patchset are pretty straight and simple. It just use =
per lruvec lru_lock to replace necessary pgdat lru_lock. just this.=20
We could talk more after I back to work. :)

Thanks alot!
Alex

