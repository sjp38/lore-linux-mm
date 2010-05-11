Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 255126B020D
	for <linux-mm@kvack.org>; Mon, 10 May 2010 21:18:26 -0400 (EDT)
Date: Tue, 11 May 2010 10:16:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 -mmotm 1/2] memcg: clean up move charge
Message-Id: <20100511101638.c70528d0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100511085446.952fb97f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
	<20100510152554.5f8a1be0.akpm@linux-foundation.org>
	<20100511085446.952fb97f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 11 May 2010 08:54:46 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 10 May 2010 15:25:54 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 8 Apr 2010 14:10:20 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > This patch cleans up move charge code by:
> > > 
> > > - define functions to handle pte for each types, and make is_target_pte_for_mc()
> > >   cleaner.
> > > - instead of checking the MOVE_CHARGE_TYPE_ANON bit, define a function that
> > >   checks the bit.
> > >
> > > ...
> > >
> > 
> > > @@ -4241,13 +4263,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> > >  		if (!ret || !target)
> > >  			put_page(page);
> > >  	}
> > > -	/* throught */
> > > -	if (ent.val && do_swap_account && !ret &&
> > > -			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
> > > -		ret = MC_TARGET_SWAP;
> > > -		if (target)
> > > -			target->ent = ent;
> > > +	/* Threre is a swap entry and a page doesn't exist or isn't charged */
> > > +	if (ent.val && !ret) {
> > > +		if (css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
> > > +			ret = MC_TARGET_SWAP;
> > > +			if (target)
> > > +				target->ent = ent;
> > > +		}
> > >  	}
> > > +
> > >  	return ret;
> > >  }
> > 
> > Are you sure that the test of do_swap_account should be removed here? 
> > it didn't seem to be covered in the changelog.
> > 
> Hmmm...thank you for pointing out. I think it should be checked.
> 
> Nishimura-san ?
> 
mc_handle_swap_pte() will set ent.val only when do_swap_account,
so it's all right to remove the check here.

(snip)
> > +static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
> > +			unsigned long addr, pte_t ptent, swp_entry_t *entry)
> > +{
> > +	int usage_count;
> > +	struct page *page = NULL;
> > +	swp_entry_t ent = pte_to_swp_entry(ptent);
> > +
> > +	if (!move_anon() || non_swap_entry(ent))
> > +		return NULL;
> > +	usage_count = mem_cgroup_count_swap_user(ent, &page);
> > +	if (usage_count > 1) { /* we don't move shared anon */
> >  		if (page)
> >  			put_page(page);
> > -		return 0;
> > +		return NULL;
> >  	}
> > +	if (do_swap_account)
> > +		entry->val = ent.val;
> 
> Maybe page should be set to NULL here. if !do_swap_account....
> 
I leave the "page"(it may store a page in swapcache) as it is intentionally
to move a charge of an unmapped swapcache.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
