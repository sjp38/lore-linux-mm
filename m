Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 990BEC742D7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 01:11:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AF7C208E4
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 01:11:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PLGES2Yt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AF7C208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 820858E0170; Fri, 12 Jul 2019 21:11:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1C38E0003; Fri, 12 Jul 2019 21:11:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C13C8E0170; Fri, 12 Jul 2019 21:11:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 511E98E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 21:11:41 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u84so12733275iod.1
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 18:11:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jUTho8nKW5hjHRWxClJOHdo4lCalGSvqrppSqDi2e5U=;
        b=TdG5/RCtLEeSKo98hd4vqHIEYIgHtPpZT8GEnGEQD+XFPTDkkoAhbo3zoe5TDyUWti
         kuLIvzmlcSF1C1zb0jj5siS6VPgbC4dOJU+dfXi40kHRR9mJb5BUwsg8OsgoTfcOP8aY
         /OHQ+iICs52RObqILY4o1dHrBUVa9Lkx6CZBLKVjfkvskqoKROHnQUg9UzC4MVgYse9v
         VOJ1dTgEFRYFQdqlvJhtlY8REgDq6Qkj8yXJhJEVhk8MjW5+tF9gdfVA30FTiIKxq+aV
         VXAIuwzXChBjPvDsV6BhQiaWkqYbNdy97RBkfGlxOjCJkACvHXbJxK8weocBHlIRLqqh
         h41A==
X-Gm-Message-State: APjAAAWEsvbN/IulHZEzanxSozM74VL5tZRF+0jO4M/B8OcyopUMfBrb
	1X50Cr3CNoA1KSyFXyhJDrxyEAfok8v0F26O24AQaJkwYeJ1SNVXChHpdqtuFrgcy+/wceeIyxr
	3g8nM5z0geCWeVr0FO7tQ6+O3oFRmvvd8BMFbtRMrNqdowoEaVBVVSE5k/zksyClEng==
X-Received: by 2002:a02:b395:: with SMTP id p21mr15000146jan.31.1562980300989;
        Fri, 12 Jul 2019 18:11:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOqZ8XpIM+P/vTIF55lNNdFp1YtmgeoE9WxSAZpX97ICMsTDHSdyutHZrYTf+kRKwO+YEQ
X-Received: by 2002:a02:b395:: with SMTP id p21mr15000111jan.31.1562980300122;
        Fri, 12 Jul 2019 18:11:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562980300; cv=none;
        d=google.com; s=arc-20160816;
        b=E1JzAhgtF8D5uSoYVAolijptPDzagEn62pS1MBjQh86KWOvMI4dXl+lgaPqeU2imql
         xKwJ4ODeB0ENyt24JFhfXx4Hec3T+BtEveCimRfGL38qx/HzCuXKGBciKXVBdTMV8lQG
         9cSRbKBwA0A+95MpUBIg7IwpeSvBF9L8gT2g5wY/u2on4HHfR1AdcsLa6ve9uCHVVrgg
         VNWqBc9Ffrmvv5ZMfaX59QY6WmKIYfDN9uNFuyZKx29tN/Fc6FUXR/9PHI6IYdxkfBi6
         50IasLE7DsBF+e/qM+ayJCAjmmQpXy6fG60LywX8sFTwkJKP27rkHIjkGPulVUHLiC59
         QURg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=jUTho8nKW5hjHRWxClJOHdo4lCalGSvqrppSqDi2e5U=;
        b=lgHtpMWNIlsU9F2uP9pPEIAJVzl/QAUD2lNIrLbLQbBjSHh6NkkuzHDiPBV56o3Bg0
         gHt6fFgOkdf7RwRq6QAnuELyfxhhHcoxFAI38/oAkMPoKxZ6EEPnLdC6XGB8j4viwsYC
         0NWBJmfbDxVmJIJqyNfxD4Qq45rwQGgIjRoLa5bbLjQ/r+gVnKabHVX2go3flrXHjSsG
         i6T3d3On1ah44SSfF9XfGHEOTb8VgInC3dWmMXyBRrVfDx5UP7zlnkFJda4nN3AytKi5
         I9CsBCy8U4DzqWiEkE9gYQV6YFjOXPG9R1i81TedtvKbH6exLwj+6o3Vea/J8NTGi16D
         EDFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PLGES2Yt;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u1si13907185iom.155.2019.07.12.18.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 18:11:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PLGES2Yt;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6D0sfpc178083;
	Sat, 13 Jul 2019 01:11:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=jUTho8nKW5hjHRWxClJOHdo4lCalGSvqrppSqDi2e5U=;
 b=PLGES2Ytpe4W9BYJworC8/e6RLJhW9Y5+9Q84yHoqn10S/+dE9MrFf0Ozd+EI0g+qgwC
 qno4eLFWqNf3h4lT23a3YFdmNObgU5rz/Cn2p1mTgGDJyoOTs2iQT9PUXmFmXk+HcfAK
 V2LKG297dptF4PzytZdGwItMYsqyDThxvhmEkgYEH2nPittyADiKNtYTjYRK1etvtE3O
 V9nM+tkWyHJW47ZzqMPJuIpdIppSFOjNl8eRooKwaDVLkCsMvyEzH86JYvKGGc4mJGNI
 FwAc2H9Y5DfDJKv75flo7uBhHMn9s3sl3Dv7PaajqZbkD2FafIBDsnG/pv4JO9p/jDa5 OA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2tjk2u855c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 13 Jul 2019 01:11:35 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6D16BUx181034;
	Sat, 13 Jul 2019 01:11:35 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2tq5bb01pg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 13 Jul 2019 01:11:34 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6D1BVaG001148;
	Sat, 13 Jul 2019 01:11:32 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 18:11:31 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Hillf Danton <hdanton@sina.com>, Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>
References: <20190712054732.7264-1-hdanton@sina.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c39e7cb3-204c-c4e3-fb43-7a37d91c0ccb@oracle.com>
Date: Fri, 12 Jul 2019 18:11:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190712054732.7264-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907130007
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907130007
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/11/19 10:47 PM, Hillf Danton wrote:
> 
> On Thu, 11 Jul 2019 02:42:56 +0800 Mike Kravetz wrote:
>>
>> It is quite easy to hit the condition where:
>> nr_reclaimed == 0  && nr_scanned == 0 is true, but we skip the previous test
>>
> Then skipping check of __GFP_RETRY_MAYFAIL makes no sense in your case.
> It is restored in respin below.
> 
>> and the compaction check:
>> sc->nr_reclaimed < pages_for_compaction &&
>> 	inactive_lru_pages > pages_for_compaction
>> is true, so we return true before the below check of costly_fg_reclaim
>>
> This check is placed after COMPACT_SUCCESS; the latter is used to
> replace sc->nr_reclaimed < pages_for_compaction.
> 
> And dryrun detection is added based on the result of last round of
> shrinking of inactive pages, particularly when their number is large
> enough.
> 

Thanks Hillf.

This change does appear to eliminate the issue with stalls by
should_continue_reclaim returning true too often.  I need to think
some more about exactly what is impacted with the change.

With this change, the problem moves to compaction with should_compact_retry
returning true too often.  It is the same behavior seem when I simply removed
the __GFP_RETRY_MAYFAIL special casing in should_continue_reclaim.

At Mel's suggestion I removed the compaction_zonelist_suitable() call
from should_compact_retry.  This eliminated the compaction stalls.  Thanks
Mel.

With both changes, stalls appear to be eliminated.  This is promising.
I'll try to refine these approaches and continue testing.
-- 
Mike Kravetz

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2571,18 +2571,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			return false;
>  	}
> 
> -	/*
> -	 * If we have not reclaimed enough pages for compaction and the
> -	 * inactive lists are large enough, continue reclaiming
> -	 */
> -	pages_for_compaction = compact_gap(sc->order);
> -	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
> -	if (get_nr_swap_pages() > 0)
> -		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
> -	if (sc->nr_reclaimed < pages_for_compaction &&
> -			inactive_lru_pages > pages_for_compaction)
> -		return true;
> -
>  	/* If compaction would go ahead or the allocation would succeed, stop */
>  	for (z = 0; z <= sc->reclaim_idx; z++) {
>  		struct zone *zone = &pgdat->node_zones[z];
> @@ -2598,7 +2586,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			;
>  		}
>  	}
> -	return true;
> +
> +	/*
> +	 * If we have not reclaimed enough pages for compaction and the
> +	 * inactive lists are large enough, continue reclaiming
> +	 */
> +	pages_for_compaction = compact_gap(sc->order);
> +	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
> +	if (get_nr_swap_pages() > 0)
> +		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
> +
> +	return inactive_lru_pages > pages_for_compaction &&
> +		/*
> +		 * avoid dryrun with plenty of inactive pages
> +		 */
> +		nr_scanned && nr_reclaimed;
>  }
> 
>  static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
> --
> 

