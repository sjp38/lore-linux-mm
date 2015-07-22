Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 79F8E9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:21:28 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so63590368pab.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 02:21:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id na2si2394355pdb.130.2015.07.22.02.21.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 02:21:27 -0700 (PDT)
Date: Wed, 22 Jul 2015 12:21:07 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 1/8] memcg: add page_cgroup_ino helper
Message-ID: <20150722092107.GH23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <aa0190b76489260b4d1b65cdfa65221f4e6390f5.1437303956.git.vdavydov@parallels.com>
 <20150721163407.4e198dfcf61eebbbc49731c2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150721163407.4e198dfcf61eebbbc49731c2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 04:34:07PM -0700, Andrew Morton wrote:
> On Sun, 19 Jul 2015 15:31:10 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > This function returns the inode number of the closest online ancestor of
> > the memory cgroup a page is charged to. It is required for exporting
> > information about which page is charged to which cgroup to userspace,
> > which will be introduced by a following patch.
> > 
> > ...
> >
> 
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -441,6 +441,29 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
> >  	return &memcg->css;
> >  }
> >  
> > +/**
> > + * page_cgroup_ino - return inode number of the memcg a page is charged to
> > + * @page: the page
> > + *
> > + * Look up the closest online ancestor of the memory cgroup @page is charged to
> > + * and return its inode number or 0 if @page is not charged to any cgroup. It
> > + * is safe to call this function without holding a reference to @page.
> > + */
> > +unsigned long page_cgroup_ino(struct page *page)
> 
> Shouldn't it return an ino_t?

Yep, thanks.

> 
> > +{
> > +	struct mem_cgroup *memcg;
> > +	unsigned long ino = 0;
> > +
> > +	rcu_read_lock();
> > +	memcg = READ_ONCE(page->mem_cgroup);
> > +	while (memcg && !(memcg->css.flags & CSS_ONLINE))
> > +		memcg = parent_mem_cgroup(memcg);
> > +	if (memcg)
> > +		ino = cgroup_ino(memcg->css.cgroup);
> > +	rcu_read_unlock();
> > +	return ino;
> > +}
> 
> The function is racy, isn't it?  There's nothing to prevent this inode
> from getting torn down and potentially reallocated one nanosecond after
> page_cgroup_ino() returns?  If so, it is only safely usable by things
> which don't care (such as procfs interfaces) and this should be
> documented in some fashion.

Agree. Here goes the incremental patch:
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d644aadfdd0d..ad800e62cb7a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -343,7 +343,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 }
 
 struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
-unsigned long page_cgroup_ino(struct page *page);
+ino_t page_cgroup_ino(struct page *page);
 
 static inline bool mem_cgroup_disabled(void)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b9c76a0906f9..bd30638c2a95 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -448,8 +448,13 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
  * Look up the closest online ancestor of the memory cgroup @page is charged to
  * and return its inode number or 0 if @page is not charged to any cgroup. It
  * is safe to call this function without holding a reference to @page.
+ *
+ * Note, this function is inherently racy, because there is nothing to prevent
+ * the cgroup inode from getting torn down and potentially reallocated a moment
+ * after page_cgroup_ino() returns, so it only should be used by callers that
+ * do not care (such as procfs interfaces).
  */
-unsigned long page_cgroup_ino(struct page *page)
+ino_t page_cgroup_ino(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long ino = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
