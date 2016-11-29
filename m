Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2C86B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:10:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so26840056wjc.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:10:56 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 15si2659698wml.145.2016.11.29.06.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 06:10:55 -0800 (PST)
Date: Tue, 29 Nov 2016 15:08:10 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 08/22] mm/vmstat: Avoid on each online CPU loops
In-Reply-To: <20161128092800.GC14835@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1611291505340.4358@nanos>
References: <20161126231350.10321-1-bigeasy@linutronix.de> <20161126231350.10321-9-bigeasy@linutronix.de> <20161128092800.GC14835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, rt@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Mon, 28 Nov 2016, Michal Hocko wrote:
> On Sun 27-11-16 00:13:36, Sebastian Andrzej Siewior wrote:
> [...]
> >  static void __init init_cpu_node_state(void)
> >  {
> > -	int cpu;
> > +	int node;
> >  
> > -	for_each_online_cpu(cpu)
> > -		node_set_state(cpu_to_node(cpu), N_CPU);
> > +	for_each_online_node(node)
> > +		node_set_state(node, N_CPU);
> 
> Is this really correct? The point of the original code was to mark only
> those nodes which have at least one CPU. Or am I missing something?

You're right. An online node does not necessarily have an online CPU.

	for_each_online_node(node) {
		if (cpumask_weight(cpumask_of_node(node)) > 0)
			node_set_state(node, N_CPU);
	}

is probably more correct.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
