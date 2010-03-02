Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C47036B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 10:05:52 -0500 (EST)
Date: Tue, 2 Mar 2010 10:05:29 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100302150529.GA12855@redhat.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com> <1267478620-5276-4-git-send-email-arighi@develer.com> <20100301220208.GH3109@redhat.com> <20100301221830.GA5460@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100301221830.GA5460@linux>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 11:18:31PM +0100, Andrea Righi wrote:
> On Mon, Mar 01, 2010 at 05:02:08PM -0500, Vivek Goyal wrote:
> > > @@ -686,10 +699,14 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> > >                   */
> > >                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> > >  
> > > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > > -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> > > -                        	break;
> > > -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > +
> > > +		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> > > +		if (dirty < 0)
> > > +			dirty = global_page_state(NR_UNSTABLE_NFS) +
> > > +				global_page_state(NR_WRITEBACK);
> > 
> > dirty is unsigned long. As mentioned last time, above will never be true?
> > In general these patches look ok to me. I will do some testing with these.
> 
> Re-introduced the same bug. My bad. :(
> 
> The value returned from mem_cgroup_page_stat() can be negative, i.e.
> when memory cgroup is disabled. We could simply use a long for dirty,
> the unit is in # of pages so s64 should be enough. Or cast dirty to long
> only for the check (see below).
> 
> Thanks!
> -Andrea
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index d83f41c..dbee976 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -701,7 +701,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  
>  
>  		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> -		if (dirty < 0)
> +		if ((long)dirty < 0)

This will also be problematic as on 32bit systems, your uppper limit of
dirty memory will be 2G?

I guess, I will prefer one of the two.

- return the error code from function and pass a pointer to store stats
  in as function argument.

- Or Peter's suggestion of checking mem_cgroup_has_dirty_limit() and if
  per cgroup dirty control is enabled, then use per cgroup stats. In that
  case you don't have to return negative values.

  Only tricky part will be careful accouting so that none of the stats go
  negative in corner cases of migration etc.

Thanks
Vivek

>  			dirty = global_page_state(NR_UNSTABLE_NFS) +
>  				global_page_state(NR_WRITEBACK);
>  		if (dirty <= dirty_thresh)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
