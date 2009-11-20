Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B56576B0088
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:21:40 -0500 (EST)
Message-ID: <4B065169.7080603@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 16:20:57 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
References: <4B064AF5.9060208@cn.fujitsu.com> <20091120081440.GA19778@elte.hu>
In-Reply-To: <20091120081440.GA19778@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> TODO:
>> - show sym+offset in 'callsite' column
> 
> The way to print symbolic information for the 'callsite' column is to 
> fill in and walk the thread->DSO->symbol trees that all perf tools 
> maintain:
> 
> 	/* simplified, without error handling */
> 
> 	ip = event->ip.ip;
> 
> 	thread = threads__findnew(event->ip.pid);
> 
> 	map = thread__find_map(thread, ip);
> 
> 	ip = map->map_ip(map, ip); /* map absolute RIP into DSO-relative one */
> 
> 	sym = map__find_symbol(map, ip, symbol_filter);
> 
> then sym->name is the string that can be printed out. This works in a 
> symmetric way for both kernel-space and user-space symbols. (Call-chain 
> information can be captured and displayed too.)
> 
> ( 'Alloc Ptr' symbolization is harder, but it would be useful too i 
>   think, to map it back to the slab cache name. )
> 

Thanks.

I was lazy to figure it out by myself. ;)

>> - show cross node allocation stats
> 
> I checked and we appear to have all the right events for that - the node 
> ID is being traced consistently AFAICS.
> 

Actually kmemtrace-user shows this stats, but in a wrong way.
It doesn't map cpu_nr to node.

>> - collect more useful stats?
>> - ...
> 
> Pekka, Eduard and the other slab hackers might have ideas about what 
> other stats they generally like to see to judge the health of a workload 
> (or system).
> 
> If this iteration looks good to the slab folks then i can apply it as-is 
> and we can do the other changes relative to that. It looks good to me as 
> a first step, and it's functional already.
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
