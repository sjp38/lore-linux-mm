Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15DB6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C54602184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:29:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C54602184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DC1C6B028E; Thu, 28 Mar 2019 17:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58A116B0290; Thu, 28 Mar 2019 17:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42BDC6B0291; Thu, 28 Mar 2019 17:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F04676B028E
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:29:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f1so106825pgv.12
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:29:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=L/3eu6ePnR2HvpnoVXIfuLSOibjEGGIRTjN9CXdEWsU=;
        b=Y+jXxj457CMYHUYIs9Y4SJkKAgK06LLACcEhlQsNbDG7qImJb8/bsC5aHyccdrVU5E
         aJnEnhH1wkGi3Fpzox1av0hO45yfl9+0HEIDQdEjUBL/ryU4HW/ftvoIQ623FL7vELHp
         uRfPtyBaSfmkGxKS1CiR6hpVcg68SYviWhLWZRVRguzoAw33eQGs0+HcXW1KoGHHfYbt
         cM+kaFN293uoabgvkDlhNpXS2XN3BNZnQQuWY4vqro5dRf3ajAAv+pMnHE5MBZ937ElL
         33QVZWbAzXv29/TxcD6W+nLXTUbgNX/hLcOqFp/jSJdOUlGLf9UZRdXIQYKA6DFvJ43x
         z62A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUIamlvIMfbyioOGBGsjyGYESZk94aVWqHJlTastYpDg6v9ilxm
	yNSMVihY24VaWANHsbZ7pnqYlMxpDMxcsilpDdVdOu/IFqV5pHzJ7hor0sXufyY9CxntX07p9hT
	q0TPjCUkmJpbVtOPV91GqGxLz7roZeP+KBhK/BzQX3WsR+i67sPz13H++F9XBXck=
X-Received: by 2002:a17:902:7c8a:: with SMTP id y10mr4014741pll.232.1553808592585;
        Thu, 28 Mar 2019 14:29:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhsdMgjLcKh06VPZIQDcBa1/urDJ847lQKo5SzlD6BaRhwqr12bc9GEdBWVOfecbO2/9bZ
X-Received: by 2002:a17:902:7c8a:: with SMTP id y10mr4014713pll.232.1553808592022;
        Thu, 28 Mar 2019 14:29:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808592; cv=none;
        d=google.com; s=arc-20160816;
        b=a/YqDOYaxgwSR9jBCpxzaeoGl+SW5FD8rzixNFe9Q6vgA5WEKRKe7m1cQkVqppG80I
         nvjezRcF3sgqMHSGyOvichm8j0snif9GYufy1RSHL4Lhp1QJP4yFmBDM/dEQn50DVDwt
         wXYCcRU3CF21g6yx37Fk0UsGB6WUT8+E1btggL4YAPGkXVtw8q382NSQU1fjLKZLhZHS
         euENdM/CS+qo6bifJPhKSZJUz/0gAuTALpIUHMbjJwjkaKVUhI/sAEO0FRMhxSphtZIH
         kWJsK7Rb6IJzzwcEgt0chn0iNPVyYrDXSj0XihhOUKBgzcBG1DSypnJBIyaeV8N3DA1T
         xG+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=L/3eu6ePnR2HvpnoVXIfuLSOibjEGGIRTjN9CXdEWsU=;
        b=c9yZgxNaU1EtDHavNPbZz9ENmX5ENtx7iJMuh8Wbv51QUqoE935Uc6qpQ3DtzN7Vt2
         p4V5tsXg0fa4ioEpkVOkMh47Tky7oiLTYSJVbxjTsF4tpq2rGb+VsRhaukDfN/saJ5Te
         EYaBEy6W5YaW0vqRP2CxNlvy7qTI5q8iZ5Sh/ezqkegNY7Ebcudlse8b4YW0Ctro18s+
         fS5h/xGfe81JFiLGM4Z6Ct4T4lJnUJnUerevGEAab1N9Omw1LsC87NtANvQgXdL0RodS
         juyLhSENTVDx72UjqqX+rL3K49i7KUJBYcsTeRwTgK8+Ef0xlFlclbdp3MU6zMxJcJcD
         1j5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id a3si187418pgg.127.2019.03.28.14.29.51
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 14:29:52 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 29 Mar 2019 07:59:50 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h9caq-0008Bp-Ef; Fri, 29 Mar 2019 08:29:48 +1100
Date: Fri, 29 Mar 2019 08:29:48 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 3/3] xfs: don't allow most setxattr to immutable files
Message-ID: <20190328212948.GL23020@dastard>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
 <155379545404.24796.5019142212767521955.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155379545404.24796.5019142212767521955.stgit@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 10:50:54AM -0700, Darrick J. Wong wrote:
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
>  fs/xfs/xfs_ioctl.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 2bd1c5ab5008..9cf0bc0ae2bd 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1067,6 +1067,14 @@ xfs_ioctl_setattr_xflags(
>  	    !capable(CAP_LINUX_IMMUTABLE))
>  		return -EPERM;
>  
> +	/*
> +	 * If immutable is set and we are not clearing it, we're not allowed
> +	 * to change anything else in the inode.
> +	 */
> +	if ((ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) &&
> +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> +		return -EPERM;
> +
>  	/* diflags2 only valid for v3 inodes. */
>  	di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
>  	if (di_flags2 && ip->i_d.di_version < 3)

Looks fine - catches both FS_IOC_SETFLAGS and FS_IOC_FSSETXATTR
for XFS.

Do the other filesystems that implement FS_IOC_FSSETXATTR have
the same bug?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

