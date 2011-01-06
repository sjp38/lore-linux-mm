Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 090536B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 05:04:47 -0500 (EST)
Date: Thu, 6 Jan 2011 11:04:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: PATCH: hugetlb: handle NODEMASK_ALLOC failure correctly
Message-ID: <20110106100439.GA5774@tiehlicka.suse.cz>
References: <20110104105214.GA10759@tiehlicka.suse.cz>
 <907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110105084357.GA21349@tiehlicka.suse.cz>
 <20110105125959.c6e3d90a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110105125959.c6e3d90a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed 05-01-11 12:59:59, Andrew Morton wrote:
> On Wed, 5 Jan 2011 09:43:57 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1928,7 +1928,8 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
> >  
> >  	table->data = &tmp;
> >  	table->maxlen = sizeof(unsigned long);
> > -	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> > +	if (proc_doulongvec_minmax(table, write, buffer, length, ppos))
> > +		return -EINVAL;
> 
> proc_doulongvec_minmax() can return -EFAULT or -ENOMEM.  It is
> incorrect to unconditionally convert those into -EINVAL.

You are right, I have missed that. Thanks for fixing that up
> 
> >  	if (write) {
> >  		NODEMASK_ALLOC(nodemask_t, nodes_allowed,
> 
> hm, the code doesn't check that NODEMASK_ALLOC succeeded.  That
> NODEMASK_ALLOC conversion was quite sloppy.

What do you think about the patch bellow? I have based it on top of
you mm patches (I was CCed):
hugetlb-check-the-return-value-of-string-conversion-in-sysctl-handler.patch
hugetlb-check-the-return-value-of-string-conversion-in-sysctl-handler-fix.patch
hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment.patch
hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment-fix.patch
hugetlb-fix-handling-of-parse-errors-in-sysfs.patch

Some of them didn't apply cleanly so I had to tweak them a bit so maybe
I am missing some other patches.
---
