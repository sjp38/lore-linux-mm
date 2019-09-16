Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD6EEC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 22:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D361214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 22:28:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="X1qADWrW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D361214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE6766B0003; Mon, 16 Sep 2019 18:28:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98D26B0006; Mon, 16 Sep 2019 18:28:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D852A6B0007; Mon, 16 Sep 2019 18:28:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id B16746B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:28:05 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6EF16180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:28:05 +0000 (UTC)
X-FDA: 75942222930.29.frame54_80c7d0d8f7424
X-HE-Tag: frame54_80c7d0d8f7424
X-Filterd-Recvd-Size: 8967
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:28:04 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8GMOGBh072445;
	Mon, 16 Sep 2019 22:28:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=a+S1+HQwi5n9jZN3U+l0LFhmQpDYNrmD4hYD1N1Wn6s=;
 b=X1qADWrWfJBrJOCtBrR/TNHFIPhsfiR72RsEufBpspSnngcBKcXilsY0DoCAgNp0xka6
 E/d8uvN7yBYar8SrfmBtDJSG+mty/Q4Ame2or6pWws7jUHHigdOfOzPLMKlHnMb6QeLo
 ecr+rvubyPXz6jpIyThb1z2Xj1bSQ2lN+xueU55zAehVUGPi01SrNAbZ0DkaQf91h59K
 5pJWayeDr/5NDtmh/uDYDMoQphTgBGbSR+btDiuHK/wuQ622ufyQ/QHB9zWoDStJmsog
 IeT7qzpr7B+rEFRKcIvRuPgHoLVId2v/StXY8yiHM9OJHAoQpOb5T+1L6d0+8DlXKwdP yw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2v0ruqjbbv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 22:28:01 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8GMPraV059834;
	Mon, 16 Sep 2019 22:26:00 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2v0qhqansd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 22:26:00 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8GMPx9f005776;
	Mon, 16 Sep 2019 22:25:59 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 16 Sep 2019 15:25:59 -0700
Subject: Re: [PATCH v4 5/9] hugetlb: remove duplicated code
To: Mina Almasry <almasrymina@google.com>
Cc: shuah@kernel.org, rientjes@google.com, shakeelb@google.com,
        gthelen@google.com, akpm@linux-foundation.org, khalid.aziz@oracle.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org,
        aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
References: <20190910233146.206080-1-almasrymina@google.com>
 <20190910233146.206080-6-almasrymina@google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9fc3270a-4da8-a126-ba91-9e2950b4c36e@oracle.com>
Date: Mon, 16 Sep 2019 15:25:57 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190910233146.206080-6-almasrymina@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9382 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909160213
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9382 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909160213
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/10/19 4:31 PM, Mina Almasry wrote:
> Remove duplicated code between region_chg and region_add, and refactor it into
> a common function, add_reservation_in_range. This is mostly done because
> there is a follow up change in this series that disables region
> coalescing in region_add, and I want to make that change in one place
> only. It should improve maintainability anyway on its own.
> 
> Signed-off-by: Mina Almasry <almasrymina@google.com>

Like the previous patch, this is a good improvement indepentent of the
rest of the series.  Thanks!

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 116 ++++++++++++++++++++++++---------------------------
>  1 file changed, 54 insertions(+), 62 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bea51ae422f63..ce5ed1056fefd 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -244,6 +244,57 @@ struct file_region {
>  	long to;
>  };
> 
> +static long add_reservation_in_range(
> +		struct resv_map *resv, long f, long t, bool count_only)
> +{
> +
> +	long chg = 0;
> +	struct list_head *head = &resv->regions;
> +	struct file_region *rg = NULL, *trg = NULL, *nrg = NULL;
> +
> +	/* Locate the region we are before or in. */
> +	list_for_each_entry(rg, head, link)
> +		if (f <= rg->to)
> +			break;
> +
> +	/* Round our left edge to the current segment if it encloses us. */
> +	if (f > rg->from)
> +		f = rg->from;
> +
> +	chg = t - f;
> +
> +	/* Check for and consume any regions we now overlap with. */
> +	nrg = rg;
> +	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> +		if (&rg->link == head)
> +			break;
> +		if (rg->from > t)
> +			break;
> +
> +		/* We overlap with this area, if it extends further than
> +		 * us then we must extend ourselves.  Account for its
> +		 * existing reservation.
> +		 */
> +		if (rg->to > t) {
> +			chg += rg->to - t;
> +			t = rg->to;
> +		}
> +		chg -= rg->to - rg->from;
> +
> +		if (!count_only && rg != nrg) {
> +			list_del(&rg->link);
> +			kfree(rg);
> +		}
> +	}
> +
> +	if (!count_only) {
> +		nrg->from = f;
> +		nrg->to = t;
> +	}
> +
> +	return chg;
> +}
> +
>  /*
>   * Add the huge page range represented by [f, t) to the reserve
>   * map.  Existing regions will be expanded to accommodate the specified
> @@ -257,7 +308,7 @@ struct file_region {
>  static long region_add(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head = &resv->regions;
> -	struct file_region *rg, *nrg, *trg;
> +	struct file_region *rg, *nrg;
>  	long add = 0;
> 
>  	spin_lock(&resv->lock);
> @@ -287,38 +338,7 @@ static long region_add(struct resv_map *resv, long f, long t)
>  		goto out_locked;
>  	}
> 
> -	/* Round our left edge to the current segment if it encloses us. */
> -	if (f > rg->from)
> -		f = rg->from;
> -
> -	/* Check for and consume any regions we now overlap with. */
> -	nrg = rg;
> -	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> -		if (&rg->link == head)
> -			break;
> -		if (rg->from > t)
> -			break;
> -
> -		/* If this area reaches higher then extend our area to
> -		 * include it completely.  If this is not the first area
> -		 * which we intend to reuse, free it. */
> -		if (rg->to > t)
> -			t = rg->to;
> -		if (rg != nrg) {
> -			/* Decrement return value by the deleted range.
> -			 * Another range will span this area so that by
> -			 * end of routine add will be >= zero
> -			 */
> -			add -= (rg->to - rg->from);
> -			list_del(&rg->link);
> -			kfree(rg);
> -		}
> -	}
> -
> -	add += (nrg->from - f);		/* Added to beginning of region */
> -	nrg->from = f;
> -	add += t - nrg->to;		/* Added to end of region */
> -	nrg->to = t;
> +	add = add_reservation_in_range(resv, f, t, false);
> 
>  out_locked:
>  	resv->adds_in_progress--;
> @@ -345,8 +365,6 @@ static long region_add(struct resv_map *resv, long f, long t)
>   */
>  static long region_chg(struct resv_map *resv, long f, long t)
>  {
> -	struct list_head *head = &resv->regions;
> -	struct file_region *rg;
>  	long chg = 0;
> 
>  	spin_lock(&resv->lock);
> @@ -375,34 +393,8 @@ static long region_chg(struct resv_map *resv, long f, long t)
>  		goto retry_locked;
>  	}
> 
> -	/* Locate the region we are before or in. */
> -	list_for_each_entry(rg, head, link)
> -		if (f <= rg->to)
> -			break;
> -
> -	/* Round our left edge to the current segment if it encloses us. */
> -	if (f > rg->from)
> -		f = rg->from;
> -	chg = t - f;
> -
> -	/* Check for and consume any regions we now overlap with. */
> -	list_for_each_entry(rg, rg->link.prev, link) {
> -		if (&rg->link == head)
> -			break;
> -		if (rg->from > t)
> -			goto out;
> +	chg = add_reservation_in_range(resv, f, t, true);
> 
> -		/* We overlap with this area, if it extends further than
> -		 * us then we must extend ourselves.  Account for its
> -		 * existing reservation. */
> -		if (rg->to > t) {
> -			chg += rg->to - t;
> -			t = rg->to;
> -		}
> -		chg -= rg->to - rg->from;
> -	}
> -
> -out:
>  	spin_unlock(&resv->lock);
>  	return chg;
>  }
> --
> 2.23.0.162.g0b9fbb3734-goog
> 

