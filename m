Subject: Re: [RFC][PATCH 5/14]  memcg: free page_cgroup by RCU
In-Reply-To: Your message of "Thu, 28 Aug 2008 19:44:54 +0900"
	<20080828194454.3fa6d0d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080828194454.3fa6d0d0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080901065144.CCA975A9C@siro.lan>
Date: Mon,  1 Sep 2008 15:51:44 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

hi,

> > > @@ -649,13 +673,17 @@ static DEFINE_MUTEX(memcg_force_drain_mu
> > > 
> > >  static void mem_cgroup_local_force_drain(struct work_struct *work)
> > >  {
> > > -	__free_obsolete_page_cgroup();
> > > +	int ret;
> > > +	do {
> > > +		ret = __free_obsolete_page_cgroup();
> > 
> > We keep repeating till we get 0?
> > 
> yes. this returns 0 or -ENOMEM. 

it's problematic to keep busy-looping on ENOMEM, esp. for GFP_ATOMIC.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
