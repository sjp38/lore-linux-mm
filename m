Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C080C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:25:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF63217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:25:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF63217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40B1E6B0594; Mon, 26 Aug 2019 10:25:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD176B0595; Mon, 26 Aug 2019 10:25:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ABDC6B0596; Mon, 26 Aug 2019 10:25:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id 0D44F6B0594
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:25:45 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B375C2DFA
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:25:44 +0000 (UTC)
X-FDA: 75864802608.18.bit22_4f262f1042e1c
X-HE-Tag: bit22_4f262f1042e1c
X-Filterd-Recvd-Size: 2440
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:25:43 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R681e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TaWxL0E_1566829535;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TaWxL0E_1566829535)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 26 Aug 2019 22:25:36 +0800
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Daniel Jordan <daniel.m.jordan@oracle.com>, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Michal Hocko <mhocko@kernel.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
 <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
 <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <0f8e2bc0-96b4-f55a-51da-b53dac415dd7@linux.alibaba.com>
Date: Mon, 26 Aug 2019 22:25:14 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E5=9C=A8 2019/8/22 =E4=B8=8B=E5=8D=8811:20, Daniel Jordan =E5=86=99=E9=81=
=93:
>>
>>> =C2=A0=C2=A0 https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-s=
calability.git/tree/case-lru-file-readtwice>
>>> It's also synthetic but it stresses lru_lock more than just anon allo=
c/free.=C2=A0 It hits the page activate path, which is where we see this =
lock in our database, and if enough memory is configured lru_lock also ge=
ts stressed during reclaim, similar to [1].
>>
>> Thanks for the sharing, this patchset can not help the [1] case, since=
 it's just relief the per container lock contention now.
>=20
> I should've been clearer.=C2=A0 [1] is meant as an example of someone s=
uffering from lru_lock during reclaim.=C2=A0 Wouldn't your series help pe=
r-memcg reclaim?

yes, I got your point, since the aim9 don't show much improvement, I am t=
rying this case in containers.

Thanks
Alex

