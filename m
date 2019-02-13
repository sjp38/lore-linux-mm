Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8ACFC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:13:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACCA821904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:13:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xS5/nDQI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACCA821904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CD5B8E0003; Wed, 13 Feb 2019 14:13:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B928E0001; Wed, 13 Feb 2019 14:13:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26B1A8E0003; Wed, 13 Feb 2019 14:13:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3ABE8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:13:34 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p205so5560455itc.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:13:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SVzrTYMXSEVBrO+ckDrkMcCbukCBiTGAwPndsX9SVvQ=;
        b=EM9IH4iIeEvT9vpjld2dzWb2w9E3D8JSXBQRPEmT9rpR+R1GvswvInchEszQMtKO2t
         E8cS2q8ZmowmqBwFMs/T5bAUj0DoGu5Y9GsGQB82JZUL1lr3RGDKzvAXnfx9YBelgwLD
         HHmTEXTCNbdRXkb68tPnkeqOyqikjV/9PGx58IREoiIQaeeKk/TTQiVaAKzRuYT6IYt9
         zlq2VVY9T8Jib+iGr8YMlUmvCCRaqeLe5M0EvnWUBDgyyZ+gBuV33G2y3Y/n9qPc2w23
         F0iE5ctF9qmlKZpf6HiJJPS1x6uowyczfVzoWm9VHLes61iq2fk3UzBq48+/io0gU1Qa
         g0kw==
X-Gm-Message-State: AHQUAub8xI/4tRjyrn22IOsUvs7YY1vnNEvcsxJThy160/GnIqYbqOrc
	D0lBV4CggDpvWdbnKPXs86/xCYCQoNepoXgnWcQWF6FnHwcaS8j+yikIjqHcTfFRJ9EAOvGck0a
	Dcps22PXyEZKipaHqQO5GK1A22upBCACnci+ATaJV1blS1tdNZ/2jgS+w6yA8ahQudw==
X-Received: by 2002:a24:5557:: with SMTP id e84mr1045068itb.178.1550085214747;
        Wed, 13 Feb 2019 11:13:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbxWaKiB6vcKazU2SQdU2tDCOCNFLkjUtMhJMdb6a8H5OnxIYyar7xd2ADGv92BGIbntz+d
X-Received: by 2002:a24:5557:: with SMTP id e84mr1045024itb.178.1550085213779;
        Wed, 13 Feb 2019 11:13:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085213; cv=none;
        d=google.com; s=arc-20160816;
        b=V370xy3eEGcDzdkli//+Wk3N3jVb4VCCk8ASqy0GrAK2BOTra2TwaC3nRP/LEjJrmF
         pFHfGVc/VFh3GXrPtFHUHKlP4uvUDmXXF1BWlV2GnvKurRiO4AOYKj+6iOmjeaOrvqJK
         C47Uk5TAUyne1az+Ofcs6G7SplfTCceDEE/CxS+MVTN/zlO0QJMOkr9c4qknTZOixjxF
         6Cn8cS6s9/mxg0GGrLw5BpmLVgvrVksjALWnyGonC4jtrq9+NJYg3Ix0S2kRfm479r7Z
         tPlpy7V6lETmGUbxW0oTtTNc67BZxuPpaoF6oT0Qr8j+XbHqxW4JZpCaZ/aC4zpWipRX
         umrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SVzrTYMXSEVBrO+ckDrkMcCbukCBiTGAwPndsX9SVvQ=;
        b=ce1mLg9WarNcr9MgtqyvoePngjLwvsNB9+NoV0NC7gWbiZbdqu101FQLKxpzTF7paX
         r3E9xRCwtnezOyHVdHE0s3G2b2s838Elfek+1BQXhpq4kBDQfIIvhrT510JXg4hTiVsT
         6NK3lmmxQjQPd6IPGcxS+PlEEkgT+xbMEu59htRtsccy6H+UzwLwAjhgftAhP6RsvkfT
         0seh4WsxFRM+oaBQ2y6HQ4elRr6EhIgoJlVsFec0Ype9/cXtlHtYOApydLU+mC50NfnF
         QwCSi02qUiXJNI+u+/fJqkiZf2dRP+qk63XG7VWVonVB2zxg+nBeKxVhcBpQT1KGejHK
         x1ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="xS5/nDQI";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b2si39083ion.146.2019.02.13.11.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:13:33 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="xS5/nDQI";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DJ8eAo065506;
	Wed, 13 Feb 2019 19:13:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=SVzrTYMXSEVBrO+ckDrkMcCbukCBiTGAwPndsX9SVvQ=;
 b=xS5/nDQIE6IsR36HV54ROP/TKiJNh/q/lYy++yP4NECWOcDRSsGl1e055VqzMvfD3ND+
 DCrevzsyJwWOJPcvPqKenldvEzn10cD/2yKO68SljPVnLWz+NHk9XfMGl63VMtWmp6yM
 GvZRNz6Qkx/fL8xQ5D/KwOQMmLJkZJVh+/3+EjXg6RPHxQ2nmMSwH3yQlGx7fUsA/d33
 xVmng7ZXZ29IoatPUpsWkeZcMvkTdK0PtvJjL+Jiv0MrxFZWLpyUjDl+wmQGtV/Ggay4
 p8YS7z5ZNSrXwayWpVSGVjpoCwSQE8RuXDUoJ9sowePQSNE7qWOdvZezoYUbvY7PNKxl WA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qhree3yx4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:13:31 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1DJDTYj019118
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:13:30 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1DJDRhh027449;
	Wed, 13 Feb 2019 19:13:28 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 11:13:27 -0800
Date: Wed, 13 Feb 2019 14:13:48 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
Message-ID: <20190213191348.tpwwu3m7o3cmg7ma@ca-dmjordan1.us.oracle.com>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998444590.18704.9387109537711017589.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154998444590.18704.9387109537711017589.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:14:05PM +0300, Kirill Tkhai wrote:
> We know, which LRU is not active.

s/,//

> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 84542004a277..8d7d55e71511 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2040,12 +2040,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
>  		}
>  	}
>  
> -	if (!is_active_lru(lru)) {
> -		__count_vm_events(PGDEACTIVATE, nr_moved);
> -		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
> -				   nr_moved);
> -	}
> -
>  	return nr_moved;
>  }
>  
> @@ -2137,6 +2131,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
>  	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> +
> +	__count_vm_events(PGDEACTIVATE, nr_deactivate);
> +	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);

Nice, you're using the irq-unsafe one since irqs are already disabled.  I guess
this was missed in c3cc39118c361.  Do you want to insert a patch before this
one that converts all instances of this pattern in vmscan.c over?

There's a similar oversight in lru_lazyfree_fn with count_memcg_page_event, but
that'd mean __count_memcg_page_event which is probably overkill.

