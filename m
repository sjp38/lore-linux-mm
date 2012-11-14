Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 60FD06B005A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 05:50:53 -0500 (EST)
Date: Wed, 14 Nov 2012 11:50:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/4] mm, oom: ensure sysrq+f always passes valid zonelist
Message-ID: <20121114105049.GE17111@dhcp22.suse.cz>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 14-11-12 01:15:19, David Rientjes wrote:
> With hotpluggable and memoryless nodes, it's possible that node 0 will
> not be online, so use the first online node's zonelist rather than
> hardcoding node 0 to pass a zonelist with all zones to the oom killer.

Makes sense although I haven't seen a machine with no 0 node yet.
According to 13808910 this is indeed possible.

> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  drivers/tty/sysrq.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -346,7 +346,8 @@ static struct sysrq_key_op sysrq_term_op = {
>  
>  static void moom_callback(struct work_struct *ignored)
>  {
> -	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
> +	out_of_memory(node_zonelist(first_online_node, GFP_KERNEL), GFP_KERNEL,
> +		      0, NULL, true);
>  }
>  
>  static DECLARE_WORK(moom_work, moom_callback);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
