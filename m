Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 45D3A6B0036
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:57:21 -0400 (EDT)
Message-ID: <1378821337.10300.990.camel@misato.fc.hp.com>
Subject: Re: [PATCH] cpu/mem hotplug: Add try_online_node() for cpu_up()
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 10 Sep 2013 07:55:37 -0600
In-Reply-To: <522E92A0.80502@jp.fujitsu.com>
References: <1378772671-27280-1-git-send-email-toshi.kani@hp.com>
	 <522E92A0.80502@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rjw@sisk.pl, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com

On Tue, 2013-09-10 at 12:31 +0900, Yasuaki Ishimatsu wrote:
> (2013/09/10 9:24), Toshi Kani wrote:
 :
> > diff --git a/kernel/cpu.c b/kernel/cpu.c
> > index d7f07a2..c10b285 100644
> > --- a/kernel/cpu.c
> > +++ b/kernel/cpu.c
> > @@ -420,11 +420,6 @@ int cpu_up(unsigned int cpu)
> >   {
> >   	int err = 0;
> >   
> > -#ifdef	CONFIG_MEMORY_HOTPLUG
> > -	int nid;
> > -	pg_data_t	*pgdat;
> > -#endif
> > -
> >   	if (!cpu_possible(cpu)) {
> >   		printk(KERN_ERR "can't online cpu %d because it is not "
> >   			"configured as may-hotadd at boot time\n", cpu);
> > @@ -435,27 +430,9 @@ int cpu_up(unsigned int cpu)
> >   		return -EINVAL;
> >   	}
> >   
> > -#ifdef	CONFIG_MEMORY_HOTPLUG
> > -	nid = cpu_to_node(cpu);
> > -	if (!node_online(nid)) {
> > -		err = mem_online_node(nid);
> > -		if (err)
> > -			return err;
> > -	}
> > -
> > -	pgdat = NODE_DATA(nid);
> > -	if (!pgdat) {
> 
> > -		printk(KERN_ERR
> > -			"Can't online cpu %d due to NULL pgdat\n", cpu);
> 
> Please move this comments into try_online_node() too.

This code block is no longer necessary, but I will add a pr_err() when
hotadd_new_pgdat() returns NULL in try_oline_node() below.

> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index ed85fe3..c326bdf 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1044,14 +1044,19 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
> >   }
> >   
> >   
> > -/*
> > +/**
> > + * try_online_node - online a node if offlined
> > + *
> >    * called by cpu_up() to online a node without onlined memory.
> >    */
> > -int mem_online_node(int nid)
> > +int try_online_node(int nid)
> >   {
> >   	pg_data_t	*pgdat;
> >   	int	ret;
> >   
> > +	if (node_online(nid))
> > +		return 0;
> > +
> >   	lock_memory_hotplug();
> >   	pgdat = hotadd_new_pgdat(nid, 0);
> >   	if (!pgdat) {

+               pr_err("Cannot online node %d due to NULL pgdat\n",
nid);

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
