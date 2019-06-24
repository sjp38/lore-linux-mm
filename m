Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FC77C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A3BE20449
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:13:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A3BE20449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4D778E0003; Mon, 24 Jun 2019 07:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFE888E0002; Mon, 24 Jun 2019 07:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ECE58E0003; Mon, 24 Jun 2019 07:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7618E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:13:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so20026232edt.4
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:13:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4ohSn2mg7XvN0khmY8SV975QiTEy30oR4Ocu/GECpYg=;
        b=pFFapeyQL2lY3OQ1AWjefLxJgnD8GYDBcGFOccglvtd7AqM2svszBKD24rahDILX3C
         r991jQ8iUG2VHyC9cQS2Spat9HbjxCof0BbNkkNOPA6uluZWyENfwzP42W/vMQC69zf5
         KEmhHgAGiqqXcmBmxv1bsf4oy4x5Fn9XJa8yl5jCopv3aksSd9bytcmCSfV2dhi5E1kf
         JWeauw/KqVp8XTGV81OLW48G1DOOQEa+Ke+o5GgNtS1m6tDO/Zi2fz7ZxkU74x/zpxSN
         QYQrTkB6JsU2UzBj8SCSkGGJv+RHX4C1uNAokDK1daShOxvrR0R2CsEtPqTBkbzUbSjS
         Iwow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUjtOh2T8yqfQ9zXvNy6Y1HPreo6LvBDphJqpM2eP47PAKJ8VD6
	CRXye6d43daSTOntiVikAwNEOC0zEKJVhqNErpw9awo1CgHg5kh91JwoatyhyVYr9mkHmG5+Dft
	WVfRHCFz1i4e4M4hF/jNukxe02HpD/2q2LkatQpIZNkdgr9S4tczCOcLS2Eb7yGaB2Q==
X-Received: by 2002:a05:6402:6d0:: with SMTP id n16mr13469165edy.168.1561374833807;
        Mon, 24 Jun 2019 04:13:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhrCtOHOl+qOTfR0Om4OfP3azlZiAL/7KgtQ5aOpLN5EDbkwZ7mwFylXiFzv0bp3AuY3VG
X-Received: by 2002:a05:6402:6d0:: with SMTP id n16mr13469077edy.168.1561374832874;
        Mon, 24 Jun 2019 04:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561374832; cv=none;
        d=google.com; s=arc-20160816;
        b=J3b5jqTe0Eomg0X7goXpzzGRPXQofoT8sVWU2k1QzM+6kGZiekDlQhyVaKZMJyYcKV
         Kg+GbC45Q7yVhfvRX8C9KDNxk+f8shyb+0WdE4sWlgFe1pZ1E27dYFQTstHgat9qShcN
         f4UFN8gg9mpP4QjWtqkzSz3u7FpiWSs/MZuhKNAdiafC6Wo2arET5GEOyBm+Rg2Qju8F
         zgqqbm5VnbE4XleQC3N1+Qcd+6CAtQyMY2y9C4wcyNSlpiQLosrCe0dem6I+cvxrDrT9
         waxjQTwxrAzw6V0D/bUBamFKLBAB2iLTamEFZLMgF1QbHiQi23+6bMe8GppHUW8c92pS
         KVtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4ohSn2mg7XvN0khmY8SV975QiTEy30oR4Ocu/GECpYg=;
        b=ytZ1pZdOU8lMI5VBF2KIGkMd/EsXCYF/trxk8qH63B3O1yKGFfCYBwpRTZ17t9QJAR
         8mNyOadiN35t5z2I0UVw0Okvd+n2l5XYFff1AGnBZtBfXZNuOoLViY7gUdbaaHUBgAiS
         3mrNvTaEaaY1wOrYwA+UsjFcq1R3xz3g5TKa/kU9yTFhQfTmru+eEYlxOuhKtDDG15WZ
         TDYV5EM2Zq/5eX3x7ItgzAj96T5GG/SdFRFk9DSSsHq/2f/Z6eNsontVI+qJnUj6/cMR
         vkj3I9NGyfI7wds6YcwG5tg/Zb6mYR/0phJ7tBVQZivoGROyb68ylXjgnFT6z+LEGFBy
         DHPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si8635306edh.234.2019.06.24.04.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 04:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE700AC20;
	Mon, 24 Jun 2019 11:13:51 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 6211D1E2F23; Mon, 24 Jun 2019 13:13:49 +0200 (CEST)
Date: Mon, 24 Jun 2019 13:13:49 +0200
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
Subject: Re: [PATCH 1/7] mm/fs: don't allow writes to immutable files
Message-ID: <20190624111349.GF32376@quack2.suse.cz>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116141836.1664939.12249697737780481978.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156116141836.1664939.12249697737780481978.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 16:56:58, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Once the flag is set, it is enforced for quite a few file operations,
> such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
> don't check for immutability when doing a write(), a PROT_WRITE mmap(),
> a truncate(), or a write to a previously established mmap.
> 
> If a program has an open write fd to a file that the administrator
> subsequently marks immutable, the program still can change the file
> contents.  Weird!
> 
> The ability to write to an immutable file does not follow the manpage
> promise that immutable files cannot be modified.  Worse yet it's
> inconsistent with the behavior of other syscalls which don't allow
> modifications of immutable files.
> 
> Therefore, add the necessary checks to make the write, mmap, and
> truncate behavior consistent with what the manpage says and consistent
> with other syscalls on filesystems which support IMMUTABLE.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/attr.c    |   13 ++++++-------
>  mm/filemap.c |    3 +++
>  mm/memory.c  |    3 +++
>  mm/mmap.c    |    8 ++++++--
>  4 files changed, 18 insertions(+), 9 deletions(-)
> 
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index d22e8187477f..1fcfdcc5b367 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -233,19 +233,18 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
>  
>  	WARN_ON_ONCE(!inode_is_locked(inode));
>  
> -	if (ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) {
> -		if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
> -			return -EPERM;
> -	}
> +	if (IS_IMMUTABLE(inode))
> +		return -EPERM;
> +
> +	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
> +	    IS_APPEND(inode))
> +		return -EPERM;
>  
>  	/*
>  	 * If utimes(2) and friends are called with times == NULL (or both
>  	 * times are UTIME_NOW), then we need to check for write permission
>  	 */
>  	if (ia_valid & ATTR_TOUCH) {
> -		if (IS_IMMUTABLE(inode))
> -			return -EPERM;
> -
>  		if (!inode_owner_or_capable(inode)) {
>  			error = inode_permission(inode, MAY_WRITE);
>  			if (error)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index aac71aef4c61..dad85e10f5f8 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2935,6 +2935,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
>  	loff_t count;
>  	int ret;
>  
> +	if (IS_IMMUTABLE(inode))
> +		return -EPERM;
> +
>  	if (!iov_iter_count(from))
>  		return 0;
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd0c317..4311cfdade90 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2235,6 +2235,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
>  
>  	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>  
> +	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
> +		return VM_FAULT_SIGBUS;
> +
>  	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
>  	/* Restore original flags so that caller is not surprised */
>  	vmf->flags = old_flags;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..ac1e32205237 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1483,8 +1483,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  		case MAP_SHARED_VALIDATE:
>  			if (flags & ~flags_mask)
>  				return -EOPNOTSUPP;
> -			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
> -				return -EACCES;
> +			if (prot & PROT_WRITE) {
> +				if (!(file->f_mode & FMODE_WRITE))
> +					return -EACCES;
> +				if (IS_IMMUTABLE(file_inode(file)))
> +					return -EPERM;
> +			}
>  
>  			/*
>  			 * Make sure we don't allow writing to an append-only
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

