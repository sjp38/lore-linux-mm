Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1FB58E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:10:48 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id i124so8447501pgc.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:10:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si10005513pgm.14.2018.12.17.06.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 06:10:47 -0800 (PST)
Date: Mon, 17 Dec 2018 15:10:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181217141044.GP30879@dhcp22.suse.cz>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
 <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
 <20181217122546.GL10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217122546.GL10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hou Tao <houtao1@huawei.com>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-12-18 04:25:46, Matthew Wilcox wrote:
> On Mon, Dec 17, 2018 at 07:51:27PM +0900, Tetsuo Handa wrote:
> > On 2018/12/17 18:33, Michal Hocko wrote:
> > > On Sun 16-12-18 19:51:57, Matthew Wilcox wrote:
> > > [...]
> > >> Ah, yes, that makes perfect sense.  Thank you for the explanation.
> > >>
> > >> I wonder if the correct fix, however, is not to move the check for
> > >> GFP_NOFS in out_of_memory() down to below the check whether to kill
> > >> the current task.  That would solve your problem, and I don't _think_
> > >> it would cause any new ones.  Michal, you touched this code last, what
> > >> do you think?
> > > 
> > > What do you mean exactly? Whether we kill a current task or something
> > > else doesn't change much on the fact that NOFS is a reclaim restricted
> > > context and we might kill too early. If the fs can do GFP_FS then it is
> > > obviously a better thing to do because FS metadata can be reclaimed as
> > > well and therefore there is potentially less memory pressure on
> > > application data.
> > > 
> > 
> > I interpreted "to move the check for GFP_NOFS in out_of_memory() down to
> > below the check whether to kill the current task" as
> 
> Too far; I meant one line earlier, before we try to select a different
> process.

We could still panic the system on pre-mature OOM. So it doesn't really
seem good.

> > @@ -1104,6 +1095,19 @@ bool out_of_memory(struct oom_control *oc)
> >  	}
> >  
> >  	select_bad_process(oc);
> > +
> > +	/*
> > +	 * The OOM killer does not compensate for IO-less reclaim.
> > +	 * pagefault_out_of_memory lost its gfp context so we have to
> > +	 * make sure exclude 0 mask - all other users should have at least
> > +	 * ___GFP_DIRECT_RECLAIM to get here.
> > +	 */
> > +	if ((oc->gfp_mask && !(oc->gfp_mask & __GFP_FS)) && oc->chosen &&
> > +	    oc->chosen != (void *)-1UL && oc->chosen != current) {
> > +		put_task_struct(oc->chosen);
> > +		return true;
> > +	}
> > +
> >  	/* Found nothing?!?! */
> >  	if (!oc->chosen) {
> >  		dump_header(oc, NULL);
> > 
> > which is prefixed by "the correct fix is not".
> > 
> > Behaving like sysctl_oom_kill_allocating_task == 1 if __GFP_FS is not used
> > will not be the correct fix. But ...
> > 
> > Hou Tao wrote:
> > > There is no need to disable __GFP_FS in ->readpage:
> > > * It's a read-only fs, so there will be no dirty/writeback page and
> > >   there will be no deadlock against the caller's locked page
> > 
> > is read-only filesystem sufficient for safe to use __GFP_FS?
> > 
> > Isn't "whether it is safe to use __GFP_FS" depends on "whether fs locks
> > are held or not" rather than "whether fs has dirty/writeback page or not" ?
> 
> It's worth noticing that squashfs _is_ in fact holding a page locked in
> squashfs_copy_cache() when it calls grab_cache_page_nowait().  I'm not
> sure if this will lead to trouble or not because I'm insufficiently
> familiar with the reclaim path.

Hmm, this is more interesting then. If there is any memcg accounted
allocation down that path _and_ the squashfs writeout can lock more
pages and mark them writeback before they are really sent to the storage
then we have a problem. See [1]

[1] http://lkml.kernel.org/r/20181213092221.27270-1-mhocko@kernel.org

-- 
Michal Hocko
SUSE Labs
