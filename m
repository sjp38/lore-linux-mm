Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AE1386B0062
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 02:24:01 -0500 (EST)
Message-ID: <4AF7C356.5020504@cn.fujitsu.com>
Date: Mon, 09 Nov 2009 15:23:02 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm 1/8] cgroup: introduce cancel_attach()
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp> <20091106141106.a2bd995a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141106.a2bd995a.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> This patch adds cancel_attach() operation to struct cgroup_subsys.
> cancel_attach() can be used when can_attach() operation prepares something
> for the subsys, but we should rollback what can_attach() operation has prepared
> if attach task fails after we've succeeded in can_attach().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

> ---
>  Documentation/cgroups/cgroups.txt |   13 +++++++++++-
>  include/linux/cgroup.h            |    2 +
>  kernel/cgroup.c                   |   38 ++++++++++++++++++++++++++++++------
>  3 files changed, 45 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 0b33bfe..c86947c 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -536,10 +536,21 @@ returns an error, this will abort the attach operation.  If a NULL
>  task is passed, then a successful result indicates that *any*
>  unspecified task can be moved into the cgroup. Note that this isn't
>  called on a fork. If this method returns 0 (success) then this should
> -remain valid while the caller holds cgroup_mutex. If threadgroup is
> +remain valid while the caller holds cgroup_mutex and it is ensured that either
> +attach() or cancel_attach() will be called in futer. If threadgroup is

s/futer/future

>  true, then a successful result indicates that all threads in the given
>  thread's threadgroup can be moved together.
...
> +out:
> +	if (retval)

I prefer:

	if (reval) {
		...
	}

> +		for_each_subsys(root, ss) {
> +			if (ss == failed_ss)
> +				/*
> +				 * This means can_attach() of this subsystem
> +				 * have failed, so we don't need to call
> +				 * cancel_attach() against rests of subsystems.
> +				 */
> +				break;
> +			if (ss->cancel_attach)
> +				ss->cancel_attach(ss, cgrp, tsk, false);
> +		}
> +	return retval;
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
