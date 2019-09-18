Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5439C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:32:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6147321907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:32:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SMwcRfBY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6147321907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 124626B0309; Wed, 18 Sep 2019 17:32:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D5046B030A; Wed, 18 Sep 2019 17:32:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2DB36B030B; Wed, 18 Sep 2019 17:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0171.hostedemail.com [216.40.44.171])
	by kanga.kvack.org (Postfix) with ESMTP id D0D0C6B0309
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:32:29 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5D0AD180AD806
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:32:29 +0000 (UTC)
X-FDA: 75949340418.21.girls61_32c2e97966914
X-HE-Tag: girls61_32c2e97966914
X-Filterd-Recvd-Size: 5150
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:32:28 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILFhMv067452;
	Wed, 18 Sep 2019 21:32:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=ydH1j+B0xRX/SyIsv01NtDcbV5mWghGk55r8xlV3jfk=;
 b=SMwcRfBYTin9EkIMiakRaKvNbt2UtbqLVWLDhkyt7TI0c0Hk7U1+Wvgljevi8GbKC+7U
 NT8pHcrfWkCjCyPHRAMaO0eF4OdOMEEfzvzx4pmGaxZVif+R4sVAtDXbBGZTwr8MNsKo
 W5p/jDvp2HAqhddgAYyWWuccs6tm1J+5C2OrlN8m8oQ2RlmQdJfKavC5lvef//cSaW+u
 +wCNffqOExhpO7ZreCvOZyuraXPimIgN1Os10O1R3Tr1RURmkk94p40X+Pjf3TBuApNr
 Vti+dr7XZJ92Wht7HB0vmShvG6utD0DoYtTLmobZm3OgRLFMqnf09mBLcFURcIKWKMPU Qw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2v3vb4r1y6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:32:24 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILFHdQ071228;
	Wed, 18 Sep 2019 21:32:23 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2v3vb8rw1w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:32:23 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x8ILWMEB002379;
	Wed, 18 Sep 2019 21:32:22 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 14:32:22 -0700
Date: Wed, 18 Sep 2019 14:32:21 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH v2 5/5] xfs: Pass a page to xfs_finish_page_writeback
Message-ID: <20190918213221.GF2229799@magnolia>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821003039.12555-6-willy@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909180182
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909180182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:30:39PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> The only part of the bvec we were accessing was the bv_page, so just
> pass that instead of the whole bvec.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Seems fine but same caveats about tree churn as the previous patch.

--D

> ---
>  fs/xfs/xfs_aops.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 1a26e9ca626b..edcb4797fcc2 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -58,21 +58,21 @@ xfs_find_daxdev_for_inode(
>  static void
>  xfs_finish_page_writeback(
>  	struct inode		*inode,
> -	struct bio_vec	*bvec,
> +	struct page		*page,
>  	int			error)
>  {
> -	struct iomap_page	*iop = to_iomap_page(bvec->bv_page);
> +	struct iomap_page	*iop = to_iomap_page(page);
>  
>  	if (error) {
> -		SetPageError(bvec->bv_page);
> +		SetPageError(page);
>  		mapping_set_error(inode->i_mapping, -EIO);
>  	}
>  
> -	ASSERT(iop || i_blocks_per_page(inode, bvec->bv_page) <= 1);
> +	ASSERT(iop || i_blocks_per_page(inode, page) <= 1);
>  	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
>  
>  	if (!iop || atomic_dec_and_test(&iop->write_count))
> -		end_page_writeback(bvec->bv_page);
> +		end_page_writeback(page);
>  }
>  
>  /*
> @@ -106,7 +106,7 @@ xfs_destroy_ioend(
>  
>  		/* walk each page on bio, ending page IO on them */
>  		bio_for_each_segment_all(bvec, bio, iter_all)
> -			xfs_finish_page_writeback(inode, bvec, error);
> +			xfs_finish_page_writeback(inode, bvec->bv_page, error);
>  		bio_put(bio);
>  	}
>  
> -- 
> 2.23.0.rc1
> 

