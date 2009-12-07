Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E25B60021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 02:47:57 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB77lqk4007735
	for <linux-mm@kvack.org>; Mon, 7 Dec 2009 13:17:52 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB77lpvN3100694
	for <linux-mm@kvack.org>; Mon, 7 Dec 2009 13:17:52 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB77logE019612
	for <linux-mm@kvack.org>; Mon, 7 Dec 2009 18:47:51 +1100
Date: Mon, 7 Dec 2009 13:17:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: correct return value at mem_cgroup reclaim
Message-ID: <20091207074746.GF5780@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
 <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091206223046.4b08cbfb.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Liu bo <bo-liu@hotmail.com>, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-12-06 22:30:46]:

> hi,
> 
> On Sun, 6 Dec 2009 18:16:14 +0800
> Liu bo <bo-liu@hotmail.com> wrote:
> 
> > 
> > In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
> > Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
> >  
> > Signed-off-by: Liu Bo <bo-liu@hotmail.com>
> > ---
> >  
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 14593f5..51b6b3c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >    css_put(&victim->css);
> >    total += ret;
> >    if (mem_cgroup_check_under_limit(root_mem))
> > -   return 1 + total;
> > +   return total;
> >   }
> >   return total;
> >  } 		 	   		  
> What's the benefit of this change ?
> I can't find any benefit to bother changing current behavior.
>

I agree, I added the "1 +" for a reason, if the new group is under its
limit magically without us having to reclaim anything (task exits or
memory freed), I don't want to look at total and see we reclaimed
nothing and take action.
 
> P.S.
> You should run ./scripts/checkpatch.pl before sending your patch,
> and refer to Documentation/email-clients.txt and check your email client setting.
>

Yes, the tabbing and spaces seem to be broken 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
