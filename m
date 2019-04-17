Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5B19C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:01:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50523206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:01:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fRbASVPt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50523206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D77D56B000C; Wed, 17 Apr 2019 15:01:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D25F46B0266; Wed, 17 Apr 2019 15:01:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C15596B026D; Wed, 17 Apr 2019 15:01:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAAF6B000C
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:01:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b1so23388762qtk.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:01:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+/GWh713FqL/H8PmEw9TPiD/zMFMSIkms3hrEPjGldk=;
        b=HLFS1pMkVW1TFNKD6xaK69kDDahsf0oSxTphXHy+jxBCyJaiw12yR0mMnmZP12X5eq
         6IglRwcVOdCOa3JAiIGqasDmEXmMgUzOwDLLP1UmKij2hHMPG4p+KWYfSNeBw/PaM4TQ
         Gviwtkc+GU9AG1z8Me+38b8maruo6ucIBVbVTFh41RDirrjI2yPfApUMoYdbLelM9rlR
         hB2UUg5pYN4oXN2XrWxD0EfqNyxefxtgV/TNINlpuHu+Umg13ba0oAen4CQ/QN2vKd9s
         3OOB+Yw8AuLg+176+xZMoDeBle1qQvHUWTQ9jL39D9nfLAP2fuWmwyDNR109bEra+A1J
         ullw==
X-Gm-Message-State: APjAAAUPZEWI7oDR1pIKipuV5FvfxeuOnAe8u5DIgRkEiqbn+geV+CzU
	+ZH/qoNvA5uynz4IWXzFsvHddWuWs8I5Jipg9O8P4dv2VHK9qospxv1JIHW+OeZ0Ef+dbrus/6O
	YizdZjF0q9WEZ6FBc/qJs59HxjT6ZRNvR1TsTXXNoO/7ftily4xEarbPCC8xjr1BrEA==
X-Received: by 2002:ac8:3258:: with SMTP id y24mr74399790qta.0.1555527692279;
        Wed, 17 Apr 2019 12:01:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+7qdZk9LUsnmDI3I40GJ4JdPA7vmtYnUaJtEDjm3EX2GmY2lwy9s+vzPLCuTPVQELUVEi
X-Received: by 2002:ac8:3258:: with SMTP id y24mr74399692qta.0.1555527691229;
        Wed, 17 Apr 2019 12:01:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527691; cv=none;
        d=google.com; s=arc-20160816;
        b=h3gJmhoNRyifGk6+NPGTS6V/jKCOgbjZgxlvsZs1eOcF/OlgPPMy9yuXcAJLpfwKNB
         GjkKERRrY9fwmWZxUYOs6SW9HTnnC8RO4f2GH5KRiD/Ta84jYN7MMNS3BsCt7otZeJXn
         im78upAyGUcsBBucVToTW5vZric0f3/HIS6BwmHPIE/W/ls8UdJgY/tXqrBxb73QeAhD
         duOtpbgt0Eq4MPrRDhmqYCm1fncG8YnCwVsyfsTsbqAKiiyEEEDX034mV2epcmxdD6sc
         Ef5toawCs6rT3/ImyxEjDcBApgWniOi8pjCO6vNLfR4lw6zBXCI23xEYbpGEmnrNPOw8
         CODw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+/GWh713FqL/H8PmEw9TPiD/zMFMSIkms3hrEPjGldk=;
        b=vu5gbGSd00D1cBxtoy8tcVoK5hIYshVh40gDOqlHfD/kxQcHIpMF6zTnSEU7My+w3m
         yT/wjIWqOd4M/6Q3KVQYnm2zMu5Mrv3TIsdF1lNj9VWdMPkKE4KRpobWWNpRg4JenEoR
         HEk8gegN2zXUa3yAKWsWMgSKmkIQi6pp71ZktwguqzAjvFXPzx70jP1S5IzizpjkYCEu
         3YWx9k+zPVlrjksWcD4/w7xdj5F/NQJSEbM16TMKOPSWI1NXzC/GkF/5n+S9rgPAf4Ns
         C0JoFmsw7hTXkHe7Gxgn/kgzKlqTYTykQ8kl5KixLraftLZZ6SXnsE9U4LsN30/lErwh
         DK7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fRbASVPt;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q3si1294770qtq.31.2019.04.17.12.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:01:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fRbASVPt;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwpEr168706;
	Wed, 17 Apr 2019 19:01:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=+/GWh713FqL/H8PmEw9TPiD/zMFMSIkms3hrEPjGldk=;
 b=fRbASVPtQ9uLksXzKdT7BQAbrdWxsanhAYsV/iNnFjPzJkzcsbIUVtK0f3snud4PKQcY
 aAvrPxHLjFjnYSXXe7gv2i8/14Ho+J1rHXtpyrOz+PNd8c9kUR+iKXgQ9enCCDvX5ZV4
 YOIx4dQvgPaAYBex0fv/SoxMx9UUPhZliNOa+GdTupxoj/KD6jPoZ3Lmp8BM0JPemH6Y
 XIXg08rneLwnvKKhllhmX8kd9JbQVRMh1wvVJLWrEGjk52n5gTfDr8dk3fGAr9DyquN2
 3xCZWmU1Fi/Ocm7mocv6qGokowbj75XYrLzUwWe9jkYAqX6S4TnqAVhW3j08drQMCPck Yw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rvwk3vys7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:01:27 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ116Y076328;
	Wed, 17 Apr 2019 19:01:27 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2ru4vtyvxy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:01:27 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3HJ1QKq007212;
	Wed, 17 Apr 2019 19:01:26 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:01:26 -0700
Date: Wed, 17 Apr 2019 12:01:24 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs <linux-xfs@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Ext4 <linux-ext4@vger.kernel.org>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>
Subject: Re: [PATCH v2 4/4] xfs: don't allow most setxattr to immutable files
Message-ID: <20190417190124.GA5057@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884962.633834.14320700092446721044.stgit@magnolia>
 <20190409031929.GE5147@magnolia>
 <CAOQ4uxgDQHJntoO6EZ1fn-iBVo8gshsSpHd_UB1cnXUJ3CXOTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxgDQHJntoO6EZ1fn-iBVo8gshsSpHd_UB1cnXUJ3CXOTg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 11:24:10AM +0300, Amir Goldstein wrote:
> On Tue, Apr 9, 2019 at 6:19 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
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
> >  fs/xfs/xfs_ioctl.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
> >  1 file changed, 44 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> > index 5a1b96dad901..67d12027f563 100644
> > --- a/fs/xfs/xfs_ioctl.c
> > +++ b/fs/xfs/xfs_ioctl.c
> > @@ -1023,6 +1023,40 @@ xfs_ioctl_setattr_flush(
> >         return filemap_write_and_wait(inode->i_mapping);
> >  }
> >
> > +/*
> > + * If immutable is set and we are not clearing it, we're not allowed to change
> > + * anything else in the inode.
> 
> This looks correct, but FYI, neither xfs_io nor chattr clears 'immutable'
> and sets projid/*extsize in one ioctl/xfsctl, so there is no justification to
> making an extra effort to support that use case. You could do with
> checking 'immutable' inside xfs_ioctl_setattr_check_projid/*extsize()
> and leave only the di_flags check here.

However, the API does allow callers to clear immutable and set other
fields in one go, so just because xfs_io won't do it doesn't mean we can
ignore it.

Then again I guess the manpage doesn't explicitly say what the behavior
is supposed to be, so I guess we'll just ... argh, fine I'll go fix the
manpage to document the behavior.

--D

> Some would say that will be cleaner code.
> Its a matter of taste and its your subsystem, so feel free to dismiss
> this comments.
> 
> Thanks,
> Amir.
> 
> > Don't error out if we're only trying to set
> > + * immutable on an immutable file.
> > + */
> > +static int
> > +xfs_ioctl_setattr_immutable(
> > +       struct xfs_inode        *ip,
> > +       struct fsxattr          *fa,
> > +       uint16_t                di_flags,
> > +       uint64_t                di_flags2)
> > +{
> > +       struct xfs_mount        *mp = ip->i_mount;
> > +
> > +       if (!(ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) ||
> > +           !(fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> > +               return 0;
> > +
> > +       if ((ip->i_d.di_flags & ~XFS_DIFLAG_IMMUTABLE) !=
> > +           (di_flags & ~XFS_DIFLAG_IMMUTABLE))
> > +               return -EPERM;
> > +       if (ip->i_d.di_version >= 3 && ip->i_d.di_flags2 != di_flags2)
> > +               return -EPERM;
> > +       if (xfs_get_projid(ip) != fa->fsx_projid)
> > +               return -EPERM;
> > +       if (ip->i_d.di_extsize != fa->fsx_extsize >> mp->m_sb.sb_blocklog)
> > +               return -EPERM;
> > +       if (ip->i_d.di_version >= 3 && (di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
> > +           ip->i_d.di_cowextsize != fa->fsx_cowextsize >> mp->m_sb.sb_blocklog)
> > +               return -EPERM;
> > +
> > +       return 0;
> > +}
> > +
> >  static int
> >  xfs_ioctl_setattr_xflags(
> >         struct xfs_trans        *tp,
> > @@ -1030,7 +1064,9 @@ xfs_ioctl_setattr_xflags(
> >         struct fsxattr          *fa)
> >  {
> >         struct xfs_mount        *mp = ip->i_mount;
> > +       uint16_t                di_flags;
> >         uint64_t                di_flags2;
> > +       int                     error;
> >
> >         /* Can't change realtime flag if any extents are allocated. */
> >         if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
> > @@ -1061,12 +1097,18 @@ xfs_ioctl_setattr_xflags(
> >             !capable(CAP_LINUX_IMMUTABLE))
> >                 return -EPERM;
> >
> > -       /* diflags2 only valid for v3 inodes. */
> > +       /* Don't allow changes to an immutable inode. */
> > +       di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
> >         di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
> > +       error = xfs_ioctl_setattr_immutable(ip, fa, di_flags, di_flags2);
> > +       if (error)
> > +               return error;
> > +
> > +       /* diflags2 only valid for v3 inodes. */
> >         if (di_flags2 && ip->i_d.di_version < 3)
> >                 return -EINVAL;
> >
> > -       ip->i_d.di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
> > +       ip->i_d.di_flags = di_flags;
> >         ip->i_d.di_flags2 = di_flags2;
> >
> >         xfs_diflags_to_linux(ip);

