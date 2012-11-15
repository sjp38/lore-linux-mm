Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7521C6B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:01:27 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1569333pbc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:01:26 -0800 (PST)
Date: Thu, 15 Nov 2012 13:01:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/4] mm, oom: cleanup pagefault oom handler
In-Reply-To: <50A4AB9E.4030106@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1211151257500.27188@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com> <alpine.DEB.2.00.1211140113020.32125@chino.kir.corp.google.com> <50A4AB9E.4030106@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 Nov 2012, Kamezawa Hiroyuki wrote:

> > @@ -708,15 +671,17 @@ out:
> > 
> >   /*
> >    * The pagefault handler calls here because it is out of memory, so kill a
> > - * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a
> > parallel
> > - * oom killing is already in progress so do nothing.  If a task is found
> > with
> > - * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
> > + * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
> > + * parallel oom killing is already in progress so do nothing.
> >    */
> >   void pagefault_out_of_memory(void)
> >   {
> > -	if (try_set_system_oom()) {
> > +	struct zonelist *zonelist = node_zonelist(first_online_node,
> > +						  GFP_KERNEL);
> 
> 
> why GFP_KERNEL ? not GFP_HIGHUSER_MOVABLE ?
> 

The usual way to get a zonelist consisting of all zones ordered by 
preferring a node is node_zonelist(nid, GFP_KERNEL), but there's no 
difference between using GFP_KERNEL, GFP_HIGHUSER_MOVABLE, or even 0.  I 
simply duplicated what the sysrq trigger was doing, but you could also do 
&first_online_pgdat->node_zonelists[0], it's really just a matter of 
preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
