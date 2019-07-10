Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD1C3C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8616A20844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:42:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qqTSQtkl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8616A20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 113728E0089; Wed, 10 Jul 2019 14:42:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C4278E0032; Wed, 10 Jul 2019 14:42:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE0B8E0089; Wed, 10 Jul 2019 14:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC1B78E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:42:53 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n8so3820536ioo.21
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:42:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FrnG1U6LEwcCjLYKp8JstQQPx/C4ErLDKYXCfTw5Xsg=;
        b=hxT4kmDugRX+jj/KUT+Zl6e3bC529zQyqaxEEEf4XzOgOgzGi0nR8NpgRPM2W3zaGH
         BMtQD7mwgsdU6rU/+7YbyJFXLvN/FZnPlslinI3g5UPS11YzzaCwL3rnIhW5SIXg7OY1
         9FcO4BrLTv69roS2rFT+QLmscv6pcEPQeeefOpuHANFJxxJQG9CTAUCTIOw6o6It9+Gm
         6cmZE2CLEeYPK9Kr8A8Zx9qGlIWBxfcY4LAFRbOXeru/AYk4SXYUReUptf7V3WRXTDGW
         pCyAXWL3JtH14OvFJvHOIWo6vO5U7D8h+yWwLrPPhBCUIQnsfl8kNUCSmgxZSBXZfb8S
         FYvg==
X-Gm-Message-State: APjAAAVjDL5BmkAASvbEnuiGe4AAuUjlO0kDirJN6y32I+6VXueoxem4
	yg4Y+3dFXxJyDKWBFMGXij8jTdf93m/csqysMZQ5unmVtwAv3yxplk2HO7hgJR2nIOXkT2amTYd
	jFoYG34t8UghpNVUDR62FgVU82PdEgu1AM3f/wr/hC4t+hgh4blu8nvrDKjDf3O3zrw==
X-Received: by 2002:a5d:8c81:: with SMTP id g1mr34622840ion.239.1562784173564;
        Wed, 10 Jul 2019 11:42:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/xPiiLYHnAedG7IPi4snyHCE23wU2c9nJG2br8AweRXMz0te4HSPxCnXaN7HRXbSIEoXU
X-Received: by 2002:a5d:8c81:: with SMTP id g1mr34622785ion.239.1562784172974;
        Wed, 10 Jul 2019 11:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562784172; cv=none;
        d=google.com; s=arc-20160816;
        b=oPjf5h+YJ0AqZYPBSgyAZFXCfMwJfP1pT8c1lofv2cLyV0eNg/Q42cWxNlVmwNCOch
         /1qFylc6gzWHbDWhlLSJsvtuU67DNhQH4RZPFCRP2KACxNlQVDuxrNCtOol8LE5OOdoT
         Ullud3ER6gTMUbSPXUKy1OaI3+nAzFbYgELjSHf8lOg2RXafZJozt0V16UB4ekpOIbZW
         3dhpyv8i35znDYRp4JCLCrtMZXh+CcMoso/z2tC0GP/iAB4vu6+cSeoTvWRgTyVPdGqb
         BPZlJr/RYHxpSdkmXNwAnfDxf+aLn888FR2o42RRBEwrPEAOV4dYBShPFz37fRKLSpEK
         yVbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=FrnG1U6LEwcCjLYKp8JstQQPx/C4ErLDKYXCfTw5Xsg=;
        b=yn6UOITDh6AcIijQQs8i/yAFWJhY9M3pv7UcBPYefj4P45fTwbqBHiPw59CAMEqzzs
         wcTiEQjrkt/Y8Ll/1477R/Ckva1trV3gAs8ePr/ifNCbR84498uOs7f3Hh2k0pMGmUKS
         BLk61/o1KyE9EZdg8nMyD4BJY1ZdJ/TLxUd2Zx9uFpA+l8QELKBweItiZAxKmBT4sz3Q
         +0ZoyE4rzIoHSSXq/qhmZ07P9ParM9foDw8O/6g0iGX3l4ufTYHDhGsbWyoA761XFL4A
         b4F5N0SGsOGMkEWz2nQpbHh5mC1mVeJLm3C5Yu0LPz1AP94P2+2i+cLnQvbQIOJHStV4
         1a5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qqTSQtkl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h5si4279133iog.11.2019.07.10.11.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 11:42:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qqTSQtkl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6AIcuKM090980;
	Wed, 10 Jul 2019 18:42:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=FrnG1U6LEwcCjLYKp8JstQQPx/C4ErLDKYXCfTw5Xsg=;
 b=qqTSQtklpXfVQkFDZ6uphbgICdiECgiJI7WBUpC44t6qLDAmnU3fpNP16KNwpnzqkAmx
 XqsIZ2bZjLdI2YhMh6mNf2Z9LM63423NsaHNMApmXNfyN+d5WEMyHycqZ78u+SLAkhgb
 2ea2rSKQF6jT1naMZKJ/9BobLmB+uo99ay9ukMWu1spdo0ANjefzUNMMkiwA9Oltd0rI
 fn8oDSjCSJ7B92o3uBVqyTFII2GZk1czVYN/eU9of9I8uO839ReLbqgF+Oo7g0x/4GkT
 7isWK8+26X5KpTWC5AvaGdQp3NYdqDdZEz1Yleo5VcVuHRiZErNqS0Bhk7eTX453ZdPW dw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2tjk2tuy1p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 18:42:49 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6AIgPSI088381;
	Wed, 10 Jul 2019 18:42:48 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2tmmh3q8k5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 18:42:48 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6AIggde029517;
	Wed, 10 Jul 2019 18:42:42 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 10 Jul 2019 11:42:42 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Hillf Danton <hdanton@sina.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
Date: Wed, 10 Jul 2019 11:42:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907100212
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907100211
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/7/19 10:19 PM, Hillf Danton wrote:
> On Mon, 01 Jul 2019 20:15:51 -0700 Mike Kravetz wrote:
>> On 7/1/19 1:59 AM, Mel Gorman wrote:
>>>
>>> I think it would be reasonable to have should_continue_reclaim allow an
>>> exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
>>> less than SWAP_CLUSTER_MAX and no pages are being reclaimed.
>>
>> Thanks Mel,
>>
>> I added such a check to should_continue_reclaim.  However, it does not
>> address the issue I am seeing.  In that do-while loop in shrink_node,
>> the scan priority is not raised (priority--).  We can enter the loop
>> with priority == DEF_PRIORITY and continue to loop for minutes as seen
>> in my previous debug output.
>>
> Does it help raise prioity in your case?

Thanks Hillf,  sorry for delay in responding I have been AFK.

I am not sure if you wanted to try this somehow in addition to Mel's
suggestion, or alone.

Unfortunately, such a change actually causes worse behavior.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2543,11 +2543,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  	unsigned long pages_for_compaction;
>  	unsigned long inactive_lru_pages;
>  	int z;
> +	bool costly_fg_reclaim = false;
>  
>  	/* If not in reclaim/compaction mode, stop */
>  	if (!in_reclaim_compaction(sc))
>  		return false;
>  
> +	/* Let compact determine what to do for high order allocators */
> +	costly_fg_reclaim = sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> +				!current_is_kswapd();
> +	if (costly_fg_reclaim)
> +		goto check_compact;

This goto makes us skip the 'if (!nr_reclaimed && !nr_scanned)' test.

> +
>  	/* Consider stopping depending on scan and reclaim activity */
>  	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
>  		/*
> @@ -2571,6 +2578,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			return false;
>  	}
>  
> +check_compact:
>  	/*
>  	 * If we have not reclaimed enough pages for compaction and the
>  	 * inactive lists are large enough, continue reclaiming

It is quite easy to hit the condition where:
nr_reclaimed == 0  && nr_scanned == 0 is true, but we skip the previous test

and the compaction check:
sc->nr_reclaimed < pages_for_compaction &&
	inactive_lru_pages > pages_for_compaction

is true, so we return true before the below check of costly_fg_reclaim

> @@ -2583,6 +2591,9 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			inactive_lru_pages > pages_for_compaction)
>  		return true;
>  
> +	if (costly_fg_reclaim)
> +		return false;
> +
>  	/* If compaction would go ahead or the allocation would succeed, stop */
>  	for (z = 0; z <= sc->reclaim_idx; z++) {
>  		struct zone *zone = &pgdat->node_zones[z];
> --
> 

As Michal suggested, I'm going to do some testing to see what impact
dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
will have on the number of pages allocated.
-- 
Mike Kravetz

