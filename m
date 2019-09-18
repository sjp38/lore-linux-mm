Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.4 required=3.0 tests=BODY_QUOTE_MALF_MSGID,
	DKIMWL_WL_HIGH,DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16EFAC4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:30:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C372321907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:30:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jmBCctYw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C372321907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7186C6B0305; Wed, 18 Sep 2019 17:30:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A2BB6B0306; Wed, 18 Sep 2019 17:30:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5904C6B0307; Wed, 18 Sep 2019 17:30:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 30E726B0305
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:30:06 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 846621F226
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:30:05 +0000 (UTC)
X-FDA: 75949334370.09.wren09_1dd377bccf318
X-HE-Tag: wren09_1dd377bccf318
X-Filterd-Recvd-Size: 8010
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:30:04 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILF9jB080762;
	Wed, 18 Sep 2019 21:29:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=1VHwLShzu/WQrTQ00kOzSWt5/ak691jXQCt3nHzKI4s=;
 b=jmBCctYwrZHz6Zzy4bopT8jvvqZaJYFF3c0PRQdpYeNb6ySX8E3xgnl7Ltie+hyVPrXT
 HriT+TgHMVKeXLCXIwurwezWBI8nIwe8xuv0BTWV2ThW4dGZsugjZR7dDNsdIXMimjo2
 zX3JH0Ju7m9DagaGRwG6ayi0XLCzBMkDcg28accHahmzDrE+MvupERlcnsqfK/iRm1Ar
 xE9jO+xRhqOj6LizyOV3DvCQ3pQO2xgPbZva/4pBD34RItisl/QN7G6jJxmLEY9RW7xM
 PiGASH3RvsFH3ESHHhEptdVBJigxAysnxHgajKjmIy5asgmV/DbVf4zZI/lPuqTdSj3o WA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2v3vb501qt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:29:58 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILEvlm195916;
	Wed, 18 Sep 2019 21:29:58 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2v3vb40r69-54
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:29:58 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8ILEese004299;
	Wed, 18 Sep 2019 21:14:40 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 14:14:40 -0700
Date: Wed, 18 Sep 2019 14:14:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH v2 1/5] fs: Introduce i_blocks_per_page
Message-ID: <20190918211439.GB2229799@magnolia>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821003039.12555-2-willy@infradead.org>
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

On Tue, Aug 20, 2019 at 05:30:35PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> This helper is useful for both large pages in the page cache and for
> supporting block size larger than page size.  Convert some example
> users (we have a few different ways of writing this idiom).
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Seems pretty straightforward, modulo whatever's going on with the kbuild
robot complaint (is there something wrong, or is it just that obnoxious
header check thing?)

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/iomap/buffered-io.c  |  4 ++--
>  fs/jfs/jfs_metapage.c   |  2 +-
>  fs/xfs/xfs_aops.c       |  8 ++++----
>  include/linux/pagemap.h | 13 +++++++++++++
>  4 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
> index e25901ae3ff4..0e76a4b6d98a 100644
> --- a/fs/iomap/buffered-io.c
> +++ b/fs/iomap/buffered-io.c
> @@ -24,7 +24,7 @@ iomap_page_create(struct inode *inode, struct page *page)
>  {
>  	struct iomap_page *iop = to_iomap_page(page);
>  
> -	if (iop || i_blocksize(inode) == PAGE_SIZE)
> +	if (iop || i_blocks_per_page(inode, page) <= 1)
>  		return iop;
>  
>  	iop = kmalloc(sizeof(*iop), GFP_NOFS | __GFP_NOFAIL);
> @@ -128,7 +128,7 @@ iomap_set_range_uptodate(struct page *page, unsigned off, unsigned len)
>  	bool uptodate = true;
>  
>  	if (iop) {
> -		for (i = 0; i < PAGE_SIZE / i_blocksize(inode); i++) {
> +		for (i = 0; i < i_blocks_per_page(inode, page); i++) {
>  			if (i >= first && i <= last)
>  				set_bit(i, iop->uptodate);
>  			else if (!test_bit(i, iop->uptodate))
> diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
> index a2f5338a5ea1..176580f54af9 100644
> --- a/fs/jfs/jfs_metapage.c
> +++ b/fs/jfs/jfs_metapage.c
> @@ -473,7 +473,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
>  	struct inode *inode = page->mapping->host;
>  	struct bio *bio = NULL;
>  	int block_offset;
> -	int blocks_per_page = PAGE_SIZE >> inode->i_blkbits;
> +	int blocks_per_page = i_blocks_per_page(inode, page);
>  	sector_t page_start;	/* address of page in fs blocks */
>  	sector_t pblock;
>  	int xlen;
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index f16d5f196c6b..102cfd8a97d6 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -68,7 +68,7 @@ xfs_finish_page_writeback(
>  		mapping_set_error(inode->i_mapping, -EIO);
>  	}
>  
> -	ASSERT(iop || i_blocksize(inode) == PAGE_SIZE);
> +	ASSERT(iop || i_blocks_per_page(inode, bvec->bv_page) <= 1);
>  	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
>  
>  	if (!iop || atomic_dec_and_test(&iop->write_count))
> @@ -839,7 +839,7 @@ xfs_aops_discard_page(
>  			page, ip->i_ino, offset);
>  
>  	error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
> -			PAGE_SIZE / i_blocksize(inode));
> +			i_blocks_per_page(inode, page));
>  	if (error && !XFS_FORCED_SHUTDOWN(mp))
>  		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
>  out_invalidate:
> @@ -877,7 +877,7 @@ xfs_writepage_map(
>  	uint64_t		file_offset;	/* file offset of page */
>  	int			error = 0, count = 0, i;
>  
> -	ASSERT(iop || i_blocksize(inode) == PAGE_SIZE);
> +	ASSERT(iop || i_blocks_per_page(inode, page) <= 1);
>  	ASSERT(!iop || atomic_read(&iop->write_count) == 0);
>  
>  	/*
> @@ -886,7 +886,7 @@ xfs_writepage_map(
>  	 * one.
>  	 */
>  	for (i = 0, file_offset = page_offset(page);
> -	     i < (PAGE_SIZE >> inode->i_blkbits) && file_offset < end_offset;
> +	     i < i_blocks_per_page(inode, page) && file_offset < end_offset;
>  	     i++, file_offset += len) {
>  		if (iop && !test_bit(i, iop->uptodate))
>  			continue;
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index cf837d313b96..2728f20fbc49 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -644,4 +644,17 @@ static inline unsigned long dir_pages(struct inode *inode)
>  			       PAGE_SHIFT;
>  }
>  
> +/**
> + * i_blocks_per_page - How many blocks fit in this page.
> + * @inode: The inode which contains the blocks.
> + * @page: The (potentially large) page.
> + *
> + * Context: Any context.
> + * Return: The number of filesystem blocks covered by this page.
> + */
> +static inline
> +unsigned int i_blocks_per_page(struct inode *inode, struct page *page)
> +{
> +	return page_size(page) >> inode->i_blkbits;
> +}
>  #endif /* _LINUX_PAGEMAP_H */
> -- 
> 2.23.0.rc1
> 

