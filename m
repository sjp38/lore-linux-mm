Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12FB8C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 13:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73AB92146E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 13:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73AB92146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B31E26B04E2; Sat, 24 Aug 2019 09:05:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE35A6B04E3; Sat, 24 Aug 2019 09:05:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F9526B04E4; Sat, 24 Aug 2019 09:05:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0077.hostedemail.com [216.40.44.77])
	by kanga.kvack.org (Postfix) with ESMTP id 7E94F6B04E2
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 09:05:35 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 26A6F180AD7C3
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 13:05:35 +0000 (UTC)
X-FDA: 75857343030.22.noise42_87de97a472638
X-HE-Tag: noise42_87de97a472638
X-Filterd-Recvd-Size: 2717
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn [202.108.3.167])
	by imf21.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 13:05:33 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([124.64.0.77])
	by sina.com with ESMTP
	id 5D6136180001A058; Sat, 24 Aug 2019 21:05:30 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 904413753887
From: Hillf Danton <hdanton@sina.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Adric Blake <promarbler14@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Linux MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup andfullmemory usage
Date: Sat, 24 Aug 2019 21:05:16 +0800
Message-Id: <20190824130516.2540-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: WARNINGs in set_task_reclaim_state with memory cgroup andfullmemory usage
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 24 Aug 2019 16:15:38 +0800 Yafang Shao wrote:
>=20
> The memcg soft reclaim is called from kswapd reclam path and direct
> reclaim path,
> so why not pass the scan_control from the callsite in these two
> reclaim paths and use it in memcg soft reclaim ?
> Seems there's no specially reason that we must introduce a new
> scan_control here.
>=20
To protect memcg from being over reclaimed?
Victim memcg is selected one after another in a fair way, and punished
by reclaiming one memcg a round no more than nr_to_reclaim =3D=3D
SWAP_CLUSTER_MAX pages. And so is the flip-flop from global to memcg
reclaiming. We can see similar protection activities in
commit a394cb8ee632 ("memcg,vmscan: do not break out targeted reclaim
without reclaimed pages") and
commit 2bb0f34fe3c1 ("mm: vmscan: do not iterate all mem cgroups for
global direct reclaim").

No preference seems in either way except for retaining
nr_to_reclaim =3D=3D SWAP_CLUSTER_MAX and target_mem_cgroup =3D=3D memcg.
>=20
> I have checked the hisotry why this order check is introduced here.
> The first commit is 4e41695356fb ("memory controller: soft limit
> reclaim on contention"),
> but it didn't explained why.
> At the first glance it is reasonable to remove it, but we should
> understand why it was introduced at the first place.

Reclaiming order can not make much sense in soft-limit reclaiming
under the current protection.

Thanks to Adric Blake again.

Hillf


