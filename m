Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E55D09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:19:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D3E973EE081
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:19:43 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B6E6F45DE51
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:19:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A0F8A45DE4F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:19:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 919341DB8045
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:19:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F4851DB803F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:19:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: (resend) [PATCH] vmscan,memcg: memcg aware swap token
In-Reply-To: <20110426130724.f2ae18e3.akpm@linux-foundation.org>
References: <20110426170146.F396.A69D9226@jp.fujitsu.com> <20110426130724.f2ae18e3.akpm@linux-foundation.org>
Message-Id: <20110427102126.D174.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 27 Apr 2011 10:19:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>

> On Tue, 26 Apr 2011 16:59:19 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > @@ -75,3 +76,19 @@ void __put_swap_token(struct mm_struct *mm)
> >  		swap_token_mm = NULL;
> >  	spin_unlock(&swap_token_lock);
> >  }
> > +
> > +int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> > +{
> > +	if (memcg) {
> > +		struct mem_cgroup *swap_token_memcg;
> > +
> > +		/*
> > +		 * memcgroup reclaim can disable swap token only if token task
> > +		 * is in the same cgroup.
> > +		 */
> > +		swap_token_memcg = try_get_mem_cgroup_from_mm(swap_token_mm);
> > +		return ((mm == swap_token_mm) && (memcg == swap_token_memcg));
> > +	} else
> > +		return (mm == swap_token_mm);
> > +}
> 
> Seems to be missing a css_put()?

Yes! Please drop this one. I'll rework it at this weekend.

Thank you for the finding!

> 
> Either I'm mistaken or that's a bug.  Perhaps neither of these would
> have happened if we'd bothered to document
> try_get_mem_cgroup_from_mm().
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
