Date: Fri, 21 Apr 2006 09:23:33 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch: 003/006] pgdat allocation for new node add (generic alloc node_data)
In-Reply-To: <20060420160131.7344fe8f.akpm@osdl.org>
References: <20060420190547.EE4E.Y-GOTO@jp.fujitsu.com> <20060420160131.7344fe8f.akpm@osdl.org>
Message-Id: <20060421090220.FCF7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> >
> >  +#define generic_alloc_nodedata(nid)				\
> >  +({								\
> >  +	(pg_data_t *)kzalloc(sizeof(pg_data_t), GFP_KERNEL);	\
> >  +})
> 
> In general, library functions which perform memory allocation should not
> make assumptions about which gfp_t they are allowed to use.
> 
> So this really should be `generic_alloc_nodedata(nid, gfp_mask)'.
> 
> However, it's very desirable that memory allocations use GFP_KERNEL rather
> than, say, GFP_ATOMIC.  So your interface here _forces_ callers to be in a
> state where GFP_KERNEL is legal, which is good discipline.
> 
> Although if that turns out to be a problem, we can expect to see a sad
> little patch from someone which tries to change this to GFP_ATOMIC, which
> makes everything worse - even those callers who _can_ use GFP_KERNEL.
> 
> (In practice, NUMA developers seem to never test with sufficient
> CONFIG_DEBUG_* flags enabled, and with CONFIG_PREEMPT, so they happily
> don't get to discover their sleep-in-spinlock bugs anyway).
> 
> Anyway, on balance, I think it'd be best to convert this API to take a
> gfp_t as well.

To tell the truth, I prefer making new interface to allocate new added
memory than using normal kzalloc().
Because this kzalloc() will allocate() other node's memory
by im-completion new memory's initialization.

In addition, memory hot-add may be required at the time that memory
is already exhausted.
This kzalloc() might be "finish blow". (pgdat is not small.
Especially, ia64 needs node data's copy.)
Probably, user will feel very strange. 
"I added new memory. But OOM killer is called by it, why????"

So I think alloc_hot_added_memory() is desirable, which can allocate new
added memory until completion of initialization.

Thanks for your advice.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
