Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 96BD56B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 20:24:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F0OiJD015995
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Sep 2010 09:24:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2347C45DE4F
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:24:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EDCE445DE4E
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:24:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6B3E1DB803B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:24:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 912C81DB8038
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:24:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] After swapout/swapin private dirty mappings become clean
In-Reply-To: <201009141640.55650.knikanth@suse.de>
References: <201009141640.55650.knikanth@suse.de>
Message-Id: <20100915092239.C9D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Sep 2010 09:24:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, balbir@linux.vnet.ibm.com, rguenther@novell.com, matz@novell.com
List-ID: <linux-mm.kvack.org>

> /proc/$pid/smaps broken: After swapout/swapin private dirty mappings become
> clean.
> 
> When a page with private file mapping becomes dirty, the vma will be in both
> i_mmap tree and anon_vma list. The /proc/$pid/smaps will account these pages
> as dirty and backed by the file.
> 
> But when those dirty pages gets swapped out, and when they are read back from
> swap, they would be marked as clean, as it should be, as they are part of swap
> cache now.
> 
> But the /proc/$pid/smaps would report the vma as a mapping of a file and it is
> clean. The pages are actually in same state i.e., dirty with respect to file
> still, but which was once reported as dirty is now being reported as clean to
> user-space.
> 
> This confuses tools like gdb which uses this information. Those tools think
> that those pages were never modified and it creates problem when they create
> dumps.
> 
> The file mapping of the vma also cannot be broken as pages never read earlier,
> will still have to come from the file. Just that those dirty pages have become
> clean anonymous pages.
> 
> During swaping in, restoring the exact state as dirty file-backed pages before
> swapout would be useless, as there in no real bug. Breaking the vma with only
> anonymous pages as seperate vmas unnecessary may not be a good thing as well.
> So let us just export the information that a file-backed vma has anonymous
> dirty pages.

Why can't gdb check Swap: field in smaps? I think Swap!=0 mean we need dump out.

Am I missing anything?

 - kosaki

> 
> Export this information in smaps by prepending file-names with "[anon]+", when
> some of the pages in a file backed vma become anonymous.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
> ---
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 439fc1f..68f9806 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -242,6 +242,8 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
>  	 */
>  	if (file) {
>  		pad_len_spaces(m, len);
> +		if (vma->anon_vma)
> +			seq_puts(m, "[anon]+");
>  		seq_path(m, &file->f_path, "\n");
>  	} else {
>  		const char *name = arch_vma_name(vma);
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
