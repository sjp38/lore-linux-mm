Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AA51C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F216B217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:29:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="E9bhYQx3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F216B217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A95FB6B000D; Thu,  4 Apr 2019 20:29:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A44AC6B000E; Thu,  4 Apr 2019 20:29:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90C976B026B; Thu,  4 Apr 2019 20:29:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 512BC6B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 20:29:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m37so2877419plg.22
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 17:29:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uaeA4mehYWLm3W6213n3D3TB8vOpPLTkH5cNKfq8CC8=;
        b=EjLKzNGGNPAsuoeZ51x+FvDbp0PEON1T+NOzAHjpeao4ayegZthdWrpJu2iEP/BulH
         p/SzsVd/tToZnzDpXXdjFh/8hOEAo96V3HzCfZglchbVxKJPZGpEQnNJ9yX4Ix4Tc6Km
         3dHlf87/fQw9jpwSYMlkxpx+imrJKrMZMkUDfNDpfg48qYYDx6d8Ki9DRBlTpUS8eokx
         KyZdI+ZiM8+y6Um9QPONMozXEitHJ2L+fqVsTHdUyUKZOFjO9/CGGFUtb+sV4So8na+G
         6bhIRq40l9XSLEc842H0mIhZ2E8NYYMYhb/PFGGUpAc9Aau/n4o+dnADGj7iCbpvPSQU
         SKdw==
X-Gm-Message-State: APjAAAVjyOET3354Q4BuJFS+kNIOICWlX4yBdK9o0OW09xegoR+ViROw
	s3rFn1zHiU8GKOWWkMa88oJ5UGKuhjkSF0Pbk0dRx26joNBVLrWvg5uf8kAVofnvXgUbI8qB9Nw
	Bo5aiBvRwkbwIIrI4w45NSbyL3hGmsM3RQ8AyS0mA1mFb4vUVLDg9T+NRTrsL/Rc6zQ==
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr9169920pfi.6.1554424177826;
        Thu, 04 Apr 2019 17:29:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU//dUBOq2SKsU11ss5S2EycGCgpV2q5KFpw/b4zb/bsl3nUfi8Z2tBGvPHtLFnf+8pN8q
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr9169836pfi.6.1554424176807;
        Thu, 04 Apr 2019 17:29:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554424176; cv=none;
        d=google.com; s=arc-20160816;
        b=dtoHxOkB6p7jZ1qNPAy+NCQQXzer/O2sQPN0jFnVDlOsM9f+K+RgwiWnhr6ZFgB6hh
         2OzWzDFLYdQQ+xWf+6IJt/4pbi28LK4Arj0QfXiS+wM4WbPzsUlwDCoelYdx3fx0xxIJ
         Nz7G+LtU1ksFtcVCqM28ardAQhpevIL7dSKsr/7p4xOioeaSmx215iU0f1wJZyK9lBG9
         NZLjwoXUiHbLqyNazMCBJUx73pzAxc+JrVrBQ591pXVW9dE9sF+AYk8GZt8zz0ctswBA
         uThrIvQ+f+DuKt3scxkKFzb7qYKOF1OoX/8OnV+lUYgNv60Q2tbgLz2b2m7pbYTFCxOT
         JKGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uaeA4mehYWLm3W6213n3D3TB8vOpPLTkH5cNKfq8CC8=;
        b=1DpXHpOopthoSiNbAZKVHc2NbXiDD1HKFhaddGPNg6ksOJjAvHLcI9+7Xh0jynD1Zs
         vMeOs31j7S88QGAeRgCFFC2tRDMED3uI2qSJhXCRGdK//7Il2zAUa5cArz4s8Rw+GeMx
         ZKEMKzwcEcOCxo0huqYu5PY2AstlJBqW2WM7Q5tuPv6/8Fv36Su/33yG6bUxmMhBBxZx
         ZhO4tP7+C+cdSkpZn0lnGd2I/ffPetUWVyebY6zAYL9LK6IjjK2kGDUcKf+jNg4AmbOL
         sFM/QIM150xm6lVQFUd2FNiJ826S7sMpr+Aj4hbrPu3L1/HrFr4CPP1drH62oouO29FG
         V/Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=E9bhYQx3;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h185si17207067pfc.241.2019.04.04.17.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 17:29:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=E9bhYQx3;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x350ScJf100391;
	Fri, 5 Apr 2019 00:29:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=uaeA4mehYWLm3W6213n3D3TB8vOpPLTkH5cNKfq8CC8=;
 b=E9bhYQx3BITlLJG+TdN55WXHsQSdWBFPdOuB23O4nt+PPWnZ7HONQh27pPn0ThxSFsnt
 2AfY5E4a7x96xtGcneoMC6Ong87Efa4l4rVB3Amauztmq6AR+qNH4qDZhX5BcCBrtwT5
 ocX10QfITWTI3p73dJdQ4jYW3Gk6fMGey8eixbeQ/GAOhZ2/GhBGbAVRLhsXcAcZc+Hd
 9xAgRnXHTI2zsbql6YdmLyZrDWg1x7VTRGdr6F3osHFyE0xjnwp2zdnsm+ILsb/TTaWK
 EgVDDvYDqXDbZfqvGTvrx/u/zNLRj2CTLF1jlh6VE0+WT5eUwe/NxoNQpMrxVbbe7UhW jw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2rj13qj2wm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 00:29:35 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x350SHXW059204;
	Fri, 5 Apr 2019 00:29:35 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2rm8f5yhxs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 00:29:35 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x350TXji008924;
	Fri, 5 Apr 2019 00:29:34 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 17:29:33 -0700
Date: Thu, 4 Apr 2019 17:29:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 2/3] xfs: reset page mappings after setting immutable
Message-ID: <20190405002929.GD1177@magnolia>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
 <155379544747.24796.1807309281507099911.stgit@magnolia>
 <20190328212147.GK23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328212147.GK23020@dastard>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904050002
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904050002
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 08:21:47AM +1100, Dave Chinner wrote:
> On Thu, Mar 28, 2019 at 10:50:47AM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > The chattr manpage has this to say about immutable files:
> > 
> > "A file with the 'i' attribute cannot be modified: it cannot be deleted
> > or renamed, no link can be created to this file, most of the file's
> > metadata can not be modified, and the file can not be opened in write
> > mode."
> > 
> > This means that we need to flush the page cache when setting the
> 
> nit: flush and invalidate the page cache.
> 
> > immutable flag so that programs cannot continue to write to writable
> > mappings.
> 
> Do we even need to invalidate the page cache for this? i.e. we've
> cleaned the pages so that any new write to them will fault,
> that will see the immutable flag via ->page_mkwrite and then the
> app should segv, right?

Yeah, we only need to flush the pages.  No need to invalidate.

> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/xfs/xfs_ioctl.c |   63 +++++++++++++++++++++++++++++++++++-----------------
> >  1 file changed, 43 insertions(+), 20 deletions(-)
> > 
> > 
> > diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> > index 6ecdbb3af7de..2bd1c5ab5008 100644
> > --- a/fs/xfs/xfs_ioctl.c
> > +++ b/fs/xfs/xfs_ioctl.c
> > @@ -998,6 +998,37 @@ xfs_diflags_to_linux(
> >  #endif
> >  }
> >  
> > +static int
> > +xfs_ioctl_setattr_flush(
> > +	struct xfs_inode	*ip,
> > +	int			*join_flags)
> > +{
> > +	struct inode		*inode = VFS_I(ip);
> > +	int			error;
> > +
> > +	if (S_ISDIR(inode->i_mode))
> > +		return 0;
> > +	if ((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
> > +		return 0;
> > +
> > +	/* lock, flush and invalidate mapping in preparation for flag change */
> > +	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> > +	error = filemap_write_and_wait(inode->i_mapping);
> > +	if (error)
> > +		goto out_unlock;
> > +	error = invalidate_inode_pages2(inode->i_mapping);
> > +	if (error)
> > +		goto out_unlock;
> > +
> > +	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
> > +	return 0;
> > +
> > +out_unlock:
> > +	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> > +	return error;
> > +
> > +}
> 
> Doesn't wait for direct IO to drain. Wouldn't it be better to do
> this?
> 
> 	lock()
> 	xfs_flush_unmap_range(ip, 0, XFS_SIZE(ip));
> 	unlock()

But if we only need to filemap_write_and_wait, then calling flush_unmap
(which also calls truncate_pagecache_range) is too much work.

--D

> 
> Otherwise looks ok.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

