Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0353DC4646C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 03:05:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE7DA20663
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 03:05:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BXJlUqAK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE7DA20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37B038E0003; Mon, 24 Jun 2019 23:05:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32B4C8E0002; Mon, 24 Jun 2019 23:05:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F2EE8E0003; Mon, 24 Jun 2019 23:05:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id F24268E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 23:05:06 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z19so7012900ioi.15
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y1nTqvm5zm2oVuuxHsrGpbU4gEqHpmqSXspC8Bne9NM=;
        b=WaYDqgr85iML2ZTslt/HQPemYY1dTQt9NXZjBuIiuO6HPVF+Pmx56ScUPNVeywProO
         cvSJhFeKFkmGd3YVIa6m/Z/tubQMttPfj4g4BMiDwcUWktWRM4WqwWlXgdLHCdSkBQHt
         pUgC30Njf3v71K9C3ZzsnMpKoK6WZdsAdNRbHrFokW/y2UoJr8G0Z2u4vzTiuDVrtvOB
         xoF7MOo1BPLJx1kbvJfDe6YRHnvyTzPguHbCt4OIfJINz7K7mkd5GZGy1phctRUH1EnH
         6zCjHOc4IZdx2puypteo3pfPoyreXaX6HvzETqnwzreFr8GTauyZjfbSTdXR4JcFQxP9
         5ezQ==
X-Gm-Message-State: APjAAAXDwp7oVaTQQbrFgrZ1H5Jxl3/kvCqgKsKjuppRBOGVnePf2qeo
	ktsI9w4zamzKDv6uTDW3w68UKEOF1VaBhNg9FERxuKwZc6B4yr3NGcV5PNWwVgEqTEyX3i+Wg2O
	9vPFxmdxyLxPt8fFT2waukgtsKanT8CkyZdV5lnhOHvAuT5CMHqxroTzPQrJVoCdo3Q==
X-Received: by 2002:a6b:8bce:: with SMTP id n197mr21074259iod.299.1561431906727;
        Mon, 24 Jun 2019 20:05:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygAcQ3URQsvKNl7ciGH3JLvSJWK1sPBHP8bBh6xvn9yWJ7dy3NrICx3JnP7Fkd38JHuQKX
X-Received: by 2002:a6b:8bce:: with SMTP id n197mr21074195iod.299.1561431905896;
        Mon, 24 Jun 2019 20:05:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561431905; cv=none;
        d=google.com; s=arc-20160816;
        b=PVgLG3gnC8gArcSz7Fsar7fomsvjMs11OPjyaW2n+GK/8CHueba1KzMIX90en+kqVU
         Fnr63ohlPtm/m3M5nukB/L4l6s061S1frVD3zen3LNEbiQLPUfBc4X+ZPizrfdP1ZC34
         3EqRj2ism0ZeaLmw9kjYzKac0iXC/4y3ZneC+3c9FHWc3mKOeR6JLH1JSNHYfVWUT1zr
         MIt2hOZW4nejzuXYgJWLg5ZYuDVWmUa/jT4ZUmauzB9mGOh1w8cZhoGaCPNLRDqRpGj3
         gFvK1RWM/9tLK1OiMfmt3Sa28GSFtORVQu8ZzdXdOA2EWYkgWqpXy9hdXfKycolWpEyA
         6m2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y1nTqvm5zm2oVuuxHsrGpbU4gEqHpmqSXspC8Bne9NM=;
        b=OE0NIUHNDvEqkxdkqV2C7N1oRyhkTMyWQ35gApBDRQDJIkDboBDZVEq2UydO0VO+E/
         s2XZpMn9UGn7FtkJrsrisdW7p1olu95Fp7FG20/pCkgeZfnJC1Usyvy8Bc+7umq5MnzD
         awwCRiNv2uvurt2qq2AmnHIE3PHbE+OSl1qS9XUrmOF0twUjNdt1X3b5p0TX42nr34T9
         qGc92KnxMmSOsEaxUqXJECMXEsewUrWCBYEMdXwnl2Nda/GwzWFeJkSpP0HWAqAvTGjl
         MPxZe9e5fhNL22b2rypGnoiS2kxqujXF+a65jzKgLrBcgY6LWBcotwMz8bLdkCkM6l18
         I3DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BXJlUqAK;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i12si20450989jal.125.2019.06.24.20.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 20:05:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BXJlUqAK;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5P2xZkP183824;
	Tue, 25 Jun 2019 03:04:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=y1nTqvm5zm2oVuuxHsrGpbU4gEqHpmqSXspC8Bne9NM=;
 b=BXJlUqAKvMETApXDcsKgEZiNdrmlXkQGnY88kMW3AMxNKcXyyaE6UXAlpYECy+ntv7pH
 6uhEP1tj4tycY9LMVwQSwCJ1OFoN8XiURaWWP5MgMDhRGeWBYKJ5F+hDMXeWyXvzw09Y
 W93kGqDhXdEUxHJGprg0ZqzGMSQuXc6a6uPIBselde0/QnSPFrNudLSF4JrDCRjZHlSe
 PtPwNFzZ3qhrAqfZeA252/OTt3UOJ6W5XclgLFaB43nqCHJq7hk5QCcLKtksxGRz16et
 vcWpg2Ca0sMBi64yleW6uVf2BPJY2qw2eabFh6Nu+9cNmwvp3CwrP4l2harCRSOmeEeb 1g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t9brt1hg7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 25 Jun 2019 03:04:56 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5P34h96101926;
	Tue, 25 Jun 2019 03:04:55 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6tx2qw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 25 Jun 2019 03:04:55 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5P34tbP102400;
	Tue, 25 Jun 2019 03:04:55 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t9p6tx2qp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 25 Jun 2019 03:04:54 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5P34gx0001788;
	Tue, 25 Jun 2019 03:04:42 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 24 Jun 2019 20:04:41 -0700
Date: Mon, 24 Jun 2019 20:04:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-efi@vger.kernel.org, linux-btrfs@vger.kernel.org, yuchao0@huawei.com,
        linux-mm@kvack.org, clm@fb.com, adilger.kernel@dilger.ca,
        matthew.garrett@nebula.com, linux-nilfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, devel@lists.orangefs.org,
        josef@toxicpanda.com, reiserfs-devel@vger.kernel.org,
        viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org,
        tytso@mit.edu, ard.biesheuvel@linaro.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        jk@ozlabs.org, jack@suse.com, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com
Subject: Re: [Ocfs2-devel] [PATCH 2/7] vfs: flush and wait for io when
 setting the immutable flag via SETFLAGS
Message-ID: <20190625030439.GA5379@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116142734.1664939.5074567130774423066.stgit@magnolia>
 <20190624113737.GG32376@quack2.suse.cz>
 <20190624215817.GE1611011@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624215817.GE1611011@magnolia>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9298 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906250023
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:58:17PM -0700, Darrick J. Wong wrote:
> On Mon, Jun 24, 2019 at 01:37:37PM +0200, Jan Kara wrote:
> > On Fri 21-06-19 16:57:07, Darrick J. Wong wrote:
> > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > 
> > > When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
> > > need to ensure that userspace can't continue to write the file after the
> > > file becomes immutable.  To make that happen, we have to flush all the
> > > dirty pagecache pages to disk to ensure that we can fail a page fault on
> > > a mmap'd region, wait for pending directio to complete, and hope the
> > > caller locked out any new writes by holding the inode lock.
> > > 
> > > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Seeing the way this worked out, is there a reason to have separate
> > vfs_ioc_setflags_flush_data() instead of folding the functionality in
> > vfs_ioc_setflags_check() (possibly renaming it to
> > vfs_ioc_setflags_prepare() to indicate it does already some changes)? I
> > don't see any place that would need these two separated...
> 
> XFS needs them to be separated.
> 
> If we even /think/ that we're going to be setting the immutable flag
> then we need to grab the IOLOCK and the MMAPLOCK to prevent further
> writes while we drain all the directio writes and dirty data.  IO
> completions for the write draining can take the ILOCK, which means that
> we can't have grabbed it yet.
> 
> Next, we grab the ILOCK so we can check the new flags against the inode
> and then update the inode core.
> 
> For most filesystems I think it suffices to inode_lock and then do both,
> though.

Heh, lol, that applies to fssetxattr, not to setflags, because xfs
setflags implementation open-codes the relevant fssetxattr pieces.
So for setflags we can combine both parts into a single _prepare
function.

--D

> > > +/*
> > > + * Flush all pending IO and dirty mappings before setting S_IMMUTABLE on an
> > > + * inode via FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
> > > + * returning error.
> > > + *
> > > + * Note: the caller should be holding i_mutex, or else be sure that
> > > + * they have exclusive access to the inode structure.
> > > + */
> > > +static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
> > > +{
> > > +	int ret;
> > > +
> > > +	if (!vfs_ioc_setflags_need_flush(inode, flags))
> > > +		return 0;
> > > +
> > > +	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
> > > +	ret = inode_flush_data(inode);
> > > +	if (ret)
> > > +		inode_set_flags(inode, 0, S_IMMUTABLE);
> > > +	return ret;
> > > +}
> > 
> > Also this sets S_IMMUTABLE whenever vfs_ioc_setflags_need_flush() returns
> > true. That is currently the right thing but seems like a landmine waiting
> > to trip? So I'd just drop the vfs_ioc_setflags_need_flush() abstraction to
> > make it clear what's going on.
> 
> Ok.
> 
> --D
> 
> > 
> > 								Honza
> > -- 
> > Jan Kara <jack@suse.com>
> > SUSE Labs, CR
> 
> _______________________________________________
> Ocfs2-devel mailing list
> Ocfs2-devel@oss.oracle.com
> https://oss.oracle.com/mailman/listinfo/ocfs2-devel

