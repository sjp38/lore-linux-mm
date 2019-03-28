Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A23CC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64AE821850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:21:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64AE821850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2E86B028A; Thu, 28 Mar 2019 17:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4C776B028C; Thu, 28 Mar 2019 17:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC6A86B028D; Thu, 28 Mar 2019 17:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60A9B6B028A
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:21:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b12so15422824pfj.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:21:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eu4iBmJ7tshOfKbGrtJErJZHo6TnzdoA2OIwYeJkAtM=;
        b=Q8MDH0SLx8WnMlaW9VrYJ4pPtX2HM+EmLmCR7puTjAv6qiGUE/Jry19DJn5WaMu0do
         LEZbhlkc38f04esw9gwMiviJyEIpx+lwvFZTd61DzaKAIFTPO+i3vjNw+8vwxqPq7yQW
         bgnsyuSQcfQ7RP7e2pHD/hM7j5GWKiDpNAv7Yv3bo8kL7CaxW6WDR9nFdX4NX+YlgPJ6
         UhLHoGDoEM/IzC/Tt2DerllHGtIs8qdb5JwqQi0O/xm8hNEzABgjQavzYQb/ONHSvH/n
         oOj2Dsg9mj/mRPV25JtWxahWQ9YNyRrLOZdxWOT7GDIf9Cn8gXcG0H/bomcFYfdmfoUy
         uAkg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVTkqq30GVtebErBcDBXXlpPk3nQWF6Y+FPDuY0B+B0x0KXBpcd
	GSMmv2EezqHJ+3oRkkByMqlg2H8ajQynGUdhDalXMJnKGqFB5PZ8xdicIZ4v7nNHbXO/uSM8eB9
	vndRYSOObdDphMKjQCqlQ8hX4c4khVfsPWrVzdFL92UhgXG21GuCnDAwmAogcdok=
X-Received: by 2002:a63:5150:: with SMTP id r16mr33293681pgl.307.1553808112048;
        Thu, 28 Mar 2019 14:21:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy23ubzTht09LkSgP+FRGmJfV6xziM0NKLmL5QSTaLG6c4e2ZXDg2K82XosWOCHFnFbp+CS
X-Received: by 2002:a63:5150:: with SMTP id r16mr33293625pgl.307.1553808111300;
        Thu, 28 Mar 2019 14:21:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808111; cv=none;
        d=google.com; s=arc-20160816;
        b=0p5Ui8PrM5ZHiBdDJn8Qqh0xE+YJQTHPTAcPaQyz5eYrJJI1Anwzv8h4XChcpZxbRX
         c6Hwy+odi4YpBk8dG1T1tTgSL7aWwXfgsvE3XiT6UgW1lOaCAWqd3pUmgF+EA1S6kJLi
         Zjnyzl9zwrELFDvp+UWoxxqT7NeKLc8OBLig3L32gpFZKaJUMUeobkl+qjyjuFqorQLf
         sh47lrFvqtEyaJHZtRLyi3vWYZHCxR/nMCNmQhRdoPcLu7bUGnmrtLc4l8AcpUj7pPsz
         Fv1anW0u/iRnAWYGWn6HW+UiYqHXzIPcF+KWcdmgY8FVWta5EiUFnVNWDelNDiDAPjQ2
         SRfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eu4iBmJ7tshOfKbGrtJErJZHo6TnzdoA2OIwYeJkAtM=;
        b=vAPOI274Cy9NIwcN3gGvsEElAIVlMpL1KuGA5b+qcuQUww1zUtnovd9NmzqWJTsqJr
         KhDtXnClonqdLo+1HV6+k+yXJApGRDEhUzqyEdwopOPXKPcwJDm7+XiIeRr24g5tYwKv
         6KKHg8+fGB83bKeL5AdjKgi2iZipl3Pvv5uoUzUCg9eehWKAb/jlD119EQr5tiA/z+uk
         Dgs/H4XQ4sCldpY68T6qbNOYqy51QFHCg6plmp9HnAbRQPxKzRqFr1GNPUMZO6xXiijs
         /CgqIG/Ak3wyYG9TIRO5dIUSEJTE6/E6FvA6+OOFsiu78MnXPTKm3cSwNZR1NwHHAk1i
         LOcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id 62si156803ple.393.2019.03.28.14.21.50
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 14:21:51 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.139;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl2.internode.on.net with ESMTP; 29 Mar 2019 07:51:48 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h9cT6-0008B9-11; Fri, 29 Mar 2019 08:21:48 +1100
Date: Fri, 29 Mar 2019 08:21:47 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/3] xfs: reset page mappings after setting immutable
Message-ID: <20190328212147.GK23020@dastard>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
 <155379544747.24796.1807309281507099911.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155379544747.24796.1807309281507099911.stgit@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 10:50:47AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> This means that we need to flush the page cache when setting the

nit: flush and invalidate the page cache.

> immutable flag so that programs cannot continue to write to writable
> mappings.

Do we even need to invalidate the page cache for this? i.e. we've
cleaned the pages so that any new write to them will fault,
that will see the immutable flag via ->page_mkwrite and then the
app should segv, right?

> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/xfs_ioctl.c |   63 +++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 43 insertions(+), 20 deletions(-)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 6ecdbb3af7de..2bd1c5ab5008 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -998,6 +998,37 @@ xfs_diflags_to_linux(
>  #endif
>  }
>  
> +static int
> +xfs_ioctl_setattr_flush(
> +	struct xfs_inode	*ip,
> +	int			*join_flags)
> +{
> +	struct inode		*inode = VFS_I(ip);
> +	int			error;
> +
> +	if (S_ISDIR(inode->i_mode))
> +		return 0;
> +	if ((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
> +		return 0;
> +
> +	/* lock, flush and invalidate mapping in preparation for flag change */
> +	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> +	error = filemap_write_and_wait(inode->i_mapping);
> +	if (error)
> +		goto out_unlock;
> +	error = invalidate_inode_pages2(inode->i_mapping);
> +	if (error)
> +		goto out_unlock;
> +
> +	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
> +	return 0;
> +
> +out_unlock:
> +	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> +	return error;
> +
> +}

Doesn't wait for direct IO to drain. Wouldn't it be better to do
this?

	lock()
	xfs_flush_unmap_range(ip, 0, XFS_SIZE(ip));
	unlock()

Otherwise looks ok.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

