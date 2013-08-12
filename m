Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 5D07F6B0036
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 19:05:34 -0400 (EDT)
Date: Mon, 12 Aug 2013 16:05:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] pagemap: fix buffer overflow in add_page_map()
Message-Id: <20130812160532.da47cac556196bf9c4356a83@linux-foundation.org>
In-Reply-To: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
References: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yonghua zheng <younghua.zheng@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Motohiro KOSAKI <kosaki.motohiro@gmail.com>

On Fri, 9 Aug 2013 13:16:41 +0800 yonghua zheng <younghua.zheng@gmail.com> wrote:

> Hi,
> 
> Recently we met quite a lot of random kernel panic issues after enable
> CONFIG_PROC_PAGE_MONITOR in kernel, after debuggint sometime we found
> this has something to do with following bug in pagemap:
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
> it is a mistake to compare pos and len in add_page_map() for checking
> buffer is full or not, and this can lead to buffer overflow and random
> kernel panic issue.
> 
> Correct len to be total number of PM_ENTRY_BYTES in buffer.
> 
> Signed-off-by: Yonghua Zheng <younghua.zheng@gmail.com>
> ---
>  fs/proc/task_mmu.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
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

Yes, that's a bug.  I'd propose this addition to your fix:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: pagemap-fix-buffer-overflow-in-add_page_map-fix

document pagemapread.pos and .len units, fix PM_ENTRY_BYTES definition

Cc: Yonghua Zheng <younghua.zheng@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/task_mmu.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-fix-buffer-overflow-in-add_page_map-fix fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~pagemap-fix-buffer-overflow-in-add_page_map-fix
+++ a/fs/proc/task_mmu.c
@@ -868,7 +868,7 @@ typedef struct {
 } pagemap_entry_t;
 
 struct pagemapread {
-	int pos, len;
+	int pos, len;		/* units: PM_ENTRY_BYTES, not bytes */
 	pagemap_entry_t *buffer;
 	bool v2;
 };
@@ -876,7 +876,7 @@ struct pagemapread {
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
 #define PAGEMAP_WALK_MASK	(PMD_MASK)
 
-#define PM_ENTRY_BYTES      sizeof(u64)
+#define PM_ENTRY_BYTES      sizeof(pagemap_entry_t)
 #define PM_STATUS_BITS      3
 #define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
 #define PM_STATUS_MASK      (((1LL << PM_STATUS_BITS) - 1) << PM_STATUS_OFFSET)
_


btw, your email client wordwraps the patches and replaces tabs with
spaces.  Please fix that up for next time?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
