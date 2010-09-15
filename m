Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7445A6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:35:03 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH] After swapout/swapin private dirty mappings become clean
Date: Wed, 15 Sep 2010 10:07:42 +0530
References: <201009141640.55650.knikanth@suse.de> <20100915092239.C9D9.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100915092239.C9D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201009151007.43232.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, balbir@linux.vnet.ibm.com, rguenther@novell.com, matz@novell.com
List-ID: <linux-mm.kvack.org>

On Wednesday 15 September 2010 05:54:31 KOSAKI Motohiro wrote:
> > /proc/$pid/smaps broken: After swapout/swapin private dirty mappings
> > become clean.
> >
> > When a page with private file mapping becomes dirty, the vma will be in
> > both i_mmap tree and anon_vma list. The /proc/$pid/smaps will account
> > these pages as dirty and backed by the file.
> >
> > But when those dirty pages gets swapped out, and when they are read back
> > from swap, they would be marked as clean, as it should be, as they are
> > part of swap cache now.
> >
> > But the /proc/$pid/smaps would report the vma as a mapping of a file and
> > it is clean. The pages are actually in same state i.e., dirty with
> > respect to file still, but which was once reported as dirty is now being
> > reported as clean to user-space.
> >
> > This confuses tools like gdb which uses this information. Those tools
> > think that those pages were never modified and it creates problem when
> > they create dumps.
> >
> > The file mapping of the vma also cannot be broken as pages never read
> > earlier, will still have to come from the file. Just that those dirty
> > pages have become clean anonymous pages.
> >
> > During swaping in, restoring the exact state as dirty file-backed pages
> > before swapout would be useless, as there in no real bug. Breaking the
> > vma with only anonymous pages as seperate vmas unnecessary may not be a
> > good thing as well. So let us just export the information that a
> > file-backed vma has anonymous dirty pages.
> 
> Why can't gdb check Swap: field in smaps? I think Swap!=0 mean we need dump
>  out.
> 

Yes. When the page is swapped out it is accounted in "Swap:".

> Am I missing anything?
> 

But when it gets swapped in back to memory, it is removed from "Swap:" and 
added to "Private_Clean:" instead of "Private_Dirty:".

Thanks
Nikanth

>  - kosaki
> 
> > Export this information in smaps by prepending file-names with "[anon]+",
> > when some of the pages in a file backed vma become anonymous.
> >
> > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> >
> > ---
> >
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 439fc1f..68f9806 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -242,6 +242,8 @@ static void show_map_vma(struct seq_file *m, struct
> > vm_area_struct *vma) */
> >  	if (file) {
> >  		pad_len_spaces(m, len);
> > +		if (vma->anon_vma)
> > +			seq_puts(m, "[anon]+");
> >  		seq_path(m, &file->f_path, "\n");
> >  	} else {
> >  		const char *name = arch_vma_name(vma);
> >
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
