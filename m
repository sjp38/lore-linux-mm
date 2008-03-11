Date: Tue, 11 Mar 2008 19:16:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] memcgoup: allow memory.failcnt to be reset
Message-Id: <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47D65A3E.100@cn.fujitsu.com>
References: <47D65A3E.100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 19:09:02 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Allow memory.failcnt to be reset to 0:
> 
>         echo 0 > memory.failcnt
> 
> And '0' is the only valid value.
> 
Can't this be generic resource counter function ?

Thanks,
-Kame


> This is useful when testing or observing the memory resource
> controller. Without this function, one will have to remember
> the previous failcnt to decide whether memory reclaim has
> happened *again*.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  Documentation/controllers/memory.txt |    4 +++-
>  mm/memcontrol.c                      |   15 +++++++++++++++
>  2 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/controllers/memory.txt b/Documentation/controllers/memory.txt
> index 866b9cd..28f80e3 100644
> --- a/Documentation/controllers/memory.txt
> +++ b/Documentation/controllers/memory.txt
> @@ -194,7 +194,9 @@ this file after a write to guarantee the value committed by the kernel.
>  4096
>  
>  The memory.failcnt field gives the number of times that the cgroup limit was
> -exceeded.
> +exceeded. It can be reset.
> +
> +# echo 0 > memory.failcnt
>  
>  The memory.stat file gives accounting information. Now, the number of
>  caches, RSS and Active pages/Inactive pages are shown.
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6145031..fd26dc2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -883,6 +883,20 @@ static int mem_force_empty_write(struct cgroup *cont, struct cftype *cft,
>  	return ret;
>  }
>  
> +static int mem_failcnt_write(struct cgroup *cont, struct cftype *cft,
> +			     u64 val)
> +{
> +	struct res_counter *counter;
> +
> +	if (val != 0)
> +		return -EINVAL;
> +
> +	counter = &mem_cgroup_from_cont(cont)->res;
> +	res_counter_write_u64(counter, cft->private, 0);
> +
> +	return 0;
> +}
> +
>  static const struct mem_cgroup_stat_desc {
>  	const char *msg;
>  	u64 unit;
> @@ -934,6 +948,7 @@ static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "failcnt",
>  		.private = RES_FAILCNT,
> +		.write_u64 = mem_failcnt_write,
>  		.read_u64 = mem_cgroup_read,
>  	},
>  	{
> -- 
> 1.5.4.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
