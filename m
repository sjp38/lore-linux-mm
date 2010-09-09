Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 139986B0093
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 19:51:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o89Npsso029972
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Sep 2010 08:51:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6921045DE51
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 08:51:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4756E45DE52
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 08:51:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E42AE18002
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 08:51:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 995A2E08006
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 08:51:53 +0900 (JST)
Date: Fri, 10 Sep 2010 08:46:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: change allocation of css ID placement
Message-Id: <20100910084651.61a8b1cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimtV+TAmxh6dQnTNsS8vSb93qux+fJGxvX7FJ3G@mail.gmail.com>
References: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
	<20100901154138.d234bf60.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimtV+TAmxh6dQnTNsS8vSb93qux+fJGxvX7FJ3G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Thank you for review.

On Thu, 9 Sep 2010 09:32:32 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Tue, Aug 31, 2010 at 11:41 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Now, css'id is allocated after ->create() is called. But to make use of ID
> > in ->create(), it should be available before ->create().
> >
> > In another thinking, considering the ID is tightly coupled with "css",
> > it should be allocated when "css" is allocated.
> > This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
> > memory and blkio are using ID. (To support complicated hierarchy walk.)
> >
> > ID will be used in mem cgroup's ->create(), later.
> >
> > This patch adds css ID documentation which is not provided.
> >
> > Note:
> > If someone changes rules of css allocation, ID allocation should be changed.
> >
> > Changelog: 2010/09/01
> > A - modified cgroups.txt
> >
> > Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A Documentation/cgroups/cgroups.txt | A  48 ++++++++++++++++++++++++++++++++++++
> > A block/blk-cgroup.c A  A  A  A  A  A  A  A | A  A 9 ++++++
> > A include/linux/cgroup.h A  A  A  A  A  A | A  16 ++++++------
> > A kernel/cgroup.c A  A  A  A  A  A  A  A  A  | A  50 +++++++++++---------------------------
> > A mm/memcontrol.c A  A  A  A  A  A  A  A  A  | A  A 5 +++
> > A 5 files changed, 86 insertions(+), 42 deletions(-)
> >
> > Index: mmotm-0827/kernel/cgroup.c
> > ===================================================================
> > --- mmotm-0827.orig/kernel/cgroup.c
> > +++ mmotm-0827/kernel/cgroup.c
> > @@ -289,9 +289,6 @@ struct cg_cgroup_link {
> > A static struct css_set init_css_set;
> > A static struct cg_cgroup_link init_css_set_link;
> >
> > -static int cgroup_init_idr(struct cgroup_subsys *ss,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A struct cgroup_subsys_state *css);
> > -
> > A /* css_set_lock protects the list of css_set objects, and the
> > A * chain of tasks off each css_set. A Nests outside task->alloc_lock
> > A * due to cgroup_iter_start() */
> > @@ -770,9 +767,6 @@ static struct backing_dev_info cgroup_ba
> > A  A  A  A .capabilities A  = BDI_CAP_NO_ACCT_AND_WRITEBACK,
> > A };
> >
> > -static int alloc_css_id(struct cgroup_subsys *ss,
> > - A  A  A  A  A  A  A  A  A  A  A  struct cgroup *parent, struct cgroup *child);
> > -
> > A static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
> > A {
> > A  A  A  A struct inode *inode = new_inode(sb);
> > @@ -3258,7 +3252,8 @@ static void init_cgroup_css(struct cgrou
> > A  A  A  A css->cgroup = cgrp;
> > A  A  A  A atomic_set(&css->refcnt, 1);
> > A  A  A  A css->flags = 0;
> > - A  A  A  css->id = NULL;
> > + A  A  A  if (!ss->use_id)
> > + A  A  A  A  A  A  A  css->id = NULL;
> > A  A  A  A if (cgrp == dummytop)
> > A  A  A  A  A  A  A  A set_bit(CSS_ROOT, &css->flags);
> > A  A  A  A BUG_ON(cgrp->subsys[ss->subsys_id]);
> > @@ -3343,12 +3338,6 @@ static long cgroup_create(struct cgroup
> > A  A  A  A  A  A  A  A  A  A  A  A goto err_destroy;
> > A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A init_cgroup_css(css, ss, cgrp);
> > - A  A  A  A  A  A  A  if (ss->use_id) {
> > - A  A  A  A  A  A  A  A  A  A  A  err = alloc_css_id(ss, parent, cgrp);
> > - A  A  A  A  A  A  A  A  A  A  A  if (err)
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto err_destroy;
> > - A  A  A  A  A  A  A  }
> > - A  A  A  A  A  A  A  /* At error, ->destroy() callback has to free assigned ID. */
> > A  A  A  A }
> >
> > A  A  A  A cgroup_lock_hierarchy(root);
> > @@ -3710,17 +3699,6 @@ int __init_or_module cgroup_load_subsys(
> >
> > A  A  A  A /* our new subsystem will be attached to the dummy hierarchy. */
> > A  A  A  A init_cgroup_css(css, ss, dummytop);
> > - A  A  A  /* init_idr must be after init_cgroup_css because it sets css->id. */
> > - A  A  A  if (ss->use_id) {
> > - A  A  A  A  A  A  A  int ret = cgroup_init_idr(ss, css);
> > - A  A  A  A  A  A  A  if (ret) {
> > - A  A  A  A  A  A  A  A  A  A  A  dummytop->subsys[ss->subsys_id] = NULL;
> > - A  A  A  A  A  A  A  A  A  A  A  ss->destroy(ss, dummytop);
> > - A  A  A  A  A  A  A  A  A  A  A  subsys[i] = NULL;
> > - A  A  A  A  A  A  A  A  A  A  A  mutex_unlock(&cgroup_mutex);
> > - A  A  A  A  A  A  A  A  A  A  A  return ret;
> > - A  A  A  A  A  A  A  }
> > - A  A  A  }
> >
> > A  A  A  A /*
> > A  A  A  A  * Now we need to entangle the css into the existing css_sets. unlike
> > @@ -3889,8 +3867,6 @@ int __init cgroup_init(void)
> > A  A  A  A  A  A  A  A struct cgroup_subsys *ss = subsys[i];
> > A  A  A  A  A  A  A  A if (!ss->early_init)
> > A  A  A  A  A  A  A  A  A  A  A  A cgroup_init_subsys(ss);
> > - A  A  A  A  A  A  A  if (ss->use_id)
> > - A  A  A  A  A  A  A  A  A  A  A  cgroup_init_idr(ss, init_css_set.subsys[ss->subsys_id]);
> > A  A  A  A }
> >
> > A  A  A  A /* Add init_css_set to the hash table */
> > @@ -4604,8 +4580,8 @@ err_out:
> >
> > A }
> >
> > -static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct cgroup_subsys_state *rootcss)
> > +static int cgroup_init_idr(struct cgroup_subsys *ss,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  struct cgroup_subsys_state *rootcss)
> > A {
> > A  A  A  A struct css_id *newid;
> >
> > @@ -4617,21 +4593,25 @@ static int __init_or_module cgroup_init_
> > A  A  A  A  A  A  A  A return PTR_ERR(newid);
> >
> > A  A  A  A newid->stack[0] = newid->id;
> > - A  A  A  newid->css = rootcss;
> > - A  A  A  rootcss->id = newid;
> > + A  A  A  rcu_assign_pointer(newid->css, rootcss);
> > + A  A  A  rcu_assign_pointer(rootcss->id, newid);
> > A  A  A  A return 0;
> > A }
> >
> > -static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
> > - A  A  A  A  A  A  A  A  A  A  A  struct cgroup *child)
> > +int alloc_css_id(struct cgroup_subsys *ss,
> > + A  A  A  struct cgroup *cgrp, struct cgroup_subsys_state *css)
> Must also add EXPORT_SYMBOL_GPL(alloc_css_id) to supported CONFIG_BLK_CGROUP=m.

Ah, yes. 

> > A {
> > A  A  A  A int subsys_id, i, depth = 0;
> > - A  A  A  struct cgroup_subsys_state *parent_css, *child_css;
> > + A  A  A  struct cgroup_subsys_state *parent_css;
> > + A  A  A  struct cgroup *parent;
> > A  A  A  A struct css_id *child_id, *parent_id;
> >
> > + A  A  A  if (cgrp == dummytop)
> > + A  A  A  A  A  A  A  return cgroup_init_idr(ss, css);
> > +
> > + A  A  A  parent = cgrp->parent;
> > A  A  A  A subsys_id = ss->subsys_id;
> > A  A  A  A parent_css = parent->subsys[subsys_id];
> > - A  A  A  child_css = child->subsys[subsys_id];
> > A  A  A  A parent_id = parent_css->id;
> > A  A  A  A depth = parent_id->depth + 1;
> >
> > @@ -4646,7 +4626,7 @@ static int alloc_css_id(struct cgroup_su
> > A  A  A  A  * child_id->css pointer will be set after this cgroup is available
> > A  A  A  A  * see cgroup_populate_dir()
> > A  A  A  A  */
> > - A  A  A  rcu_assign_pointer(child_css->id, child_id);
> > + A  A  A  rcu_assign_pointer(css->id, child_id);
> >
> > A  A  A  A return 0;
> > A }
> > Index: mmotm-0827/include/linux/cgroup.h
> > ===================================================================
> > --- mmotm-0827.orig/include/linux/cgroup.h
> > +++ mmotm-0827/include/linux/cgroup.h
> > @@ -588,9 +588,11 @@ static inline int cgroup_attach_task_cur
> > A /*
> > A * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
> > A * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
> > - * CSS ID is assigned at cgroup allocation (create) automatically
> > - * and removed when subsys calls free_css_id() function. This is because
> > - * the lifetime of cgroup_subsys_state is subsys's matter.
> > + * CSS ID must be assigned by subsys itself at cgroup creation and deleted
> > + * when subsys calls free_css_id() function. This is because the life time of
> To be consistent with document: s/life time/lifetime/
> > + * of cgroup_subsys_state is subsys's matter.
> > + *
> > + * ID->css look up is available after cgroup's directory is populated.
> > A *
> > A * Looking up and scanning function should be called under rcu_read_lock().
> > A * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for following calls.
> > @@ -598,10 +600,10 @@ static inline int cgroup_attach_task_cur
> > A * destroyed". The caller should check css and cgroup's status.
> > A */
> >
> > -/*
> > - * Typically Called at ->destroy(), or somewhere the subsys frees
> > - * cgroup_subsys_state.
> > - */
> > +/* Should be called in ->create() by subsys itself */
> > +int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *newgr,
> > + A  A  A  A  A  A  A  struct cgroup_subsys_state *css);
> > +/* Typically Called at ->destroy(), or somewhere the subsys frees css */
> s/Called/called/

will fix.


> > A void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
> >
> > A /* Find a cgroup_subsys_state which has given ID */
> > Index: mmotm-0827/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0827.orig/mm/memcontrol.c
> > +++ mmotm-0827/mm/memcontrol.c
> > @@ -4141,6 +4141,11 @@ mem_cgroup_create(struct cgroup_subsys *
> > A  A  A  A  A  A  A  A if (alloc_mem_cgroup_per_zone_info(mem, node))
> > A  A  A  A  A  A  A  A  A  A  A  A goto free_out;
> >
> > + A  A  A  error = alloc_css_id(ss, cont, &mem->css);
> > + A  A  A  if (error)
> > + A  A  A  A  A  A  A  goto free_out;
> > + A  A  A  /* Here, css_id(&mem->css) works. but css_lookup(id)->mem doesn't */
> > +
> > A  A  A  A /* root ? */
> > A  A  A  A if (cont->parent == NULL) {
> > A  A  A  A  A  A  A  A int cpu;
> > Index: mmotm-0827/block/blk-cgroup.c
> > ===================================================================
> > --- mmotm-0827.orig/block/blk-cgroup.c
> > +++ mmotm-0827/block/blk-cgroup.c
> > @@ -958,9 +958,13 @@ blkiocg_create(struct cgroup_subsys *sub
> > A {
> > A  A  A  A struct blkio_cgroup *blkcg;
> > A  A  A  A struct cgroup *parent = cgroup->parent;
> > + A  A  A  int ret;
> >
> > A  A  A  A if (!parent) {
> > A  A  A  A  A  A  A  A blkcg = &blkio_root_cgroup;
> > + A  A  A  A  A  A  A  ret = alloc_css_id(subsys, cgroup, &blkcg->css);
> > + A  A  A  A  A  A  A  if (ret)
> > + A  A  A  A  A  A  A  A  A  A  A  return ERR_PTR(ret);
> > A  A  A  A  A  A  A  A goto done;
> > A  A  A  A }
> >
> > @@ -971,6 +975,11 @@ blkiocg_create(struct cgroup_subsys *sub
> > A  A  A  A blkcg = kzalloc(sizeof(*blkcg), GFP_KERNEL);
> > A  A  A  A if (!blkcg)
> > A  A  A  A  A  A  A  A return ERR_PTR(-ENOMEM);
> > + A  A  A  ret = alloc_css_id(subsys, cgroup, &blkcg->css);
> > + A  A  A  if (ret) {
> > + A  A  A  A  A  A  A  kfree(blkcg);
> > + A  A  A  A  A  A  A  return ERR_PTR(ret);
> > + A  A  A  }
> >
> > A  A  A  A blkcg->weight = BLKIO_WEIGHT_DEFAULT;
> > A done:
> > Index: mmotm-0827/Documentation/cgroups/cgroups.txt
> > ===================================================================
> > --- mmotm-0827.orig/Documentation/cgroups/cgroups.txt
> > +++ mmotm-0827/Documentation/cgroups/cgroups.txt
> > @@ -621,6 +621,54 @@ and root cgroup. Currently this will onl
> > A the default hierarchy (which never has sub-cgroups) and a hierarchy
> > A that is being created/destroyed (and hence has no sub-cgroups).
> >
> > +3.4 cgroup subsys state IDs.
> > +------------
> > +When subsystem sets use_id == true, an ID per [cgroup, subsys] is added
> > +and it will be tied to cgroup_subsys_state object.
> > +
> > +When use_id==true can use following interfaces. But please note that
> > +allocation/free an ID is subsystem's job because cgroup_subsys_state
> > +object's lifetime is subsystem's matter.
> > +
> > +unsigned short css_id(struct cgroup_subsys_state *css)
> > +
> > +Returns ID of cgroup_subsys_state
> Please add trailing '.' (period character).
> 

will fix.

> > +
> > +unsigend short css_depth(struct cgroup_subsys_state *css)
> Typo: s/unsigend/unsigned/
> > +
> > +Returns the level which "css" is exisiting under hierarchy tree.
> > +The root cgroup's depth 0, its children are 1, children's children are
> > +2....
> > +
> > +int alloc_css_id(struct struct cgroup_subsys *ss, struct cgroup *newgr,
> > + A  A  A  A  A  A  A  A struct cgroup_subsys_state *css);
> > +
> > +Attach an new ID to given css under subsystem ([ss, cgroup])
> > +should be called in ->create() callback.
> > +
> > +void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
> > +
> > +Free ID attached to "css" under subsystem. Should be called before
> > +"css" is freed.
> > +
> > +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
> > +
> > +Look up cgroup_subsys_state via ID. Should be called under rcu_read_lock().
> > +
> > +struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int id,
> > + A  A  A  A  A  A  A  A struct cgroup_subsys_state *root, int *foundid);
> > +
> > +Returns ID which is under "root" i.e. under sub-directory of "root"
> > +cgroup's directory at considering cgroup hierarchy. The order of IDs
> > +returned by this function is not sorted. Please be careful.
> > +
> > +bool css_is_ancestor(struct cgroup_subsys_state *cg,
> > + A  A  A  A  A  A  A  A  A  A  const struct cgroup_subsys_state *root);
> 
> To match code: s/cg/child/
> 
will fix.

> > +
> > +Returns true if "root" and "cs" is under the same hierarchy and
> > +"root" can be found when you see all ->parent from "cs" until
> This may be more clear: s/see all/walk all/
> 
> > +the root cgroup.
> As above: s/cs/child/
> 

will fix.

I'll reorder patches and post file-stat ones 1st.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
