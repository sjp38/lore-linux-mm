Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 761626B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 23:42:34 -0500 (EST)
Date: Fri, 18 Jan 2013 13:42:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC][PATCH v2] slub: Keep page and object in sync in
 slab_alloc_node()
Message-ID: <20130118044242.GA18665@lge.com>
References: <1358446258.23211.32.camel@gandalf.local.home>
 <1358447864.23211.34.camel@gandalf.local.home>
 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
 <1358458996.23211.46.camel@gandalf.local.home>
 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
 <1358462763.23211.57.camel@gandalf.local.home>
 <1358464245.23211.62.camel@gandalf.local.home>
 <1358464837.23211.66.camel@gandalf.local.home>
 <1358468598.23211.67.camel@gandalf.local.home>
 <1358468924.23211.69.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358468924.23211.69.camel@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

Hello, Steven.

On Thu, Jan 17, 2013 at 07:28:44PM -0500, Steven Rostedt wrote:
> In slab_alloc_node(), after the cpu_slab is assigned, if the task is
> preempted and moves to another CPU, there's nothing keeping the page and
> object in sync. The -rt kernel crashed because page was NULL and object
> was not, and the node_match() dereferences page. Even though the crash
> happened on -rt, there's nothing that's keeping this from happening on
> mainline.
> 
> The easiest fix is to disable interrupts for the entire time from
> acquiring the current CPU cpu_slab and assigning the object and page.
> After that, it's fine to allow preemption.

How about this?

It's based on v3.8-rc3.
I'm not test this patch, yet.
Just for sharing my idea to fix a problem.

-----------------8<-----------------------
