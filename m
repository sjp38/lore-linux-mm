Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C46C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 11:57:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2F98233FD
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 11:57:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2F98233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2FFF6B0309; Thu, 22 Aug 2019 07:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1656B030A; Thu, 22 Aug 2019 07:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1EA56B030B; Thu, 22 Aug 2019 07:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id B1D006B0309
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:57:10 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4EA11181AC9AE
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:57:10 +0000 (UTC)
X-FDA: 75849913020.09.robin35_3d24aa0fba1f
X-HE-Tag: robin35_3d24aa0fba1f
X-Filterd-Recvd-Size: 3604
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:57:05 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0Ta8EzwU_1566475019;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta8EzwU_1566475019)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 22 Aug 2019 19:56:59 +0800
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Daniel Jordan <daniel.m.jordan@oracle.com>, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Michal Hocko <mhocko@kernel.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
Date: Thu, 22 Aug 2019 19:56:59 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E5=9C=A8 2019/8/22 =E4=B8=8A=E5=8D=882:00, Daniel Jordan =E5=86=99=E9=81=
=93:
>>
>=20
> This is system-wide right, not per container?=C2=A0 Even per container,=
 89 usec isn't much contention over 20 seconds.=C2=A0 You may want to giv=
e this a try:

yes, perf lock show the host info.
>=20
> =C2=A0 https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-scalabili=
ty.git/tree/case-lru-file-readtwice>=20
> It's also synthetic but it stresses lru_lock more than just anon alloc/=
free.=C2=A0 It hits the page activate path, which is where we see this lo=
ck in our database, and if enough memory is configured lru_lock also gets=
 stressed during reclaim, similar to [1].

Thanks for the sharing, this patchset can not help the [1] case, since it=
's just relief the per container lock contention now. Yes, readtwice case=
 could be more sensitive for this lru_lock changes in containers. I may t=
ry to use it in container with some tuning. But anyway, aim9 is also pret=
ty good to show the problem and solutions. :)
>=20
> It'd be better though, as Michal suggests, to use the real workload tha=
t's causing problems.=C2=A0 Where are you seeing contention?

We repeatly create or delete a lot of different containers according to s=
ervers load/usage, so normal workload could cause lots of pages alloc/rem=
ove. aim9 could reflect part of scenarios. I don't know the DB scenario y=
et.

>=20
>> With this patch series, lruvec->lru_lock show no contentions
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &(&lruvec->lru_l...=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
>>
>> and aim9 page_test/brk_test performance increased 5%~50%.
>=20
> Where does the 50% number come in?=C2=A0 The numbers below seem to only=
 show ~4% boost.

the Setddev/CoeffVar case has about 50% performance increase. one of cont=
ainer's mmtests result as following:

Stddev    page_test      245.15 (   0.00%)      189.29 (  22.79%)
Stddev    brk_test      1258.60 (   0.00%)      629.16 (  50.01%)
CoeffVar  page_test        0.71 (   0.00%)        0.53 (  26.05%)
CoeffVar  brk_test         1.32 (   0.00%)        0.64 (  51.14%)


