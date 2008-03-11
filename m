Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m2B8vsVp013120
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 08:57:54 GMT
Received: from py-out-1112.google.com (pyed32.prod.google.com [10.34.156.32])
	by zps78.corp.google.com with ESMTP id m2B8vqU2003002
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 01:57:53 -0700
Received: by py-out-1112.google.com with SMTP id d32so2567561pye.12
        for <linux-mm@kvack.org>; Tue, 11 Mar 2008 01:57:52 -0700 (PDT)
Message-ID: <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
Date: Tue, 11 Mar 2008 01:57:43 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
In-Reply-To: <47D63FBC.1010805@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47D16004.7050204@openvz.org>
	 <20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <47D63FBC.1010805@openvz.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 11, 2008 at 1:15 AM, Pavel Emelyanov <xemul@openvz.org> wrote:
>
>  <mem_couter_0>
>   + -- <swap_counter_0>
>   + -- <mem_counter_1>
>   |     + -- <swap_counter_1>
>   |     + -- <mem_counter_11>
>   |     |     + -- <swap_counter_11>
>   |     + -- <mem_counter_12>
>   |           + -- <swap_counter_12>
>   + -- <mem_counter_2>
>   |     + -- <swap_counter_2>
>   |     + -- <mem_counter_21>
>   |     |     + -- <swap_counter_21>
>   |     + -- <mem_counter_22>
>   |           + -- <swap_counter_22>
>   + -- <mem_counter_N>
>        + -- <swap_counter_N>
>        + -- <mem_counter_N1>
>        |     + -- <swap_counter_N1>
>        + -- <mem_counter_N2>
>              + -- <swap_counter_N2>
>

The idea of hierarchy is good, but I don't think this particular
hierarchy works for memory.

Main memory and swap space are very different resources, with very
different performance characteristics. Suppose you have a 2G machine,
and you want to guarantee each job 1GB of main memory, plus give them
the option of 1GB of swap for when they go over the 1G main memory
limit. With the hierarchy given above, you've need to give each job a
2GB mem.limit and a 1GB swap.limit, and so there would be no main
memory isolation.

My feeling is that people are going to want to limit swap and main
memory usage as two independent resource hierarchies more often than
they're going to want to limit overall virtual memory. But assuming
that there are people who need to do the latter, then you should make
it configurable how the hierarchies fit together.

Alternatively, you could make it possible for a res_counter to have
multiple parents (each of which constrains the overall usage of it and
its siblings), and have three counters for each cgroup:

- vm_counter: overall virtual memory limit for group, parent =
parent_mem_cgroup->vm_counter

- mem_counter: main memory limit for group, parents = vm_counter,
parent_mem_cgroup->mem_counter

- swap_counter: swap limit for group, parents = vm_counter,
parent_mem_cgroup->swap_counter

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
