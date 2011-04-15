Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 37479900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 04:20:59 -0400 (EDT)
Date: Fri, 15 Apr 2011 10:20:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
Message-ID: <20110415082051.GB8828@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
 <20110414160145.0830.A69D9226@jp.fujitsu.com>
 <20110415161831.12F8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415161831.12F8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

[I just realized that I forgot to CC mm mailing list]

On Fri 15-04-11 16:18:45, KOSAKI Motohiro wrote:
> Oops.
> I should have look into !mempolicy part too.
> I'm sorry.
> 
[...]
> Michal, I think this should be
> 
> #ifdef CONFIG_CPUSETS
> 	if (cpuset_do_page_mem_spread())
> 		p->cpuset_mem_spread_rotor = node_random(&p->mems_allowed);
> 	if (cpuset_do_slab_mem_spread())
> 		p->cpuset_slab_spread_rotor = node_random(&p->mems_allowed);
> #endif
> 
> because 99.999% people don't use cpuset's spread mem/slab feature and
> get_random_int() isn't zero cost.
> 
> What do you think?

You are right. I was thinking about lazy approach and initialize those
values when they are used for the first time. What about the patch
below?

Change from v1:
- initialize cpuset_{mem,slab}_spread_rotor lazily

---
