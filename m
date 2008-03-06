Date: Thu, 6 Mar 2008 11:10:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot
 time
In-Reply-To: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Balbir Singh wrote:

> @@ -3010,3 +3020,16 @@ static void cgroup_release_agent(struct 
>  	spin_unlock(&release_list_lock);
>  	mutex_unlock(&cgroup_mutex);
>  }
> +
> +static int __init cgroup_disable(char *str)
> +{
> +	int i;
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +		struct cgroup_subsys *ss = subsys[i];
> +		if (!strcmp(str, ss->name)) {
> +			ss->disabled = 1;
> +			break;
> +		}
> +	}
> +}
> +__setup("cgroup_disable=", cgroup_disable);

This doesn't handle spaces very well, so isn't it possible for the name of 
a current or future cgroup subsystem to be specified after cgroup_disable= 
on the command line and have it disabled by accident?

> diff -puN Documentation/kernel-parameters.txt~cgroup_disable Documentation/kernel-parameters.txt
> --- linux-2.6.25-rc4/Documentation/kernel-parameters.txt~cgroup_disable	2008-03-06 17:57:32.000000000 +0530
> +++ linux-2.6.25-rc4-balbir/Documentation/kernel-parameters.txt	2008-03-06 18:00:32.000000000 +0530
> @@ -383,6 +383,10 @@ and is between 256 and 4096 characters. 
>  	ccw_timeout_log [S390]
>  			See Documentation/s390/CommonIO for details.
>  
> +	cgroup_disable= [KNL] Enable disable a particular controller
> +			Format: {name of the controller}
> +			See /proc/cgroups for a list of compiled controllers
> +

This works on multiple controllers, though, if they follow 
cgroup_disable=, so the documentation and format should reflect that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
