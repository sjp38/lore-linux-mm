Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54994C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 04:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC6D206DD
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 04:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="dVN34tq6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC6D206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0E2A6B0007; Fri, 29 Mar 2019 00:02:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 998656B0008; Fri, 29 Mar 2019 00:02:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85F7A6B000C; Fri, 29 Mar 2019 00:02:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60FF86B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 00:02:29 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id v18so1064696qtk.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:02:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=u01ttpO1CNLjAEDYksWHTKEjyHSBV2Sue3sQFqhEFl4=;
        b=VPpNqc9BhmlHrd5mmWA47IrT4TgPyOy8JH/B0gJ5jbIzh+7hWITQ6dcG69CezEKWZl
         cHXwccjV/DqhEn1cEHpHt1p/8cLmC1c2nxV/QJcvuo7yfuZikbrEwL1+fSx+t639NZ3F
         yUvnu90UaqUYeXvFEVCKslazcCopgeYzNZcfbIKxqGA3XJCmZ/VNM6DKoHybl/3RP23l
         feFYV3Nh758vy9pVFM1p0DtjzckRfuzvWTJL6ehlE4zCZOqmWdUuIm06+tfOkqhjafRm
         Q/9qNaQdXtMlDW/EUbeKdQ1cJ3kYLGBGK34iMhLDwJLwp6VWRpIjgUiuhYatWYfkYY8R
         VOUg==
X-Gm-Message-State: APjAAAUQO2K78auY3NiEPcHyia2dUGONZhhvo8e0Q/iDGvHyxMr44iIT
	Qfiq0d/ZFzEPFp54YCANIALc4MDocezIcL0QqMpdMA3r6mQPLUVYzBVOAUhPQafCkQNDFFI5nrI
	q0aA1rfQXv3NwKjN1ADSnbnmy73+v3DHYGiP25cDOpnmATRM8sugbcjYgljmuuCBoLg==
X-Received: by 2002:a0c:897b:: with SMTP id 56mr38365201qvq.55.1553832149059;
        Thu, 28 Mar 2019 21:02:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9ccE78btTfIosgwf0lsUlyRRctR7/puKjkbNti1FHkH4y+DFxYhPxIgprmG2rdsbJDjbx
X-Received: by 2002:a0c:897b:: with SMTP id 56mr38365143qvq.55.1553832147903;
        Thu, 28 Mar 2019 21:02:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553832147; cv=none;
        d=google.com; s=arc-20160816;
        b=XjMe6PtkLTaLkBxBVnyqL/XI7BtxcuaLHPKbLyW3xjD9rUMXc8/Jq6HVWA1EVyKHZE
         4zCKH2DtpRAaZb30e7zBPeyHlSJzqoPEbFX+n3Cs+pbKJ1E1EilRivXCIx1WxnfSt1zz
         GCpkVdorLlKOUz405SZjsR3c7abh4KeJ/zU/a9JqBH3AnQA6kMg+lH55iTOB/uZxBhMk
         E1JuAqKqDvafUiBMXm+pL4ZH9ha+EOcpWyYfAoeO1cW4Xz+LsrvOP8/oxqYoiyXs6sBU
         p2UVBY957pP+K+fV0gvhYMHXJvuyIr+S4DRwTz3/8Spk9BNgZP0WMYnO+EKgrUIXZUkl
         oBfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u01ttpO1CNLjAEDYksWHTKEjyHSBV2Sue3sQFqhEFl4=;
        b=pnyxrtNvl+Sqxh3qSdHoPlvcpNO35PsSdTMIJI7rmJhEOc2VbGmIvLvaSU34BzvAgF
         37Ri9yekK22c3/NeVe47JEItnoCe8Pj4TlQhmDkTkV1FnxEpabacxJ0EIjiCmht9VrS9
         6HsbESreFn1XRA9mRdK6tN8RsS1d0mEeXiCE0REj6ToNyHa74MaDWV9clfzcFDm2ePT3
         Q7VRMQvAwK34gt6lWa556QEkpAMYING3WSNuGvsTf0Ox7ajIiURKwFZ/h22CR9QMuNOT
         r6MoRtTM4TyAUVV8dx+ifkKDAZG3+5Fa+ybFpYtx6l9IfY48RPdzAVxk/ISAvRYvwyd2
         CJKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dVN34tq6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b43si510759qvd.78.2019.03.28.21.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 21:02:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dVN34tq6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2T3whWq107708;
	Fri, 29 Mar 2019 04:02:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=u01ttpO1CNLjAEDYksWHTKEjyHSBV2Sue3sQFqhEFl4=;
 b=dVN34tq6HtCv36WRYsQrQ9AuxOEQQDZjohx3wShwVgBesFMRwEUxLmixuGfX2OHhN50Z
 VvCNugd5TDovuLz7qp47gyx6pAkxblAn2t3gYEkKImJKceyXBb24EFcwKc/hoFd0m4WU
 HV9bIQsgfZlIbRWb9QBPQTcL8b4pOKJmbww6aMAMqeUOaTjQm5A2JFSsBaDalhccc1Pv
 u/2qnXPA9UCygfQ99jfeUV7o3lFHdyRlUlvmkwnjyerfpG5FRQ/CeJGfirCCXu4FCPrG
 f6d/gVIxHm6/PoqcSUoHvWbpgUoUky31lWdz0u+9rS5Qyt4lB8EDHeipWQAwsr/1SNAw 6A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2re6djt6h5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 29 Mar 2019 04:02:26 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2T42PCp027427
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 29 Mar 2019 04:02:25 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2T42O3b001680;
	Fri, 29 Mar 2019 04:02:24 GMT
Received: from localhost (/67.161.8.12)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 21:02:24 -0700
Date: Thu, 28 Mar 2019 21:02:22 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 3/3] xfs: don't allow most setxattr to immutable files
Message-ID: <20190329040222.GC18833@magnolia>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
 <155379545404.24796.5019142212767521955.stgit@magnolia>
 <20190328212948.GL23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328212948.GL23020@dastard>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9210 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=992 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903290029
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 08:29:48AM +1100, Dave Chinner wrote:
> On Thu, Mar 28, 2019 at 10:50:54AM -0700, Darrick J. Wong wrote:
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
> > which means that we can update project ids and extent size hints on
> > supposedly immutable files.  Therefore, reject a setattr call on an
> > immutable file except for the case where we're trying to unset
> > IMMUTABLE.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/xfs/xfs_ioctl.c |    8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > 
> > diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> > index 2bd1c5ab5008..9cf0bc0ae2bd 100644
> > --- a/fs/xfs/xfs_ioctl.c
> > +++ b/fs/xfs/xfs_ioctl.c
> > @@ -1067,6 +1067,14 @@ xfs_ioctl_setattr_xflags(
> >  	    !capable(CAP_LINUX_IMMUTABLE))
> >  		return -EPERM;
> >  
> > +	/*
> > +	 * If immutable is set and we are not clearing it, we're not allowed
> > +	 * to change anything else in the inode.
> > +	 */
> > +	if ((ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) &&
> > +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> > +		return -EPERM;
> > +
> >  	/* diflags2 only valid for v3 inodes. */
> >  	di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
> >  	if (di_flags2 && ip->i_d.di_version < 3)
> 
> Looks fine - catches both FS_IOC_SETFLAGS and FS_IOC_FSSETXATTR
> for XFS.
> 
> Do the other filesystems that implement FS_IOC_FSSETXATTR have
> the same bug?

Yes.  I'm not even 100% sure I've finished playing xfs whackamole yet.

--D

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

