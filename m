Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id AFE416B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 19:20:54 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so951557ieb.20
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:20:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id p4si2865855ice.62.2014.06.24.16.20.53
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 16:20:54 -0700 (PDT)
Date: Tue, 24 Jun 2014 16:20:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 3/3] page-cgroup: fix flags definition
Message-Id: <20140624162052.6778a13e3b3f4af251e300e7@linux-foundation.org>
In-Reply-To: <aacc50fb60eeb9cbe14e07235310fb9295b2658b.1403626729.git.vdavydov@parallels.com>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
	<aacc50fb60eeb9cbe14e07235310fb9295b2658b.1403626729.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Jun 2014 20:33:06 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> Since commit a9ce315aaec1f ("mm: memcontrol: rewrite uncharge API"),
> PCG_* flags are used as bit masks, but they are still defined in a enum
> as bit numbers. Fix it.
> 
> ...
>
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,12 +1,10 @@
>  #ifndef __LINUX_PAGE_CGROUP_H
>  #define __LINUX_PAGE_CGROUP_H
>  
> -enum {
> -	/* flags for mem_cgroup */
> -	PCG_USED,	/* This page is charged to a memcg */
> -	PCG_MEM,	/* This page holds a memory charge */
> -	PCG_MEMSW,	/* This page holds a memory+swap charge */
> -};
> +/* flags for mem_cgroup */
> +#define PCG_USED	0x01	/* This page is charged to a memcg */
> +#define PCG_MEM		0x02	/* This page holds a memory charge */
> +#define PCG_MEMSW	0x04	/* This page holds a memory+swap charge */
>  
>  struct pglist_data;
>  
> @@ -44,7 +42,7 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc);
>  
>  static inline int PageCgroupUsed(struct page_cgroup *pc)
>  {
> -	return test_bit(PCG_USED, &pc->flags);
> +	return !!(pc->flags & PCG_USED);
>  }
>  #else /* !CONFIG_MEMCG */
>  struct page_cgroup;

hm, yes, whoops.  I think I'll redo this as a fix against
mm-memcontrol-rewrite-uncharge-api.patch:

--- a/include/linux/page_cgroup.h~page-cgroup-fix-flags-definition
+++ a/include/linux/page_cgroup.h
@@ -3,9 +3,9 @@
 
 enum {
 	/* flags for mem_cgroup */
-	PCG_USED,	/* This page is charged to a memcg */
-	PCG_MEM,	/* This page holds a memory charge */
-	PCG_MEMSW,	/* This page holds a memory+swap charge */
+	PCG_USED = 0x01,	/* This page is charged to a memcg */
+	PCG_MEM = 0x02,		/* This page holds a memory charge */
+	PCG_MEMSW = 0x04,	/* This page holds a memory+swap charge */
 	__NR_PCG_FLAGS,
 };
 
@@ -46,7 +46,7 @@ struct page *lookup_cgroup_page(struct p
 
 static inline int PageCgroupUsed(struct page_cgroup *pc)
 {
-	return test_bit(PCG_USED, &pc->flags);
+	return !!(pc->flags & PCG_USED);
 }
 
 #else /* CONFIG_MEMCG */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
