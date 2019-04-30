Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C52C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9701321670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PWmwqwnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9701321670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DC316B0005; Tue, 30 Apr 2019 11:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2661E6B0008; Tue, 30 Apr 2019 11:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B8296B000A; Tue, 30 Apr 2019 11:33:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF45D6B0005
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:33:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o8so9250343pgq.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E1N7i2/XGYSszDfFaE6hIiWMezb6L1pK4BEiaM0LVCs=;
        b=ZrdleEEgaNdk7K4OZFdneL9QL7YXAzhmTRcEbVPyLfmKFad2f00lsogds2oAAUdSCa
         MD7biQvFskQEfV0RF4M82+9pmxQYmHN2NQZlGkDtoap865KmMKEMgfkZwnJbgn2AkeT0
         wlrt2sWsbC1Py5+sxRoQoaHtoQ0GXOoGiTLycE07KICyc+4jBZn4jOdvW+2TMHGd2yAb
         ZxdeF3m5F9FcvutF3e47wj1QIDwEWrQIEbgyE5wZpibVohi7EVf98/L+kSHuxSAQRFvV
         58QkCEaWzNTID/szU4aWCsJmyo6x66IHkRRbum7xsMDsCy2GkcIpx0fOcp+Hx7cY5Iob
         QuYw==
X-Gm-Message-State: APjAAAUCYx+WxnFvKi3OtzJzl9TYyoNS8nI9ndhbB2z8gc99l6INxXos
	U3qAI2FqdXee7peZTmf1agf/gCfH8mxw7oSmevNBTKbzb+g8goYLKfX2B0TWcgT23h/YHTsbQxX
	O8FHXqPMOIUxkrQMACnbUkV2ynxW6wa8JWTeE2RAFWSbV/DC/+w7/9Y0lZtdGOO44HA==
X-Received: by 2002:a17:902:28a9:: with SMTP id f38mr69491053plb.295.1556638388404;
        Tue, 30 Apr 2019 08:33:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh3rlsdDqCdxPc6XdhGx0j+T7QlI5zuzIOex4cKOe41Ulcdrv1tUl/KqJcBhnr99b6s47J
X-Received: by 2002:a17:902:28a9:: with SMTP id f38mr69490933plb.295.1556638387387;
        Tue, 30 Apr 2019 08:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556638387; cv=none;
        d=google.com; s=arc-20160816;
        b=H7vKQ0lQp/DRfd3k1fziN+5tg7vuicPjnXJg0k3BzkdRHiK7nX7ar1WHUa8PhfVpdc
         Glz3vThUIKq75MF6v6ts6p1ATWkFWsqk8c2RdAz6KbomAyIwOLwP2GKVBTHaGqvL4mJ9
         tAviVTcYb/gnxionTYEhYCHwoWkKaN2vH2RCMw385b4/b99oG+jA1X6mxQVdk5IL1pog
         9edES9QQ7Ia161J9WXD5uVTJ+4EyBHuJf9LjixFSMCpw5juJAIugtsQIWlaIoZNPVt1m
         LcQ+oG7wVSYVLkvl7qoQb/OQ9AHKpi0DMT7Ny2DtA0AKDl3pimsnaUz+fT6HKhKKLs+r
         mnPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=E1N7i2/XGYSszDfFaE6hIiWMezb6L1pK4BEiaM0LVCs=;
        b=VwLqVjeTe+PA7CklQS2b8Cv2BIEW8oSCZc7c8HYZdGGATSMsADg93hCUwi1oEydtji
         up0B3A00El5eqEPe7mkr9HtXg2+03abv6BX2s/jkjftBO6bJcw06dBpHLmmzsS9B3L0k
         GmqH/HaSBXQWhYrQOzYniQ6+ywZlyOUWWrIvkjKxR/QwhZpGtKEppKmqo2uX4CmS1LMO
         3agKfi3HluTbiuopKZxsEpo7XVGuuXi8bEm8fLzNvDk0Oasxalz2xGIzcHwyuAkeOKAD
         +7ckrXUmzf4gaZAfJdZGhwxqR8VJVCtQdP7c6sj2DXgqABuMRPIBO4/r4dpBgwwXHvZp
         Fjmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PWmwqwnD;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h189si39301214pfc.283.2019.04.30.08.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 08:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PWmwqwnD;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFOBM9132005;
	Tue, 30 Apr 2019 15:33:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=E1N7i2/XGYSszDfFaE6hIiWMezb6L1pK4BEiaM0LVCs=;
 b=PWmwqwnDWFUihe1VVrUAyd5EXMuLqkncuSn5rMLjZ4BUdj2mkH1meyAyZQ3s45cZFPur
 ME0HEli7rLhsinwnN+GN5JYe7Yn1yRQzJ17Q6Tneo6DyJMv5M8i9cUSy9KZxDuaqOlKh
 meHEjnSou20VUZmznrgv68ZtpJ7RhPR1uW6PBoFbpcI9bR3yJOioTN+3CL0jXTNQISJz
 RMyYSC1+OdAq5Fp9J5JI0eksl1hPN2Jl70cEbTrmyjPlycYxBgsgW/aSKDwxK7BW/cgk
 n+AUr7eGz/UbSMQVbAcIu37IOadC3qWYLhsjx6KXLRi4vD2S2yXREGrhAWoxWGdpxDWw dw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2s4fqq58uj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:33:01 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UFWhX5109947;
	Tue, 30 Apr 2019 15:33:00 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2s4d4ak8ny-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 15:33:00 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3UFWwXb016341;
	Tue, 30 Apr 2019 15:32:58 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Apr 2019 08:32:58 -0700
Date: Tue, 30 Apr 2019 08:32:56 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
        Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Chinner <david@fromorbit.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 5/5] gfs2: Fix iomap write page reclaim deadlock
Message-ID: <20190430153256.GF5200@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190429220934.10415-6-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190429220934.10415-6-agruenba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300095
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:34AM +0200, Andreas Gruenbacher wrote:
> Since commit 64bc06bb32ee ("gfs2: iomap buffered write support"), gfs2 is doing
> buffered writes by starting a transaction in iomap_begin, writing a range of
> pages, and ending that transaction in iomap_end.  This approach suffers from
> two problems:
> 
>   (1) Any allocations necessary for the write are done in iomap_begin, so when
>   the data aren't journaled, there is no need for keeping the transaction open
>   until iomap_end.
> 
>   (2) Transactions keep the gfs2 log flush lock held.  When
>   iomap_file_buffered_write calls balance_dirty_pages, this can end up calling
>   gfs2_write_inode, which will try to flush the log.  This requires taking the
>   log flush lock which is already held, resulting in a deadlock.

/me wonders how holding the log flush lock doesn't seriously limit
performance, but gfs2 isn't my fight so I'll set that aside and assume
that a patch S-o-B'd by both maintainers is ok. :)

How should we merge this patch #5?  It doesn't touch fs/iomap.c itself,
so do you want me to pull it into the iomap branch along with the
previous four patches?  That would be fine with me (and easier than a
multi-tree merge mess)...

--D

> 
> Fix both of these issues by not keeping transactions open from iomap_begin to
> iomap_end.  Instead, start a small transaction in page_prepare and end it in
> page_done when necessary.
> 
> Reported-by: Edwin Török <edvin.torok@citrix.com>
> Fixes: 64bc06bb32ee ("gfs2: iomap buffered write support")
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Signed-off-by: Bob Peterson <rpeterso@redhat.com>
> ---
>  fs/gfs2/aops.c | 14 +++++---
>  fs/gfs2/bmap.c | 88 +++++++++++++++++++++++++++-----------------------
>  2 files changed, 58 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
> index 05dd78f4b2b3..6210d4429d84 100644
> --- a/fs/gfs2/aops.c
> +++ b/fs/gfs2/aops.c
> @@ -649,7 +649,7 @@ static int gfs2_readpages(struct file *file, struct address_space *mapping,
>   */
>  void adjust_fs_space(struct inode *inode)
>  {
> -	struct gfs2_sbd *sdp = inode->i_sb->s_fs_info;
> +	struct gfs2_sbd *sdp = GFS2_SB(inode);
>  	struct gfs2_inode *m_ip = GFS2_I(sdp->sd_statfs_inode);
>  	struct gfs2_inode *l_ip = GFS2_I(sdp->sd_sc_inode);
>  	struct gfs2_statfs_change_host *m_sc = &sdp->sd_statfs_master;
> @@ -657,10 +657,13 @@ void adjust_fs_space(struct inode *inode)
>  	struct buffer_head *m_bh, *l_bh;
>  	u64 fs_total, new_free;
>  
> +	if (gfs2_trans_begin(sdp, 2 * RES_STATFS, 0) != 0)
> +		return;
> +
>  	/* Total up the file system space, according to the latest rindex. */
>  	fs_total = gfs2_ri_total(sdp);
>  	if (gfs2_meta_inode_buffer(m_ip, &m_bh) != 0)
> -		return;
> +		goto out;
>  
>  	spin_lock(&sdp->sd_statfs_spin);
>  	gfs2_statfs_change_in(m_sc, m_bh->b_data +
> @@ -675,11 +678,14 @@ void adjust_fs_space(struct inode *inode)
>  	gfs2_statfs_change(sdp, new_free, new_free, 0);
>  
>  	if (gfs2_meta_inode_buffer(l_ip, &l_bh) != 0)
> -		goto out;
> +		goto out2;
>  	update_statfs(sdp, m_bh, l_bh);
>  	brelse(l_bh);
> -out:
> +out2:
>  	brelse(m_bh);
> +out:
> +	sdp->sd_rindex_uptodate = 0;
> +	gfs2_trans_end(sdp);
>  }
>  
>  /**
> diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
> index aa014725f84a..27c82f4aaf32 100644
> --- a/fs/gfs2/bmap.c
> +++ b/fs/gfs2/bmap.c
> @@ -991,17 +991,28 @@ static void gfs2_write_unlock(struct inode *inode)
>  	gfs2_glock_dq_uninit(&ip->i_gh);
>  }
>  
> +static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
> +				   unsigned len, struct iomap *iomap)
> +{
> +	struct gfs2_sbd *sdp = GFS2_SB(inode);
> +
> +	return gfs2_trans_begin(sdp, RES_DINODE + (len >> inode->i_blkbits), 0);
> +}
> +
>  static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
>  				 unsigned copied, struct page *page,
>  				 struct iomap *iomap)
>  {
>  	struct gfs2_inode *ip = GFS2_I(inode);
> +	struct gfs2_sbd *sdp = GFS2_SB(inode);
>  
> -	if (page)
> +	if (page && !gfs2_is_stuffed(ip))
>  		gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
> +	gfs2_trans_end(sdp);
>  }
>  
>  static const struct iomap_page_ops gfs2_iomap_page_ops = {
> +	.page_prepare = gfs2_iomap_page_prepare,
>  	.page_done = gfs2_iomap_page_done,
>  };
>  
> @@ -1057,31 +1068,45 @@ static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
>  	if (alloc_required)
>  		rblocks += gfs2_rg_blocks(ip, data_blocks + ind_blocks);
>  
> -	ret = gfs2_trans_begin(sdp, rblocks, iomap->length >> inode->i_blkbits);
> -	if (ret)
> -		goto out_trans_fail;
> +	if (unstuff || iomap->type == IOMAP_HOLE) {
> +		struct gfs2_trans *tr;
>  
> -	if (unstuff) {
> -		ret = gfs2_unstuff_dinode(ip, NULL);
> +		ret = gfs2_trans_begin(sdp, rblocks,
> +				       iomap->length >> inode->i_blkbits);
>  		if (ret)
> -			goto out_trans_end;
> -		release_metapath(mp);
> -		ret = gfs2_iomap_get(inode, iomap->offset, iomap->length,
> -				     flags, iomap, mp);
> -		if (ret)
> -			goto out_trans_end;
> -	}
> +			goto out_trans_fail;
>  
> -	if (iomap->type == IOMAP_HOLE) {
> -		ret = gfs2_iomap_alloc(inode, iomap, flags, mp);
> -		if (ret) {
> -			gfs2_trans_end(sdp);
> -			gfs2_inplace_release(ip);
> -			punch_hole(ip, iomap->offset, iomap->length);
> -			goto out_qunlock;
> +		if (unstuff) {
> +			ret = gfs2_unstuff_dinode(ip, NULL);
> +			if (ret)
> +				goto out_trans_end;
> +			release_metapath(mp);
> +			ret = gfs2_iomap_get(inode, iomap->offset,
> +					     iomap->length, flags, iomap, mp);
> +			if (ret)
> +				goto out_trans_end;
> +		}
> +
> +		if (iomap->type == IOMAP_HOLE) {
> +			ret = gfs2_iomap_alloc(inode, iomap, flags, mp);
> +			if (ret) {
> +				gfs2_trans_end(sdp);
> +				gfs2_inplace_release(ip);
> +				punch_hole(ip, iomap->offset, iomap->length);
> +				goto out_qunlock;
> +			}
>  		}
> +
> +		tr = current->journal_info;
> +		if (tr->tr_num_buf_new)
> +			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +		else
> +			gfs2_trans_add_meta(ip->i_gl, mp->mp_bh[0]);
> +
> +		gfs2_trans_end(sdp);
>  	}
> -	if (!gfs2_is_stuffed(ip) && gfs2_is_jdata(ip))
> +
> +	if (gfs2_is_stuffed(ip) || gfs2_is_jdata(ip))
>  		iomap->page_ops = &gfs2_iomap_page_ops;
>  	return 0;
>  
> @@ -1121,10 +1146,6 @@ static int gfs2_iomap_begin(struct inode *inode, loff_t pos, loff_t length,
>  		    iomap->type != IOMAP_MAPPED)
>  			ret = -ENOTBLK;
>  	}
> -	if (!ret) {
> -		get_bh(mp.mp_bh[0]);
> -		iomap->private = mp.mp_bh[0];
> -	}
>  	release_metapath(&mp);
>  	trace_gfs2_iomap_end(ip, iomap, ret);
>  	return ret;
> @@ -1135,27 +1156,16 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
>  {
>  	struct gfs2_inode *ip = GFS2_I(inode);
>  	struct gfs2_sbd *sdp = GFS2_SB(inode);
> -	struct gfs2_trans *tr = current->journal_info;
> -	struct buffer_head *dibh = iomap->private;
>  
>  	if ((flags & (IOMAP_WRITE | IOMAP_DIRECT)) != IOMAP_WRITE)
>  		goto out;
>  
> -	if (iomap->type != IOMAP_INLINE) {
> +	if (!gfs2_is_stuffed(ip))
>  		gfs2_ordered_add_inode(ip);
>  
> -		if (tr->tr_num_buf_new)
> -			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> -		else
> -			gfs2_trans_add_meta(ip->i_gl, dibh);
> -	}
> -
> -	if (inode == sdp->sd_rindex) {
> +	if (inode == sdp->sd_rindex)
>  		adjust_fs_space(inode);
> -		sdp->sd_rindex_uptodate = 0;
> -	}
>  
> -	gfs2_trans_end(sdp);
>  	gfs2_inplace_release(ip);
>  
>  	if (length != written && (iomap->flags & IOMAP_F_NEW)) {
> @@ -1175,8 +1185,6 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
>  	gfs2_write_unlock(inode);
>  
>  out:
> -	if (dibh)
> -		brelse(dibh);
>  	return 0;
>  }
>  
> -- 
> 2.20.1
> 

