Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 87F256B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 17:00:40 -0400 (EDT)
Date: Thu, 25 Apr 2013 17:00:17 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366923617-dvp2vbsx-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130424232600.GB18686@cmpxchg.org>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424153951.GQ2018@cmpxchg.org>
 <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424232600.GB18686@cmpxchg.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Wed, Apr 24, 2013 at 07:26:00PM -0400, Johannes Weiner wrote:
> On Wed, Apr 24, 2013 at 07:05:35PM -0400, Naoya Horiguchi wrote:
> > On Wed, Apr 24, 2013 at 11:39:51AM -0400, Johannes Weiner wrote:
> > > On Wed, Apr 24, 2013 at 11:16:39AM -0400, Naoya Horiguchi wrote:
> > > > On Wed, Apr 24, 2013 at 04:14:54AM -0400, Johannes Weiner wrote:
> > > > > @@ -491,10 +491,13 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> > > > >  
> > > > >  	sprintf (name, "SYSV%08x", key);
> > > > >  	if (shmflg & SHM_HUGETLB) {
> > > > > +		unsigned int hugesize;
> > > > > +
> > > > >  		/* hugetlb_file_setup applies strict accounting */
> > > > >  		if (shmflg & SHM_NORESERVE)
> > > > >  			acctflag = VM_NORESERVE;
> > > > > -		file = hugetlb_file_setup(name, 0, size, acctflag,
> > > > > +		hugesize = ALIGN(size, huge_page_size(&default_hstate));
> > > > > +		file = hugetlb_file_setup(name, hugesize, acctflag,
> > > > >  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
> > > > >  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
> > > > >  	} else {
> > > > 
> > > > Would it be better to find proper hstate instead of using default_hstate?
> > > 
> > > You are probably right, I guess we can't assume default_hstate anymore
> > > after page_size_log can be passed in.
> > > 
> > > Can we have hugetlb_file_setup() return an adjusted length, or an
> > > alignment requirement?
> > 
> > Yes, it's possible if callers pass the pointer of size (length) to
> > hugetlb_file_setup() and make it adjusted inside the function.
> > And as for alignment, I think it's not a hugetlb_file_setup's job,
> > so we don't have to do it in this function.
> > 
> > > Or pull the hstate lookup into the callsites (since they pass in
> > > page_size_log to begin with)?
> > 
> > This is also a possible solution, where we might need to define and
> > export a function converting hugepage order to hstate.
> 
> After thinking about it some more, I would actually prefer this.  The
> callsites have all the information and the file setup code should not
> really care about the alignment requirements of the callers.
> 
> I.e. export something like get_hstate_idx() but which returns hstate,
> then make the callers look it up, do the alignment, pass in the
> aligned size and hstate instead of page_size_log.  Then they are free
> to use the aligned size (mmap) or use the original size (shm).

OK. I'll do this.

> > I like the former one, so wrote a patch like below.
> > # I added your Signed-off-by: because this's based on your draft patch.
> > # if you don't like it, please let me know.
> 
> Thanks, I appreciate it.  But usually if you take and modify a patch
> add the original From: line to the changelog to give credit, then add
> your own signoff and only add other people's signoff after they agree.

OK, got it.

> > @@ -929,9 +929,8 @@ static struct dentry_operations anon_ops = {
> >  	.d_dname = hugetlb_dname
> >  };
> >  
> > -struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> > -				size_t size, vm_flags_t acctflag,
> > -				struct user_struct **user,
> > +struct file *hugetlb_file_setup(const char *name, size_t *sizeptr,
> > +				vm_flags_t acctflag, struct user_struct **user,
> >  				int creat_flags, int page_size_log)
> >  {
> >  	struct file *file = ERR_PTR(-ENOMEM);
> > @@ -939,9 +938,8 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> >  	struct path path;
> >  	struct super_block *sb;
> >  	struct qstr quick_string;
> > -	struct hstate *hstate;
> > -	unsigned long num_pages;
> >  	int hstate_idx;
> > +	size_t size;
> >  
> >  	hstate_idx = get_hstate_idx(page_size_log);
> >  	if (hstate_idx < 0)
> > @@ -951,6 +949,10 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> >  	if (!hugetlbfs_vfsmount[hstate_idx])
> >  		return ERR_PTR(-ENOENT);
> >  
> > +	size = 1 << hstate_index_to_shift(hstate_idx);
> > +	if (sizeptr)
> > +		*sizeptr = ALIGN(*sizeptr, size);
> 
> You always assume the file will just be one hugepage in size?

No, this line means that *sizeptr (given by the caller) is round up
to the multiple of hugepage's size. So assuming size is 2MB, for example,
if 5MB is given it's round up to 6MB in return (3 hugepages.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
