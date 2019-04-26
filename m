Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2545CC4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:18:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA5E0212F5
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:18:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA5E0212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2A16B000D; Fri, 26 Apr 2019 14:18:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781AF6B000E; Fri, 26 Apr 2019 14:18:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 672AC6B0010; Fri, 26 Apr 2019 14:18:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4762A6B000D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:18:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f20so3755896qtf.3
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:18:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v+8CnCpasp8Hdluh1oYE6LpD4uqKpxB7qAZp4XOOo9c=;
        b=Hzwp/a2BrJs7Md7z2A5MEM1tT8fMkbPnxMdYX2XAP6gBQOOxKVKLV7WXB7henDRuCT
         +gDXLhcNq02ZYH9nvo66a3yBYuOA0H18jhOS0TdS7WV8aaxGH6Yv8V+dnksZ5WDwZREs
         4vnjpZr3RwcSfYXhKahPSGNc5OyRpmQGu58F81+idcFfS/cc62Uo4wG4roIQ96LhQjwQ
         Wq7Df98TokSI/XGcY2rMEOShxrhA84kmdZwjAGuA7jktYYQw+MpC2llQa5Tra54NwnN4
         5a1x0/2nwaQQNHCe4bfGdX+9eAERW/vqZKGguxyzhuqe7SYQO54vAzt4K3EIrmBt6DD7
         O4/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVlpTNmEE5SopbzuHADqs1bnAIZfWkcjnhDN+JEP0CumIYggQPw
	Ku4Byh096QSV0V2XoQ8J5kmnjC3RUEdMXFwo6Vg3qrsgxLAjCmzXGye9hDZcqQ5uUc8zw3VkCVM
	zm5t1VZOvpMmsamVL6xCpoptWHLUtGD9UPCDDgqW4BJZ9I7LI+iZfcTOJIIZiS4q+Tg==
X-Received: by 2002:ac8:304f:: with SMTP id g15mr18334458qte.306.1556302686050;
        Fri, 26 Apr 2019 11:18:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFOaMlS0a2ZLKSOP2xRaOXtBF29mR/W27qVktA6O5+AlhiooR3hPPrW+X6zwaxggupUTgo
X-Received: by 2002:ac8:304f:: with SMTP id g15mr18334413qte.306.1556302685378;
        Fri, 26 Apr 2019 11:18:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556302685; cv=none;
        d=google.com; s=arc-20160816;
        b=GRT2lp1Q13Px2018KI8bntppnTqYy/s+9goKWIs887/yzOsdbmkqohCtT1lPVAyZTS
         l0gg33vsNPRamVA7mt0x1dYezHVmYCxZbYefeHML9XxYdv4cIfLH80AY/xF7sL99YxYc
         YF1wrHLxtfagCfR6CxmPxHVW7fKD5WyhE2B0wxXKWssEKNd8A8xSJyERbgNNSjiZmmfo
         YyHOlQVcywJ2ZmmJslSammqPmnhyawdt8K+ASr/w2cnbxxVxNY3x/rmyt2gkf5YJ0TrR
         ItCwF3g0/aPzeDjei/nuE7bH5Xs0+FjqcE9KIvQNpIKY1LHTKMzptlhZExXcGiktG5rx
         qSVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v+8CnCpasp8Hdluh1oYE6LpD4uqKpxB7qAZp4XOOo9c=;
        b=X3CM3UQVIfbWSD2DB3Vy4PXhPagvhpdemLOjiRL9VZhERErP6ARoNHa6j4xwcmbaeY
         ND/DfL3JlezhxEwljMi7L1zPwcPFxnPXFddc4ErqEt9s3IcV2Oo5TjcO9p1x4xBAuVyI
         uPdygs6ab05uW9zx09Db4X80VZFyd1LUne2Wb021Eookb+Bd6d0frflXC1tf9AEx4/iJ
         YFipmdF3dRbQ3AnGOMUJCmAS/RfSeflN2+/Z2sn89OWjkEtHTOlsRwTtE4xASlZFWor0
         S3Lu5SimQSx4c/VRoYRgLj1zbOwxxCUbB6E9rIGnYJaJYkKR/1r5xdt9d2nK2L3wA97j
         qpng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si8468772qvm.77.2019.04.26.11.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 11:18:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 93895753CB;
	Fri, 26 Apr 2019 18:18:04 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DFC2A608AC;
	Fri, 26 Apr 2019 18:18:03 +0000 (UTC)
Date: Fri, 26 Apr 2019 14:18:02 -0400
From: Brian Foster <bfoster@redhat.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 3/8] xfs: flush page mappings as part of setting immutable
Message-ID: <20190426181759.GD34536@bfoster>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552788742.20411.8968554209133632884.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552788742.20411.8968554209133632884.stgit@magnolia>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 26 Apr 2019 18:18:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:04:47PM -0700, Darrick J. Wong wrote:
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
> immutable flag so that all mappings will become read-only again and
> therefore programs cannot continue to write to writable mappings.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/xfs_ioctl.c |   52 +++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 45 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 21d6f433c375..de35cf4469f6 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1009,6 +1009,31 @@ xfs_diflags_to_linux(
>  #endif
>  }
>  
> +/*
> + * Lock the inode against file io and page faults, then flush all dirty pages
> + * and wait for writeback and direct IO operations to finish.  Returns with
> + * the relevant inode lock flags set in @join_flags.  Caller is responsible for
> + * unlocking even on error return.
> + */
> +static int
> +xfs_ioctl_setattr_flush(
> +	struct xfs_inode	*ip,
> +	int			*join_flags)
> +{
> +	struct inode		*inode = VFS_I(ip);
> +
> +	/* Already locked the inode from IO?  Assume we're done. */
> +	if (((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL)) ==
> +			     (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
> +		return 0;
> +

Ok, so I take it this is because the xfs_setattr_path() can call down
into here via dax_invalidate() and then subsequently via the immutable
check. Instead of burying this down here, could we just check join_flags
!= 0 prior to the second setattr_flush() call? Otherwise this looks Ok
to me.

Brian

> +	/* Lock and flush all mappings and IO in preparation for flag change */
> +	*join_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
> +	xfs_ilock(ip, *join_flags);
> +	inode_dio_wait(inode);
> +	return filemap_write_and_wait(inode->i_mapping);
> +}
> +
>  static int
>  xfs_ioctl_setattr_xflags(
>  	struct xfs_trans	*tp,
> @@ -1103,25 +1128,22 @@ xfs_ioctl_setattr_dax_invalidate(
>  	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
>  		return 0;
>  
> -	if (S_ISDIR(inode->i_mode))
> +	if (!S_ISREG(inode->i_mode))
>  		return 0;
>  
>  	/* lock, flush and invalidate mapping in preparation for flag change */
> -	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> -	error = filemap_write_and_wait(inode->i_mapping);
> +	error = xfs_ioctl_setattr_flush(ip, join_flags);
>  	if (error)
>  		goto out_unlock;
>  	error = invalidate_inode_pages2(inode->i_mapping);
>  	if (error)
>  		goto out_unlock;
> -
> -	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
>  	return 0;
>  
>  out_unlock:
> -	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> +	xfs_iunlock(ip, *join_flags);
> +	*join_flags = 0;
>  	return error;
> -
>  }
>  
>  /*
> @@ -1367,6 +1389,22 @@ xfs_ioctl_setattr(
>  	if (code)
>  		goto error_free_dquots;
>  
> +	/*
> +	 * Wait for all pending directio and then flush all the dirty pages
> +	 * for this file.  The flush marks all the pages readonly, so any
> +	 * subsequent attempt to write to the file (particularly mmap pages)
> +	 * will come through the filesystem and fail.
> +	 */
> +	if (S_ISREG(VFS_I(ip)->i_mode) && !IS_IMMUTABLE(VFS_I(ip)) &&
> +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
> +		code = xfs_ioctl_setattr_flush(ip, &join_flags);
> +		if (code) {
> +			xfs_iunlock(ip, join_flags);
> +			join_flags = 0;
> +			goto error_free_dquots;
> +		}
> +	}
> +
>  	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
>  	if (IS_ERR(tp)) {
>  		code = PTR_ERR(tp);
> 

