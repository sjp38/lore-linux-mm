Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6E9D6B0261
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:29:33 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id n3so80156962wjy.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:29:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si8357579wra.300.2017.01.09.06.29.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 06:29:32 -0800 (PST)
Date: Mon, 9 Jan 2017 15:29:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/8] xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
Message-ID: <20170109142930.GL7495@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-3-mhocko@kernel.org>
 <bf7594a9-7e1a-0895-2d0e-df1f27502db1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf7594a9-7e1a-0895-2d0e-df1f27502db1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-01-17 13:59:05, Vlastimil Babka wrote:
> On 01/06/2017 03:11 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > xfs has defined PF_FSTRANS to declare a scope GFP_NOFS semantic quite
> > some time ago. We would like to make this concept more generic and use
> > it for other filesystems as well. Let's start by giving the flag a
> > more generic name PF_MEMALLOC_NOFS which is in line with an exiting
> > PF_MEMALLOC_NOIO already used for the same purpose for GFP_NOIO
> > contexts. Replace all PF_FSTRANS usage from the xfs code in the first
> > step before we introduce a full API for it as xfs uses the flag directly
> > anyway.
> > 
> > This patch doesn't introduce any functional change.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Brian Foster <bfoster@redhat.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> 
> A nit:
> 
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -2320,6 +2320,8 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
> >  #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezable */
> >  #define PF_SUSPEND_TASK 0x80000000      /* this thread called freeze_processes and should not be frozen */
> >  
> > +#define PF_MEMALLOC_NOFS PF_FSTRANS	/* Transition to a more generic GFP_NOFS scope semantic */
> 
> I don't see why this transition is needed, as there are already no users
> of PF_FSTRANS after this patch. The next patch doesn't remove any more,
> so this is just extra churn IMHO. But not a strong objection.

I just wanted to have this transparent for the xfs in this patch.
AFAIR Dave wanted to have xfs and generic parts separated. So it was the
easiest to simply keep the flag and then remove it in a separate patach.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
