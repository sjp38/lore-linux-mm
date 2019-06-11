Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC034C31E44
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92CB120872
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92CB120872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03C286B0006; Tue, 11 Jun 2019 17:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2DB86B000C; Tue, 11 Jun 2019 17:36:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1CB56B000D; Tue, 11 Jun 2019 17:36:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A757E6B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:36:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f1so10506370pfb.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5sOm7iYADBJakOPuW1mfr/hU0M6Vm95ot5Q353saeu8=;
        b=h3Hj4P5Zhp12y978Eb0MeligJwlUYTv27T9DJW6boRm0N8znhJMoPoAstEQ2ijKvxH
         7k6uH8ut9iD4O78TybIbevlYhliXDNmCB9KZqQVITkpmYDc/laP84A2UjNk/3m7SXSXj
         ViyWE2uu81Ke/Gx3X+wp1J36JASP/KjqcbUKv04ZX0Q7xoUXdWgrK/lNj144gZYljxGG
         lQp8PNF1ajIurjTzsK/lTU05Ox9VIQOL07CmJiI0SRQcB5nLqR0VWqDqgiZEudFncpvR
         UT92+u2cEudazMNCDiofMFWpb6HesyNIa/aaJCZWQ/STMg+uBDgXPTT0d+TLfYLJn3N6
         fdBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWSJOoS7bABxwqYPyuvdTMKd9iHscCitOJACZCw19oMkLHhyOjc
	7KX3UCfw0xoJTPaENGAYINnKf2q2UmtXhsaEG+xOPRTCfVj/5eka9LDtxn0KmnpjcAdy5LRU9Nl
	t7ObcH4aR1xoa2YtgsJeoVK6qQCUBplSjGhvylkmgGGS/2sain7sG/TSJWJF3HJBlUQ==
X-Received: by 2002:a65:408d:: with SMTP id t13mr21676187pgp.373.1560289016158;
        Tue, 11 Jun 2019 14:36:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFdjHsW5s22XRQ92YFAE3ZCi8ff74SIJFD6JDoYW8mS2tqpswrG2sryFz+lrlt+nMy6lnW
X-Received: by 2002:a65:408d:: with SMTP id t13mr21676118pgp.373.1560289014858;
        Tue, 11 Jun 2019 14:36:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560289014; cv=none;
        d=google.com; s=arc-20160816;
        b=NOfmaZlyDsbXryueP1YGW5PKS3N6DN+kNIdHmEasTYXPcgxHoh7nGO40wHre9+LAfL
         YqmAM1p89DrQgJtevLkfyzVAVtShHFX1YL/f8PzrYWzWxlUvwHIZTuiN+gmTaRmp16KO
         1PO3USpV+ID8UL56LamdN1U/BBtgH75I1qxfnCGXplTtAIkDNaCiewzaC0zVspLxhL2r
         IrCteS3996p1fBRX16y/GyGq95hNVr7AYMTJ2JqJqaBY+YPdxZWiUkVzaYGk/ckkWZje
         BMa3UCFiZBKzZpuTKdIKsSUDScEiPdrctI0CZAi1Be0mbeSh4i1W5eEAn6+IBvegnA9v
         urIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5sOm7iYADBJakOPuW1mfr/hU0M6Vm95ot5Q353saeu8=;
        b=oEL91ZC49R7MUwKjd3LiHpXsWkW4+Ak0SsZkG9EOxc9+hTmpGEKRWycJ9xgBm58Pjp
         RzB3jO6CWXXnNGtFr4i9VA/wYS3TIf1d+SgjOpBgiD3uZTcrhD+zf2RWyNFB/uEv7jZ6
         29CbU6PzzMkwTMRXAwtd/Xp2F89IzbVHEAjOqT6JmJ0opO2sRH1ACdVc1vfNWjz2hMsM
         4QYwVRToVwjqjEObTxFUVrtFxqzrtGZPoQK6V9YRUE49R9v6i/kSpMLSUksvlGiexVJN
         +qCpRb6r2WKhJyzMOS/35zspdlPRdUMY1tqwRJTINGVzXH5i8CPDEhihAj7LrY50kZFq
         ZO3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f17si13095394pgv.338.2019.06.11.14.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:36:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 14:36:54 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 11 Jun 2019 14:36:53 -0700
Date: Tue, 11 Jun 2019 14:38:13 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 02/10] fs/locks: Export F_LAYOUT lease to user space
Message-ID: <20190611213812.GC14336@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-3-ira.weiny@intel.com>
 <4e5eb31a41b91a28fbc83c65195a2c75a59cfa24.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e5eb31a41b91a28fbc83c65195a2c75a59cfa24.camel@kernel.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 09:00:24AM -0400, Jeff Layton wrote:
> On Wed, 2019-06-05 at 18:45 -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > GUP longterm pins of non-pagecache file system pages (eg FS DAX) are
> > currently disallowed because they are unsafe.
> > 
> > The danger for pinning these pages comes from the fact that hole punch
> > and/or truncate of those files results in the pages being mapped and
> > pinned by a user space process while DAX has potentially allocated those
> > pages to other processes.
> > 
> > Most (All) users who are mapping FS DAX pages for long term pin purposes
> > (such as RDMA) are not going to want to deallocate these pages while
> > those pages are in use.  To do so would mean the application would lose
> > data.  So the use case for allowing truncate operations of such pages
> > is limited.
> > 
> > However, the kernel must protect itself and users from potential
> > mistakes and/or malicious user space code.  Rather than disabling long
> > term pins as is done now.   Allow for users who know they are going to
> > be pinning this memory to alert the file system of this intention.
> > Furthermore, allow users to be alerted such that they can react if a
> > truncate operation occurs for some reason.
> > 
> > Example user space pseudocode for a user using RDMA and wanting to allow
> > a truncate would look like this:
> > 
> > lease_break_sigio_handler() {
> > ...
> > 	if (sigio.fd == rdma_fd) {
> > 		complete_rdma_operations(...);
> > 		ibv_dereg_mr(mr);
> > 		close(rdma_fd);
> > 		fcntl(rdma_fd, F_SETLEASE, F_UNLCK);
> > 	}
> > }
> > 
> > setup_rdma_to_dax_file() {
> > ...
> > 	rdma_fd = open(...)
> > 	fcntl(rdma_fd, F_SETLEASE, F_LAYOUT);
> 
> I'm not crazy about this interface. F_LAYOUT doesn't seem to be in the
> same category as F_RDLCK/F_WRLCK/F_UNLCK.
> 
> Maybe instead of F_SETLEASE, this should use new
> F_SETLAYOUT/F_GETLAYOUT cmd values? There is nothing that would prevent
> you from setting both a lease and a layout on a file, and indeed knfsd
> can set both.
> 
> This interface seems to conflate the two.

I've been feeling the same way.  This is why I was leaning toward a new lease
type.  I called it "F_LONGTERM" but the name is not important.

I think the concept of adding "exclusive" to the layout lease can fix this
because the NFS lease is non-exclusive where the user space one (for the
purpose of GUP pinning) would need to be.

FWIW I have not worked out exactly what this new "exclusive" code will look
like.  Jan said:

	"There actually is support for locks that are not broken after given
	timeout so there shouldn't be too many changes need."

But I'm not seeing that for Lease code.  So I'm working on something for the
lease code now.

Ira

> 
> > 	sigaction(SIGIO, ...  lease_break ...);
> > 	ptr = mmap(rdma_fd, ...);
> > 	mr = ibv_reg_mr(ptr, ...);
> > 	do_rdma_stuff(...);
> > }
> > 
> > Follow on patches implement the notification of the lease holder on
> > truncate as well as failing the truncate if the GUP pin is not released.
> > 
> > This first patch exports the F_LAYOUT lease type and allows the user to set
> > and get it.
> > 
> > After the complete series:
> > 
> > 1) Failure to obtain a F_LAYOUT lease on an open FS DAX file will result
> >    in a failure to GUP pin any pages in that file.  An example of a call
> >    which results in GUP pin is ibv_reg_mr().
> > 2) While the GUP pin is in place (eg MR is in use) truncates of the
> >    affected pages will fail.
> > 3) If the user registers a sigaction they will be notified of the
> >    truncate so they can react.  Failure to react will result in the
> >    lease being revoked after <sysfs>/lease-break-time seconds.  After
> >    this time new GUP pins will fail without a new lease being taken.
> > 4) A truncate will work if the pages being truncated are not actively
> >    pinned at the time of truncate.  Attempts to pin these pages after
> >    will result in a failure.
> > 
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  fs/locks.c                       | 36 +++++++++++++++++++++++++++-----
> >  include/linux/fs.h               |  2 +-
> >  include/uapi/asm-generic/fcntl.h |  3 +++
> >  3 files changed, 35 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 0cc2b9f30e22..de9761c068de 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -191,6 +191,8 @@ static int target_leasetype(struct file_lock *fl)
> >  		return F_UNLCK;
> >  	if (fl->fl_flags & FL_DOWNGRADE_PENDING)
> >  		return F_RDLCK;
> > +	if (fl->fl_flags & FL_LAYOUT)
> > +		return F_LAYOUT;
> >  	return fl->fl_type;
> >  }
> >  
> > @@ -611,7 +613,8 @@ static const struct lock_manager_operations lease_manager_ops = {
> >  /*
> >   * Initialize a lease, use the default lock manager operations
> >   */
> > -static int lease_init(struct file *filp, long type, struct file_lock *fl)
> > +static int lease_init(struct file *filp, long type, unsigned int flags,
> > +		      struct file_lock *fl)
> >  {
> >  	if (assign_type(fl, type) != 0)
> >  		return -EINVAL;
> > @@ -621,6 +624,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
> >  
> >  	fl->fl_file = filp;
> >  	fl->fl_flags = FL_LEASE;
> > +	if (flags & FL_LAYOUT)
> > +		fl->fl_flags |= FL_LAYOUT;
> >  	fl->fl_start = 0;
> >  	fl->fl_end = OFFSET_MAX;
> >  	fl->fl_ops = NULL;
> > @@ -629,7 +634,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
> >  }
> >  
> >  /* Allocate a file_lock initialised to this type of lease */
> > -static struct file_lock *lease_alloc(struct file *filp, long type)
> > +static struct file_lock *lease_alloc(struct file *filp, long type,
> > +				     unsigned int flags)
> >  {
> >  	struct file_lock *fl = locks_alloc_lock();
> >  	int error = -ENOMEM;
> > @@ -637,7 +643,7 @@ static struct file_lock *lease_alloc(struct file *filp, long type)
> >  	if (fl == NULL)
> >  		return ERR_PTR(error);
> >  
> > -	error = lease_init(filp, type, fl);
> > +	error = lease_init(filp, type, flags, fl);
> >  	if (error) {
> >  		locks_free_lock(fl);
> >  		return ERR_PTR(error);
> > @@ -1588,7 +1594,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
> >  	int want_write = (mode & O_ACCMODE) != O_RDONLY;
> >  	LIST_HEAD(dispose);
> >  
> > -	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
> > +	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK, 0);
> >  	if (IS_ERR(new_fl))
> >  		return PTR_ERR(new_fl);
> >  	new_fl->fl_flags = type;
> > @@ -1725,6 +1731,8 @@ EXPORT_SYMBOL(lease_get_mtime);
> >   *
> >   *	%F_UNLCK to indicate no lease is held.
> >   *
> > + *	%F_LAYOUT to indicate a layout lease is held.
> > + *
> >   *	(if a lease break is pending):
> >   *
> >   *	%F_RDLCK to indicate an exclusive lease needs to be
> > @@ -2015,8 +2023,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  	struct file_lock *fl;
> >  	struct fasync_struct *new;
> >  	int error;
> > +	unsigned int flags = 0;
> > +
> > +	/*
> > +	 * NOTE on F_LAYOUT lease
> > +	 *
> > +	 * LAYOUT lease types are taken on files which the user knows that
> > +	 * they will be pinning in memory for some indeterminate amount of
> > +	 * time.  Such as for use with RDMA.  While we don't know what user
> > +	 * space is going to do with the file we still use a F_RDLOCK level of
> > +	 * lease.  This ensures that there are no conflicts between
> > +	 * 2 users.  The conflict should only come from the File system wanting
> > +	 * to revoke the lease in break_layout()  And this is done by using
> > +	 * F_WRLCK in the break code.
> > +	 */
> > +	if (arg == F_LAYOUT) {
> > +		arg = F_RDLCK;
> > +		flags = FL_LAYOUT;
> > +	}
> >  
> > -	fl = lease_alloc(filp, arg);
> > +	fl = lease_alloc(filp, arg, flags);
> >  	if (IS_ERR(fl))
> >  		return PTR_ERR(fl);
> >  
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index f7fdfe93e25d..9e9d8d35ee93 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -998,7 +998,7 @@ static inline struct file *get_file(struct file *f)
> >  #define FL_DOWNGRADE_PENDING	256 /* Lease is being downgraded */
> >  #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
> >  #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
> > -#define FL_LAYOUT	2048	/* outstanding pNFS layout */
> > +#define FL_LAYOUT	2048	/* outstanding pNFS layout or user held pin */
> >  
> >  #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
> >  
> > diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> > index 9dc0bf0c5a6e..baddd54f3031 100644
> > --- a/include/uapi/asm-generic/fcntl.h
> > +++ b/include/uapi/asm-generic/fcntl.h
> > @@ -174,6 +174,9 @@ struct f_owner_ex {
> >  #define F_SHLCK		8	/* or 4 */
> >  #endif
> >  
> > +#define F_LAYOUT	16      /* layout lease to allow longterm pins such as
> > +				   RDMA */
> > +
> >  /* operations for bsd flock(), also used by the kernel implementation */
> >  #define LOCK_SH		1	/* shared lock */
> >  #define LOCK_EX		2	/* exclusive lock */
> 

