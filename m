Date: Wed, 11 May 2005 05:37:33 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2.6.12-rc3 7/8] mm: manual page migration-rc2 --
 sys_migrate_pages-cpuset-support-rc2.patch
Message-Id: <20050511053733.2ec67499.pj@sgi.com>
In-Reply-To: <20050511043840.10876.87654.53504@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
	<20050511043840.10876.87654.53504@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: taka@valinux.co.jp, marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

My apologies for not considering some of the following code review
comments earlier.  I was on vacation, more-or-less, for the last month.

Ray wrote:
+static inline nodemask_t cpuset_mems_allowed(const struct task_struct *tsk)
+{
+	return node_possible_map;
+}

I would have expected node_online_map here, not node_possible_map.
But I am not entirely sure that I am right in this expectation.

It is mildly unfortunate that your new cpuset_mems_allowed(const struct
task_struct *tsk) requires the task lock to be held on tsk before the
call, but the corresponding cpuset_cpus_allowed() expects to be called
without the task lock held, and locks the task temporarilly, during the
call.  This difference may trip someone up someday.

The abuse of the local variable 'nodes', changing its meaning towards
the end of a long sequence of code that knows it as the target tasks
nodes, to become the current tasks nodes, is unfortunate.  Egads - it is
worse than that.  The nodemask_t 'nodes' starts out being set to the
nodes in tmp_old_nodes[], and then is set to the nodes allowed to the
target task, and then is set to nodes allowed to the current task.
Perhaps this confusion can be reduced by using the suggested code below
with two nodemask_t's old_node_mask and new_node_mask.

The existing several loops over count nodes in this sys_migrate_pages()
code:

        for(i=0; i<count; i++)
                if(node_isset(tmp_new_nodes[i], nodes)) {

as well as the two new such loops that your cpuset check adds might
better be replaced with bitmap based operations on nodemasks, as in:

asmlinkage long
sys_migrate_pages(const pid_t pid, const int count,
        caddr_t old_nodes, caddr_t new_nodes)
{
	...
	nodemask_t old_node_mask, new_node_mask;

	...
	nodes_clear(old_node_mask);
	nodes_clear(new_node_mask);
	ret = -EINVAL;
	for (i = 0; i < count; i++) {
		int n;

		n = tmp_old_nodes[i];
		if (n < 0 || n >= MAX_NUMNODES)
			goto out;
		node_set(n, old_node_mask);

		n = tmp_new_nodes[i];
		if (n < 0 || n >= MAX_NUMNODES)
			goto out;
		node_set(n, new_node_mask);
	}

	/* old_nodes and new_nodes must be disjoint */
	if (nodes_intersects(old_node_mask, new_node_mask)
		goto out;
	...

With the above code, there is only a single loop over count, and then
various node_*() operations on the old and new node_mask should suffice
in more or less all cases.  Well ... two loops ... looks like at least
the loop to "set up the node_map array" is still needed, near the end.

Note also the more traditional Linux kernel for-loop spacing I used:
	for (i = 0; i < count; i++)
not:
	for(i=0; i<count; i++)
nor:
	for(i = 0; i < count; i++)

The existing sys_migrate_pages() is inconsistent in its spacing of
for-loops, both with itself and with the recommended kernel coding
style.

And note that I put the "old_nodes and new_nodes must be disjoint"
comment on one line, not three.

It doesn't look like tmp_old_nodes and tmp_new_nodes are initialized to
NULL in their declaration at the top of this sys_migrate_pages()
routine.  If say the kmalloc() of the first of these failed, then the
closing code might try to kfree() the second, which would still have
random stack junk in it.

Could you avoid the use of two labels at the end, 'out' and 'out_dec',
by making the decrement conditional on mm being set, as in:

out:
	if (mm)
		atomic_dec(&mm->mm_users);
	kfree(...);

This bit of code:

                /* migrate the pages of this vma */
                ret = migrate_vma(task, mm, vma, node_map);
                if (ret >= 0)
                        migrated += ret;
                else
                        goto out_dec;

might better be written as:

                /* migrate the pages of this vma */
                ret = migrate_vma(task, mm, vma, node_map);
                if (ret < 0)
			goto out;
                migrated += ret;

It is more common I think to dispense with the error case first,
and then unconditionally present the successful mainline case.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@engr.sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
