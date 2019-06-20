Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85513C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 456522070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 456522070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D58928E0002; Thu, 20 Jun 2019 10:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D07C48E0001; Thu, 20 Jun 2019 10:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF75C8E0002; Thu, 20 Jun 2019 10:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7388B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:00:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so4414142eda.9
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:00:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RhPrggSwUXWePd9F4ptGWxocknThYvUSkEbzphlxStU=;
        b=GwKnq1sq4j++5jErSwZkSeEUVLmwzEGuG6GZ6JDUh8Q1iPfoZ2KXCfaKBZL4mhClzk
         gzYc+PC8AbHVnDK+Lma4tVjfkjdggnwXTFU9t7lm+wqPraguuDixtNmbLdWoHnfwhAxR
         VgQ4VO6Lv5yB77YVmavpTm6caRed57XmTQ1+rXSJjJc46n4RJMI96B0O1EIi9PCtIU85
         2PYpWo2KdwoACnNKdvZEu6f01wObCev7mol6OJfEJFosL/FABlY6h9tGJdvuLi/z/NRk
         IG1ityMoxuI1ZRTZsSaenaChdf7cnNknW7CMpzUrpy83G+SvL7A/L0wJ/IeuoQsRFYzH
         11Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWZjnw3gCQoylVuenWJm4U5mKhaM1enotx9serU9JTxjx8U4wdm
	oV2vfZWQz9v6jdr5no3HqNxaFtL30ehzcTN9hPBY1Aq+OBOjaMqZyVZilmfW7QIcNW9FiHS3KiG
	fWVFDyA/G5DqCRMtyG33Psuaadi0aSZCgcOO6GgDXkBF/1jU8kzfhI85XAWq2O1L4CA==
X-Received: by 2002:a50:97ac:: with SMTP id e41mr82978476edb.27.1561039230826;
        Thu, 20 Jun 2019 07:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAokpTP//a0Ph/AX877RVNevOeSiFeCmBnPQwGvBVMFxRlzmp0Lc+Lr5806i/x5Seu/+ml
X-Received: by 2002:a50:97ac:: with SMTP id e41mr82978255edb.27.1561039229411;
        Thu, 20 Jun 2019 07:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561039229; cv=none;
        d=google.com; s=arc-20160816;
        b=GF3jVH5dySpT6dQHOlFu07S3EgyISlUPK3ZhjJQ31c1pAbry5ZEXHEZKfoU2VIWpM+
         r/7D4YHgi8Pngak4nsOEe4mUFeSMoyg7bKYdAJt3WYf0F+NdwiDpsD9P6YdLfDV/0J6T
         xN4HULerYYjKSQ6kGxQok9U94Y0RFFAj04UOI9dOdzLUPjUtSY0rgUAC7GDejATWfLdX
         lhZIi8vmIGAcSIOLW7vxUTApw5NdeeuYE6dxYBZXqVjpD2Vj677tCLo+Iomh7AFmF2O+
         nhrCg7q8tnF1Sih8cCw3nyAJH5wzOOYHWKhpqPO8hE4rbjKToMCrLwfgwPA44JxYftPR
         WCUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RhPrggSwUXWePd9F4ptGWxocknThYvUSkEbzphlxStU=;
        b=qe+zz7dfsX3nTlzOGtSSg50XYuB/XVww3DUUzfPpV/+UgGpPWRBdRrWbXFhMYY0bNY
         vHNbGZ0Yqfe3yX5tA0IyrJ84PBVULnbhxQ3QmYhEM8ZRGYrmqkUSRtW1Pkbbkh35YfNQ
         gMrtmy5n+OgpOkr196YszjTmq9+EUOIDKPhKbtZCFF33Y8v4GR8PIGSsCicG1DZPc9WA
         MKhEIgKLfEmPByEkb0erVjWaqnCJVohb2l6VoJPKz0k+q9/ifCgkgE198YPrXVtAJH+T
         5ejpIPB7pf0yRtdiKDKp9C91Zvv73qbotVdmE0aus6a1vC0xI7jEMKby5DTJj3YKlJdd
         GnYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c58si17517029ede.408.2019.06.20.07.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8BBB1AEF8;
	Thu, 20 Jun 2019 14:00:28 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 1187D1E434F; Thu, 20 Jun 2019 16:00:28 +0200 (CEST)
Date: Thu, 20 Jun 2019 16:00:28 +0200
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
Subject: Re: [PATCH 2/6] vfs: flush and wait for io when setting the
 immutable flag via SETFLAGS
Message-ID: <20190620140028.GH30243@quack2.suse.cz>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
 <156022838496.3227213.3771632042609589318.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156022838496.3227213.3771632042609589318.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 21:46:25, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
> need to ensure that userspace can't continue to write the file after the
> file becomes immutable.  To make that happen, we have to flush all the
> dirty pagecache pages to disk to ensure that we can fail a page fault on
> a mmap'd region, wait for pending directio to complete, and hope the
> caller locked out any new writes by holding the inode lock.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

...

> diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
> index 6aa1df1918f7..a05341b94d98 100644
> --- a/fs/ext4/ioctl.c
> +++ b/fs/ext4/ioctl.c
> @@ -290,6 +290,9 @@ static int ext4_ioctl_setflags(struct inode *inode,
>  	jflag = flags & EXT4_JOURNAL_DATA_FL;
>  
>  	err = vfs_ioc_setflags_check(inode, oldflags, flags);
> +	if (err)
> +		goto flags_out;
> +	err = vfs_ioc_setflags_flush_data(inode, flags);
>  	if (err)
>  		goto flags_out;
>  

...

> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8dad3c80b611..9c899c63957e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -3548,7 +3548,41 @@ static inline struct sock *io_uring_get_socket(struct file *file)
>  
>  int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags);
>  
> +/*
> + * Do we need to flush the file data before changing attributes?  When we're
> + * setting the immutable flag we must stop all directio writes and flush the
> + * dirty pages so that we can fail the page fault on the next write attempt.
> + */
> +static inline bool vfs_ioc_setflags_need_flush(struct inode *inode, int flags)
> +{
> +	if (S_ISREG(inode->i_mode) && !IS_IMMUTABLE(inode) &&
> +	    (flags & FS_IMMUTABLE_FL))
> +		return true;
> +
> +	return false;
> +}
> +
> +/*
> + * Flush file data before changing attributes.  Caller must hold any locks
> + * required to prevent further writes to this file until we're done setting
> + * flags.
> + */
> +static inline int inode_flush_data(struct inode *inode)
> +{
> +	inode_dio_wait(inode);
> +	return filemap_write_and_wait(inode->i_mapping);
> +}
> +
> +/* Flush file data before changing attributes, if necessary. */
> +static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
> +{
> +	if (vfs_ioc_setflags_need_flush(inode, flags))
> +		return inode_flush_data(inode);
> +	return 0;
> +}
> +

But this is racy at least for page faults, isn't it? What protects you
against write faults just after filemap_write_and_wait() has finished?
So either you need to set FS_IMMUTABLE_FL before flushing data or you need
to get more protection from the fs than just i_rwsem. In the case of ext4
that would be i_mmap_rwsem but other filesystems don't have equivalent
protection...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

