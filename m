Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE0866B00E5
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 03:03:35 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2683XF1029429
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Mar 2009 17:03:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA2C245DE4F
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 17:03:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E73045DE55
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 17:03:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8A97E0800D
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 17:03:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C550E08002
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 17:03:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
In-Reply-To: <20090306163600.3469.A69D9226@jp.fujitsu.com>
References: <20090306072328.GL22605@hack.private> <20090306163600.3469.A69D9226@jp.fujitsu.com>
Message-Id: <20090306164445.7BE4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Mar 2009 17:03:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Davi Arnaut <davi.arnaut@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Americo Wang <xiyou.wangcong@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(cc to Davi Arnaut)

> > > /**
> > >+ * kmemdup_from_user - duplicate memory region from user space
> > >+ *
> > >+ * @src: source address in user space
> > >+ * @len: number of bytes to copy
> > >+ * @gfp: GFP mask to use
> > >+ */
> > >+void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp)
> > >+{
> > >+	void *p;
> > >+
> > >+	p = kmalloc_track_caller(len, gfp);
> > 
> > 
> > Well, you use kmalloc_track_caller, instead of kmalloc as you showed
> > above. :) Why don't you mention this?
> 
> kmalloc() wrapper function must use kmalloc_track_caller().

I find another kmalloc() usage in the same file.
Davi, Can you agree following patch?


==
Subject: [PATCH] Don't use kmalloc() in strndup_user(). instead, use kmalloc_track_caller().

kmalloc() wrapper function should use kmalloc_track_caller() instead
kmalloc().

slab.h talk about the reason. 

/*
 * kmalloc_track_caller is a special version of kmalloc that records the
 * calling function of the routine calling it for slab leak tracking instead
 * of just the calling function (confusing, eh?).
 * It's useful when the call to kmalloc comes from a widely-used standard
 * allocator where we care about the real place the memory allocation
 * request comes from.
 */


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/util.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 37eaccd..202da19 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -167,7 +167,7 @@ char *strndup_user(const char __user *s, long n)
 	if (length > n)
 		return ERR_PTR(-EINVAL);
 
-	p = kmalloc(length, GFP_KERNEL);
+	p = kmalloc_track_caller(length, GFP_KERNEL);
 
 	if (!p)
 		return ERR_PTR(-ENOMEM);
-- 
1.6.1.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
