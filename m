Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5DDC56B0033
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 11:40:03 -0400 (EDT)
Date: Wed, 24 Apr 2013 11:39:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Message-ID: <20130424153951.GQ2018@cmpxchg.org>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Wed, Apr 24, 2013 at 11:16:39AM -0400, Naoya Horiguchi wrote:
> On Wed, Apr 24, 2013 at 04:14:54AM -0400, Johannes Weiner wrote:
> > @@ -491,10 +491,13 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> >  
> >  	sprintf (name, "SYSV%08x", key);
> >  	if (shmflg & SHM_HUGETLB) {
> > +		unsigned int hugesize;
> > +
> >  		/* hugetlb_file_setup applies strict accounting */
> >  		if (shmflg & SHM_NORESERVE)
> >  			acctflag = VM_NORESERVE;
> > -		file = hugetlb_file_setup(name, 0, size, acctflag,
> > +		hugesize = ALIGN(size, huge_page_size(&default_hstate));
> > +		file = hugetlb_file_setup(name, hugesize, acctflag,
> >  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
> >  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
> >  	} else {
> 
> Would it be better to find proper hstate instead of using default_hstate?

You are probably right, I guess we can't assume default_hstate anymore
after page_size_log can be passed in.

Can we have hugetlb_file_setup() return an adjusted length, or an
alignment requirement?

Or pull the hstate lookup into the callsites (since they pass in
page_size_log to begin with)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
