Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 258C38E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:25:57 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so11660366pfi.22
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:25:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j61si10790555plb.232.2018.12.17.04.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 04:25:55 -0800 (PST)
Date: Mon, 17 Dec 2018 04:25:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181217122546.GL10600@bombadil.infradead.org>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
 <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Hou Tao <houtao1@huawei.com>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 17, 2018 at 07:51:27PM +0900, Tetsuo Handa wrote:
> On 2018/12/17 18:33, Michal Hocko wrote:
> > On Sun 16-12-18 19:51:57, Matthew Wilcox wrote:
> > [...]
> >> Ah, yes, that makes perfect sense.  Thank you for the explanation.
> >>
> >> I wonder if the correct fix, however, is not to move the check for
> >> GFP_NOFS in out_of_memory() down to below the check whether to kill
> >> the current task.  That would solve your problem, and I don't _think_
> >> it would cause any new ones.  Michal, you touched this code last, what
> >> do you think?
> > 
> > What do you mean exactly? Whether we kill a current task or something
> > else doesn't change much on the fact that NOFS is a reclaim restricted
> > context and we might kill too early. If the fs can do GFP_FS then it is
> > obviously a better thing to do because FS metadata can be reclaimed as
> > well and therefore there is potentially less memory pressure on
> > application data.
> > 
> 
> I interpreted "to move the check for GFP_NOFS in out_of_memory() down to
> below the check whether to kill the current task" as

Too far; I meant one line earlier, before we try to select a different
process.

> @@ -1104,6 +1095,19 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	select_bad_process(oc);
> +
> +	/*
> +	 * The OOM killer does not compensate for IO-less reclaim.
> +	 * pagefault_out_of_memory lost its gfp context so we have to
> +	 * make sure exclude 0 mask - all other users should have at least
> +	 * ___GFP_DIRECT_RECLAIM to get here.
> +	 */
> +	if ((oc->gfp_mask && !(oc->gfp_mask & __GFP_FS)) && oc->chosen &&
> +	    oc->chosen != (void *)-1UL && oc->chosen != current) {
> +		put_task_struct(oc->chosen);
> +		return true;
> +	}
> +
>  	/* Found nothing?!?! */
>  	if (!oc->chosen) {
>  		dump_header(oc, NULL);
> 
> which is prefixed by "the correct fix is not".
> 
> Behaving like sysctl_oom_kill_allocating_task == 1 if __GFP_FS is not used
> will not be the correct fix. But ...
> 
> Hou Tao wrote:
> > There is no need to disable __GFP_FS in ->readpage:
> > * It's a read-only fs, so there will be no dirty/writeback page and
> >   there will be no deadlock against the caller's locked page
> 
> is read-only filesystem sufficient for safe to use __GFP_FS?
> 
> Isn't "whether it is safe to use __GFP_FS" depends on "whether fs locks
> are held or not" rather than "whether fs has dirty/writeback page or not" ?

It's worth noticing that squashfs _is_ in fact holding a page locked in
squashfs_copy_cache() when it calls grab_cache_page_nowait().  I'm not
sure if this will lead to trouble or not because I'm insufficiently
familiar with the reclaim path.
