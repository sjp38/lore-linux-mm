Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E038CC04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:15:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8107021744
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:15:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jYPe92SQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8107021744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1396B0003; Tue, 30 Apr 2019 11:15:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6919C6B0006; Tue, 30 Apr 2019 11:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 580406B0007; Tue, 30 Apr 2019 11:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 218906B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:15:00 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a17so7267239plm.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gu8MWvTYCi41J/gN2asvVGcjr6fDPYUJLpVtB5eyYmw=;
        b=HLVHBhIDxQc1UgNPvTLcbj9rNuLaq/WTx3Y8oWg9qsFfmpxbxayirIv+qNKERAxfXv
         dAh5gS8UwO97Zp+629u2tGdULabyZSuhrkQAQiX+zKnEl8rOI6MOcpcCMd2ThYlMGR9b
         njNbP56je8KwVHR+KXdWOD1GJpztr3IxJmCa/tAxZ2P2tqc0yJu1gA7CQe9M3Pr9uUg4
         hq3YZwO4PI028zZbwLRHHTokYHLa7SrZGerDGsyM3VqcYMuycYiIe0m88bFAM9kgVkHy
         H/3OQKSR1o3wVRNaDDJw8qCVNFYvObKb3pvoTPGyrLrCb6BlrZ9xP4yHmY8By0QVUkn2
         UvSA==
X-Gm-Message-State: APjAAAXYHiBPqfgZvUqG5zncFxPV4tfc0ISYT8NxF/pmUYYSxMwvOojl
	+Mwosmby1/wlO9CIaV1tbN6WXx/h5bcjJtK2Ij7MRqxx83pRPcMtpu5wUov1JlBEx2nvxNbErCl
	f9hZZ/G3+Jxc9QZBN73XvfHB4w6fj+2mOQ7BEepnE+hArChKLsMZASmMBkL7GdvjPIQ==
X-Received: by 2002:a62:b40b:: with SMTP id h11mr69294216pfn.133.1556637299713;
        Tue, 30 Apr 2019 08:14:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxny2oyKCyCA8jkejWr4TT+iTDeEQhfITm4G0YsU82/wVA6ZVROleWKnZDWxw090msqnhTZ
X-Received: by 2002:a62:b40b:: with SMTP id h11mr69294131pfn.133.1556637298939;
        Tue, 30 Apr 2019 08:14:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556637298; cv=none;
        d=google.com; s=arc-20160816;
        b=YNSmr7BUAPDa9WaelR/HHcGSNcLCCE8lc/hpd4SunQEQNa+8B6O7gNeu4bGD9QQxwX
         csZy+ktc6tSBmqPTrJAxcAd7Wb3eCHNaVKlcqRSqES9BsItOFgH1DdCURcGA8YOc8zwf
         0z4q8Td+tBW5VnrNJy+c6aEdmKNE8Lxh/wDIewnl3LxS30++VnEG+kCHM8ED8XYFT/Dh
         so3uXnGodVeLh9EbMLpK1tbSPoPhoJU/zaI18lgbKNvafeHpIzetHj73XFrxq9PSfQew
         5m2BcsqoWKWIG5hY6vhSTRlPazA7itZoHoXpPp9qWCdlC1qHJGAn54rpXebvpoGtMXyq
         sw8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gu8MWvTYCi41J/gN2asvVGcjr6fDPYUJLpVtB5eyYmw=;
        b=oS/CUMGlwgwpBl6dBQkRYkWbN0dkIzviPmCMJ+6r3rkYg0OHcybqtmPAPU3bl8N6y6
         q3DW0gCpSzftPqoEUHxmxAJsU3+L73I2WGc2y8yZPz6lif6+4yNkQBUGsb1FakHixqOo
         mkqacxO8mGV7+1KObP8Q21avrzpQJ9LWdr0yxCpWZNd3OkBOv9nO5GDfx4gsA3Th7DhL
         SYLzk2sPlHmTZI4oPpE+DSbEsWleKE6VLRrDAEcfl+M1dQFeGjf092WaOUwQfYeKXPUJ
         IeeIlu9+G465uKcu6Gj79HXqS9kwBr+6IpvFsGEjJHWtpdNsPCuwdFzgaHlwQWZ/7A53
         HBAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jYPe92SQ;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i189si1771537pfb.41.2019.04.30.08.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 08:14:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jYPe92SQ;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UF9cQU106361;
	Tue, 30 Apr 2019 15:14:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=gu8MWvTYCi41J/gN2asvVGcjr6fDPYUJLpVtB5eyYmw=;
 b=jYPe92SQ/dw7NPBvK6P/ZdX211I0o4yDoMNvZte4PxbH1Qh7YcNVmW2IVLKUN5xxiLN8
 Vz03hnDRk2bvbX5hRKegFA6gayRf6Wo3k3+mBR7VCtCuhsRkeq2rEjvI/sNJ4GpefMxz
 aA2vdG+xl6EHzGqFJu8Ch/SfHTQXjNZlpLAB8GWj+WwXmVNLzW4KsMmqH5vO38i6PANr
 oSr37bCkhgfWsOfvPT2eDZvSAhRHBt4wlxn1f55KfeiCTeWhBTyOMGiiSWkglhCXpFpp
 Pwnf36X9WBo9GnM9/5JFcf58OC+N1pGSv+kc6UxBRB38xHBUZa/INn+/5H0DfY6M5COK Ww== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2s4ckdderp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:14:53 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFEgdi059434;
	Tue, 30 Apr 2019 15:14:53 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2s4d4ajx7k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:14:53 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3UFEnaZ020024;
	Tue, 30 Apr 2019 15:14:49 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Apr 2019 08:14:49 -0700
Date: Tue, 30 Apr 2019 08:14:46 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
        Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Chinner <david@fromorbit.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 1/5] iomap: Clean up __generic_write_end calling
Message-ID: <20190430151446.GB5200@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190429220934.10415-2-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429220934.10415-2-agruenba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300094
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:30AM +0200, Andreas Gruenbacher wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Move the call to __generic_write_end into iomap_write_end instead of
> duplicating it in each of the three branches.  This requires open coding
> the generic_write_end for the buffer_head case.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/iomap.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 97cb9d486a7d..2344c662e6fc 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -738,13 +738,11 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	 * uptodate page as a zero-length write, and force the caller to redo
>  	 * the whole thing.
>  	 */
> -	if (unlikely(copied < len && !PageUptodate(page))) {
> -		copied = 0;
> -	} else {
> -		iomap_set_range_uptodate(page, offset_in_page(pos), len);
> -		iomap_set_page_dirty(page);
> -	}
> -	return __generic_write_end(inode, pos, copied, page);
> +	if (unlikely(copied < len && !PageUptodate(page)))
> +		return 0;
> +	iomap_set_range_uptodate(page, offset_in_page(pos), len);
> +	iomap_set_page_dirty(page);
> +	return copied;
>  }
>  
>  static int
> @@ -761,7 +759,6 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
>  	kunmap_atomic(addr);
>  
>  	mark_inode_dirty(inode);
> -	__generic_write_end(inode, pos, copied, page);
>  	return copied;
>  }
>  
> @@ -774,12 +771,13 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	if (iomap->type == IOMAP_INLINE) {
>  		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
>  	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
> -		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
> -				copied, page, NULL);
> +		ret = block_write_end(NULL, inode->i_mapping, pos, len, copied,
> +				page, NULL);
>  	} else {
>  		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
>  	}
>  
> +	ret = __generic_write_end(inode, pos, ret, page);
>  	if (iomap->page_done)
>  		iomap->page_done(inode, pos, copied, page, iomap);
>  
> -- 
> 2.20.1
> 

