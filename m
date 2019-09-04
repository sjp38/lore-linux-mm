Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C10DC3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:41:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE7D4206BB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gj8iVwZF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE7D4206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47C7C6B0003; Wed,  4 Sep 2019 03:41:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42DC96B0006; Wed,  4 Sep 2019 03:41:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31BE06B0007; Wed,  4 Sep 2019 03:41:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id 1171F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:41:34 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A233E1EF2
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:41:33 +0000 (UTC)
X-FDA: 75896443266.29.man77_81f20ccc7313a
X-HE-Tag: man77_81f20ccc7313a
X-Filterd-Recvd-Size: 6404
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:41:32 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x847f9YS006378;
	Wed, 4 Sep 2019 07:41:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=vgqudwBhTYcriUc2Nr50gBMH3ycZ91ED9w6IsPqWTok=;
 b=gj8iVwZFHf8hroh2VAbJ8sxbut6Ke7MMws83Ri71EGgmlVSdWrSMEBk/Rk/PhURTnRuh
 n1XMLt1F30Z4SXIGzdeGq0BR1MkcgWOgpbL2ncV8HOP1KBtIioXOH+DJVzgOe0SGs2TX
 zk8iBnRVIfS4ockokhjEA6CxASbkmhz2PQ8qZrK5rebTmQz+grefPxDCsm6PjWdx3sSG
 9Yal34wXaoeQo+0KYnjtpu/lpeHuwofjzu0NlZZ9yqUz0sj8n+6K3N2UPMNpUeJpLAKx
 Zf7Zzl/1U3IGxL688cBv8NnRl6kHKRH1piaPieQPIgMEqKsxym17cs0PeriQvd0bI9QE Ww== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2ut93hg035-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 04 Sep 2019 07:41:28 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x847XHHx034497;
	Wed, 4 Sep 2019 07:39:07 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2usu52k66p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 04 Sep 2019 07:39:06 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x847d4OU030246;
	Wed, 4 Sep 2019 07:39:04 GMT
Received: from [10.182.69.197] (/10.182.69.197)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 04 Sep 2019 00:39:04 -0700
Subject: Re: [PATCH] mm/vmscan: get number of pages on the LRU list in
 memcgroup base on lru_zone_size
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org
References: <20190903085416.12059-1-honglei.wang@oracle.com>
 <20190903092827.GP14028@dhcp22.suse.cz>
From: Honglei Wang <honglei.wang@oracle.com>
Message-ID: <1c7b1982-3aee-5a99-e10b-b46d05a5f7f0@oracle.com>
Date: Wed, 4 Sep 2019 15:38:59 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903092827.GP14028@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909040079
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909040079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/3/19 5:28 PM, Michal Hocko wrote:
> On Tue 03-09-19 16:54:16, Honglei Wang wrote:
>> lruvec_lru_size() is involving lruvec_page_state_local() to get the
>> lru_size in the current code. It's base on lruvec_stat_local.count[]
>> of mem_cgroup_per_node. This counter is updated in batch. It won't
>> do charge if the number of coming pages doesn't meet the needs of
>> MEMCG_CHARGE_BATCH who's defined as 32 now.
>>
>> This causes small section of memory can't be handled as expected in
>> some scenario. For example, if we have only 32 pages madvise free
>> memory in memcgroup, these pages won't be freed as expected when it
>> meets memory pressure in this group.
> 
> Could you be more specific please?

Okay, will add more detailed description at next version.

> 
>> Getting lru_size base on lru_zone_size of mem_cgroup_per_node which
>> is not updated in batch can make this a bit more accurate.
> 
> This is effectivelly reverting 1a61ab8038e72. There were no numbers
> backing that commit, neither this one has. The only hot path I can see
> is workingset_refault. All others seems to be in the reclaim path.

Yep, I saw the lruvec increasing is not in batch way in 
workingset_refault path, so thought maybe change the way in 
lruvec_lru_size() to no-batch might match the act more.

It seems to me less than 32 pages deviations for seq_show stuff is not a 
big deal (maybe it's not a big deal in lruvec_lru_size() as well...), so 
I choose just modify lruvec_lru_size(), but not revert 1a61ab8038e72.

>   
>> Signed-off-by: Honglei Wang <honglei.wang@oracle.com>
> 
> That being said, I am not against this patch but the changelog should be
> more specific about the particular problem and how serious it is.

Thanks for the suggestions. I don't think this is a really serious one, 
and I'll try to give a more detailed changelog about what it's trying to 
fix.

Honglei

> 
>> ---
>>   mm/vmscan.c | 9 +++++----
>>   1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c77d1e3761a7..c28672460868 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -354,12 +354,13 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
>>    */
>>   unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
>>   {
>> -	unsigned long lru_size;
>> +	unsigned long lru_size = 0;
>>   	int zid;
>>   
>> -	if (!mem_cgroup_disabled())
>> -		lru_size = lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
>> -	else
>> +	if (!mem_cgroup_disabled()) {
>> +		for (zid = 0; zid < MAX_NR_ZONES; zid++)
>> +			lru_size += mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
>> +	} else
>>   		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
>>   
>>   	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
>> -- 
>> 2.17.0
> 

