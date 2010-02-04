Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 046326B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 22:01:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1431TsC011092
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Feb 2010 12:01:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3565345DE60
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:01:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 11E6845DE7B
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:01:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BB281DB803A
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:01:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 265011DB8042
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:01:27 +0900 (JST)
Date: Thu, 4 Feb 2010 11:58:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [stable] [PATCH] devmem: check vmalloc address on kmem
 read/write
Message-Id: <20100204115801.cac7c342.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100204024202.GD6343@localhost>
References: <20100122045914.993668874@intel.com>
	<20100203234724.GA23902@kroah.com>
	<20100204024202.GD6343@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "stable@kernel.org" <stable@kernel.org>, juha_motorsportcom@luukku.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010 10:42:02 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> commit 325fda71d0badc1073dc59f12a948f24ff05796a upstream.
> 
> Otherwise vmalloc_to_page() will BUG().
> 
> This also makes the kmem read/write implementation aligned with mem(4):
> "References to nonexistent locations cause errors to be returned." Here
> we return -ENXIO (inspired by Hugh) if no bytes have been transfered
> to/from user space, otherwise return partial read/write results.
> 

Wu-san, I have additonal fix to this patch. Now, *ppos update is unstable..
Could you make merged one ?
Maybe this one makes the all behavior clearer.

==
This is a more fix for devmem-check-vmalloc-address-on-kmem-read-write.patch
Now, the condition for updating *ppos is not good. (it's updated even if EFAULT
occurs..). This fixes that.


Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
CC: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/char/mem.c |   34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

Index: mmotm-2.6.33-Feb01/drivers/char/mem.c
===================================================================
--- mmotm-2.6.33-Feb01.orig/drivers/char/mem.c
+++ mmotm-2.6.33-Feb01/drivers/char/mem.c
@@ -460,14 +460,18 @@ static ssize_t read_kmem(struct file *fi
 		}
 		free_page((unsigned long)kbuf);
 	}
+	/* EFAULT is always critical */
+	if (err == -EFAULT)
+		return err;
+	if (err == -ENXIO && !read)
+		return -ENXIO;
 	*ppos = p;
-	return read ? read : err;
+	return read;
 }
 
 
 static inline ssize_t
-do_write_kmem(unsigned long p, const char __user *buf,
-	      size_t count, loff_t *ppos)
+do_write_kmem(unsigned long p, const char __user *buf, size_t count)
 {
 	ssize_t written, sz;
 	unsigned long copied;
@@ -510,7 +514,6 @@ do_write_kmem(unsigned long p, const cha
 		written += sz;
 	}
 
-	*ppos += written;
 	return written;
 }
 
@@ -521,6 +524,7 @@ do_write_kmem(unsigned long p, const cha
 static ssize_t write_kmem(struct file * file, const char __user * buf, 
 			  size_t count, loff_t *ppos)
 {
+	/* Kernel virtual memory never exceeds unsigned long */
 	unsigned long p = *ppos;
 	ssize_t wrote = 0;
 	ssize_t virtr = 0;
@@ -530,7 +534,7 @@ static ssize_t write_kmem(struct file * 
 	if (p < (unsigned long) high_memory) {
 		unsigned long to_write = min_t(unsigned long, count,
 					       (unsigned long)high_memory - p);
-		wrote = do_write_kmem(p, buf, to_write, ppos);
+		wrote = do_write_kmem(p, buf, to_write);
 		if (wrote != to_write)
 			return wrote;
 		p += wrote;
@@ -540,8 +544,13 @@ static ssize_t write_kmem(struct file * 
 
 	if (count > 0) {
 		kbuf = (char *)__get_free_page(GFP_KERNEL);
-		if (!kbuf)
-			return wrote ? wrote : -ENOMEM;
+		if (!kbuf) {
+			if (wrote) { /* update ppos and return copied bytes */
+				*ppos = p;
+				return wrote;
+			} else
+				return -ENOMEM;
+		}
 		while (count > 0) {
 			unsigned long sz = size_inside_page(p, count);
 			unsigned long n;
@@ -563,9 +572,16 @@ static ssize_t write_kmem(struct file * 
 		}
 		free_page((unsigned long)kbuf);
 	}
-
+	/* EFAULT is always critical. */
+	if (err == -EFAULT)
+		return err;
+	if (err == -ENXIO) {
+		/* We reached the end of vmalloc area..check real bug or not*/
+		if (!(virtr + wrote)) /* nothing written */
+			return -ENXIO;
+	}
 	*ppos = p;
-	return virtr + wrote ? : err;
+	return virtr + wrote;
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
