Message-ID: <48B2FC9D.3020300@sgi.com>
Date: Mon, 25 Aug 2008 11:40:29 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20080820234615.258a9c04.akpm@linux-foundation.org> <20080821.001322.236658980.davem@davemloft.net>
In-Reply-To: <20080821.001322.236658980.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 20 Aug 2008 23:46:15 -0700
> 
>> On Wed, 20 Aug 2008 20:08:13 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>>> +	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));

I think the more correct usage would be:

	{
		node_to_cpumask_ptr(v, node);
		num_cpus_per_node = cpus_weight_nr(*v);
		max /= num_cpus_per_node;

		return max(max, min_pages);
	}

which should load 'v' with a pointer to the node_to_cpumask_map[node] entry
[and avoid using stack space for the cpumask_t variable for those arch's
that define a node_to_cpumask_map (or similar).]  Otherwise a local cpumask_t
variable '_v' is created to which 'v' is pointing to and thus can be used
directly as an arg to the cpu_xxx ops.

Thanks,
Mike


>> sparc64 allmodconfig:
>>
>> mm/quicklist.c: In function `max_pages':
>> mm/quicklist.c:44: error: invalid lvalue in unary `&'
>>
>> we seem to have a made a spectacular mess of cpumasks lately.
> 
> It should explode similarly on x86, since it also defines node_to_cpumask()
> as an inline function.
> 
> IA64 seems to be one of the few platforms to define this as a macro
> evaluating to the node-to-cpumask array entry, so it's clear what
> platform Motohiro-san did build testing on :-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
