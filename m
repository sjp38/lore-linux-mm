Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 052C46B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 05:38:40 -0500 (EST)
Date: Mon, 1 Mar 2010 11:38:36 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100301103836.GC2087@linux>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
 <1267224751-6382-2-git-send-email-arighi@develer.com>
 <cc557aab1003010058i3a824f98l4cec173fac05911f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc557aab1003010058i3a824f98l4cec173fac05911f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 10:58:35AM +0200, Kirill A. Shutemov wrote:
[snip]
> > +static u64 mem_cgroup_dirty_ratio_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       return get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_ratio_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       if ((cgrp->parent == NULL) || (val > 100))
> > +               return -EINVAL;
> > +
> > +       spin_lock(&memcg->reclaim_param_lock);
> > +       memcg->dirty_ratio = val;
> > +       memcg->dirty_bytes = 0;
> > +       spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +       return 0;
> > +}
> > +
> > +static u64 mem_cgroup_dirty_bytes_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       if (cgrp->parent == NULL)
> > +               return -EINVAL;
> > +
> > +       spin_lock(&memcg->reclaim_param_lock);
> > +       memcg->dirty_ratio = 0;
> > +       memcg->dirty_bytes = val;
> > +       spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +       return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_ratio_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_ratio_write(struct cgroup *cgrp,
> > +                               struct cftype *cft, u64 val)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       if ((cgrp->parent == NULL) || (val > 100))
> > +               return -EINVAL;
> > +
> > +       spin_lock(&memcg->reclaim_param_lock);
> > +       memcg->dirty_background_ratio = val;
> > +       memcg->dirty_background_bytes = 0;
> > +       spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +       return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_bytes_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_bytes_write(struct cgroup *cgrp,
> > +                               struct cftype *cft, u64 val)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +       if (cgrp->parent == NULL)
> > +               return -EINVAL;
> > +
> > +       spin_lock(&memcg->reclaim_param_lock);
> > +       memcg->dirty_background_ratio = 0;
> > +       memcg->dirty_background_bytes = val;
> > +       spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +       return 0;
> > +}
> > +
> >  static struct cftype mem_cgroup_files[] = {
> >        {
> >                .name = "usage_in_bytes",
> > @@ -3518,6 +3785,26 @@ static struct cftype mem_cgroup_files[] = {
> >                .write_u64 = mem_cgroup_swappiness_write,
> >        },
> >        {
> > +               .name = "dirty_ratio",
> > +               .read_u64 = mem_cgroup_dirty_ratio_read,
> > +               .write_u64 = mem_cgroup_dirty_ratio_write,
> > +       },
> > +       {
> > +               .name = "dirty_bytes",
> > +               .read_u64 = mem_cgroup_dirty_bytes_read,
> > +               .write_u64 = mem_cgroup_dirty_bytes_write,
> > +       },
> > +       {
> > +               .name = "dirty_background_ratio",
> > +               .read_u64 = mem_cgroup_dirty_background_ratio_read,
> > +               .write_u64 = mem_cgroup_dirty_background_ratio_write,
> > +       },
> > +       {
> > +               .name = "dirty_background_bytes",
> > +               .read_u64 = mem_cgroup_dirty_background_bytes_read,
> > +               .write_u64 = mem_cgroup_dirty_background_bytes_write,
> > +       },
> > +       {
> 
> mem_cgroup_dirty_background_* functions are too similar to
> mem_cgroup_dirty_bytes_*. I think they should be combined
> like mem_cgroup_read() and mem_cgroup_write(). It will be
> cleaner.

Agreed.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
