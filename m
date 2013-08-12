Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2C2FF6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 14:15:54 -0400 (EDT)
Date: Mon, 12 Aug 2013 14:15:48 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376331348-jsc6hffx-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAMyfujeC_p-2cJteayPnA82wPRvoL2ekDNB6bd38d76v7Gb+6w@mail.gmail.com>
References: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
 <1376080406-4r7r3uye-mutt-n-horiguchi@ah.jp.nec.com>
 <CAMyfujeC_p-2cJteayPnA82wPRvoL2ekDNB6bd38d76v7Gb+6w@mail.gmail.com>
Subject: Re: [PATCH 1/1] pagemap: fix buffer overflow in add_page_map()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yonghua zheng <younghua.zheng@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Motohiro KOSAKI <kosaki.motohiro@gmail.com>

On Sat, Aug 10, 2013 at 08:49:34AM +0800, yonghua zheng wrote:
> Update the patch according to Naoya's comment, I also run
> ./scripts/checkpatch.pl, and it passed ;D.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

# Sorry if I missed something, but I guess that your MTA might replace tabs
# with spaces. Documentation/email-clients.txt can be helpful to solve it.

> 
> From 96826b0fdf9ec6d6e16c2c595f371dbb841250f7 Mon Sep 17 00:00:00 2001
> From: Yonghua Zheng <younghua.zheng@gmail.com>
> Date: Mon, 5 Aug 2013 12:12:24 +0800
> Subject: [PATCH 1/1] pagemap: fix buffer overflow in add_to_pagemap()
> 
> In struc pagemapread:
> 
> struct pagemapread {
>     int pos, len;
>     pagemap_entry_t *buffer;
>     bool v2;
> };
> 
> pos is number of PM_ENTRY_BYTES in buffer, but len is the size of buffer,
> it is a mistake to compare pos and len in add_to_pagemap() for checking
> buffer is full or not, and this can lead to buffer overflow and random
> kernel panic issue.
> 
> Correct len to be total number of PM_ENTRY_BYTES in buffer.
> 
> Signed-off-by: Yonghua Zheng <younghua.zheng@gmail.com>
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index dbf61f6..cb98853 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1116,8 +1116,8 @@ static ssize_t pagemap_read(struct file *file,
> char __user *buf,
>          goto out_task;
> 
>      pm.v2 = soft_dirty_cleared;
> -    pm.len = PM_ENTRY_BYTES * (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
> -    pm.buffer = kmalloc(pm.len, GFP_TEMPORARY);
> +    pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
> +    pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
>      ret = -ENOMEM;
>      if (!pm.buffer)
>          goto out_task;
> -- 
> 1.7.9.5
> 
> On Sat, Aug 10, 2013 at 4:33 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > On Fri, Aug 09, 2013 at 01:16:41PM +0800, yonghua zheng wrote:
> >> Hi,
> >>
> >> Recently we met quite a lot of random kernel panic issues after enable
> >> CONFIG_PROC_PAGE_MONITOR in kernel, after debuggint sometime we found
> >> this has something to do with following bug in pagemap:
> >>
> >> In struc pagemapread:
> >>
> >> struct pagemapread {
> >>     int pos, len;
> >>     pagemap_entry_t *buffer;
> >>     bool v2;
> >> };
> >>
> >> pos is number of PM_ENTRY_BYTES in buffer, but len is the size of buffer,
> >> it is a mistake to compare pos and len in add_page_map() for checking
> >
> > s/add_page_map/add_to_pagemap/ ?
> >
> >> buffer is full or not, and this can lead to buffer overflow and random
> >> kernel panic issue.
> >>
> >> Correct len to be total number of PM_ENTRY_BYTES in buffer.
> >>
> >> Signed-off-by: Yonghua Zheng <younghua.zheng@gmail.com>
> >
> > You can find coding style violation with scripts/checkpatch.pl.
> > And I think this patch is worth going into -stable trees
> > (maybe since 2.6.34.)
> >
> > The fix itself looks fine to me.
> >
> > Thanks,
> > Naoya Horiguchi
> >
> >> ---
> >>  fs/proc/task_mmu.c |    4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >> index dbf61f6..cb98853 100644
> >> --- a/fs/proc/task_mmu.c
> >> +++ b/fs/proc/task_mmu.c
> >> @@ -1116,8 +1116,8 @@ static ssize_t pagemap_read(struct file *file,
> >> char __user *buf,
> >>          goto out_task;
> >>
> >>      pm.v2 = soft_dirty_cleared;
> >> -    pm.len = PM_ENTRY_BYTES * (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
> >> -    pm.buffer = kmalloc(pm.len, GFP_TEMPORARY);
> >> +    pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
> >> +    pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
> >>      ret = -ENOMEM;
> >>      if (!pm.buffer)
> >>          goto out_task;
> >>
> >> --
> >> 1.7.9.5
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>
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
