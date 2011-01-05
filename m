Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0564B6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 11:42:10 -0500 (EST)
Date: Wed, 5 Jan 2011 11:42:01 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1744627.141722.1294245721475.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110105155938.GE21349@tiehlicka.suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Wed 05-01-11 10:36:47, CAI Qian wrote:
> > From f90b54f9f5607128e375bd78d21e751c433b3cf6 Mon Sep 17 00:00:00
> > 2001
> > From: CAI Qian <caiqian@redhat.com>
> > Date: Wed, 5 Jan 2011 23:26:57 +0800
> > Subject: [PATCH] hugetlbfs: check invalid nr_hugepages and
> > nr_overcommit_hugepages
> >
> > First, nr_*hugepages* in procfs and sysfs do not check for invalid
> > input like "". Second, when using oversize pages, nr_*hugepages* are
> > expected to be allocated during boot time. Therefore, return -EINVAL
> > for those cases.
> 
> I think that the two things should be split into two patches - one for
> the proper input data handling and the other one for the size check.
> Albeit, I am not sure about the size check because this is a thing
> that is just a current implementation limitation and can be change later.
OK, will do two patches.

> > Signed-off-by: CAI Qian <caiqian@redhat.com>
> > ---
> >  fs/sysfs/file.c | 2 ++
> >  mm/hugetlb.c | 18 ++++++++++++++++--
> >  2 files changed, 18 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
> > index da3fefe..9f4ea67 100644
> > --- a/fs/sysfs/file.c
> > +++ b/fs/sysfs/file.c
> > @@ -207,6 +207,8 @@ flush_write_buffer(struct dentry * dentry,
> > struct sysfs_buffer * buffer, size_t
> >  		return -ENODEV;
> >
> >  	rc = ops->store(kobj, attr_sd->s_attr.attr, buffer->page, count);
> > + if (!rc)
> > + return -EINVAL;
> 
> This doesn't look correct, you would imbalance sysfs_{get,put}_active.
Right, I'll fix this up.

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
