Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 216E8C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7DE62082F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:00:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HwUtvYoI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7DE62082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BE986B0332; Wed, 21 Aug 2019 14:00:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56FD26B0333; Wed, 21 Aug 2019 14:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DD76B0334; Wed, 21 Aug 2019 14:00:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAC56B0332
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:00:41 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BEBA883E6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:00:40 +0000 (UTC)
X-FDA: 75847200240.16.flame53_400c9a007ad36
X-HE-Tag: flame53_400c9a007ad36
X-Filterd-Recvd-Size: 7830
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:00:39 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7LHsXJu086567;
	Wed, 21 Aug 2019 18:00:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=tmRGzebsdlR9sHASmyyyKPRbTYCSfFlnVG/zj++02Y4=;
 b=HwUtvYoInfaOTd1lpkEF2lXCkMMdX8CCXLFKikiq1tJTeuhrZIHbtyZt8T8CDAj/kJ49
 VnjSul33YJvV5jf+Uj9PtxaV5/CcI73/kU9ElXuNugL621Rk0AiI1I2oL79Mvf+xi36n
 76vZRSktp24TmNIuHTXekZuGyRu1NjL3pw0YsEbJpb/vUWHsKQa9qEjZmm9AYUV4RSd2
 B/EJ0530GJxR6tkZmHGGcESAaXpcopGjSgNDdU8f26Xc2dkZ+WaruJgFG4B6bTZtEq7j
 s9K8k8QULrqN1tnEiUSa4SGco7jrEgYaenk4MeWWYscV6wZZTdubbQBpR3Nu+vQofrnT VQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2ue90tqk0m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 21 Aug 2019 18:00:37 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7LHwho4092514;
	Wed, 21 Aug 2019 18:00:37 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2uh2q4twq2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 21 Aug 2019 18:00:36 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7LI0WiV009735;
	Wed, 21 Aug 2019 18:00:32 GMT
Received: from [192.168.1.218] (/98.229.125.203)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 21 Aug 2019 11:00:32 -0700
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Alex Shi <alex.shi@linux.alibaba.com>, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
        Michal Hocko <mhocko@kernel.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <6ba1ffb0-fce0-c590-c373-7cbc516dbebd@oracle.com>
Date: Wed, 21 Aug 2019 14:00:31 -0400
MIME-Version: 1.0
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9355 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908210179
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9355 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908210179
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alex,

On 8/20/19 5:48 AM, Alex Shi wrote:
> In some data center, containers are used widely to deploy different kind
> of services, then multiple memcgs share per node pgdat->lru_lock which
> cause heavy lock contentions when doing lru operation.
> 
> On my 2 socket * 6 cores E5-2630 platform, 24 containers run aim9
> simultaneously with mmtests' config:
>          # AIM9
>          export AIM9_TESTTIME=180
>          export AIM9_TESTLIST=page_test,brk_test
> 
> perf lock report show much contentions on lru_lock in 20 second snapshot:
>                          Name   acquired  contended   avg wait (ns) total wait (ns)   max wait (ns)   min wait (ns)
>          &(ptlock_ptr(pag...         22          0               0       0               0               0
>          ...
>          &(&pgdat->lru_lo...          9          7           12728       89096           26656            1597

This is system-wide right, not per container?  Even per container, 89 usec isn't much contention over 20 seconds.  You may want to give this a try:

   https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-scalability.git/tree/case-lru-file-readtwice

It's also synthetic but it stresses lru_lock more than just anon alloc/free.  It hits the page activate path, which is where we see this lock in our database, and if enough memory is configured lru_lock also gets stressed during reclaim, similar to [1].

It'd be better though, as Michal suggests, to use the real workload that's causing problems.  Where are you seeing contention?

> With this patch series, lruvec->lru_lock show no contentions
>          &(&lruvec->lru_l...          8          0               0       0               0               0
> 
> and aim9 page_test/brk_test performance increased 5%~50%.

Where does the 50% number come in?  The numbers below seem to only show ~4% boost.

> BTW, Detailed results in aim9-pft.compare.log if needed,
> All containers data are increased and pretty steady.
> 
> $for i in Max Min Hmean Stddev CoeffVar BHmean-50 BHmean-95 BHmean-99; do echo "========= $i page_test ============"; cat aim9-pft.compare.log | grep "^$i.*page_test" | awk 'BEGIN {a=b=0;}  { a+=$3; b+=$6 } END { print "5.3-rc4          " a/24; print "5.3-rc4+lru_lock " b/24}' ; done
> ========= Max page_test ============
> 5.3-rc4          34729.6
> 5.3-rc4+lru_lock 36128.3
> ========= Min page_test ============
> 5.3-rc4          33644.2
> 5.3-rc4+lru_lock 35349.7
> ========= Hmean page_test ============
> 5.3-rc4          34355.4
> 5.3-rc4+lru_lock 35810.9
> ========= Stddev page_test ============
> 5.3-rc4          319.757
> 5.3-rc4+lru_lock 223.324
> ========= CoeffVar page_test ============
> 5.3-rc4          0.93125
> 5.3-rc4+lru_lock 0.623333
> ========= BHmean-50 page_test ============
> 5.3-rc4          34579.2
> 5.3-rc4+lru_lock 35977.1
> ========= BHmean-95 page_test ============
> 5.3-rc4          34421.7
> 5.3-rc4+lru_lock 35853.6
> ========= BHmean-99 page_test ============
> 5.3-rc4          34421.7
> 5.3-rc4+lru_lock 35853.6
> 
> $for i in Max Min Hmean Stddev CoeffVar BHmean-50 BHmean-95 BHmean-99; do echo "========= $i brk_test ============"; cat aim9-pft.compare.log | grep "^$i.*brk_test" | awk 'BEGIN {a=b=0;}  { a+=$3; b+=$6 } END { print "5.3-rc4          " a/24; print "5.3-rc4+lru_lock " b/24}' ; done
> ========= Max brk_test ============
> 5.3-rc4          96647.7
> 5.3-rc4+lru_lock 98960.3
> ========= Min brk_test ============
> 5.3-rc4          91800.8
> 5.3-rc4+lru_lock 96817.6
> ========= Hmean brk_test ============
> 5.3-rc4          95470
> 5.3-rc4+lru_lock 97769.6
> ========= Stddev brk_test ============
> 5.3-rc4          1253.52
> 5.3-rc4+lru_lock 596.593
> ========= CoeffVar brk_test ============
> 5.3-rc4          1.31375
> 5.3-rc4+lru_lock 0.609583
> ========= BHmean-50 brk_test ============
> 5.3-rc4          96141.4
> 5.3-rc4+lru_lock 98194
> ========= BHmean-95 brk_test ============
> 5.3-rc4          95818.5
> 5.3-rc4+lru_lock 97857.2
> ========= BHmean-99 brk_test ============
> 5.3-rc4          95818.5
> 5.3-rc4+lru_lock 97857.2

[1] https://lore.kernel.org/linux-mm/CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com/

