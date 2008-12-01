Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1Hl5Cx004347
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 10:47:05 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1Hla69045394
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 10:47:36 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1HlX0G025379
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 10:47:36 -0700
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081128101919.GO28946@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>
	 <20081128101919.GO28946@ZenIV.linux.org.uk>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 09:47:25 -0800
Message-Id: <1228153645.2971.36.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-11-28 at 10:19 +0000, Al Viro wrote:
> On Wed, Nov 26, 2008 at 08:04:39PM -0500, Oren Laadan wrote:
> > +int cr_scan_fds(struct files_struct *files, int **fdtable)
> > +{
> > +	struct fdtable *fdt;
> > +	int *fds;
> > +	int i, n = 0;
> > +	int tot = CR_DEFAULT_FDTABLE;
> > +
> > +	fds = kmalloc(tot * sizeof(*fds), GFP_KERNEL);
> > +	if (!fds)
> > +		return -ENOMEM;
> > +
> > +	/*
> > +	 * We assume that the target task is frozen (or that we checkpoint
> > +	 * ourselves), so we can safely proceed after krealloc() from where
> > +	 * we left off; in the worst cases restart will fail.
> > +	 */
> 
> Task may be frozen, but it may share the table with any number of other
> tasks...

First of all, thanks for looking at this, Al.  

I think Oren's assumption here is that all tasks possibly sharing the
table would be frozen.  I don't think that's a good assumption,
either. :)

This would be a lot safer and bulletproof if we size the allocation
ahead of time, take all the locks, then retry if the size has changed.

I think that will just plain work of we do this:

> > +	spin_lock(&files->file_lock);
> > +	rcu_read_lock();
> > +	fdt = files_fdtable(files);
> > +	for (i = 0; i < fdt->max_fds; i++) {
> > +		if (!fcheck_files(files, i))
> > +			continue;
> > +		if (n == tot) {
> > +			/*
> > +			 * fcheck_files() is safe with drop/re-acquire
> > +			 * of the lock, because it tests:  fd < max_fds
> > +			 */
> > +			spin_unlock(&files->file_lock);
> > +			rcu_read_unlock();
> > +			tot *= 2;	/* won't overflow: kmalloc will fail */

			  free(fds);
			  goto first_kmalloc_in_this_function;

> > +		}
> > +		fds[n++] = i;
> > +	}
> > +	rcu_read_unlock();
> > +	spin_unlock(&files->file_lock);
> > +
> > +	*fdtable = fds;
> > +	return n;
> > +}

Right?

> > +	switch (inode->i_mode & S_IFMT) {
> > +	case S_IFREG:
> > +		fd_type = CR_FD_FILE;
> > +		break;
> > +	case S_IFDIR:
> > +		fd_type = CR_FD_DIR;
> > +		break;
> > +	case S_IFLNK:
> > +		fd_type = CR_FD_LINK;
> 
> Opened symlinks?  May I have whatever you'd been smoking, please?

Ugh, that certainly doesn't have any place here.  I do wonder if Oren
had some use for that in the fully put together code, but it can
certainly go for now.

I'll send patches for these shortly.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
