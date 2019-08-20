Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6FD1C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:17:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7313422DA9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:17:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7313422DA9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE3446B0005; Tue, 20 Aug 2019 10:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E94186B0006; Tue, 20 Aug 2019 10:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAAE16B000C; Tue, 20 Aug 2019 10:17:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id B98D96B0005
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:17:02 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6B17E4859
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:17:02 +0000 (UTC)
X-FDA: 75843007884.19.event66_5a6a9f4c1132e
X-HE-Tag: event66_5a6a9f4c1132e
X-Filterd-Recvd-Size: 3335
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com [115.124.30.42])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:17:00 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=39;SR=0;TI=SMTPD_---0Ta-t.lc_1566310288;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta-t.lc_1566310288)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 22:11:31 +0800
Subject: Re: [PATCH 01/14] mm/lru: move pgdat lru_lock into lruvec
To: Matthew Wilcox <willy@infradead.org>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
 Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>,
 Wei Yang <richard.weiyang@gmail.com>,
 Pavel Tatashin <pasha.tatashin@oracle.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 David Rientjes <rientjes@google.com>, Souptick Joarder
 <jrdr.linux@gmail.com>, swkhack <swkhack@gmail.com>,
 "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Colin Ian King <colin.king@canonical.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
 Peng Fan <peng.fan@nxp.com>, Ira Weiny <ira.weiny@intel.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Daniel Jordan <daniel.m.jordan@oracle.com>,
 Yafang Shao <laoar.shao@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-2-git-send-email-alex.shi@linux.alibaba.com>
 <20190820134032.GA24642@bombadil.infradead.org>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <9980292a-a073-201c-ae06-c8cdbc9f98af@linux.alibaba.com>
Date: Tue, 20 Aug 2019 22:11:28 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190820134032.GA24642@bombadil.infradead.org>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=D4=DA 2019/8/20 =CF=C2=CE=E79:40, Matthew Wilcox =D0=B4=B5=C0:
> On Tue, Aug 20, 2019 at 05:48:24PM +0800, Alex Shi wrote:
>> +++ b/include/linux/mmzone.h
>> @@ -295,6 +295,9 @@ struct zone_reclaim_stat {
>> =20
>>  struct lruvec {
>>  	struct list_head		lists[NR_LRU_LISTS];
>> +	/* move lru_lock to per lruvec for memcg */
>> +	spinlock_t			lru_lock;
>=20
> This comment makes no sense outside the context of this patch.
>=20

Right, Thanks for point out this. will remove it in v2.

Thanks
Alex

