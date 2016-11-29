Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 677056B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:44:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so44525451wms.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:44:40 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o76si2846734wmi.60.2016.11.29.06.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 06:44:39 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so24779975wme.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:44:39 -0800 (PST)
Date: Tue, 29 Nov 2016 15:44:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/22] mm/vmstat: Avoid on each online CPU loops
Message-ID: <20161129144437.GA9796@dhcp22.suse.cz>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-9-bigeasy@linutronix.de>
 <20161128092800.GC14835@dhcp22.suse.cz>
 <alpine.DEB.2.20.1611291505340.4358@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1611291505340.4358@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, rt@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue 29-11-16 15:08:10, Thomas Gleixner wrote:
> On Mon, 28 Nov 2016, Michal Hocko wrote:
> > On Sun 27-11-16 00:13:36, Sebastian Andrzej Siewior wrote:
> > [...]
> > >  static void __init init_cpu_node_state(void)
> > >  {
> > > -	int cpu;
> > > +	int node;
> > >  
> > > -	for_each_online_cpu(cpu)
> > > -		node_set_state(cpu_to_node(cpu), N_CPU);
> > > +	for_each_online_node(node)
> > > +		node_set_state(node, N_CPU);
> > 
> > Is this really correct? The point of the original code was to mark only
> > those nodes which have at least one CPU. Or am I missing something?
> 
> You're right. An online node does not necessarily have an online CPU.
> 
> 	for_each_online_node(node) {
> 		if (cpumask_weight(cpumask_of_node(node)) > 0)
> 			node_set_state(node, N_CPU);
> 	}
> 
> is probably more correct.

Yes, this looks correct. Considering that the same cpumask_weight is
used in another function I guess a small helper would be nice. E.g.
bool node_has_cpus(int node)
{
	return cpumask_weight(cpumask_of_node(node)) > 0;
}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
