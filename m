Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A78C48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:38:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9FCB20657
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:38:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HKn791tb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9FCB20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B65716B0005; Thu, 20 Jun 2019 17:38:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEF088E0002; Thu, 20 Jun 2019 17:38:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98EA78E0001; Thu, 20 Jun 2019 17:38:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 746DE6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:38:52 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b75so4371823ywh.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:38:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=D3CnJNHOIgWdUG1TcE81fq/bsWj72ILMBiE1tAPqQwo=;
        b=cZ0WlWOwmLv1W4g6NOt19AcloFZLbRJ/fhR+Qp8vQ5gtd9TAyIK5fCXO8kjHMwcLor
         Rrt9Tng9PTgXqOoyG1sLR68jpgW+xZSCmI/qUFFmVyAm/HEg5miMX3U0V5ogaPxJVeHY
         crxeaO12lyuz5SCFeDKtW5wwzGXRi8kNunxSLm7txMe4N6jrzK//f6tBkDacC7J3F7az
         CAEewU1MTAGpwbz47wiKSCaCgv5WKWvv+sgLEmY3v1yZBMdX7L+2d9NAsejs1P8XwqAG
         ftFGRPY05c7iF/IEkToNUAjldWmCbQRc37Zmmj57+Ys4teISMTX1HTYTskvD5SIeb6tz
         Auxg==
X-Gm-Message-State: APjAAAXaEmjfFtmjWHnJvu2wdazsuuanxVOJfp4HiqDBdRI4C94rdBSc
	miYQOljSk0Vgw+snnIqjaHSe7AXsWGUw3Mo7FUN0W8M9yviAZpq9QtCsTtVDOB21ULl6Hjg7pdF
	SFjX1HB8Dk7JcdCKTZcCxLTK60yRErteJkFS6mDmL0WsUDAi//0KLwk8tpzDQfi2COw==
X-Received: by 2002:a25:ef02:: with SMTP id g2mr69364662ybd.271.1561066732212;
        Thu, 20 Jun 2019 14:38:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqRck52NtUCF/xWyVMu9yqAkieF7wlws1q9gVSHP9IRjQ81JfNeH155oVUuz6ChDHUSEe4
X-Received: by 2002:a25:ef02:: with SMTP id g2mr69364581ybd.271.1561066729906;
        Thu, 20 Jun 2019 14:38:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561066729; cv=none;
        d=google.com; s=arc-20160816;
        b=QCBW/7W//gYrMKDVFqm4k578mIbl730hk40PUlrotVsGEVRiMrFunNv4r4PRfA2G/3
         HGjQu/8MQUiCs5TQZNOpLFiu+LfoQQjmZKHt4oruAxoJlpxCuzfP20QlT79qhjRWUjc8
         VHC65Ubms0x7Wri98ITz2B9NPLF0SEgBjw4GNanezYe6ijduOBb8TuOtGb6L9UiA+QTI
         4v9lru5/JfsbsAVhKCBjmpJQrok41NEQZTH0yZcGZsyHunK+61L4fQbWnNCWPYfe2OuU
         zgb5wEYZj5jg4RLiwUT5oDTU1u8nuIbLrD4CHkmy3mlz3hRDxjZSOIzLir2WNm6RuOhs
         f9tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=D3CnJNHOIgWdUG1TcE81fq/bsWj72ILMBiE1tAPqQwo=;
        b=YywQbzx7lKVlegf2mECHneqQmfnksRAeERinx3klw1Tq2ZzDN+AY7g9naakyt+oeBX
         /bGxyfhXScI9l/VZ56e3baAQxQpouQMclNCpvCALmp4YyzRmJ3NqvFXpDu8N2lMYMjHQ
         w47UaZgm5rloOfjSjLleWyzLLDywWcZILLmXXOYih5DFJxfFUCoDjpATDHnXNtsm156N
         7DDay6xSH7cE1orIEtdVVSfZSSR9tlNsI0S8xRzor3nPtGWZm8i4EmYL94aCOvgpQgli
         2A26MdVi9URodfds2u9ZmAaf2PRp4n/TTFAbIUId3rnqvbG7A7uhXBeSSK4x6Bk/ZRPe
         emew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HKn791tb;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 185si232170ybk.240.2019.06.20.14.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:38:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HKn791tb;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KLYHVn088700;
	Thu, 20 Jun 2019 21:38:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=D3CnJNHOIgWdUG1TcE81fq/bsWj72ILMBiE1tAPqQwo=;
 b=HKn791tbDcSyV5tTwA4L7n0iz31Dp5T+PYftD80uW1HfTEOKSjNNo8ILTMjO1/Rv8cOI
 hpROCjBB23fPljyiuqdvwYxNy/xpAecXOJ97+qJXUbuQysBIXp6+kq1M1NohTdSt2o5m
 bdEHlQfhcUcK9Q2VlmkUVsRBf7mVWZm2yOm4eXP0y5gikqkZmSL3eKCbJdvsPzjLY50k
 BfxiWb1VEIm42WU1tUp/bKXk3/F6YlHbkAbzrc8pKPgHNgEvkWIV2bY4z7UBJVZQfH8/
 ZSoTLiWzgKluhc0l9SvuD6uztH108WS7lGdHTqumoJ0SNSOf6qr9qij979gZkZoaMzEB qg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t7809kdj1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 21:38:38 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KLacer151050;
	Thu, 20 Jun 2019 21:36:38 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t77ypkrr0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 20 Jun 2019 21:36:38 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5KLabeL151041;
	Thu, 20 Jun 2019 21:36:37 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t77ypkrqs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 21:36:37 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5KLaWqH007037;
	Thu, 20 Jun 2019 21:36:32 GMT
Received: from localhost (/10.145.179.81)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 20 Jun 2019 14:36:31 -0700
Date: Thu, 20 Jun 2019 14:36:29 -0700
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
Subject: Re: [PATCH 4/6] vfs: don't allow most setxattr to immutable files
Message-ID: <20190620213629.GB5375@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
 <156022840560.3227213.4776913678782966728.stgit@magnolia>
 <20190620140345.GI30243@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620140345.GI30243@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9294 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906200154
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 04:03:45PM +0200, Jan Kara wrote:
> On Mon 10-06-19 21:46:45, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > The chattr manpage has this to say about immutable files:
> > 
> > "A file with the 'i' attribute cannot be modified: it cannot be deleted
> > or renamed, no link can be created to this file, most of the file's
> > metadata can not be modified, and the file can not be opened in write
> > mode."
> > 
> > However, we don't actually check the immutable flag in the setattr code,
> > which means that we can update inode flags and project ids and extent
> > size hints on supposedly immutable files.  Therefore, reject setflags
> > and fssetxattr calls on an immutable file if the file is immutable and
> > will remain that way.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/inode.c |   31 +++++++++++++++++++++++++++++++
> >  1 file changed, 31 insertions(+)
> > 
> > 
> > diff --git a/fs/inode.c b/fs/inode.c
> > index a3757051fd55..adfb458bf533 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -2184,6 +2184,17 @@ int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags)
> >  	    !capable(CAP_LINUX_IMMUTABLE))
> >  		return -EPERM;
> >  
> > +	/*
> > +	 * We aren't allowed to change any other flags if the immutable flag is
> > +	 * already set and is not being unset.
> > +	 */
> > +	if ((oldflags & FS_IMMUTABLE_FL) &&
> > +	    (flags & FS_IMMUTABLE_FL)) {
> > +		if ((oldflags & ~FS_IMMUTABLE_FL) !=
> > +		    (flags & ~FS_IMMUTABLE_FL))
> 
> This check looks a bit strange when you've just check FS_IMMUTABLE_FL isn't
> changing... Why not just oldflags != flags?
> 
> > +	if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
> > +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
> > +		if ((old_fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE) !=
> > +		    (fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE))
> 
> Ditto here...

Good point!  I'll fix it.

--D

> 
> > +			return -EPERM;
> > +		if (old_fa->fsx_projid != fa->fsx_projid)
> > +			return -EPERM;
> > +		if ((fa->fsx_xflags & (FS_XFLAG_EXTSIZE |
> > +				       FS_XFLAG_EXTSZINHERIT)) &&
> > +		    old_fa->fsx_extsize != fa->fsx_extsize)
> > +			return -EPERM;
> > +		if ((old_fa->fsx_xflags & FS_XFLAG_COWEXTSIZE) &&
> > +		    old_fa->fsx_cowextsize != fa->fsx_cowextsize)
> > +			return -EPERM;
> > +	}
> > +
> >  	/* Extent size hints of zero turn off the flags. */
> >  	if (fa->fsx_extsize == 0)
> >  		fa->fsx_xflags &= ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

