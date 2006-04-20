Date: Thu, 20 Apr 2006 16:01:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Patch: 003/006] pgdat allocation for new node add (generic
 alloc node_data)
Message-Id: <20060420160131.7344fe8f.akpm@osdl.org>
In-Reply-To: <20060420190547.EE4E.Y-GOTO@jp.fujitsu.com>
References: <20060420185123.EE48.Y-GOTO@jp.fujitsu.com>
	<20060420190547.EE4E.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
>  +#define generic_alloc_nodedata(nid)				\
>  +({								\
>  +	(pg_data_t *)kzalloc(sizeof(pg_data_t), GFP_KERNEL);	\
>  +})

In general, library functions which perform memory allocation should not
make assumptions about which gfp_t they are allowed to use.

So this really should be `generic_alloc_nodedata(nid, gfp_mask)'.

However, it's very desirable that memory allocations use GFP_KERNEL rather
than, say, GFP_ATOMIC.  So your interface here _forces_ callers to be in a
state where GFP_KERNEL is legal, which is good discipline.

Although if that turns out to be a problem, we can expect to see a sad
little patch from someone which tries to change this to GFP_ATOMIC, which
makes everything worse - even those callers who _can_ use GFP_KERNEL.

(In practice, NUMA developers seem to never test with sufficient
CONFIG_DEBUG_* flags enabled, and with CONFIG_PREEMPT, so they happily
don't get to discover their sleep-in-spinlock bugs anyway).

Anyway, on balance, I think it'd be best to convert this API to take a
gfp_t as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
