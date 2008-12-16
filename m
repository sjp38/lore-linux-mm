Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 448B86B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 05:23:25 -0500 (EST)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id mBGAOsga012783
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 02:24:55 -0800
Received: from rv-out-0506.google.com (rvbk40.prod.google.com [10.140.87.40])
	by zps36.corp.google.com with ESMTP id mBGAOr8w026973
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 02:24:53 -0800
Received: by rv-out-0506.google.com with SMTP id k40so2929357rvb.1
        for <linux-mm@kvack.org>; Tue, 16 Dec 2008 02:24:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081216181909.2d500446.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081216181909.2d500446.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 16 Dec 2008 02:24:52 -0800
Message-ID: <6599ad830812160224x7af92b4bl414612f9c353a6b7@mail.gmail.com>
Subject: Re: [PATCH 7/9] cgroup: Support CSS ID
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 16, 2008 at 1:19 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Patch for Per-CSS ID and private hierarchy code.
>
> This patch tries to assign a ID to each css. Attach unique ID to each
> css and provides following functions.
>
>  - css_lookup(subsys, id)
>   returns struct cgroup of id.
>  - css_get_next(subsys, id, rootid, depth, foundid)
>   returns the next cgroup under "root" by scanning bitmap (not by tree-walk)

Basic approach looks great - but there are a lot of typos in comments.

>
> When cgrou_subsys->use_id is set, id field and bitmap for css is maintained.

When cgroup_subsyst.use_id is set, an id is maintained for each css
(via an idr bitmap)

> kernel/cgroup.c just parepare

The cgroups framework only prepares:

>        - css_id of root css for subsys
>        - alloc/free id functions.
> So, each subsys should allocate ID in attach() callback if necessary.
>
> There is several reasons to develop this.
>        - Saving space .... For example, memcg's swap_cgroup is array of
>          pointers to cgroup. But it is not necessary to be very fast.
>          By replacing pointers(8bytes per ent) to ID (2byes per ent), we can
>          reduce much amount of memory usage.
>
>        - Scanning without lock.
>          CSS_ID provides "scan id under this ROOT" function. By this, scanning
>          css under root can be written without locks.
>          ex)
>          do {
>                rcu_read_lock();
>                next = cgroup_get_next(subsys, id, root, &found);
>                /* check sanity of next here */
>                css_tryget();
>                rcu_read_unlock();
>                id = found + 1
>         } while(...)
>
> Characteristics:
>        - Each css has unique ID under subsys.
>        - Lifetime of ID is controlled by subsys.
>        - css ID contains "ID" and "Depth in hierarchy" and stack of hierarchy
>        - Allowed ID is 1-65535, ID 0 is UNUSED ID.
>
> +       /*
> +        * set 1 if subsys uses ID. ID is not available before cgroup_init()

Make this a bool rather than an int?

> +        * (not available in early_init time.
> +        */
> +       int use_id;
>  #define MAX_CGROUP_TYPE_NAMELEN 32
>        const char *name;
>

> + * CSS ID is a ID for all css struct under subsys. Only works when
> + * cgroup_subsys->use_id != 0. It can be used for look up and scanning
> + * Cgroup ID is assined at cgroup allocation (create) and removed

assined -> assigned

> + * when refcnt to ID goes down to 0. Refcnt is inremented when subsys want to
> + * avoid reuse of ID for persistent objects.

Although the CSS ID is RCU-safe, the subsystem may increment its
refcount when it wishes to avoid reuse of that ID for a different CSS
while it holds the reference outside of an RCU section.

> In usual, refcnt to ID will be 0
> + * when cgroup is removed.

In the normal case, the refcount to the ID will be 0 when the cgroup is removed.

> + *
> + * Note: At using ID, max depth of the hierarchy is determined by

When using ID

> + * cgroup_subsys->max_id_depth.
> + */

Is this comment stale? There's no cgroup_subsys.max_id_depth in this patch.

> +
> +/* called at create() */

If the subsystem has specified use_id=true, is there any reason not to
automatically allocate the ID on its behalf?

> -
> +#include <linux/idr.h>

This is already included in cgroup.h

> +        * The cgroup to whiech this ID points. If cgroup is removed,

"to which"

Mention RCU-safety of the cgroup pointer?

> +        */
> +       unsigned short  stack[0]; /* Length of this field is defined by depth */

/* Array of length (depth+1) */

> +int css_is_ancestor(struct cgroup_subsys_state *css,
> +                   struct cgroup_subsys_state *root)
> +{
> +       struct css_id *id = css->id;
> +       struct css_id *ans = root->id;

It might be clearer to name the css pointers "child" and "root" and
the id pointers "child_id" and "root_id".

> +static int __get_and_prepare_newid(struct cgroup_subsys *ss,
> +                               int depth, struct css_id **ret)
> +{
> +       struct css_id *newid;
> +       int myid, error, size;
> +
> +       BUG_ON(!ss->use_id);
> +
> +       size = sizeof(struct css_id) + sizeof(unsigned short) * (depth + 1);
> +       newid = kzalloc(size, GFP_KERNEL);
> +       if (!newid)
> +               return -ENOMEM;
> +       /* get id */
> +       if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
> +               error = -ENOMEM;
> +               goto err_out;
> +       }

Is this safe? If the only place that we allocated ids was in
cgroup_create() then it should be fine since allocation is
synchronized. But if the subsystem can allocate at other times as
well, then theoretically two threads could get past the idr_pre_get()
stage and one of them could exhaust the pre-allocated objects.

> +       spin_lock(&ss->id_lock);
> +       /* Don't use 0 */
> +       error = idr_get_new_above(&ss->idr, newid, 1, &myid);
> +       spin_unlock(&ss->id_lock);
> +
> +       /* Returns error when there are no free spaces for new ID.*/
> +       if (error) {
> +               error = -ENOSPC;
> +               goto err_out;
> +       }
> +
> +       newid->id = myid;
> +       newid->depth = depth;
> +       *ret = newid;
> +       return 0;
> +err_out:
> +       kfree(newid);
> +       return error;
> +
> +}
> +
> +
> +static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
> +{
> +       struct css_id *newid;
> +       struct cgroup_subsys_state *rootcss;
> +       int err = -ENOMEM;
> +
> +       spin_lock_init(&ss->id_lock);
> +       idr_init(&ss->idr);
> +
> +       rootcss = init_css_set.subsys[ss->subsys_id];
> +       err = __get_and_prepare_newid(ss, 0, &newid);
> +       if (err)
> +               return err;
> +
> +       newid->stack[0] = newid->id;
> +       newid->css = rootcss;
> +       rootcss->id = newid;
> +       return 0;
> +}
> +

> + * css_lookup - lookup css by id
> + * @id: the id of cgroup to be looked up
> + *
> + * Returns pointer to css if there is valid css with id, NULL if not.
> + * Should be called under rcu_read_lock()
> + */
> +
> +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
> +{
> +       struct cgroup_subsys_state *css = NULL;
> +       struct css_id *cssid = NULL;
> +
> +       BUG_ON(!ss->use_id);
> +       rcu_read_lock();

Why do we need an additional rcu_read_lock() here? Since we've
required that the caller be under rcu_read_lock()?

> +               if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
> +                       ret = rcu_dereference(tmp->css);
> +                       /* Sanity check and check hierarchy */
> +                       if (ret && !css_is_removed(ret))
> +                               break;

Is there much point checking for css_is_removed here? The caller will
have to check it anyway since we're not synchronized against cgroup
removal.

> +               }
> +               tmpid = tmpid + 1;

Comment here?

Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
