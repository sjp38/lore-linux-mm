Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C094C48BD4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:58:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4461220665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:58:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vwSceTOF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4461220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D603C6B0005; Mon, 24 Jun 2019 17:58:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D11FA8E0003; Mon, 24 Jun 2019 17:58:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1898E0002; Mon, 24 Jun 2019 17:58:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 937756B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:58:39 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id y198so6956516vky.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:58:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JPBEqrnBb8FJilUCQCUmMJhL0pO+qsW2uzegjGEHDYQ=;
        b=Be6z3b3XwWjsVl2gLPeBO/UKBEezE7VyKBlUwfgYezkyNRmTvB/zD8Ff9WdAAQeN56
         QDl7/9DpzjX09L0jgM0iPG+cuRHb8szJpevpqqA6c2VOehDSZjae0840+n5+dIDp6fMW
         JijPtpvFLgd8FvvT4+3OJN4sQKAZOAZetbK2CHInh0GDO/wS/MR1Ol223k8Vh+E1tvZ+
         rELpy6xqZeS0VlvD+NU2xEwjjIaecv8ftT4xBPY1HkQvBnGfmZ+qydhT4hLjeKEdgTi7
         aD8H3r3owE3BrEREwhF5bGaLMkcY/bDmJ3mqCeY08oxwF4SXl+jdOPzRAvvWUpatOg6u
         Usuw==
X-Gm-Message-State: APjAAAUAgZlO9aajx0mcAKjuPaVCYqC+/TzJQl3dyhKeu1UduIIp1MxY
	Zod3OqyriPrvrIRRdaJWQi+ZD2FbjSOjRIPD+7yHoc0eTZK1ZfLdzpjP2GaV13tOEUy0i+wlOMN
	5AHTWHegfCcvkzeZVFtSzbzGMV2NOxgSLwaq1yBXLvdIwyg9X0pPH6UYuNXrfcviw0w==
X-Received: by 2002:a67:f5d0:: with SMTP id t16mr38475632vso.175.1561413519320;
        Mon, 24 Jun 2019 14:58:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8olrwUjdpQn818gLKrm3Fg2brC7gYLU2U0WPErwXePyqxudwM7m6P6UJdQojg3pd21TP1
X-Received: by 2002:a67:f5d0:: with SMTP id t16mr38475592vso.175.1561413518687;
        Mon, 24 Jun 2019 14:58:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561413518; cv=none;
        d=google.com; s=arc-20160816;
        b=c65GVn6xkp1ylM7pXY43t8nXXIxVebwW7eEkvVy4IJZcaeeyhdbeHVg+qzR/xRFEx5
         GxtsIlztruQ5Cq99g+LrJvS5ECYBk1LHxPm4U2V5v1YmcHFN5ISrtpu4/YDuidDqBauD
         LrKHfeVrvzoTyJzGYvwTUB00iRRHhGgtLMT1nUmngYBx72h9PL3YvYkRTeu/TZBhIlt1
         EymTU/Z2+heEuxts/LISVRGk9+b2Nyp4+TyBNlOC6OM3V66d1vXbGbTsChlE/EwUHykm
         zEfJfQtBbe+TW8fsY+6cxxDWqrgA2kt7tj8gobvP+FCnpxH0ukzMyqY8JjxsiumOVUbt
         DsDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JPBEqrnBb8FJilUCQCUmMJhL0pO+qsW2uzegjGEHDYQ=;
        b=em6P63M4J0xl1LhSMvQJsrjzDVN2MTuGo1PQJ8yWT7GANlJkRKLvZMsB2nGYvmBtKU
         GOyYmvC2ASDDHLIpdXKUuCPHYNSWbwaR01meygAG24yWC3K/eicX6cUEgm9NJSMk9D1L
         kv+zChnA7/bitsYY+Ye5llw/q6oS2vw2jbGs78M0NBGJvgFSIyTkcRWTtAgp6h07bG+B
         1JEwSqNjtSoc1iDY3j4ZHv0QeHVadIhCDIb20wSXo7PnXHx7eHIdMyiBHG2iATOR++bX
         XkaLNOsNpvJopz+mtnB5VPXm3AegOB8pGCVhGCeurV9PU79yZwTr/LS66qQfvI001AbO
         ZcOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vwSceTOF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 7si2358201uai.155.2019.06.24.14.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 14:58:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vwSceTOF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OLsca6091939;
	Mon, 24 Jun 2019 21:58:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=JPBEqrnBb8FJilUCQCUmMJhL0pO+qsW2uzegjGEHDYQ=;
 b=vwSceTOFPnndaHyinJXnA0XxpMTF4zGHNj5lEs+w8XWiVL6ly7Z9VEVjJV4gnFgKkKwW
 B8SdZ4krsyR6f1E0FlYW5moxuEmjhgn85HtSg0z2oOp1hhMJdo3XOqpiHvEil1BlZ2KW
 PEGmAIadWWqhl9+AmMr5FDs139rF0no0szY6ZnskKVnUEMSG9PrJ5dCsFbIdJrY2zxiP
 3z4yfqHwUSqvLrreOnH+MDuEMhE8ElZOtQ8shgvbsZ/7FCLrYScc7NOmLBxChFYSaq/u
 gI1Rn+l+GOiLbqZED3Z1Od5UlWcckpvKqSJxtGUwwy+7uAnIrP4j5qb9NqSYBMPprys8 Qw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2t9c9pgrf7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 21:58:29 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OLwP9j160075;
	Mon, 24 Jun 2019 21:58:28 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2tat7bvjfc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 24 Jun 2019 21:58:28 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5OLwS3d160108;
	Mon, 24 Jun 2019 21:58:28 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tat7bvjf7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 21:58:28 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5OLwK6v015219;
	Mon, 24 Jun 2019 21:58:20 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 24 Jun 2019 14:58:20 -0700
Date: Mon, 24 Jun 2019 14:58:17 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        ard.biesheuvel@linaro.org, josef@toxicpanda.com, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
        reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/7] vfs: flush and wait for io when setting the
 immutable flag via SETFLAGS
Message-ID: <20190624215817.GE1611011@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116142734.1664939.5074567130774423066.stgit@magnolia>
 <20190624113737.GG32376@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624113737.GG32376@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9298 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=805 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906240172
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 01:37:37PM +0200, Jan Kara wrote:
> On Fri 21-06-19 16:57:07, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
> > need to ensure that userspace can't continue to write the file after the
> > file becomes immutable.  To make that happen, we have to flush all the
> > dirty pagecache pages to disk to ensure that we can fail a page fault on
> > a mmap'd region, wait for pending directio to complete, and hope the
> > caller locked out any new writes by holding the inode lock.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Seeing the way this worked out, is there a reason to have separate
> vfs_ioc_setflags_flush_data() instead of folding the functionality in
> vfs_ioc_setflags_check() (possibly renaming it to
> vfs_ioc_setflags_prepare() to indicate it does already some changes)? I
> don't see any place that would need these two separated...

XFS needs them to be separated.

If we even /think/ that we're going to be setting the immutable flag
then we need to grab the IOLOCK and the MMAPLOCK to prevent further
writes while we drain all the directio writes and dirty data.  IO
completions for the write draining can take the ILOCK, which means that
we can't have grabbed it yet.

Next, we grab the ILOCK so we can check the new flags against the inode
and then update the inode core.

For most filesystems I think it suffices to inode_lock and then do both,
though.

> > +/*
> > + * Flush all pending IO and dirty mappings before setting S_IMMUTABLE on an
> > + * inode via FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
> > + * returning error.
> > + *
> > + * Note: the caller should be holding i_mutex, or else be sure that
> > + * they have exclusive access to the inode structure.
> > + */
> > +static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
> > +{
> > +	int ret;
> > +
> > +	if (!vfs_ioc_setflags_need_flush(inode, flags))
> > +		return 0;
> > +
> > +	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
> > +	ret = inode_flush_data(inode);
> > +	if (ret)
> > +		inode_set_flags(inode, 0, S_IMMUTABLE);
> > +	return ret;
> > +}
> 
> Also this sets S_IMMUTABLE whenever vfs_ioc_setflags_need_flush() returns
> true. That is currently the right thing but seems like a landmine waiting
> to trip? So I'd just drop the vfs_ioc_setflags_need_flush() abstraction to
> make it clear what's going on.

Ok.

--D

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

