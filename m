Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 186B2C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C330F21907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Q1tYMv4h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C330F21907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78C5F6B0307; Wed, 18 Sep 2019 17:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7167A6B0308; Wed, 18 Sep 2019 17:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6050D6B0309; Wed, 18 Sep 2019 17:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id 39E6A6B0307
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:31:17 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AB762180AD805
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:31:16 +0000 (UTC)
X-FDA: 75949337352.27.shock65_2833f5a650e31
X-HE-Tag: shock65_2833f5a650e31
X-Filterd-Recvd-Size: 6405
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:31:16 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILG1kE067512;
	Wed, 18 Sep 2019 21:31:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=cepEtUTTs2FluRenGgDKla4FhOIsiV7PRcyw0cSLR7E=;
 b=Q1tYMv4ht5W765mUvQCF4+C7054/xWVW3v+D8hzQgzmsVvzIYHcwKN6STChraq2mH1dl
 GEAyeYHOqc3qSaGEjRvQKWBZh7oDL20kpcURkPfRVYbf0dxzgzah8stStqtdVfb+VmLV
 7/dssIxCDErqcg4254VekZBBCSfCJR0hL1tFQ6bn7l6anNDWNZTw0pJ5u750FO4PcGY+
 lLREITpgF7hCTMPHQQhdGEl+ipGLY0m/Hdw67Itfj08WzPmvr/YlpsoqSh+BwdTZuHFD
 SjbkG5GK/PFVEwD5QHNC+D4tqRe2Jz9gKNCbUVOyBz2TuZKJbrwNCwI3z7mS2uMMfuvk LA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2v3vb4r1u9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:31:11 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILGFkj032297;
	Wed, 18 Sep 2019 21:31:10 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2v3vbqrfec-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:31:10 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x8ILV9RR001551;
	Wed, 18 Sep 2019 21:31:09 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 14:31:09 -0700
Date: Wed, 18 Sep 2019 14:31:08 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH v2 4/5] xfs: Support large pages
Message-ID: <20190918213108.GE2229799@magnolia>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-5-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821003039.12555-5-willy@infradead.org>
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

On Tue, Aug 20, 2019 at 05:30:38PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Mostly this is just checking the page size of each page instead of
> assuming PAGE_SIZE.  Clean up the logic in writepage a little.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Looks ok, let's see what happens when I get back to the "make xfs use
iomap writeback" series...

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 19 +++++++++----------
>  1 file changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 102cfd8a97d6..1a26e9ca626b 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -765,7 +765,7 @@ xfs_add_to_ioend(
>  	struct xfs_mount	*mp = ip->i_mount;
>  	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
>  	unsigned		len = i_blocksize(inode);
> -	unsigned		poff = offset & (PAGE_SIZE - 1);
> +	unsigned		poff = offset & (page_size(page) - 1);
>  	bool			merged, same_page = false;
>  	sector_t		sector;
>  
> @@ -843,7 +843,7 @@ xfs_aops_discard_page(
>  	if (error && !XFS_FORCED_SHUTDOWN(mp))
>  		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
>  out_invalidate:
> -	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
> +	xfs_vm_invalidatepage(page, 0, page_size(page));
>  }
>  
>  /*
> @@ -984,8 +984,7 @@ xfs_do_writepage(
>  	struct xfs_writepage_ctx *wpc = data;
>  	struct inode		*inode = page->mapping->host;
>  	loff_t			offset;
> -	uint64_t              end_offset;
> -	pgoff_t                 end_index;
> +	uint64_t		end_offset;
>  
>  	trace_xfs_writepage(inode, page, 0, 0);
>  
> @@ -1024,10 +1023,9 @@ xfs_do_writepage(
>  	 * ---------------------------------^------------------|
>  	 */
>  	offset = i_size_read(inode);
> -	end_index = offset >> PAGE_SHIFT;
> -	if (page->index < end_index)
> -		end_offset = (xfs_off_t)(page->index + 1) << PAGE_SHIFT;
> -	else {
> +	end_offset = file_offset_of_next_page(page);
> +
> +	if (end_offset > offset) {
>  		/*
>  		 * Check whether the page to write out is beyond or straddles
>  		 * i_size or not.
> @@ -1039,7 +1037,8 @@ xfs_do_writepage(
>  		 * |				    |      Straddles     |
>  		 * ---------------------------------^-----------|--------|
>  		 */
> -		unsigned offset_into_page = offset & (PAGE_SIZE - 1);
> +		unsigned offset_into_page = offset_in_this_page(page, offset);
> +		pgoff_t end_index = offset >> PAGE_SHIFT;
>  
>  		/*
>  		 * Skip the page if it is fully outside i_size, e.g. due to a
> @@ -1070,7 +1069,7 @@ xfs_do_writepage(
>  		 * memory is zeroed when mapped, and writes to that region are
>  		 * not written out to the file."
>  		 */
> -		zero_user_segment(page, offset_into_page, PAGE_SIZE);
> +		zero_user_segment(page, offset_into_page, page_size(page));
>  
>  		/* Adjust the end_offset to the end of file */
>  		end_offset = offset;
> -- 
> 2.23.0.rc1
> 

