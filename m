Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9DA6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:16:24 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0QF6qKo023895
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:07:18 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A3E7C4DE803B
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:12:50 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0QFGL3s159424
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:16:21 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0QFGJ8n010300
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:16:21 -0500
Date: Wed, 26 Jan 2011 20:39:46 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 8/20]  8: uprobes: mmap and fork
 hooks.
Message-ID: <20110126150946.GK19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095848.23751.73144.sendpatchset@localhost6.localdomain6>
 <1295957741.28776.719.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295957741.28776.719.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-25 13:15:41]:

> On Thu, 2010-12-16 at 15:28 +0530, Srikar Dronamraju wrote:
> > +static void search_within_subtree(struct rb_node *n, struct inode *inode,
> > +               struct list_head *tmp_list);
> > +
> > +static void add_to_temp_list(struct vm_area_struct *vma, struct inode *inode,
> > +               struct list_head *tmp_list)
> > +{
> > +       struct uprobe *uprobe;
> > +       struct rb_node *n;
> > +       unsigned long flags;
> > +
> > +       n = uprobes_tree.rb_node;
> > +       spin_lock_irqsave(&treelock, flags);
> > +       while (n) {
> > +               uprobe = rb_entry(n, struct uprobe, rb_node);
> > +               if (match_inode(uprobe, inode, &n)) {
> > +                       list_add(&uprobe->pending_list, tmp_list);
> > +                       search_within_subtree(n, inode, tmp_list);
> > +                       break;
> > +               }
> > +       }
> > +       spin_unlock_irqrestore(&treelock, flags);
> > +}
> > +
> > +static void __search_within_subtree(struct rb_node *p, struct inode *inode,
> > +               struct list_head *tmp_list)
> > +{
> > +       struct uprobe *uprobe;
> > +
> > +       uprobe = rb_entry(p, struct uprobe, rb_node);
> > +       if (match_inode(uprobe, inode, &p)) {
> > +               list_add(&uprobe->pending_list, tmp_list);
> > +               search_within_subtree(p, inode, tmp_list);
> > +       }
> > +
> > +
> > +}
> > +
> > +static void search_within_subtree(struct rb_node *n, struct inode *inode,
> > +               struct list_head *tmp_list)
> > +{
> > +       struct rb_node *p;
> > +
> > +       if (p)
> > +               __search_within_subtree(p, inode, tmp_list);
> > +
> > +       p = n->rb_right;
> > +       if (p)
> > +               __search_within_subtree(p, inode, tmp_list);
> > +} 
> 
> Whee recursion FTW!, you just blew your kernel stack :-)
> 
> Since you sort inode first, offset second, I think you can simply look
> for the first matching inode entry and simply rb_next() until you don't
> match.

Agree that we should get rid of recursion.

I dont think we can simply use rb_next() once we have the first
matching function. There could be a matching inode but a smaller
offset in left that will be missed by rb_next(). (Unless I have
misunderstood rb_next() !!!)

Here are the ways I think we can workaround.
A. change the match_inode() logic to use rb_first/rb_next.
This would make negate the benefit we get from rb_trees because we
have to match every node. Also match_offset might get a little tricky.

B. use the current match_inode but change the search_within_subtree
logic. search_within_subtree() would first find the leftmode node
within the subtree that still has the same inode. Thereafter it will use
rb_next().

Do you have any other ideas?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
