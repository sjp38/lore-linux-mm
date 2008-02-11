Date: Mon, 11 Feb 2008 12:24:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
Message-Id: <20080211122408.5008902f.akpm@linux-foundation.org>
In-Reply-To: <20080211141816.094061000@bull.net>
References: <20080211141646.948191000@bull.net>
	<20080211141816.094061000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia.Derbey@bull.net
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2008 15:16:53 +0100
Nadia.Derbey@bull.net wrote:

> [PATCH 07/08]
> 
> This patch makes msgmni not recomputed anymore upon ipc namespace creation /
> removal or memory add/remove, as soon as it has been set from userland.
> 
> As soon as msgmni is explicitely set via procfs or sysctl(), the associated
> callback routine is unregistered from the ipc namespace notifier chain.
> 

The patch series looks pretty good.

> ===================================================================
> --- linux-2.6.24-mm1.orig/ipc/ipc_sysctl.c	2008-02-08 16:07:15.000000000 +0100
> +++ linux-2.6.24-mm1/ipc/ipc_sysctl.c	2008-02-08 16:08:32.000000000 +0100
> @@ -35,6 +35,24 @@ static int proc_ipc_dointvec(ctl_table *
>  	return proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
>  }
>  
> +static int proc_ipc_callback_dointvec(ctl_table *table, int write,
> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	size_t lenp_bef = *lenp;
> +	int rc;
> +
> +	rc = proc_ipc_dointvec(table, write, filp, buffer, lenp, ppos);
> +
> +	if (write && !rc && lenp_bef == *lenp)
> +		/*
> +		 * Tunable has successfully been changed from userland:
> +		 * disable its automatic recomputing.
> +		 */
> +		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
> +
> +	return rc;
> +}

If you haven't done so, could you please check that it all builds cleanly
with CONFIG_PROCFS=n, and that all code which isn't needed if procfs is
disabled is not present in the final binary?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
