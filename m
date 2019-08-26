Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 438C0C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E4592173E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:23:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E4592173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A02636B0592; Mon, 26 Aug 2019 10:23:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DAA56B0593; Mon, 26 Aug 2019 10:23:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C9826B0594; Mon, 26 Aug 2019 10:23:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF626B0592
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:23:13 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1FCFD52B3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:23:13 +0000 (UTC)
X-FDA: 75864796266.13.farm44_3916744491a29
X-HE-Tag: farm44_3916744491a29
X-Filterd-Recvd-Size: 2102
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com [115.124.30.133])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:23:11 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TaX2Psc_1566829386;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TaX2Psc_1566829386)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 26 Aug 2019 22:23:07 +0800
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 Daniel Jordan <daniel.m.jordan@oracle.com>, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
 <348495d2-b558-fdfd-a411-89c75d4a9c78@linux.alibaba.com>
 <b776032e-eabb-64ff-8aee-acc2b3711717@oracle.com>
 <d5256ebf-8314-8c24-a7ed-e170b7d39b61@yandex-team.ru>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <1e2de503-9f53-9c51-f20c-f11a4b9625ed@linux.alibaba.com>
Date: Mon, 26 Aug 2019 22:22:46 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d5256ebf-8314-8c24-a7ed-e170b7d39b61@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E5=9C=A8 2019/8/26 =E4=B8=8B=E5=8D=884:39, Konstantin Khlebnikov =E5=86=99=
=E9=81=93:
>>>
> because they mixes pages from different cgroups.
>=20
> pagevec_lru_move_fn and friends need better implementation:
> either sorting pages or splitting vectores in per-lruvec basis.

Right, this should be the next step to improve. Maybe we could try the pe=
r-lruvec pagevec?

Thanks
Alex

