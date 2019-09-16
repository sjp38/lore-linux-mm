Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C28DC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 22:18:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE14E21670
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 22:18:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="T6LkMsom"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE14E21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21C066B0003; Mon, 16 Sep 2019 18:18:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CD1D6B0006; Mon, 16 Sep 2019 18:18:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BC8F6B0007; Mon, 16 Sep 2019 18:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0018.hostedemail.com [216.40.44.18])
	by kanga.kvack.org (Postfix) with ESMTP id DDB206B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:18:34 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 558216D67
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:18:34 +0000 (UTC)
X-FDA: 75942198948.13.pipe32_2dac7ffff4b40
X-HE-Tag: pipe32_2dac7ffff4b40
X-Filterd-Recvd-Size: 10133
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:18:33 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8GMEWwf028893;
	Mon, 16 Sep 2019 22:18:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=5OkYw5loGY+OZIKxyRG0zWZuSmCpM8iP5v71+KbI6wE=;
 b=T6LkMsomnlr9e7oB0XtUY1t7V3HJL+mwG5+JE3QrXX9x2O1kPF8LFd8W9s96Ll7f9oR+
 fSGcId+xwGbD3lH5muRVYv0Ore6kJHF7eddUWdf3xZ2xySXDgfGE5HgU5MbLHIKBFPrA
 pzIYxeyU8q5wwB3srG9+/P8zSTIIEUzhQAADA6UA8tflwE+IN2jvpkpj772ReunZJ6tU
 0oqKU6LThA1Ppif7YWp58GYLmIf2Ad9mNeT5L+F9Du09Skbf0bBWuiwf1EVAsASvuvhR
 PNbL0mpYfytf24cLd8OcO2OwI/qeXUwHNh8RphFuAnXq5oEy+JAG/Buy26dfm1+HmdER og== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2v0r5pabxd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 22:18:29 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8GMIOGx113575;
	Mon, 16 Sep 2019 22:18:28 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2v2jxg87fq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 22:18:28 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8GMHbdr006630;
	Mon, 16 Sep 2019 22:17:37 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 16 Sep 2019 15:17:37 -0700
Subject: Re: [PATCH v4 4/9] hugetlb: region_chg provides only cache entry
To: Mina Almasry <almasrymina@google.com>
Cc: shuah@kernel.org, rientjes@google.com, shakeelb@google.com,
        gthelen@google.com, akpm@linux-foundation.org, khalid.aziz@oracle.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org,
        aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
References: <20190910233146.206080-1-almasrymina@google.com>
 <20190910233146.206080-5-almasrymina@google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b2fa24c3-c92f-6834-e6da-b952ac25e5f3@oracle.com>
Date: Mon, 16 Sep 2019 15:17:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190910233146.206080-5-almasrymina@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9382 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909160212
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9382 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909160212
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/10/19 4:31 PM, Mina Almasry wrote:
> Current behavior is that region_chg provides both a cache entry in
> resv->region_cache, AND a placeholder entry in resv->regions. region_add
> first tries to use the placeholder, and if it finds that the placeholder
> has been deleted by a racing region_del call, it uses the cache entry.
> 
> This behavior is completely unnecessary and is removed in this patch for
> a couple of reasons:
> 
> 1. region_add needs to either find a cached file_region entry in
>    resv->region_cache, or find an entry in resv->regions to expand. It
>    does not need both.
> 2. region_chg adding a placeholder entry in resv->regions opens up
>    a possible race with region_del, where region_chg adds a placeholder
>    region in resv->regions, and this region is deleted by a racing call
>    to region_del during region_chg execution or before region_add is
>    called. Removing the race makes the code easier to reason about and
>    maintain.
> 
> In addition, a follow up patch in this series disables region
> coalescing, which would be further complicated if the race with
> region_del exists.
> 
> Signed-off-by: Mina Almasry <almasrymina@google.com>

Thanks.  I like this modification as it does simplify the code and could
be added as a general cleanup independent of the other changes.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 63 +++++++++-------------------------------------------
>  1 file changed, 11 insertions(+), 52 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index fbd7c52e17348..bea51ae422f63 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -246,14 +246,10 @@ struct file_region {
> 
>  /*
>   * Add the huge page range represented by [f, t) to the reserve
> - * map.  In the normal case, existing regions will be expanded
> - * to accommodate the specified range.  Sufficient regions should
> - * exist for expansion due to the previous call to region_chg
> - * with the same range.  However, it is possible that region_del
> - * could have been called after region_chg and modifed the map
> - * in such a way that no region exists to be expanded.  In this
> - * case, pull a region descriptor from the cache associated with
> - * the map and use that for the new range.
> + * map.  Existing regions will be expanded to accommodate the specified
> + * range, or a region will be taken from the cache.  Sufficient regions
> + * must exist in the cache due to the previous call to region_chg with
> + * the same range.
>   *
>   * Return the number of new huge pages added to the map.  This
>   * number is greater than or equal to zero.
> @@ -272,9 +268,8 @@ static long region_add(struct resv_map *resv, long f, long t)
> 
>  	/*
>  	 * If no region exists which can be expanded to include the
> -	 * specified range, the list must have been modified by an
> -	 * interleving call to region_del().  Pull a region descriptor
> -	 * from the cache and use it for this range.
> +	 * specified range, pull a region descriptor from the cache
> +	 * and use it for this range.
>  	 */
>  	if (&rg->link == head || t < rg->from) {
>  		VM_BUG_ON(resv->region_cache_count <= 0);
> @@ -339,15 +334,9 @@ static long region_add(struct resv_map *resv, long f, long t)
>   * call to region_add that will actually modify the reserve
>   * map to add the specified range [f, t).  region_chg does
>   * not change the number of huge pages represented by the
> - * map.  However, if the existing regions in the map can not
> - * be expanded to represent the new range, a new file_region
> - * structure is added to the map as a placeholder.  This is
> - * so that the subsequent region_add call will have all the
> - * regions it needs and will not fail.
> - *
> - * Upon entry, region_chg will also examine the cache of region descriptors
> - * associated with the map.  If there are not enough descriptors cached, one
> - * will be allocated for the in progress add operation.
> + * map.  A new file_region structure is added to the cache
> + * as a placeholder, so that the subsequent region_add
> + * call will have all the regions it needs and will not fail.
>   *
>   * Returns the number of huge pages that need to be added to the existing
>   * reservation map for the range [f, t).  This number is greater or equal to
> @@ -357,10 +346,9 @@ static long region_add(struct resv_map *resv, long f, long t)
>  static long region_chg(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head = &resv->regions;
> -	struct file_region *rg, *nrg = NULL;
> +	struct file_region *rg;
>  	long chg = 0;
> 
> -retry:
>  	spin_lock(&resv->lock);
>  retry_locked:
>  	resv->adds_in_progress++;
> @@ -378,10 +366,8 @@ static long region_chg(struct resv_map *resv, long f, long t)
>  		spin_unlock(&resv->lock);
> 
>  		trg = kmalloc(sizeof(*trg), GFP_KERNEL);
> -		if (!trg) {
> -			kfree(nrg);
> +		if (!trg)
>  			return -ENOMEM;
> -		}
> 
>  		spin_lock(&resv->lock);
>  		list_add(&trg->link, &resv->region_cache);
> @@ -394,28 +380,6 @@ static long region_chg(struct resv_map *resv, long f, long t)
>  		if (f <= rg->to)
>  			break;
> 
> -	/* If we are below the current region then a new region is required.
> -	 * Subtle, allocate a new region at the position but make it zero
> -	 * size such that we can guarantee to record the reservation. */
> -	if (&rg->link == head || t < rg->from) {
> -		if (!nrg) {
> -			resv->adds_in_progress--;
> -			spin_unlock(&resv->lock);
> -			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> -			if (!nrg)
> -				return -ENOMEM;
> -
> -			nrg->from = f;
> -			nrg->to   = f;
> -			INIT_LIST_HEAD(&nrg->link);
> -			goto retry;
> -		}
> -
> -		list_add(&nrg->link, rg->link.prev);
> -		chg = t - f;
> -		goto out_nrg;
> -	}
> -
>  	/* Round our left edge to the current segment if it encloses us. */
>  	if (f > rg->from)
>  		f = rg->from;
> @@ -439,11 +403,6 @@ static long region_chg(struct resv_map *resv, long f, long t)
>  	}
> 
>  out:
> -	spin_unlock(&resv->lock);
> -	/*  We already know we raced and no longer need the new region */
> -	kfree(nrg);
> -	return chg;
> -out_nrg:
>  	spin_unlock(&resv->lock);
>  	return chg;
>  }
> --
> 2.23.0.162.g0b9fbb3734-goog

