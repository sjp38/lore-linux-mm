Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F121A6B0071
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 03:30:26 -0500 (EST)
Message-ID: <50E935D5.4040402@huawei.com>
Date: Sun, 6 Jan 2013 16:29:09 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/13] cpuset: make CPU / memory hotplug propagation asynchronous
References: <1357248967-24959-1-git-send-email-tj@kernel.org> <1357248967-24959-11-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-11-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> +static void schedule_cpuset_propagate_hotplug(struct cpuset *cs)
> +{
> +	/*
> +	 * Pin @cs.  The refcnt will be released when the work item
> +	 * finishes executing.
> +	 */
> +	if (!css_tryget(&cs->css))
> +		return;
> +
> +	/*
> +	 * Queue @cs->empty_cpuset_work.  If already pending, lose the css

cs->hotplug_work

> +	 * ref.  cpuset_propagate_hotplug_wq is ordered and propagation
> +	 * will happen in the order this function is called.
> +	 */
> +	if (!queue_work(cpuset_propagate_hotplug_wq, &cs->hotplug_work))
> +		css_put(&cs->css);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
