Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7370C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 08:24:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40FCE20880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 08:24:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l885hRvr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40FCE20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A52B86B0006; Tue,  9 Apr 2019 04:24:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A01526B0007; Tue,  9 Apr 2019 04:24:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0846B0008; Tue,  9 Apr 2019 04:24:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67D4E6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 04:24:23 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b131so12576299ywe.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 01:24:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bWQFwo7IHDylYNN8NyHxPZ7hU2kY+f0QWx1JmjnI1F8=;
        b=pswFNWNwF5FMj5qYsGx5gSps/BmBzXv04W/smysRLt3842A/tjOL0N5xMvkO0xLpsH
         O+LtHMn2vSJ4BkPsp+Ky52K2A4Di4E2gWzkH6NbwIswxXq3V1/Cm0EI2tY+WLptQ2RMa
         JMbKM18HM8b26SI+zhWTkwK5WLrULGqM2SbibTMDsBQEYv+QHNMi2RXZ6MDsW+R3SaAH
         0AFKHu27c7Qw+iVFexdZKeUXi1wT3l1Eo1O0A6b8d4qQxxeOqZ+8Qw5I65FXY+VFemuh
         NF50AbbdieHiFOvU5dzqe8xqBClquGkHmlix7934t95xz5Ex6moEVwGC6liJTyxub8Lx
         sCIg==
X-Gm-Message-State: APjAAAXFtEd5vgAh05oFoZ5nnV3I4Uav872f9bFysrzsWzZ8FUQGzlMA
	o4zI/7XQb2GKn4Fr5JKmwbCvhYNTDkBITPoh9c3RxX/mRbW2ETcEAzuXOtM3zOcbO84X+qhuwdG
	zD7BbkguyzE8XlHL4T76LocHQ0cNirCLo6qFDpES2hUSFsItpSfFDmHvpd30FGkn1EQ==
X-Received: by 2002:a25:320d:: with SMTP id y13mr29382221yby.466.1554798263110;
        Tue, 09 Apr 2019 01:24:23 -0700 (PDT)
X-Received: by 2002:a25:320d:: with SMTP id y13mr29382186yby.466.1554798262433;
        Tue, 09 Apr 2019 01:24:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554798262; cv=none;
        d=google.com; s=arc-20160816;
        b=slW/kKPBOvU8skF04uilKt7PZrgMenNbrzGvrGWIFnDELlJh+YeZItCdeKDVTxDmo4
         yG79oLKSIaeu3b7QfAWReR9PZvnGXy3KGVbWFbJXhvc43SccDpaUxUBBp8VfOt1vUNeJ
         gHXfz247m8YqzDIa0lSRA4PZF3AIkmh07qYVobqrH8iYrMPEcCUm5oi/kKDW0U+ll782
         kr16bTe290pCUtdMGyXuWAz6E6BVgiLf2jU9hg2pHyupY5OoG5NVGw0q1VLToce1V02m
         TmPxl3XM0xS6/b3uIV6rrPFaPGKYp6TZzwVYh13jjzgzdcRClzEbOWQ+tYax8TkwRDnU
         3A8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bWQFwo7IHDylYNN8NyHxPZ7hU2kY+f0QWx1JmjnI1F8=;
        b=JwDqOs7zIWcKrQLcbKCYljnpajvg5Haf1ZKfCFQC4EKQUILmTH8cXDRJe7c9sX3E/Q
         Ei+eTeECXNFsOY1cC5GuT3wwWvb/STPZ0lPav/tBZrgvVddN/QjK/WqGQSmMODZ0dFG+
         1cMjuyXuznz6/ciGfdqUaIyiG8rUFFTlpt0p90v9JezHW79XL7Mwv38KzLTXW5pD4J0i
         CMLHjV18nlbsKaoPLGnd256jqKrwG8D+Y7vrZb0fVoAJGX1Yw3PrsyqTEmPJa97J8Ozj
         h5JjivO7TGJTx25FDTV/uRlpP8DzTLxWhYtsisBEX3bNOsijvM+JorNHDw/1sk3vDUO/
         TZgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l885hRvr;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor11125064ywg.89.2019.04.09.01.24.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 01:24:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l885hRvr;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bWQFwo7IHDylYNN8NyHxPZ7hU2kY+f0QWx1JmjnI1F8=;
        b=l885hRvrFXm9KxwnJJq0DifCiw24GZL7QCGuCEL8qQOU8Eq/Qud59KwIfmSRv2Sh9G
         fT1vppb0DHQgkOaVCIxm+Gd73163C6x60XGT+zTB9ls15VR2EODAeYlNDYoJ7AjCkm/2
         lcSni2HLILDC5T1izm9kB39F/ppk6RqWWGQpEUwNbr85Px4WHx/QSL7eOv5mKcIpKfmn
         pGp6Cl3s4cB54vyVpnF/u0cVMU9nvxlLbjKhd+I81VMojpwTO6D0Sh+gj5bKmpnm+BMQ
         NjIthNgLfnJJmf22TnnRFF4EMDYMoi9Yn7c7XCxnHLaP2ayAyOW4hXRx7rt7h82BRb2l
         t2Ug==
X-Google-Smtp-Source: APXvYqzou3QnWh3Vv2nMQWyo4D7id6da58r3bg3DsHGTl7DQcgno15ZNugvun/RPcvRvvDvoF1Ocf7d6VA6OL7YiVfs=
X-Received: by 2002:a81:1383:: with SMTP id 125mr27735505ywt.265.1554798262016;
 Tue, 09 Apr 2019 01:24:22 -0700 (PDT)
MIME-Version: 1.0
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884962.633834.14320700092446721044.stgit@magnolia> <20190409031929.GE5147@magnolia>
In-Reply-To: <20190409031929.GE5147@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 9 Apr 2019 11:24:10 +0300
Message-ID: <CAOQ4uxgDQHJntoO6EZ1fn-iBVo8gshsSpHd_UB1cnXUJ3CXOTg@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] xfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Ext4 <linux-ext4@vger.kernel.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 9, 2019 at 6:19 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> The chattr manpage has this to say about immutable files:
>
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
>
> However, we don't actually check the immutable flag in the setattr code,
> which means that we can update project ids and extent size hints on
> supposedly immutable files.  Therefore, reject a setattr call on an
> immutable file except for the case where we're trying to unset
> IMMUTABLE.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/xfs_ioctl.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 44 insertions(+), 2 deletions(-)
>
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 5a1b96dad901..67d12027f563 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1023,6 +1023,40 @@ xfs_ioctl_setattr_flush(
>         return filemap_write_and_wait(inode->i_mapping);
>  }
>
> +/*
> + * If immutable is set and we are not clearing it, we're not allowed to change
> + * anything else in the inode.

This looks correct, but FYI, neither xfs_io nor chattr clears 'immutable'
and sets projid/*extsize in one ioctl/xfsctl, so there is no justification to
making an extra effort to support that use case. You could do with
checking 'immutable' inside xfs_ioctl_setattr_check_projid/*extsize()
and leave only the di_flags check here.

Some would say that will be cleaner code.
Its a matter of taste and its your subsystem, so feel free to dismiss
this comments.

Thanks,
Amir.

> Don't error out if we're only trying to set
> + * immutable on an immutable file.
> + */
> +static int
> +xfs_ioctl_setattr_immutable(
> +       struct xfs_inode        *ip,
> +       struct fsxattr          *fa,
> +       uint16_t                di_flags,
> +       uint64_t                di_flags2)
> +{
> +       struct xfs_mount        *mp = ip->i_mount;
> +
> +       if (!(ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) ||
> +           !(fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> +               return 0;
> +
> +       if ((ip->i_d.di_flags & ~XFS_DIFLAG_IMMUTABLE) !=
> +           (di_flags & ~XFS_DIFLAG_IMMUTABLE))
> +               return -EPERM;
> +       if (ip->i_d.di_version >= 3 && ip->i_d.di_flags2 != di_flags2)
> +               return -EPERM;
> +       if (xfs_get_projid(ip) != fa->fsx_projid)
> +               return -EPERM;
> +       if (ip->i_d.di_extsize != fa->fsx_extsize >> mp->m_sb.sb_blocklog)
> +               return -EPERM;
> +       if (ip->i_d.di_version >= 3 && (di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
> +           ip->i_d.di_cowextsize != fa->fsx_cowextsize >> mp->m_sb.sb_blocklog)
> +               return -EPERM;
> +
> +       return 0;
> +}
> +
>  static int
>  xfs_ioctl_setattr_xflags(
>         struct xfs_trans        *tp,
> @@ -1030,7 +1064,9 @@ xfs_ioctl_setattr_xflags(
>         struct fsxattr          *fa)
>  {
>         struct xfs_mount        *mp = ip->i_mount;
> +       uint16_t                di_flags;
>         uint64_t                di_flags2;
> +       int                     error;
>
>         /* Can't change realtime flag if any extents are allocated. */
>         if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
> @@ -1061,12 +1097,18 @@ xfs_ioctl_setattr_xflags(
>             !capable(CAP_LINUX_IMMUTABLE))
>                 return -EPERM;
>
> -       /* diflags2 only valid for v3 inodes. */
> +       /* Don't allow changes to an immutable inode. */
> +       di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
>         di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
> +       error = xfs_ioctl_setattr_immutable(ip, fa, di_flags, di_flags2);
> +       if (error)
> +               return error;
> +
> +       /* diflags2 only valid for v3 inodes. */
>         if (di_flags2 && ip->i_d.di_version < 3)
>                 return -EINVAL;
>
> -       ip->i_d.di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
> +       ip->i_d.di_flags = di_flags;
>         ip->i_d.di_flags2 = di_flags2;
>
>         xfs_diflags_to_linux(ip);

