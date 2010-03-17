Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A85D600368
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:52:09 -0400 (EDT)
Date: Wed, 17 Mar 2010 23:52:03 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100317225203.GD8467@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-5-git-send-email-arighi@develer.com>
 <20100316113238.f7d74848.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100316113238.f7d74848.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 11:32:38AM +0900, Daisuke Nishimura wrote:
[snip]
> > @@ -3190,10 +3512,14 @@ struct {
> >  } memcg_stat_strings[NR_MCS_STAT] = {
> >  	{"cache", "total_cache"},
> >  	{"rss", "total_rss"},
> > -	{"mapped_file", "total_mapped_file"},
> >  	{"pgpgin", "total_pgpgin"},
> >  	{"pgpgout", "total_pgpgout"},
> >  	{"swap", "total_swap"},
> > +	{"mapped_file", "total_mapped_file"},
> > +	{"filedirty", "dirty_pages"},
> > +	{"writeback", "writeback_pages"},
> > +	{"writeback_tmp", "writeback_temp_pages"},
> > +	{"nfs", "nfs_unstable"},
> >  	{"inactive_anon", "total_inactive_anon"},
> >  	{"active_anon", "total_active_anon"},
> >  	{"inactive_file", "total_inactive_file"},
> Why not using "total_xxx" for total_name ?

Agreed. I would be definitely more clear. Balbir, KAME-san, what do you
think?

> 
> > @@ -3212,8 +3538,6 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> >  	s->stat[MCS_RSS] += val * PAGE_SIZE;
> > -	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
> > -	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
> >  	s->stat[MCS_PGPGIN] += val;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGOUT_COUNT);
> > @@ -3222,6 +3546,16 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
> >  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
> >  	}
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
> > +	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
> > +	s->stat[MCS_FILE_DIRTY] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK);
> > +	s->stat[MCS_WRITEBACK] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK_TEMP);
> > +	s->stat[MCS_WRITEBACK_TEMP] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +	s->stat[MCS_UNSTABLE_NFS] += val;
> >  
> I don't have a strong objection, but I prefer showing them in bytes.
> And can you add to mem_cgroup_stat_show() something like:
> 
> 	for (i = 0; i < NR_MCS_STAT; i++) {
> 		if (i == MCS_SWAP && !do_swap_account)
> 			continue;
> +		if (i >= MCS_FILE_STAT_STAR && i <= MCS_FILE_STAT_END &&
> +		   mem_cgroup_is_root(mem_cont))
> +			continue;
> 		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
> 	}

I like this. And I also prefer to show these values in bytes.

> 
> not to show file stat in root cgroup ? It's meaningless value anyway.
> Of course, you'd better mention it in [2/5] too.

OK.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
