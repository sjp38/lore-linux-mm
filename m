Date: Sun, 6 Feb 2005 00:02:21 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20050206020221.GA6221@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com, taka@valinux.co.jp, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 04, 2005 at 10:08:57AM -0600, Ray Bryant wrote:
> Hirokazu Takahashi wrote:
> >
> >
> >>If I take out the migration cache patch, this "VM: killing ..." problem
> >>goes away.   So it has something to do specifically with the migration
> >>cache code.
> >
> >
> >I've never seen the message though the migration cache code may have
> >some bugs. May I ask you some questions about it?
> >
> > - Which version of kernel did you use for it?
> 
> 2.6.10.  I pulled enough of the mm fixes (2 patches) so that the base
> migration patch from the hotplug tree would work on top of 2.6.10.  AFAIK
> the same problem occurs on 2.6.11-mm2 which is where I started with the
> migration cache patch.  But I admit I haven't tested it there recently.

Ray,

A possibility is that lookup_migration_cache() returns NULL, but for some
reason (?) pte_same() fails, giving us VM_FAULT_OOM which results in 
do_page_fault() killing the task.

Can you a printk in here to confirm this?

do_swap_page():
if (pte_is_migration(orig_pte)) {
+               page = lookup_migration_cache(entry.val);
+               if (!page) {
+                       spin_lock(&mm->page_table_lock);
+                       page_table = pte_offset_map(pmd, address);
+                       if (likely(pte_same(*page_table, orig_pte)))
+                               ret = VM_FAULT_OOM;
+                       else
+                               ret = VM_FAULT_MINOR;
+                       pte_unmap(page_table);
+                       spin_unlock(&mm->page_table_lock);
+                       goto out;
+               }


If that happens not to be the case, please find out what exactly is going
on (ie where the VM_FAULT_OOM is coming from) so we can try to help you. 

Do you have any other VM modifications in this kernel? What are they, except
the process migration code?

BTW, can you please post your process migration code? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
