Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F29146B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:12:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H6CL5J017170
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 15:12:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 87F2B45DE5C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:12:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D80545DE54
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:12:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6285F1DB8038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:12:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 153DB1DB8043
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:12:20 +0900 (JST)
Date: Thu, 17 Sep 2009 15:10:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3][mmotm] showing size of kcore v2
Message-Id: <20090917151016.99f7c5ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2375c9f90909162302m1fb89414o4f72b6b36e7cbb06@mail.gmail.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	<1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	<20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	<20090917114404.d87b155d.kamezawa.hiroyu@jp.fujitsu.com>
	<2375c9f90909162302m1fb89414o4f72b6b36e7cbb06@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 14:02:39 +0800
AmA(C)rico Wang <xiyou.wangcong@gmail.com> wrote:
> > @@ -124,6 +126,7 @@ static void __kcore_update_ram(struct li
> > A  A  A  A write_unlock(&kclist_lock);
> >
> > A  A  A  A free_kclist_ents(&garbage);
> > + A  A  A  proc_root_kcore->size = get_kcore_size(&nphdr, &size);
> 
> 
> This makes me to think if we will have some race condition here?
> Two processes can open kcore at the same time...
> 
Finally,
==
static void __kcore_update_ram(struct list_head *list)
{
 write_lock(&kclist_lock);
        if (kcore_need_update) {
                list_for_each_entry_safe(pos, tmp, &kclist_head, list) {
                        if (pos->type == KCORE_RAM
                                || pos->type == KCORE_VMEMMAP)
                                list_move(&pos->list, &garbage);
                }
                list_splice_tail(list, &kclist_head);
        } else
                list_splice(list, &garbage);
        kcore_need_update = 0;
        write_unlock(&kclist_lock);
}

kclist itself is double checked under write_lock.
And, once updated, get_kcore_size()'s return vaule is static.
So, I think there are no race. But..Hmm...is this clearer ?

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, size of /proc/kcore which can be read by 'ls -l' is 0.
But it's not correct value.

This is a patch for showing size of /proc/kcore as following.

On x86-64, ls -l shows
 ... root root 140737486266368 2009-09-17 10:29 /proc/kcore
Then, 7FFFFFFE02000. This comes from vmalloc area's size.
This shows "core" size, not  memory size.

This patch shows the size by updating "size" field in struct proc_dir_entry.
Later, lookup routine will create inode and fill inode->i_size based
on this value. Then, this has a problem.

 - Once inode is cached, inode->i_size will never be updated.

Then, this patch is not memory-hotplug-aware.

To update inode->i_size, we have to know dentry or inode.
But there is no way to lookup them by inside kernel. Hmmm....
Next patch will try it.

Changelog:
 -moved upadting ->size under lock.

Cc: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/kcore.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
===================================================================
--- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
+++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
@@ -107,6 +107,8 @@ static void free_kclist_ents(struct list
  */
 static void __kcore_update_ram(struct list_head *list)
 {
+	int nphdr;
+	size_t size;
 	struct kcore_list *tmp, *pos;
 	LIST_HEAD(garbage);
 
@@ -121,6 +123,7 @@ static void __kcore_update_ram(struct li
 	} else
 		list_splice(list, &garbage);
 	kcore_need_update = 0;
+	proc_root_kcore->size = get_kcore_size(&nphdr, &size);
 	write_unlock(&kclist_lock);
 
 	free_kclist_ents(&garbage);
@@ -429,7 +432,8 @@ read_kcore(struct file *file, char __use
 	unsigned long start;
 
 	read_lock(&kclist_lock);
-	proc_root_kcore->size = size = get_kcore_size(&nphdr, &elf_buflen);
+	size = get_kcore_size(&nphdr, &elf_buflen);
+
 	if (buflen == 0 || *fpos >= size) {
 		read_unlock(&kclist_lock);
 		return 0;







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
