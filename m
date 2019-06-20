Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B6D6C4646B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:03:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBDA92083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:03:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBDA92083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171C78E0003; Thu, 20 Jun 2019 10:03:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 146188E0001; Thu, 20 Jun 2019 10:03:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05B938E0003; Thu, 20 Jun 2019 10:03:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B10D98E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:03:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so4376492edw.20
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:03:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ToNfqA1qtuKBR7PgDNN9N50tBNymGFS9RPUY+mCXJFo=;
        b=PjltlBd2lXpQPiSZqcbOM+zQlHVVH0Xl4RpbGRGcfAGpTEEOyiOM6MQEw9XnIPtvNP
         Vb4Sv0wsyLoLSB22GIJ1+wvWwoLH4h3wun+T7pMoi05UdXkVydpNaKUc8O1wdq++Y+KE
         c+gczzG8mb448XW7LJNTlk0xWJYR5KeH1xlFI76Y3NtcaKu9UYy4JMmiKheROMaHjDJ/
         Kh2byMimBtFLRr6X4eGOWCAlc+aD7DQYCQjUzLgoosQ7gbjMSGBMB5tztGDYsKk0CMmi
         9dqoEqL9yiwjBQy0jpNG1M6MDu4NkrnMXn2B8wD/SyRwRnncnhIv6tGaMEvuYmsy1lP3
         FSxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAX8jmz7aar8jhfsugQFe/NEl8ZYwvcMKsn3iypSvkIHJUJFF4QQ
	cAeop6kbJh+EpbJ9ujTTCZubz82DDstH8jyG6t5qru06+Np8gYDxA3L7XZLiAYA87mJUlAbn97A
	GV+j/WhVPxsa6c6Cw4vGQf9Xf1XRohEJwpv1V6W6IlVL+hoKYJSsqqsnUjVGZ/bpruA==
X-Received: by 2002:a17:906:3953:: with SMTP id g19mr59842431eje.242.1561039427259;
        Thu, 20 Jun 2019 07:03:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxv+hJlLHke300bMMsy907nOeh8EqfAZWGTOD5z/EWDH1iw3biFSkESxLqaE4fJ6GF2H08q
X-Received: by 2002:a17:906:3953:: with SMTP id g19mr59842375eje.242.1561039426559;
        Thu, 20 Jun 2019 07:03:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561039426; cv=none;
        d=google.com; s=arc-20160816;
        b=nIwHOJgXRCv2ZuaWFUEuc5UCQ6HAEePxFsWfVoqvzju7hYshAAMxTYrAJuL9oeAncK
         M/QtFK17MFuCTLWGsH1gfYgVE41vTPORqI0NoeqhcNfqWl3SOLA7IVIE9ITBuu9Y0pSR
         rPX+fWbL1iyfSHWQb3LD6jB1EgWb4n8z9+pS3AN6yvXupuOnzpt0HhK0OP6FkHIf7Hmn
         9FMndFX2Qj58MjKMTygE48qqC/zkzBYObTw++P8IkLILPP+FWS7H73olAjy0tuG8/btY
         BkduBV/vy4Nb7cvI3I36UdWqVeXEjlEqTQhgIfelbOP8WKaZcfcQ2ONDhgKr9lhamGR9
         G7pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ToNfqA1qtuKBR7PgDNN9N50tBNymGFS9RPUY+mCXJFo=;
        b=IXo2K/m7hqgXpNAo/fyIQYK+GztMRQfuH/FXdXuNlotIdIlMqSRcoECY+eOpZzMzpN
         EwfEq6GxpTGcXKQfoFvbG+Ws5WlnyQvALczWxUuLEkE7Y1RdmRGb75zLzMf9UvA4Hljy
         2YS41J2Q2LcDCNjTwAZqTwT7sdU0IXK2x1OwywY3hmZa43qfyfPskIFORlWtESGoPL+D
         9rtZpamGxhefsduVUwB31rhHZdTWhHmK2OqTnUjOvwGxzCMT29VpzKDWkRstu8pw1drZ
         ARTCCFWcT23Z/zmQUZvha5sW2AVcDfnLzUVTrtKwTpVDQmvnFVZ0bnQXrp5vgfcYpyOl
         HHrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h47si14974214ede.173.2019.06.20.07.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:03:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 05638AF85;
	Thu, 20 Jun 2019 14:03:46 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id A12B31E434F; Thu, 20 Jun 2019 16:03:45 +0200 (CEST)
Date: Thu, 20 Jun 2019 16:03:45 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
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
Message-ID: <20190620140345.GI30243@quack2.suse.cz>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
 <156022840560.3227213.4776913678782966728.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156022840560.3227213.4776913678782966728.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 21:46:45, Darrick J. Wong wrote:
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
> which means that we can update inode flags and project ids and extent
> size hints on supposedly immutable files.  Therefore, reject setflags
> and fssetxattr calls on an immutable file if the file is immutable and
> will remain that way.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/inode.c |   31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index a3757051fd55..adfb458bf533 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2184,6 +2184,17 @@ int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags)
>  	    !capable(CAP_LINUX_IMMUTABLE))
>  		return -EPERM;
>  
> +	/*
> +	 * We aren't allowed to change any other flags if the immutable flag is
> +	 * already set and is not being unset.
> +	 */
> +	if ((oldflags & FS_IMMUTABLE_FL) &&
> +	    (flags & FS_IMMUTABLE_FL)) {
> +		if ((oldflags & ~FS_IMMUTABLE_FL) !=
> +		    (flags & ~FS_IMMUTABLE_FL))

This check looks a bit strange when you've just check FS_IMMUTABLE_FL isn't
changing... Why not just oldflags != flags?

> +	if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
> +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
> +		if ((old_fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE) !=
> +		    (fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE))

Ditto here...

> +			return -EPERM;
> +		if (old_fa->fsx_projid != fa->fsx_projid)
> +			return -EPERM;
> +		if ((fa->fsx_xflags & (FS_XFLAG_EXTSIZE |
> +				       FS_XFLAG_EXTSZINHERIT)) &&
> +		    old_fa->fsx_extsize != fa->fsx_extsize)
> +			return -EPERM;
> +		if ((old_fa->fsx_xflags & FS_XFLAG_COWEXTSIZE) &&
> +		    old_fa->fsx_cowextsize != fa->fsx_cowextsize)
> +			return -EPERM;
> +	}
> +
>  	/* Extent size hints of zero turn off the flags. */
>  	if (fa->fsx_extsize == 0)
>  		fa->fsx_xflags &= ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

