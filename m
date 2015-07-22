Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 658559003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:45:19 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so65255690pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 02:45:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id p3si2519323pds.160.2015.07.22.02.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 02:45:18 -0700 (PDT)
Date: Wed, 22 Jul 2015 12:45:04 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 2/8] hwpoison: use page_cgroup_ino for filtering
 by memcg
Message-ID: <20150722094504.GI23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <94215634d13582d2a1453686d6cc6b1a59b07d2a.1437303956.git.vdavydov@parallels.com>
 <20150721163412.1b44e77f5ac3b742734d1ce6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150721163412.1b44e77f5ac3b742734d1ce6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 04:34:12PM -0700, Andrew Morton wrote:
> On Sun, 19 Jul 2015 15:31:11 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Hwpoison allows to filter pages by memory cgroup ino. Currently, it
> > calls try_get_mem_cgroup_from_page to obtain the cgroup from a page and
> > then its ino using cgroup_ino, but now we have an apter method for that,
> > page_cgroup_ino, so use it instead.
> 
> I assume "an apter" was supposed to be "a helper"?

Yes, sounds better :-)

> 
> > --- a/mm/hwpoison-inject.c
> > +++ b/mm/hwpoison-inject.c
> > @@ -45,12 +45,9 @@ static int hwpoison_inject(void *data, u64 val)
> >  	/*
> >  	 * do a racy check with elevated page count, to make sure PG_hwpoison
> >  	 * will only be set for the targeted owner (or on a free page).
> > -	 * We temporarily take page lock for try_get_mem_cgroup_from_page().
> >  	 * memory_failure() will redo the check reliably inside page lock.
> >  	 */
> > -	lock_page(hpage);
> >  	err = hwpoison_filter(hpage);
> > -	unlock_page(hpage);
> >  	if (err)
> >  		goto put_out;
> >  
> > @@ -126,7 +123,7 @@ static int pfn_inject_init(void)
> >  	if (!dentry)
> >  		goto fail;
> >  
> > -#ifdef CONFIG_MEMCG_SWAP
> > +#ifdef CONFIG_MEMCG
> >  	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
> >  				    hwpoison_dir, &hwpoison_filter_memcg);
> >  	if (!dentry)
> 
> Confused.  We're changing the conditions under which this debugfs file
> is created.  Is this a typo or some unchangelogged thing or what?

This is an unchangelogged cleanup. In fact, there had been a comment
regarding it before v6, but then it got lost. Sorry about that. The
commit message should look like this:

"""
Hwpoison allows to filter pages by memory cgroup ino. Currently, it
calls try_get_mem_cgroup_from_page to obtain the cgroup from a page and
then its ino using cgroup_ino, but now we have a helper method for that,
page_cgroup_ino, so use it instead.

This patch also loosens the hwpoison memcg filter dependency rules - it
makes it depend on CONFIG_MEMCG instead of CONFIG_MEMCG_SWAP, because
hwpoison memcg filter does not require anything (nor it used to) from
CONFIG_MEMCG_SWAP side.
"""

Or we can simply revert this cleanups if you don't like it:
---
diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 5015679014c1..1cd105ee5a7b 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -123,7 +123,7 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
-#ifdef CONFIG_MEMCG
+#ifdef CONFIG_MEMCG_SWAP
 	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
 				    hwpoison_dir, &hwpoison_filter_memcg);
 	if (!dentry)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 97005396a507..5ea7d8c760fa 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -130,7 +130,7 @@ static int hwpoison_filter_flags(struct page *p)
  * can only guarantee that the page either belongs to the memcg tasks, or is
  * a freed page.
  */
-#ifdef CONFIG_MEMCG
+#ifdef CONFIG_MEMCG_SWAP
 u64 hwpoison_filter_memcg;
 EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
 static int hwpoison_filter_task(struct page *p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
