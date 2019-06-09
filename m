Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA275C2BCA1
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 13:00:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F34208C0
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 13:00:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lvFMTFuV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F34208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E24916B0266; Sun,  9 Jun 2019 09:00:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD5576B0269; Sun,  9 Jun 2019 09:00:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC4546B026A; Sun,  9 Jun 2019 09:00:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90A126B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 09:00:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k23so4859137pgh.10
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 06:00:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=NQudY9FFsAW79M5c5385NSMdE/hIO+weB7ZIwQN1QBA=;
        b=X40d7ChBYnBN59bmvB8TZOPitk4m3k0tdeh0SpNJaQ5EKdWL6xkqa2cex/a5G43vnY
         LndosMt0t2GRfOU0R406eo3tEQwtrOn7LlYUbUL+xSYwD6mNczDBi+a8Dez5Eik009TM
         6XkjsF6vHr33PETdRBuXPKtyXhTrrATQCmjwYVTwFeKEz2GpCSrf4OokKHpaL7IOrm89
         Wpily7psA/SSe1GLciRAEe4FaWv/f02nSvncB0HQiJ9UTCCdONWUZmRH6B5MrXCd7yKL
         OtMVzBgVJ62t+IIrvx1RH4UT2V9wnsXASZ1fKGf1vssW6Qf6Hl/TvfCexJaaT09BOudn
         lmjQ==
X-Gm-Message-State: APjAAAUW0lFiUIoungfQzjxtsMCBUXmiar8pja4rg7qmWfx4T6rgNTEX
	4rv7hExqK/fQZQG4i+PeQEnYveyiDwD681DyMSFucCI16dFVL6VhHl+NvVyohfIxUBSWg4afJWf
	7l++taJhArPIhZ/WMXfUgCHj4AGlD9f1UTEDL9vjRzbVjfdYoITxK70HeIildPKTEiw==
X-Received: by 2002:a63:18e:: with SMTP id 136mr11340322pgb.277.1560085230892;
        Sun, 09 Jun 2019 06:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIX0a6SGs2dAaIVvt2LWnHWqC9Hde5bvmxZoJbclUlZB0Jejc/Cnf1KZ19ogdOhZwmjoYv
X-Received: by 2002:a63:18e:: with SMTP id 136mr11340260pgb.277.1560085229875;
        Sun, 09 Jun 2019 06:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560085229; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCWTxTIXGNi5PT7kkDb588/0NotEqH3DCPqg6MG1C2yVhrVjndjqr5/c1nmqKJ93ij
         ha5obTxngn+5L/RvwklqhYa+Yqe6i/KRMwxtAOiFaUh45QVt73jfCTf3UGdn2DUfuVBc
         NIXdUXXGcGe5DgjcMPHjEYOJ9PUuU46xk56zS+OnY1CW6qEqRW+MHR9fFgomNYqu/ww+
         ync42zJQwzddnS9adRKJSJJY5CV3QOI+xnDCVz4fIBMuoCvumkstHko2iyAhIprpyNwl
         G+EvhaodnZwsg5eWD4EgeT4Ka9yB5Y3Bu/Ec2/GrVyMj0WTpl7Ub/6O/ppVVFvry5vAM
         SLWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=NQudY9FFsAW79M5c5385NSMdE/hIO+weB7ZIwQN1QBA=;
        b=YtE30sHlnz2LJ95B62XdITuU4bDzHu5hrxDmK1zRORFMb/qhL8l14vNZufQiajj3Rj
         awewyv2yFkgsg7MoYQlHh706KQVGTE3AoYQ5mLfYPz52XTKn0uJsPbnc1aahONV0twXa
         HQ+gDSXqGFcqqDYXkc2BbUEpKrvs2t9nRCIkqlYl0avTewOhu+gUt12EaY7/YZ3SKk4X
         KwhQiOzPSFhScWMVidteOuxFG6rHcMWOwc8nTwamwli9ygktiLNT2znq4JtL1NYrC2No
         OAPy7/sEiJ1vHmJrHU1k7Ss6BxQoHYDIkyi9wKpiUK5U4l9ycLO9iBxAvukKwi3e5nea
         bAyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lvFMTFuV;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s17si7334255pjp.26.2019.06.09.06.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 06:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lvFMTFuV;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from vulcan (047-135-017-034.res.spectrum.com [47.135.17.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9FCDF20868;
	Sun,  9 Jun 2019 13:00:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560085229;
	bh=L0yNfd1FSvmAPkTQHTncEd561Zv88fasReuSNoRcSdw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=lvFMTFuVGn0xl1kfRqKAez4aHevZIYYINphCjUN2Y3kNxo7awfqz8Id4dnn3IO+F7
	 WH0wPcq4HaJWuCD2v9oC8sDF2z/9TRL7O8VR5rzCGVdWP7vtIYJILJDWGT+7uOAvIq
	 25x4b+dR6F/ecGxQ5APky5IMNsDLyOjVHNrAph1E=
Message-ID: <4e5eb31a41b91a28fbc83c65195a2c75a59cfa24.camel@kernel.org>
Subject: Re: [PATCH RFC 02/10] fs/locks: Export F_LAYOUT lease to user space
From: Jeff Layton <jlayton@kernel.org>
To: ira.weiny@intel.com, Dan Williams <dan.j.williams@intel.com>, Jan Kara
 <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner
 <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org, Andrew
	Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?ISO-8859-1?Q?J=E9r=F4me?= Glisse
	 <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, 
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Date: Sun, 09 Jun 2019 09:00:24 -0400
In-Reply-To: <20190606014544.8339-3-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
	 <20190606014544.8339-3-ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-05 at 18:45 -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> GUP longterm pins of non-pagecache file system pages (eg FS DAX) are
> currently disallowed because they are unsafe.
> 
> The danger for pinning these pages comes from the fact that hole punch
> and/or truncate of those files results in the pages being mapped and
> pinned by a user space process while DAX has potentially allocated those
> pages to other processes.
> 
> Most (All) users who are mapping FS DAX pages for long term pin purposes
> (such as RDMA) are not going to want to deallocate these pages while
> those pages are in use.  To do so would mean the application would lose
> data.  So the use case for allowing truncate operations of such pages
> is limited.
> 
> However, the kernel must protect itself and users from potential
> mistakes and/or malicious user space code.  Rather than disabling long
> term pins as is done now.   Allow for users who know they are going to
> be pinning this memory to alert the file system of this intention.
> Furthermore, allow users to be alerted such that they can react if a
> truncate operation occurs for some reason.
> 
> Example user space pseudocode for a user using RDMA and wanting to allow
> a truncate would look like this:
> 
> lease_break_sigio_handler() {
> ...
> 	if (sigio.fd == rdma_fd) {
> 		complete_rdma_operations(...);
> 		ibv_dereg_mr(mr);
> 		close(rdma_fd);
> 		fcntl(rdma_fd, F_SETLEASE, F_UNLCK);
> 	}
> }
> 
> setup_rdma_to_dax_file() {
> ...
> 	rdma_fd = open(...)
> 	fcntl(rdma_fd, F_SETLEASE, F_LAYOUT);

I'm not crazy about this interface. F_LAYOUT doesn't seem to be in the
same category as F_RDLCK/F_WRLCK/F_UNLCK.

Maybe instead of F_SETLEASE, this should use new
F_SETLAYOUT/F_GETLAYOUT cmd values? There is nothing that would prevent
you from setting both a lease and a layout on a file, and indeed knfsd
can set both.

This interface seems to conflate the two.

> 	sigaction(SIGIO, ...  lease_break ...);
> 	ptr = mmap(rdma_fd, ...);
> 	mr = ibv_reg_mr(ptr, ...);
> 	do_rdma_stuff(...);
> }
> 
> Follow on patches implement the notification of the lease holder on
> truncate as well as failing the truncate if the GUP pin is not released.
> 
> This first patch exports the F_LAYOUT lease type and allows the user to set
> and get it.
> 
> After the complete series:
> 
> 1) Failure to obtain a F_LAYOUT lease on an open FS DAX file will result
>    in a failure to GUP pin any pages in that file.  An example of a call
>    which results in GUP pin is ibv_reg_mr().
> 2) While the GUP pin is in place (eg MR is in use) truncates of the
>    affected pages will fail.
> 3) If the user registers a sigaction they will be notified of the
>    truncate so they can react.  Failure to react will result in the
>    lease being revoked after <sysfs>/lease-break-time seconds.  After
>    this time new GUP pins will fail without a new lease being taken.
> 4) A truncate will work if the pages being truncated are not actively
>    pinned at the time of truncate.  Attempts to pin these pages after
>    will result in a failure.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  fs/locks.c                       | 36 +++++++++++++++++++++++++++-----
>  include/linux/fs.h               |  2 +-
>  include/uapi/asm-generic/fcntl.h |  3 +++
>  3 files changed, 35 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 0cc2b9f30e22..de9761c068de 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -191,6 +191,8 @@ static int target_leasetype(struct file_lock *fl)
>  		return F_UNLCK;
>  	if (fl->fl_flags & FL_DOWNGRADE_PENDING)
>  		return F_RDLCK;
> +	if (fl->fl_flags & FL_LAYOUT)
> +		return F_LAYOUT;
>  	return fl->fl_type;
>  }
>  
> @@ -611,7 +613,8 @@ static const struct lock_manager_operations lease_manager_ops = {
>  /*
>   * Initialize a lease, use the default lock manager operations
>   */
> -static int lease_init(struct file *filp, long type, struct file_lock *fl)
> +static int lease_init(struct file *filp, long type, unsigned int flags,
> +		      struct file_lock *fl)
>  {
>  	if (assign_type(fl, type) != 0)
>  		return -EINVAL;
> @@ -621,6 +624,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
>  
>  	fl->fl_file = filp;
>  	fl->fl_flags = FL_LEASE;
> +	if (flags & FL_LAYOUT)
> +		fl->fl_flags |= FL_LAYOUT;
>  	fl->fl_start = 0;
>  	fl->fl_end = OFFSET_MAX;
>  	fl->fl_ops = NULL;
> @@ -629,7 +634,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
>  }
>  
>  /* Allocate a file_lock initialised to this type of lease */
> -static struct file_lock *lease_alloc(struct file *filp, long type)
> +static struct file_lock *lease_alloc(struct file *filp, long type,
> +				     unsigned int flags)
>  {
>  	struct file_lock *fl = locks_alloc_lock();
>  	int error = -ENOMEM;
> @@ -637,7 +643,7 @@ static struct file_lock *lease_alloc(struct file *filp, long type)
>  	if (fl == NULL)
>  		return ERR_PTR(error);
>  
> -	error = lease_init(filp, type, fl);
> +	error = lease_init(filp, type, flags, fl);
>  	if (error) {
>  		locks_free_lock(fl);
>  		return ERR_PTR(error);
> @@ -1588,7 +1594,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
>  	int want_write = (mode & O_ACCMODE) != O_RDONLY;
>  	LIST_HEAD(dispose);
>  
> -	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
> +	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK, 0);
>  	if (IS_ERR(new_fl))
>  		return PTR_ERR(new_fl);
>  	new_fl->fl_flags = type;
> @@ -1725,6 +1731,8 @@ EXPORT_SYMBOL(lease_get_mtime);
>   *
>   *	%F_UNLCK to indicate no lease is held.
>   *
> + *	%F_LAYOUT to indicate a layout lease is held.
> + *
>   *	(if a lease break is pending):
>   *
>   *	%F_RDLCK to indicate an exclusive lease needs to be
> @@ -2015,8 +2023,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
>  	struct file_lock *fl;
>  	struct fasync_struct *new;
>  	int error;
> +	unsigned int flags = 0;
> +
> +	/*
> +	 * NOTE on F_LAYOUT lease
> +	 *
> +	 * LAYOUT lease types are taken on files which the user knows that
> +	 * they will be pinning in memory for some indeterminate amount of
> +	 * time.  Such as for use with RDMA.  While we don't know what user
> +	 * space is going to do with the file we still use a F_RDLOCK level of
> +	 * lease.  This ensures that there are no conflicts between
> +	 * 2 users.  The conflict should only come from the File system wanting
> +	 * to revoke the lease in break_layout()  And this is done by using
> +	 * F_WRLCK in the break code.
> +	 */
> +	if (arg == F_LAYOUT) {
> +		arg = F_RDLCK;
> +		flags = FL_LAYOUT;
> +	}
>  
> -	fl = lease_alloc(filp, arg);
> +	fl = lease_alloc(filp, arg, flags);
>  	if (IS_ERR(fl))
>  		return PTR_ERR(fl);
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f7fdfe93e25d..9e9d8d35ee93 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -998,7 +998,7 @@ static inline struct file *get_file(struct file *f)
>  #define FL_DOWNGRADE_PENDING	256 /* Lease is being downgraded */
>  #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
>  #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
> -#define FL_LAYOUT	2048	/* outstanding pNFS layout */
> +#define FL_LAYOUT	2048	/* outstanding pNFS layout or user held pin */
>  
>  #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
>  
> diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> index 9dc0bf0c5a6e..baddd54f3031 100644
> --- a/include/uapi/asm-generic/fcntl.h
> +++ b/include/uapi/asm-generic/fcntl.h
> @@ -174,6 +174,9 @@ struct f_owner_ex {
>  #define F_SHLCK		8	/* or 4 */
>  #endif
>  
> +#define F_LAYOUT	16      /* layout lease to allow longterm pins such as
> +				   RDMA */
> +
>  /* operations for bsd flock(), also used by the kernel implementation */
>  #define LOCK_SH		1	/* shared lock */
>  #define LOCK_EX		2	/* exclusive lock */

