Date: Fri, 7 Nov 2008 22:30:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/6] memcg: mem+swap controller
Message-Id: <20081107223032.7f5cd698.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081107181932.94e6f307.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<20081105172316.354c00fb.kamezawa.hiroyu@jp.fujitsu.com>
	<20081107180248.39251a80.nishimura@mxp.nes.nec.co.jp>
	<20081107181932.94e6f307.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

> > >  static struct cftype mem_cgroup_files[] = {
> > >  	{
> > >  		.name = "usage_in_bytes",
> > > -		.private = RES_USAGE,
> > > +		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> > >  		.read_u64 = mem_cgroup_read,
> > >  	},
> > >  	{
> > >  		.name = "max_usage_in_bytes",
> > > -		.private = RES_MAX_USAGE,
> > > +		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
> > >  		.trigger = mem_cgroup_reset,
> > >  		.read_u64 = mem_cgroup_read,
> > >  	},
> > >  	{
> > >  		.name = "limit_in_bytes",
> > > -		.private = RES_LIMIT,
> > > +		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
> > >  		.write_string = mem_cgroup_write,
> > >  		.read_u64 = mem_cgroup_read,
> > >  	},
> > >  	{
> > >  		.name = "failcnt",
> > > -		.private = RES_FAILCNT,
> > > +		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
> > >  		.trigger = mem_cgroup_reset,
> > >  		.read_u64 = mem_cgroup_read,
> > >  	},
> > > @@ -1317,6 +1541,31 @@ static struct cftype mem_cgroup_files[] 
> > >  		.name = "stat",
> > >  		.read_map = mem_control_stat_show,
> > >  	},
> > > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > +	{
> > > +		.name = "memsw.usage_in_bytes",
> > > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> > > +		.read_u64 = mem_cgroup_read,
> > > +	},
> > > +	{
> > > +		.name = "memsw.max_usage_in_bytes",
> > > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
> > > +		.trigger = mem_cgroup_reset,
> > > +		.read_u64 = mem_cgroup_read,
> > > +	},
> > > +	{
> > > +		.name = "memsw.limit_in_bytes",
> > > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
> > > +		.write_string = mem_cgroup_write,
> > > +		.read_u64 = mem_cgroup_read,
> > > +	},
> > > +	{
> > > +		.name = "memsw.failcnt",
> > > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
> > > +		.trigger = mem_cgroup_reset,
> > > +		.read_u64 = mem_cgroup_read,
> > > +	},
> > > +#endif
> > >  };
> > >  
> > IMHO, it would be better to define those "memsw.*" files as memsw_cgroup_files[],
> > and change mem_cgroup_populate() like:
> > 
> > static int mem_cgroup_populate(struct cgroup_subsys *ss,
> > 				struct cgroup *cont)
> > {
> > 	int ret;
> > 
> > 	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
> > 					ARRAY_SIZE(mem_cgroup_files));
> > 	if (!ret && do_swap_account)
> > 		ret = cgroup_add_files(cont, ss, memsw_cgroup_files,
> > 					ARRAY_SIZE(memsw_cgroup_files));
> > 
> > 	return ret;
> > }
> > 
> > so that those files appear only when swap accounting is enabled.
> > 
> 
> Nice idea. I'll try that. 
> 
I made a patch for this.

please merge this if it looks good to you.

I've confirmed that memsw.* files doesn't created with noswapaccount,
and this can be compiled with !CONFIG_CGROUP_MEM_RES_CTLR_SWAP.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 27f1772..03dfc46 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1542,6 +1542,9 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+};
+
+static struct cftype swap_cgroup_files[] = {
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 	{
 		.name = "memsw.usage_in_bytes",
@@ -1724,8 +1727,14 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	return cgroup_add_files(cont, ss, mem_cgroup_files,
+	int ret;
+	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
 					ARRAY_SIZE(mem_cgroup_files));
+	if (!ret && do_swap_account)
+		ret = cgroup_add_files(cont, ss, swap_cgroup_files,
+					ARRAY_SIZE(swap_cgroup_files));
+
+	return ret;
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
