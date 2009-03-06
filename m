Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E52C6B00DF
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 02:23:22 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so159598tia.8
        for <linux-mm@kvack.org>; Thu, 05 Mar 2009 23:23:19 -0800 (PST)
Date: Fri, 6 Mar 2009 15:23:28 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
Message-ID: <20090306072328.GL22605@hack.private>
References: <49B0CAEC.80801@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49B0CAEC.80801@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 03:04:12PM +0800, Li Zefan wrote:
>I notice there are many places doing copy_from_user() which follows
>kmalloc():
>
>        dst = kmalloc(len, GFP_KERNEL);
>        if (!dst)
>                return -ENOMEM;
>        if (copy_from_user(dst, src, len)) {
>		kfree(dst);
>		return -EFAULT
>	}
>
>kmemdup_from_user() is a wrapper of the above code. With this new
>function, we don't have to write 'len' twice, which can lead to
>typos/mistakes. It also produces smaller code.
>
>A qucik grep shows 250+ places where kmemdup_from_user() *may* be
>used. I'll prepare a patchset to do this conversion.
>
>Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>---
> include/linux/string.h |    1 +
> mm/util.c              |   24 ++++++++++++++++++++++++
> 2 files changed, 25 insertions(+), 0 deletions(-)
>
>diff --git a/include/linux/string.h b/include/linux/string.h
>index 76ec218..397e622 100644
>--- a/include/linux/string.h
>+++ b/include/linux/string.h
>@@ -105,6 +105,7 @@ extern void * memchr(const void *,int,__kernel_size_t);
> extern char *kstrdup(const char *s, gfp_t gfp);
> extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
> extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
>+extern void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp);
> 
> extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
> extern void argv_free(char **argv);
>diff --git a/mm/util.c b/mm/util.c
>index 37eaccd..a608ebb 100644
>--- a/mm/util.c
>+++ b/mm/util.c
>@@ -70,6 +70,30 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
> EXPORT_SYMBOL(kmemdup);
> 
> /**
>+ * kmemdup_from_user - duplicate memory region from user space
>+ *
>+ * @src: source address in user space
>+ * @len: number of bytes to copy
>+ * @gfp: GFP mask to use
>+ */
>+void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp)
>+{
>+	void *p;
>+
>+	p = kmalloc_track_caller(len, gfp);


Well, you use kmalloc_track_caller, instead of kmalloc as you showed
above. :) Why don't you mention this?


>+	if (!p)
>+		return ERR_PTR(-ENOMEM);
>+
>+	if (copy_from_user(p, src, len)) {
>+		kfree(p);
>+		return ERR_PTR(-EFAULT);
>+	}
>+
>+	return p;
>+}
>+EXPORT_SYMBOL(kmemdup_from_user);
>+
>+/**
>  * __krealloc - like krealloc() but don't free @p.
>  * @p: object to reallocate memory for.
>  * @new_size: how many bytes of memory are required.
>-- 
>1.5.4.rc3
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/

-- 
Do what you love, f**k the rest! F**k the regulations!
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
