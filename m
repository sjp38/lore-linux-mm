Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8BEAE6B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 17:03:27 -0400 (EDT)
Date: Thu, 25 Apr 2013 17:03:19 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366923799-th7oth-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <51789CE3.6020709@huawei.com>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424153951.GQ2018@cmpxchg.org>
 <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
 <51789CE3.6020709@huawei.com>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Thu, Apr 25, 2013 at 11:02:59AM +0800, Jianguo Wu wrote:
> On 2013/4/25 7:05, Naoya Horiguchi wrote:
> 
> > On Wed, Apr 24, 2013 at 11:39:51AM -0400, Johannes Weiner wrote:
> >> On Wed, Apr 24, 2013 at 11:16:39AM -0400, Naoya Horiguchi wrote:
> >>> On Wed, Apr 24, 2013 at 04:14:54AM -0400, Johannes Weiner wrote:
> >>>> @@ -491,10 +491,13 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> >>>>  
> >>>>  	sprintf (name, "SYSV%08x", key);
> >>>>  	if (shmflg & SHM_HUGETLB) {
> >>>> +		unsigned int hugesize;
> >>>> +
> >>>>  		/* hugetlb_file_setup applies strict accounting */
> >>>>  		if (shmflg & SHM_NORESERVE)
> >>>>  			acctflag = VM_NORESERVE;
> >>>> -		file = hugetlb_file_setup(name, 0, size, acctflag,
> >>>> +		hugesize = ALIGN(size, huge_page_size(&default_hstate));
> >>>> +		file = hugetlb_file_setup(name, hugesize, acctflag,
> >>>>  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
> >>>>  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
> >>>>  	} else {
> >>>
> >>> Would it be better to find proper hstate instead of using default_hstate?
> >>
> >> You are probably right, I guess we can't assume default_hstate anymore
> >> after page_size_log can be passed in.
> >>
> >> Can we have hugetlb_file_setup() return an adjusted length, or an
> >> alignment requirement?
> > 
> > Yes, it's possible if callers pass the pointer of size (length) to
> > hugetlb_file_setup() and make it adjusted inside the function.
> > And as for alignment, I think it's not a hugetlb_file_setup's job,
> > so we don't have to do it in this function.
> > 
> >> Or pull the hstate lookup into the callsites (since they pass in
> >> page_size_log to begin with)?
> > 
> > This is also a possible solution, where we might need to define and
> > export a function converting hugepage order to hstate.
> > 
> > I like the former one, so wrote a patch like below.
> > # I added your Signed-off-by: because this's based on your draft patch.
> > # if you don't like it, please let me know.
> > 
> > Thanks,
> > Naoya Horiguchi
> > ---
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Wed, 24 Apr 2013 16:44:19 -0400
> > Subject: [PATCH] hugetlbfs: fix mmap failure in unaligned size request
> > 
> > As reported in https://bugzilla.kernel.org/show_bug.cgi?id=56881, current
> > kernel returns -EINVAL unless a given mmap length is "almost" hugepage
> > aligned. This is because in sys_mmap_pgoff() the given length is passed to
> > vm_mmap_pgoff() as it is without being aligned with hugepage boundary.
> > 
> > This is a regression introduced in commit 40716e29243d "hugetlbfs: fix
> > alignment of huge page requests", where alignment code is pushed into
> > hugetlb_file_setup() and the variable len in caller side is not changed.
> > 
> > To fix this, this patch partially reverts that commit, and changes
> > the type of parameter size from size_t to (size_t *) in order to
> > align the size in caller side.
> > 
> 
> Hi Naoya,
> 
> This patch only fix anonymous hugetlb mmap case, should also fix hugetlbfs file mmap case?

Right, thank you, Jianguo.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0db0de1..5ed9561 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1327,6 +1327,8 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		file = fget(fd);
>  		if (!file)
>  			goto out;
> +		else if (is_file_hugepages(file))
> +			len = ALIGN(len, huge_page_size(hstate_file(file)));
>  	} else if (flags & MAP_HUGETLB) {
>  		struct user_struct *user = NULL;
>  		/*

I'll added this in next post.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
