Message-ID: <42BA11AF.4080302@engr.sgi.com>
Date: Wed, 22 Jun 2005 20:34:39 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.12-rc5 4/10] mm: manual page migration-rc3 --	add-sys_migrate_pages-rc3.patch
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>	 <20050622163934.25515.22804.81297@tomahawk.engr.sgi.com> <1119461013.18457.61.camel@localhost>
In-Reply-To: <1119461013.18457.61.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Wed, 2005-06-22 at 09:39 -0700, Ray Bryant wrote:
> 
>>+asmlinkage long
>>+sys_migrate_pages(pid_t pid, __u32 count, __u32 *old_nodes, __u32 *new_nodes)
>>+{
> 
> 
> Should the buffers be marked __user?
> 

I've tried it both ways, but with the __user in the system call declaration,
you still need to have it on the copy_from_user() calls to get sparse to
shut up, so it really doesn't appear to help much to put it in the 
declaration.  I'm easy though.  If you think it helps, I'll add it.

> 
>>+       if ((count < 1) || (count > MAX_NUMNODES))
>>+               return -EINVAL;
> 
> 
> Since you have an out_einval:, it's probably best to use it
> consistently.  There is another place or two like this.
>

Good point.  I looked for other places like this and didn't find any, though.

> 
>>+       for (i = 0; i < count; i++) {
>>+               int n;
>>+
>>+               n = tmp_old_nodes[i];
>>+               if ((n < 0) || (n >= MAX_NUMNODES))
>>+                       goto out_einval;
>>+               node_set(n, old_node_mask);
>>+
>>+               n = tmp_new_nodes[i];
>>+               if ((n < 0) || (n >= MAX_NUMNODES) || !node_online(n))
>>+                       goto out_einval;
>>+               node_set(n, new_node_mask);
>>+
>>+       }
> 
> 
> I know it's a simple operation, but I think I'd probably break out the
> array validation into its own function.
> 
> Then, replace the above loop with this:
> 
> if (!migrate_masks_valid(tmp_old_nodes, count) ||
>      migrate_masks_valid(tmp_old_nodes, count))
> 	goto out_einval;
> 
> for (i = 0; i < count; i++) {
> 	node_set(tmp_old_nodes[i], old_node_mask);
> 	node_set(tmp_new_nodes[i], new_node_mask);
> }
> 
> 
>>+static int
>>+migrate_vma(struct task_struct *task, struct mm_struct *mm,
>>+       struct vm_area_struct *vma, int *node_map)
> 
> ...
> 

ok.

>>+       spin_lock(&mm->page_table_lock);
>>+       for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
>>+               page = follow_page(mm, vaddr, 0);
>>+               /*
>>+                * follow_page has been known to return pages with zero mapcount
>>+                * and NULL mapping.  Skip those pages as well
>>+                */
>>+               if (page && page_mapcount(page)) {
>>+                       if (node_map[page_to_nid(page)] >= 0) {
>>+                               if (steal_page_from_lru(page_zone(page), page,
>>+                                       &page_list))
>>+                                               count++;
>>+                               else
>>+                                       BUG();
>>+                       }
>>+               }
>>+       }
>>+       spin_unlock(&mm->page_table_lock);
> 
> 
> Personally, I dislike having so many embedded ifs, especially in a for
> loop like that.  I think it's a lot more logical to code it up as a
> series of continues, mostly because it's easy to read a continue as,
> "skip this page."  You can't always see that as easily with an if().  It
> also makes it so that you don't have to wrap the steal_page_from_lru()
> call across two lines, which is super-ugly. :)

ok, but I had to shorten page_list to pglist go get it to fit in 80 columns,
anyway.

> 
> for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
> 	page = follow_page(mm, vaddr, 0);
> 	if (!page || !page_mapcount(page))
> 		continue;
> 
> 	if (node_map[page_to_nid(page)] < 0)
> 		continue;
> 
> 	if (steal_page_from_lru(page_zone(page), page, &page_list));
> 		count++;
> 	else
> 		BUG();
> }
> 
> The same kind of thing goes for this if: 
> 
> 
>>+       /* call the page migration code to move the pages */
>>+       if (count) {
>>+               nr_busy = try_to_migrate_pages(&page_list, node_map);
>>+
>>+               if (nr_busy < 0)
>>+                       return nr_busy;
>>+
>>+               if (nr_busy == 0)
>>+                       return count;
>>+
>>+               /* return the unmigrated pages to the LRU lists */
>>+               list_for_each_entry_safe(page, page2, &page_list, lru)
>>{
>>+                       list_del(&page->lru);
>>+                       putback_page_to_lru(page_zone(page), page);
>>+               }
>>+               return -EAGAIN;
>>+       }
>>+
>>+       return 0;
> 
> 
> It looks a lot cleaner if you just do 
> 
> 	if (!count)
> 		return count;
> 
> 	... contents of the if(){} block go here
>

ok.

> -- Dave
> 
> 

Let me make the changes and I'll send out a new set of patches in a bit.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
