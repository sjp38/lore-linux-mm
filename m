Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id EDD9B6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 01:27:46 -0400 (EDT)
Message-ID: <51930FCD.3090001@redhat.com>
Date: Wed, 15 May 2013 12:32:13 +0800
From: Lingzhu Xiang <lxiang@redhat.com>
MIME-Version: 1.0
Subject: Re: 3.9.0: panic during boot - kernel BUG at include/linux/gfp.h:323!
References: <22600323.7586117.1367826906910.JavaMail.root@redhat.com> <5191B101.1070000@redhat.com> <20130514183500.GN6795@mtj.dyndns.org>
In-Reply-To: <20130514183500.GN6795@mtj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/15/2013 02:35 AM, Tejun Heo wrote:
> Hello,
>
> On Tue, May 14, 2013 at 11:35:29AM +0800, Lingzhu Xiang wrote:
>> On 05/06/2013 03:55 PM, CAI Qian wrote:
>>> [    0.928031] ------------[ cut here ]------------
>>> [    0.934231] kernel BUG at include/linux/gfp.h:323!
> ...
>>> [    1.662913]  [<ffffffff812e3aa8>] alloc_cpumask_var_node+0x28/0x90
>>> [    1.671224]  [<ffffffff81a0bdb3>] wq_numa_init+0x10d/0x1be
>>> [    1.686085]  [<ffffffff81a0bec8>] init_workqueues+0x64/0x341
>
> Does the following patch make the problem go away?  The dynamic paths
> should be safe as they are synchronized against CPU hot plug paths and
> don't allocate anything on nodes w/o any CPUs.

Yes, no more panics.


> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 4aa9f5b..232c1bb 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -4895,7 +4895,8 @@ static void __init wq_numa_init(void)
>   	BUG_ON(!tbl);
>
>   	for_each_node(node)
> -		BUG_ON(!alloc_cpumask_var_node(&tbl[node], GFP_KERNEL, node));
> +		BUG_ON(!alloc_cpumask_var_node(&tbl[node], GFP_KERNEL,
> +				node_online(node) ? node : NUMA_NO_NODE));
>
>   	for_each_possible_cpu(cpu) {
>   		node = cpu_to_node(cpu);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
