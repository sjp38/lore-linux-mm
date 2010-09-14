Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE4E6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:13:43 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH] After swapout/swapin private dirty mappings become clean
Date: Tue, 14 Sep 2010 22:42:29 +0530
References: <201009141640.55650.knikanth@suse.de> <alpine.LNX.2.00.1009141330030.28912@zhemvz.fhfr.qr>
In-Reply-To: <alpine.LNX.2.00.1009141330030.28912@zhemvz.fhfr.qr>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201009142242.29245.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 14 September 2010 17:03:59 Richard Guenther wrote:
> On Tue, 14 Sep 2010, Nikanth Karthikesan wrote:
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
> >
> > Export this information in smaps by prepending file-names with "[anon]+",
> > when some of the pages in a file backed vma become anonymous.
> 
> For the sake of not breaking existing tools I'd prefer appending
> " [anon]" instead.
> 

A filename might have it as suffix!

> Though a much simpler thing would be to account
> the clean anon pages as Private_Dirty (with respect to the backing
> file displayed).

Agreed.

> Anonymous vmas in /proc/smaps seem to contain
> Private_Dirty pages as well.  So I still don't understand why this
> isn't just an accounting bug.
> 

anonymous pages can be dirty as well. Even these pages now marked as clean 
would be marked as dirty again, if they are re-dirtied.

Thanks
Nikanth

> Thanks,
> Richard.
> 
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
