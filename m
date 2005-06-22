Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5MHO6og020663
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 13:24:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5MHO6jx214052
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 13:24:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5MHNun4017358
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 13:23:56 -0400
Subject: Re: [PATCH 2.6.12-rc5 4/10] mm: manual page migration-rc3 --
	add-sys_migrate_pages-rc3.patch
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050622163934.25515.22804.81297@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
	 <20050622163934.25515.22804.81297@tomahawk.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 22 Jun 2005 10:23:33 -0700
Message-Id: <1119461013.18457.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-22 at 09:39 -0700, Ray Bryant wrote:
> +asmlinkage long
> +sys_migrate_pages(pid_t pid, __u32 count, __u32 *old_nodes, __u32 *new_nodes)
> +{

Should the buffers be marked __user?

> +       if ((count < 1) || (count > MAX_NUMNODES))
> +               return -EINVAL;

Since you have an out_einval:, it's probably best to use it
consistently.  There is another place or two like this.

> +       for (i = 0; i < count; i++) {
> +               int n;
> +
> +               n = tmp_old_nodes[i];
> +               if ((n < 0) || (n >= MAX_NUMNODES))
> +                       goto out_einval;
> +               node_set(n, old_node_mask);
> +
> +               n = tmp_new_nodes[i];
> +               if ((n < 0) || (n >= MAX_NUMNODES) || !node_online(n))
> +                       goto out_einval;
> +               node_set(n, new_node_mask);
> +
> +       }

I know it's a simple operation, but I think I'd probably break out the
array validation into its own function.

Then, replace the above loop with this:

if (!migrate_masks_valid(tmp_old_nodes, count) ||
     migrate_masks_valid(tmp_old_nodes, count))
	goto out_einval;

for (i = 0; i < count; i++) {
	node_set(tmp_old_nodes[i], old_node_mask);
	node_set(tmp_new_nodes[i], new_node_mask);
}

> +static int
> +migrate_vma(struct task_struct *task, struct mm_struct *mm,
> +       struct vm_area_struct *vma, int *node_map)
...
> +       spin_lock(&mm->page_table_lock);
> +       for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
> +               page = follow_page(mm, vaddr, 0);
> +               /*
> +                * follow_page has been known to return pages with zero mapcount
> +                * and NULL mapping.  Skip those pages as well
> +                */
> +               if (page && page_mapcount(page)) {
> +                       if (node_map[page_to_nid(page)] >= 0) {
> +                               if (steal_page_from_lru(page_zone(page), page,
> +                                       &page_list))
> +                                               count++;
> +                               else
> +                                       BUG();
> +                       }
> +               }
> +       }
> +       spin_unlock(&mm->page_table_lock);

Personally, I dislike having so many embedded ifs, especially in a for
loop like that.  I think it's a lot more logical to code it up as a
series of continues, mostly because it's easy to read a continue as,
"skip this page."  You can't always see that as easily with an if().  It
also makes it so that you don't have to wrap the steal_page_from_lru()
call across two lines, which is super-ugly. :)

for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
	page = follow_page(mm, vaddr, 0);
	if (!page || !page_mapcount(page))
		continue;

	if (node_map[page_to_nid(page)] < 0)
		continue;

	if (steal_page_from_lru(page_zone(page), page, &page_list));
		count++;
	else
		BUG();
}

The same kind of thing goes for this if: 

> +       /* call the page migration code to move the pages */
> +       if (count) {
> +               nr_busy = try_to_migrate_pages(&page_list, node_map);
> +
> +               if (nr_busy < 0)
> +                       return nr_busy;
> +
> +               if (nr_busy == 0)
> +                       return count;
> +
> +               /* return the unmigrated pages to the LRU lists */
> +               list_for_each_entry_safe(page, page2, &page_list, lru)
> {
> +                       list_del(&page->lru);
> +                       putback_page_to_lru(page_zone(page), page);
> +               }
> +               return -EAGAIN;
> +       }
> +
> +       return 0;

It looks a lot cleaner if you just do 

	if (!count)
		return count;

	... contents of the if(){} block go here

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
