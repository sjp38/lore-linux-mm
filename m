Date: Mon, 27 Oct 2008 16:02:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 10/11] memcg: swap cgroup
Message-Id: <20081027160216.29196b96.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081023181349.63096aeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181349.63096aeb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> +int swap_cgroup_swapon(int type, unsigned long max_pages)
> +{
> +	void *array;
> +	unsigned long array_size;
> +	unsigned long length;
> +	struct swap_cgroup_ctrl *ctrl;
> +
> +	if (!do_swap_account)
> +		return 0;
> +
> +	length = ((max_pages/SC_PER_PAGE) + 1);
> +	array_size = length * sizeof(void *);
> +
> +	array = vmalloc(array_size);
> +	if (!array)
> +		goto nomem;
> +
> +	memset(array, 0, array_size);
> +	ctrl = &swap_cgroup_ctrl[type];
> +	mutex_lock(&swap_cgroup_mutex);
> +	ctrl->length = length;
> +	ctrl->map = array;
> +	if (swap_cgroup_prepare(type)) {
> +		/* memory shortage */
> +		ctrl->map = NULL;
> +		ctrl->length = 0;
> +		vfree(array);
> +		mutex_unlock(&swap_cgroup_mutex);
> +		goto nomem;
> +	}
> +	mutex_unlock(&swap_cgroup_mutex);
> +
> +	printk(KERN_INFO
> +		"swap_cgroup: uses %ldbytes vmalloc and %ld bytes buffres\n",
just a minor nitpick, s/ldbytes/ld bytes.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
