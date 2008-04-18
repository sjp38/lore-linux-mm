Date: Thu, 17 Apr 2008 18:35:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080417183538.d88feff5.akpm@linux-foundation.org>
In-Reply-To: <200804171955.46600.paul.moore@hp.com>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<200804171955.46600.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Moore <paul.moore@hp.com>
Cc: mingo@elte.hu, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008 19:55:46 -0400
Paul Moore <paul.moore@hp.com> wrote:

> > security/selinux/netnode.c looks to be doing simple old
> > kzalloc/kfree, so I'd be suspecting slab.  But there are significant
> > changes netnode.c in git-selinux.
> >
> > I have maybe two hours in which to weed out whatever
> > very-recently-added dud patches are causing this.  Any suggestions
> > are welcome.
> 
> For what it's worth I just looked over the changes in netnode.c and 
> nothing is jumping out at me.  The changes ran fine for me when tested 
> on the later 2.6.25-rcX kernels but I suppose that doesn't mean a whole 
> lot.
> 
> I've got a 4-way x86_64 box but it needs to be installed (which means 
> I'm not going to be able to do anything useful with it until tomorrow 
> at the earliest).  I'll try it out and see if I can recreate the 
> problem.

I dropped git-selinux and that crash seems to have gone away.  It took about
five minutes before, but would presumably have happened earlier if I'd
reduced the cache size.

btw, wouldn't this

--- a/security/selinux/netnode.c~a
+++ a/security/selinux/netnode.c
@@ -190,7 +190,7 @@ static int sel_netnode_insert(struct sel
 	if (sel_netnode_hash[idx].size == SEL_NETNODE_HASH_BKT_LIMIT) {
 		struct sel_netnode *tail;
 		tail = list_entry(node->list.prev, struct sel_netnode, list);
-		list_del_rcu(node->list.prev);
+		list_del_rcu(&tail->list);
 		call_rcu(&tail->rcu, sel_netnode_free);
 	} else
 		sel_netnode_hash[idx].size++;
_

be a bit clearer?  If it's correct - I didn't try too hard :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
