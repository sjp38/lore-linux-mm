Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DE31E8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 04:30:01 -0500 (EST)
Date: Thu, 27 Jan 2011 10:29:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memsw: handle swapaccount kernel parameter correctly
Message-ID: <20110127092951.GA8036@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
 <20110126140618.8e09cd23.akpm@linux-foundation.org>
 <20110127082320.GA15500@tiehlicka.suse.cz>
 <20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu 27-01-11 18:03:30, KAMEZAWA Hiroyuki wrote:
> On Thu, 27 Jan 2011 09:23:20 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index db76ef7..cea2be48 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5013,9 +5013,9 @@ struct cgroup_subsys mem_cgroup_subsys = {
> >  static int __init enable_swap_account(char *s)
> >  {
> >  	/* consider enabled if no parameter or 1 is given */
> > -	if (!s || !strcmp(s, "1"))
> > +	if (!(*s) || !strcmp(s, "=1"))
> >  		really_do_swap_account = 1;
> > -	else if (!strcmp(s, "0"))
> > +	else if (!strcmp(s, "=0"))
> >  		really_do_swap_account = 0;
> >  	return 1;
> >  }
> 
> Hmm, usual callser of __setup() includes '=' to parameter name, as
> 
> mm/hugetlb.c:__setup("hugepages=", hugetlb_nrpages_setup);
> mm/hugetlb.c:__setup("default_hugepagesz=", hugetlb_default_setup);
> 
> How about moving "=" to __setup() ?

I have considered that as well but then we couldn't use swapaccount
parameter without any value because the parameter parsing matches the
whole string. 
I found it better to have consistent [no]swapaccount with the =0|1
extension rather than keeping = in the setup like other users.

Sounds reasonable?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
