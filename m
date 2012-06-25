Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id BCC916B03A5
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 18:49:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7309602dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 15:49:47 -0700 (PDT)
Date: Mon, 25 Jun 2012 15:49:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
Message-ID: <20120625224942.GN3869@google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <1340633728-12785-10-git-send-email-glommer@parallels.com>
 <20120625182907.GF3869@google.com>
 <4FE8E7EB.2020804@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE8E7EB.2020804@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

Hello, Glauber.

On Tue, Jun 26, 2012 at 02:36:27AM +0400, Glauber Costa wrote:
> >Is the volatile declaration really necessary?  Why is it necessary?
> >Why no comment explaining it?
> 
> Seems to be required by set_bit and friends. gcc will complain if it
> is not volatile (take a look at the bit function headers)

Hmmm?  Are you sure gcc includes volatile in type check?  There are a
lot of bitops users in the kernel but most of them don't use volatile
decl on the variable.

> >>+			 */
> >>+			parent = parent_mem_cgroup(iter);
> >>+			while (parent && (parent != memcg)) {
> >>+				if (test_bit(KMEM_ACCOUNTED_THIS, &parent->kmem_accounted))
> >>+					goto noclear;
> >>+					
> >>+				parent = parent_mem_cgroup(parent);
> >>+			}
> >
> >Better written in for (;;)?  Also, if we're breaking on parent ==
> >memcg, can we ever hit NULL parent in the above loop?
> 
> I can simplify to test parent != memcg only, indeed it is not
> expected to be NULL (but if it happens to be due to any kind of bug,
> we protect against NULL-dereference, that is why I like to write
> this way)

I personally don't really like that.  It doesn't really add meaningful
protection (if that happens the tree walking is already severely
broken) while causes confusion to future readers of the code (when can
parent be NULL?).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
