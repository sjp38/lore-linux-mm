Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 094EDC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD34D20679
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD34D20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4166B058D; Mon, 26 Aug 2019 10:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87D646B058F; Mon, 26 Aug 2019 10:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76BB56B0590; Mon, 26 Aug 2019 10:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 579026B058D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:17:33 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EE8F8180AD7C3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:17:32 +0000 (UTC)
X-FDA: 75864781944.17.lift23_78c532b3273e
X-HE-Tag: lift23_78c532b3273e
X-Filterd-Recvd-Size: 2197
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com [115.124.30.133])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:17:31 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TaX0VPG_1566829040;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TaX0VPG_1566829040)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 26 Aug 2019 22:17:23 +0800
Subject: Re: [PATCH 03/14] lru/memcg: using per lruvec lock in
 un/lock_page_lru
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Hugh Dickins <hughd@google.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-4-git-send-email-alex.shi@linux.alibaba.com>
 <936eb865-d8da-8e53-3e2b-6858c586aa49@yandex-team.ru>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <bd44a613-d820-6085-0145-657078fd79cc@linux.alibaba.com>
Date: Mon, 26 Aug 2019 22:16:58 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <936eb865-d8da-8e53-3e2b-6858c586aa49@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E5=9C=A8 2019/8/26 =E4=B8=8B=E5=8D=884:30, Konstantin Khlebnikov =E5=86=99=
=E9=81=93:
>>
>> =C2=A0=20
>=20
> What protects lruvec from freeing at this point?
> After reading resolving lruvec page could be moved and cgroup deleted.
>=20
> In this old patches I've used RCU for that: https://lkml.org/lkml/2012/=
2/20/276
> Pointer to lruvec should be resolved under disabled irq.
> Not sure this works these days.

Thanks for reminder! I will reconsider this point and come up with change=
s.

Thanks
Alex

