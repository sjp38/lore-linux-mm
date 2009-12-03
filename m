Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 356A5600727
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 22:01:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB331ai0025090
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Dec 2009 12:01:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98ED945DE52
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 12:01:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 676A545DE50
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 12:01:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E9B61DB8043
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 12:01:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 976931DB803F
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 12:01:35 +0900 (JST)
Date: Thu, 3 Dec 2009 11:58:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-Id: <20091203115840.45f73bd3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091203024739.GB17716@localhost>
References: <20091202031231.735876003@intel.com>
	<20091202043046.519053333@intel.com>
	<20091202124446.GA18989@one.firstfloor.org>
	<20091202125842.GA13277@localhost>
	<20091203105229.afb0efc4.kamezawa.hiroyu@jp.fujitsu.com>
	<20091203021915.GA13587@localhost>
	<20091203112822.ecee5bf5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091203024739.GB17716@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Dec 2009 10:47:39 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Thu, Dec 03, 2009 at 10:28:22AM +0800, KAMEZAWA Hiroyuki wrote:
> Ah please forgive my memcg ignorance..  Then how about bring back the
> old css_id() based scheme (old patch follows)?
> 
maybe enough. but please take care of the fact that css is can be "reused"
once freed.


> > If you have more patches to be usable the function above,
> > I recommend you to post this with some real-use patches, in step by step.
> 
> Do you mean user space test case? Here is a simple one:
> 
>         #!/bin/sh
> 
>         TEST_PROG=usemem
>         TEST_PARM="-m 100 -s 100"
> 
>         test -d /cgroup/hwpoison && rmdir /cgroup/hwpoison
>         mkdir /cgroup/hwpoison
> 
>         $TEST_PROG $TEST_PARM &
>         echo `pidof $TEST_PROG` > /cgroup/hwpoison/tasks
> 
>         memcg_id=$(</cgroup/hwpoison/memory.id)
>         echo $memcg_id > /debug/hwpoison/corrupt-filter-memcg
> 
>         ./corrupt-all-pfn
> 
Ah, this is nice to be put into changelog or some documentation.


> > patch 19,20 is ok for me.
> 
> Thanks,
> Fengguang
> ---
> memcg: show memory.id in cgroupfs
> 
> The hwpoison test suite need to selectively inject hwpoison to some
> targeted task pages, and must not kill important system processes
> such as init.
> 
> The memory cgroup serves this purpose well. We can put the target
> processes under the control of a memory cgroup, tell the hwpoison
> injection code the id of that memory cgroup so that it will only
> poison pages associated with it.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

No objections from me. please use "id" check. or adds new flag to
struct mem_cgroup, as you like.

The style I prefer is
==
 struct mem_cgroup {
  ....
  bool hwpoison_test_enabled;
 };

+#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison testing */
+	{
+		.name = "hwpoison_test_enable",
+		.read_u64 = ....
+	},
+#endif

and.
	mem = try_get_mem_cgroup_from_page(p);
	if (mem_cgroup_is_under_poison_test(mem))
		ret = true;
	mem_cgroup_put(mem);	/* calls css_put() */

Maybe not difficult. and this is an usual way. But it's ok if you don't want to
scannter HWPOISON things to other function's files. This is test operation.

So, "including real use case and patches" is only my request, for this time.

Thanks,
-Kame


> ---
>  mm/memcontrol.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> --- linux-mm.orig/mm/memcontrol.c	2009-09-07 16:01:02.000000000 +0800
> +++ linux-mm/mm/memcontrol.c	2009-09-11 18:20:55.000000000 +0800
> @@ -2510,6 +2510,13 @@ mem_cgroup_get_recursive_idx_stat(struct
>  	*val = d.val;
>  }
>  
> +#ifdef CONFIG_HWPOISON_INJECT
> +static u64 mem_cgroup_id_read(struct cgroup *cont, struct cftype *cft)
> +{
> +	return css_id(cgroup_subsys_state(cont, mem_cgroup_subsys_id));
> +}
> +#endif
> +
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  {
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> @@ -2841,6 +2848,12 @@ static int mem_cgroup_swappiness_write(s
>  
>  
>  static struct cftype mem_cgroup_files[] = {
> +#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison testing */
> +	{
> +		.name = "id",
> +		.read_u64 = mem_cgroup_id_read,
> +	},
> +#endif
>  	{
>  		.name = "usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
