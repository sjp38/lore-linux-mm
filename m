Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15051C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C06F22166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:49:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="z6RbRebk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C06F22166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23ECF8E00E9; Thu, 11 Jul 2019 11:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EFC08E00DB; Thu, 11 Jul 2019 11:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B8C28E00E9; Thu, 11 Jul 2019 11:49:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD05D8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:49:24 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id d139so1260566vsc.14
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j215i1F+Cj1jBxpyc5Dg9ssCRZ6c6YYT+7Y2PbtLI6Y=;
        b=gP52rqqktJPQaRzynoc9iRhfSv/HxZZOzE5w3V3v5J1w/EqFgwfYSM9IfF7z1RxTjk
         XfLTXDATOKLZfWplgW69akE3XLJ6gv78d721hXM8S+4mIzl69V25HoIGEd1iH2WVWu5w
         gyvu6AVjljIHPAWgs0cXheAAJbPXr665U7vkBzIY+yhe7lulO8bhObRMIDKMCYMKrjeV
         UWhOdELkHKzqHVfVNjGnETzTiF+YirjyGomawqdkPY6Qc301+avmJcf995h5SmKHiL9K
         WtQ1FofMGlbhdkCsnjYlXNnpgq3bgrHL7YmgWxt8reW4qG/nfLkoXbS74uE20FPK7fpx
         NuPA==
X-Gm-Message-State: APjAAAVOR+pTPcZCCP7g+EDjX3l2hXxcWam2FdU7n7YKBBmnvX2tXfBt
	lD/61u9G0xCN26QigTQrSWnlSx+k1i4QaQdThk+wzXVdC0N4ykfvq2/MOLFw9hwLxN4a8iXrvWT
	klEa2yJ3NTxjNzIyMi9iQko5cTAkCbK/OdGkzSOksGBo44MdnmTVJPukCS1DMsi7WlA==
X-Received: by 2002:ab0:2a0c:: with SMTP id o12mr5374252uar.122.1562860164583;
        Thu, 11 Jul 2019 08:49:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx04kNrSKNaLePkk4gKyOqKFm7OXACN9czdEO4owVHUkYUgqr/BEii8RoSvFkLCf9iJO3W2
X-Received: by 2002:ab0:2a0c:: with SMTP id o12mr5374129uar.122.1562860163522;
        Thu, 11 Jul 2019 08:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562860163; cv=none;
        d=google.com; s=arc-20160816;
        b=w9ZMcCUhTXBLo4spOMEMLrOvca9feQ+m1spT8iUTDiuBeAgbvU/7TqpFUV7DZ8rTvX
         icj61OuypTheolwZH0BGYFPVRdpFN9wJz9sD/CUmYZmxloQ/0v6TXxXVJQLSpvsxnzFh
         ax2iJdhZcZJj6STxLqN5ciaz5fhgU7q6GN1kHggiBjppGtTaIzpNM739oEaRPFhsbIaQ
         SftAqW1q5HCzxRPIBzvJ2BKswjRZVTe6kDJQVybRDlxorMFNVFP5BGR6jIfkdAOzlakS
         M/OGUbxBgxeip9W8Tq+kDWhj8CwqzuWxcPrOASrO1Elm1aaIRZP/7OlQmDHnV3x/Gr8a
         6fXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j215i1F+Cj1jBxpyc5Dg9ssCRZ6c6YYT+7Y2PbtLI6Y=;
        b=y01LS7/IpZgLyjpBDVRh2idNOc3WF6GXh+2WbGZVtePmORNvJv4IWzwM4iGM359XJu
         fWa/yrukM5orSAILtra3rGhDHDkdcn1YWxV54R0Gt+ld2rawUZVtS/PKhVML+t2n4nNf
         E+vmEPrAMMoqJLXEr7012CB7W8BAx/qJ11cATKvpWGJAmzhyz1oGI7utxS9sv0afWsKA
         QtvOhWYD0bh5yLckThwn5052mg4b8e8JNhnQNt7xEolvKWksA8yNWcZt7n1yhtY0vL1/
         OkSIOrLxAjITSEucbntnCvEdeaWstLVge8j6Qvthz4/L1k/ffBESi9SukmXbTFXtv3H/
         +U+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z6RbRebk;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e1si1883732vkh.76.2019.07.11.08.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 08:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z6RbRebk;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BFnLRH090753;
	Thu, 11 Jul 2019 15:49:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=j215i1F+Cj1jBxpyc5Dg9ssCRZ6c6YYT+7Y2PbtLI6Y=;
 b=z6RbRebkT6c4OLvokn1VUnPBwMGXVBL3ehUeAGrovAZf3m2SBsYnUyWX/9Ln5f1Fc8zP
 cCFT5czhrjYooSuhCIFHTTNjNew0W/Tn04F2JU+eNkcWPQQnz6jXXj3oh7DDqTzOOyNJ
 TrCEkazaz6CheIOI8vB1JPRN2CH8ypKVy9dY1bGvjw6IayA9YQHEEZ5RVz4mq7RbnWSz
 mwlSPFn8bp9HpMgyvrbuxK3joacg7tHO5VM2Jin6DYFd67u+pajkL1/pX7PdHWGRusOm
 a8yjvGTK5EGQ4WpOw7+s76vlkT8eQ2J5TuRrNnLQ4pnSjHXP8R7Ii4gO0n1q/RQfxD1f rQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2tjm9r0v2d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 15:49:20 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BFlvsE011931;
	Thu, 11 Jul 2019 15:49:20 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2tmmh47snt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 15:49:19 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6BFnIMH001134;
	Thu, 11 Jul 2019 15:49:18 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Jul 2019 08:49:18 -0700
Date: Thu, 11 Jul 2019 08:49:17 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, linux-xfs <linux-xfs@vger.kernel.org>,
        Boaz Harrosh <boaz@plexistor.com>, stable <stable@vger.kernel.org>
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190711154917.GW1404256@magnolia>
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-4-jack@suse.cz>
 <CAOQ4uxh-xpwgF-wQf1ozaZ3yg8nWuBvSyLr_ZFQpkA=coW1dxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxh-xpwgF-wQf1ozaZ3yg8nWuBvSyLr_ZFQpkA=coW1dxA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907110178
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110178
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 06:28:54PM +0300, Amir Goldstein wrote:
> On Thu, Jul 11, 2019 at 5:00 PM Jan Kara <jack@suse.cz> wrote:
> >
> > Hole puching currently evicts pages from page cache and then goes on to
> > remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
> > and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
> > racing reads or page faults. However there is currently nothing that
> > prevents readahead triggered by fadvise() or madvise() from racing with
> > the hole punch and instantiating page cache page after hole punching has
> > evicted page cache in xfs_flush_unmap_range() but before it has removed
> > blocks from the inode. This page cache page will be mapping soon to be
> > freed block and that can lead to returning stale data to userspace or
> > even filesystem corruption.
> >
> > Fix the problem by protecting handling of readahead requests by
> > XFS_IOLOCK_SHARED similarly as we protect reads.
> >
> > CC: stable@vger.kernel.org
> > Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
> > Reported-by: Amir Goldstein <amir73il@gmail.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> 
> Looks sane. (I'll let xfs developers offer reviewed-by tags)
> 
> >  fs/xfs/xfs_file.c | 20 ++++++++++++++++++++
> >  1 file changed, 20 insertions(+)
> >
> > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> > index 76748255f843..88fe3dbb3ba2 100644
> > --- a/fs/xfs/xfs_file.c
> > +++ b/fs/xfs/xfs_file.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/pagevec.h>
> >  #include <linux/backing-dev.h>
> >  #include <linux/mman.h>
> > +#include <linux/fadvise.h>
> >
> >  static const struct vm_operations_struct xfs_file_vm_ops;
> >
> > @@ -939,6 +940,24 @@ xfs_file_fallocate(
> >         return error;
> >  }
> >
> > +STATIC int
> > +xfs_file_fadvise(
> > +       struct file *file,
> > +       loff_t start,
> > +       loff_t end,
> > +       int advice)

Indentation needs fixing here.

> > +{
> > +       struct xfs_inode *ip = XFS_I(file_inode(file));
> > +       int ret;
> > +
> > +       /* Readahead needs protection from hole punching and similar ops */
> > +       if (advice == POSIX_FADV_WILLNEED)
> > +               xfs_ilock(ip, XFS_IOLOCK_SHARED);

It's good to fix this race, but at the same time I wonder what's the
impact to processes writing to one part of a file waiting on IOLOCK_EXCL
while readahead holds IOLOCK_SHARED?

(bluh bluh range locks ftw bluh bluh)

Do we need a lock for DONTNEED?  I think the answer is that you have to
lock the page to drop it and that will protect us from <myriad punch and
truncate spaghetti> ... ?

> > +       ret = generic_fadvise(file, start, end, advice);
> > +       if (advice == POSIX_FADV_WILLNEED)
> > +               xfs_iunlock(ip, XFS_IOLOCK_SHARED);

Maybe it'd be better to do:

	int	lockflags = 0;

	if (advice == POSIX_FADV_WILLNEED) {
		lockflags = XFS_IOLOCK_SHARED;
		xfs_ilock(ip, lockflags);
	}

	ret = generic_fadvise(file, start, end, advice);

	if (lockflags)
		xfs_iunlock(ip, lockflags);

Just in case we some day want more or different types of inode locks?

--D

> > +       return ret;
> > +}
> >
> >  STATIC loff_t
> >  xfs_file_remap_range(
> > @@ -1235,6 +1254,7 @@ const struct file_operations xfs_file_operations = {
> >         .fsync          = xfs_file_fsync,
> >         .get_unmapped_area = thp_get_unmapped_area,
> >         .fallocate      = xfs_file_fallocate,
> > +       .fadvise        = xfs_file_fadvise,
> >         .remap_file_range = xfs_file_remap_range,
> >  };
> >
> > --
> > 2.16.4
> >

