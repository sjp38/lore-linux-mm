Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCC00C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CAAA205ED
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YJ4EdWrq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CAAA205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA3D76B0275; Thu, 29 Aug 2019 11:52:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E53876B0276; Thu, 29 Aug 2019 11:52:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6A336B0277; Thu, 29 Aug 2019 11:52:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id B01476B0275
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:52:14 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 60BAEBEF5
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:52:14 +0000 (UTC)
X-FDA: 75875906988.02.cloth88_87e8edc62521a
X-HE-Tag: cloth88_87e8edc62521a
X-Filterd-Recvd-Size: 6232
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:52:13 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7TFhrNr030706;
	Thu, 29 Aug 2019 15:52:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=sZ2wJVCaCx4ayGv+glOtET55sKUDTDNz0zk7gEWxJE8=;
 b=YJ4EdWrqPjZgsd3oxpHYkPGMwSGEtsJmxmWls45AQyRIRiYZ0CZ59Tg77T/9MwoHWOra
 2XxwqaEqrpq4gw/9hj/94VyDHa/rLeGs/4BRG2FCkHYWtOSOM6zGOGR/7cEIVdbHqRLh
 Jj+O7pzQ7qhfUkISrk1sOv3BpeC4VCvd/Xvcwds5apVSmH9ft6Fw/rmGMAS3jaDfmdjX
 VI1b6MzqRtlWRFE1xJTDOMWhVerxM3SN4XsUz9FDOq+IImYDwPImfFNwiYgqMifQg5xM
 wGE6fIvRqmG1RoOkDPEG96T5idBskSJrqYbuOU6iXabRgegjqqqulv0QgKP+l1cNE1KH 9Q== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2uphcyg7aw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 15:52:10 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7TFicHC049247;
	Thu, 29 Aug 2019 15:52:09 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2untev826q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 15:52:08 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7TFq6HA012139;
	Thu, 29 Aug 2019 15:52:06 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 29 Aug 2019 08:52:05 -0700
Date: Thu, 29 Aug 2019 08:52:04 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        Amir Goldstein <amir73il@gmail.com>, Boaz Harrosh <boaz@plexistor.com>,
        linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190829155204.GD5354@magnolia>
References: <20190829131034.10563-1-jack@suse.cz>
 <20190829131034.10563-4-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829131034.10563-4-jack@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9364 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908290168
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9364 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908290168
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 03:10:34PM +0200, Jan Kara wrote:
> Hole puching currently evicts pages from page cache and then goes on to
> remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
> and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
> racing reads or page faults. However there is currently nothing that
> prevents readahead triggered by fadvise() or madvise() from racing with
> the hole punch and instantiating page cache page after hole punching has
> evicted page cache in xfs_flush_unmap_range() but before it has removed
> blocks from the inode. This page cache page will be mapping soon to be
> freed block and that can lead to returning stale data to userspace or
> even filesystem corruption.
> 
> Fix the problem by protecting handling of readahead requests by
> XFS_IOLOCK_SHARED similarly as we protect reads.
> 
> CC: stable@vger.kernel.org
> Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
> Reported-by: Amir Goldstein <amir73il@gmail.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Is there a test on xfstests to demonstrate this race?

Will test it out though...

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_file.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 28101bbc0b78..d952d5962e93 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -28,6 +28,7 @@
>  #include <linux/falloc.h>
>  #include <linux/backing-dev.h>
>  #include <linux/mman.h>
> +#include <linux/fadvise.h>
>  
>  static const struct vm_operations_struct xfs_file_vm_ops;
>  
> @@ -933,6 +934,30 @@ xfs_file_fallocate(
>  	return error;
>  }
>  
> +STATIC int
> +xfs_file_fadvise(
> +	struct file	*file,
> +	loff_t		start,
> +	loff_t		end,
> +	int		advice)
> +{
> +	struct xfs_inode *ip = XFS_I(file_inode(file));
> +	int ret;
> +	int lockflags = 0;
> +
> +	/*
> +	 * Operations creating pages in page cache need protection from hole
> +	 * punching and similar ops
> +	 */
> +	if (advice == POSIX_FADV_WILLNEED) {
> +		lockflags = XFS_IOLOCK_SHARED;
> +		xfs_ilock(ip, lockflags);
> +	}
> +	ret = generic_fadvise(file, start, end, advice);
> +	if (lockflags)
> +		xfs_iunlock(ip, lockflags);
> +	return ret;
> +}
>  
>  STATIC loff_t
>  xfs_file_remap_range(
> @@ -1232,6 +1257,7 @@ const struct file_operations xfs_file_operations = {
>  	.fsync		= xfs_file_fsync,
>  	.get_unmapped_area = thp_get_unmapped_area,
>  	.fallocate	= xfs_file_fallocate,
> +	.fadvise	= xfs_file_fadvise,
>  	.remap_file_range = xfs_file_remap_range,
>  };
>  
> -- 
> 2.16.4
> 

