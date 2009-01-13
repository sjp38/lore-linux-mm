Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 93E716B005C
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 04:24:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0D9O4Tn027429
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jan 2009 18:24:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B6045DE51
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:24:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A1F045DD79
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:24:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A551DB803A
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:24:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A98301DB8038
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:24:00 +0900 (JST)
Date: Tue, 13 Jan 2009 18:22:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] cgroup: support per cgroup subsys state ID
 (CSS ID)
Message-Id: <20090113182258.1af14519.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496C456D.2090909@cn.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
	<496C456D.2090909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2009 15:40:29 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Patch for Per-CSS(Cgroup Subsys State) ID and private hierarchy code.
> > 
> 
> Except the one in cgroup_create(), I don't find any other bugs.
> 
Thank you!!

> Some minor comments below. :)
> 
<snip>

> > + * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
> > + * if cgroup_subsys.use_id == true. It can be used for looking up and scanning.
> > + * CSS ID is assigned at cgroup allocation (create) automatically
> > + * and removed when subsys calls free_css_id() function. This is because
> > + * the lifetime of cgroup_subsys_state is  subsys's matter.
> 
>                                    2 spaces ^^
> 

will fix.

> > + *
> > + * Looking up and scanning function should be called under rcu_read_lock().
> > + * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for all calls.
> > + */
> > +
> > +/* Typically Called at ->destroy(), or somewhere the subsys frees
> > +  cgroup_subsys_state. */
> 
> use
> /*
>  * xxx
>  */
> for consistentcy.
> 

ok.


> > +void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
> > +
> > +/* Find a cgroup_subsys_state which has given ID */
> > +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
> 
> add a blank line here
> 
ok

> > +/*
> > + * Get a cgroup whose id is greater than or equal to id under tree of root.
> 
> s/a cgroup/a css/
> 
sure,


> > + * Returning a cgroup_subsys_state or NULL.
> > + */
> > +struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int id,
> > +		struct cgroup_subsys_state *root, int *foundid);
> > +
> > +/* Returns true if root is ancestor of cg */
> > +bool css_is_ancestor(struct cgroup_subsys_state *cg,
> > +		     struct cgroup_subsys_state *root);
> > +
> > +/* Get id and depth of css */
> > +unsigned short css_id(struct cgroup_subsys_state *css);
> > +unsigned short css_depth(struct cgroup_subsys_state *css);
> > +
> >  #else /* !CONFIG_CGROUPS */
> >  
> >  static inline int cgroup_init_early(void) { return 0; }
> > Index: mmotm-2.6.28-Jan7/kernel/cgroup.c
> > ===================================================================
> > --- mmotm-2.6.28-Jan7.orig/kernel/cgroup.c
> > +++ mmotm-2.6.28-Jan7/kernel/cgroup.c
> > @@ -46,7 +46,6 @@
> >  #include <linux/cgroupstats.h>
> >  #include <linux/hash.h>
> >  #include <linux/namei.h>
> > -
> 
> it's common to add a blank line between <linux/*> and <asm/*>
> 
ok,



> >  #include <asm/atomic.h>
> >  
> >  static DEFINE_MUTEX(cgroup_mutex);
> > @@ -185,6 +184,8 @@ struct cg_cgroup_link {
> >  static struct css_set init_css_set;
> >  static struct cg_cgroup_link init_css_set_link;
> >  
> > +static int cgroup_subsys_init_idr(struct cgroup_subsys *ss);
> > +
> >  /* css_set_lock protects the list of css_set objects, and the
> >   * chain of tasks off each css_set.  Nests outside task->alloc_lock
> >   * due to cgroup_iter_start() */
> > @@ -567,6 +568,9 @@ static struct backing_dev_info cgroup_ba
> >  	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
> >  };
> >  
> > +static int alloc_css_id(struct cgroup_subsys *ss,
> > +			struct cgroup *parent, struct cgroup *child);
> > +
> >  static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
> >  {
> >  	struct inode *inode = new_inode(sb);
> > @@ -2335,6 +2339,7 @@ static void init_cgroup_css(struct cgrou
> >  	css->cgroup = cgrp;
> >  	atomic_set(&css->refcnt, 1);
> >  	css->flags = 0;
> > +	css->id = NULL;
> >  	if (cgrp == dummytop)
> >  		set_bit(CSS_ROOT, &css->flags);
> >  	BUG_ON(cgrp->subsys[ss->subsys_id]);
> > @@ -2410,6 +2415,10 @@ static long cgroup_create(struct cgroup 
> >  			goto err_destroy;
> >  		}
> >  		init_cgroup_css(css, ss, cgrp);
> > +		if (ss->use_id)
> > +			if (alloc_css_id(ss, parent, cgrp))
> > +				goto err_destroy;
> > +		/* At error, ->destroy() callback has to free assigned ID. */
> >  	}
> >  
> >  	cgroup_lock_hierarchy(root);
> > @@ -2699,6 +2708,8 @@ int __init cgroup_init(void)
> >  		struct cgroup_subsys *ss = subsys[i];
> >  		if (!ss->early_init)
> >  			cgroup_init_subsys(ss);
> > +		if (ss->use_id)
> > +			cgroup_subsys_init_idr(ss);
> >  	}
> >  
> >  	/* Add init_css_set to the hash table */
> > @@ -3231,3 +3242,260 @@ static int __init cgroup_disable(char *s
> >  	return 1;
> >  }
> >  __setup("cgroup_disable=", cgroup_disable);
> > +
> > +/*
> > + * CSS ID -- ID per Subsys's Cgroup Subsys State.
> > + */
> > +struct css_id {
> > +	/*
> > +	 * The cgroup to which this ID points. If cgroup is removed, this will
> 
> s/The cgroup/css/ ?
> 
Ah, yes.


> > +	 * be NULL. This pointer is expected to be RCU-safe because destroy()
> > +	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
> > +	 * css_tryget() should be used for avoiding race.
> > +	 */
> > +	struct cgroup_subsys_state *css;
> > +	/*
> > +	 * ID of this css.
> > +	 */
> > +	unsigned short  id;
> 
>                       ^^
> 
> > +	/*
> > +	 * Depth in hierarchy which this ID belongs to.
> > +	 */
> > +	unsigned short depth;
> > +	/*
> > +	 * ID is freed by RCU. (and lookup routine is RCU safe.)
> > +	 */
> > +	struct rcu_head rcu_head;
> > +	/*
> > +	 * Hierarchy of CSS ID belongs to.
> > +	 */
> > +	unsigned short  stack[0]; /* Array of Length (depth+1) */
> 
>                       ^^
> 

ok, I'll check double space for all my patches ...


> > +};
> > +#define CSS_ID_MAX	(65535)
> > +
> > +/*
> > + * To get ID other than 0, this should be called when !cgroup_is_removed().
> > + */
> > +unsigned short css_id(struct cgroup_subsys_state *css)
> > +{
> > +	struct css_id *cssid = rcu_dereference(css->id);
> > +
> > +	if (cssid)
> > +		return cssid->id;
> > +	return 0;
> > +}
> > +
> > +unsigned short css_depth(struct cgroup_subsys_state *css)
> > +{
> > +	struct css_id *cssid = rcu_dereference(css->id);
> > +
> > +	if (cssid)
> > +		return cssid->depth;
> > +	return 0;
> > +}
> > +
> > +bool css_is_ancestor(struct cgroup_subsys_state *child,
> > +		    struct cgroup_subsys_state *root)
> > +{
> > +	struct css_id *child_id = rcu_dereference(child->id);
> > +	struct css_id *root_id = rcu_dereference(root->id);
> > +
> > +	if (!child_id || !root_id || (child_id->depth < root_id->depth))
> > +		return false;
> > +	return child_id->stack[root_id->depth] == root_id->id;
> > +}
> > +
> > +static void __free_css_id_cb(struct rcu_head *head)
> > +{
> > +	struct css_id *id;
> > +
> > +	id = container_of(head, struct css_id, rcu_head);
> > +	kfree(id);
> > +}
> > +
> > +void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
> > +{
> > +	struct css_id *id = css->id;
> > +
> > +	BUG_ON(!ss->use_id);
> > +
> > +	rcu_assign_pointer(id->css, NULL);
> > +	rcu_assign_pointer(css->id, NULL);
> > +	spin_lock(&ss->id_lock);
> > +	idr_remove(&ss->idr, id->id);
> > +	spin_unlock(&ss->id_lock);
> > +	call_rcu(&id->rcu_head, __free_css_id_cb);
> > +}
> > +
> > +/*
> > + * This is called by init or create(). Then, calls to this function are
> > + * always serialized (By cgroup_mutex() at create()).
> > + */
> > +
> > +static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
> > +{
> > +	struct css_id *newid;
> > +	int myid, error, size;
> > +
> > +	BUG_ON(!ss->use_id);
> > +
> > +	size = sizeof(*newid) + sizeof(unsigned short) * (depth + 1);
> > +	newid = kzalloc(size, GFP_KERNEL);
> > +	if (!newid)
> > +		return ERR_PTR(-ENOMEM);
> > +	/* get id */
> > +	if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
> > +		error = -ENOMEM;
> > +		goto err_out;
> > +	}
> > +	spin_lock(&ss->id_lock);
> > +	/* Don't use 0. allocates an ID of 1-65535 */
> > +	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
> > +	spin_unlock(&ss->id_lock);
> > +
> > +	/* Returns error when there are no free spaces for new ID.*/
> > +	if (error) {
> > +		error = -ENOSPC;
> > +		goto err_out;
> > +	}
> > +	if (myid > CSS_ID_MAX) {
> > +		error = -ENOSPC;
> > +		spin_lock(&ss->id_lock);
> > +		idr_remove(&ss->idr, myid);
> > +		spin_unlock(&ss->id_lock);
> > +		goto err_out;
> 
> I'd rather "goto remove_idr", this seperates normal routine and error routine.
> 

ok.

> > +	}
> > +
> > +	newid->id = myid;
> > +	newid->depth = depth;
> > +	return newid;
> > +err_out:
> > +	kfree(newid);
> > +	return ERR_PTR(error);
> > +
> > +}
> > +
> > +
> 
> 2 blanks lines here.
> 
> > +static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
> > +{
> > +	struct css_id *newid;
> > +	struct cgroup_subsys_state *rootcss;
> > +
> > +	spin_lock_init(&ss->id_lock);
> > +	idr_init(&ss->idr);
> > +
> > +	rootcss = init_css_set.subsys[ss->subsys_id];
> > +	newid = get_new_cssid(ss, 0);
> > +	if (IS_ERR(newid))
> > +		return PTR_ERR(newid);
> > +
> > +	newid->stack[0] = newid->id;
> > +	newid->css = rootcss;
> > +	rootcss->id = newid;
> > +	return 0;
> > +}
> > +
> > +static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
> > +			struct cgroup *child)
> > +{
> > +	int subsys_id, i, depth = 0;
> > +	struct cgroup_subsys_state *parent_css, *child_css;
> > +	struct css_id *child_id, *parent_id = NULL;
> > +
> > +	subsys_id = ss->subsys_id;
> > +	parent_css = parent->subsys[subsys_id];
> > +	child_css = child->subsys[subsys_id];
> > +	depth = css_depth(parent_css) + 1;
> > +	parent_id = parent_css->id;
> > +
> > +	child_id = get_new_cssid(ss, depth);
> > +	if (IS_ERR(child_id))
> > +		return PTR_ERR(child_id);
> > +
> > +	for (i = 0; i < depth; i++)
> > +		child_id->stack[i] = parent_id->stack[i];
> > +	child_id->stack[depth] = child_id->id;
> > +
> > +	rcu_assign_pointer(child_id->css, child_css);
> > +	rcu_assign_pointer(child_css->id, child_id);
> > +
> > +	return 0;
> > +}
> > +
> > +/**
> > + * css_lookup - lookup css by id
> > + * @ss: cgroup subsys to be looked into.
> > + * @id: the id
> > + *
> > + * Returns pointer to cgroup_subsys_state if there is valid one with id.
> > + * NULL if not.Should be called under rcu_read_lock()
> 
> s/not./not. /
> 
yes..


> > + */
> > +
> 
> remove this line ?
> 

ok.

Thank you very much.

-Kame

> > +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
> > +{
> > +	struct css_id *cssid = NULL;
> > +
> > +	BUG_ON(!ss->use_id);
> > +	cssid = idr_find(&ss->idr, id);
> > +
> > +	if (unlikely(!cssid))
> > +		return NULL;
> > +
> > +	return rcu_dereference(cssid->css);
> > +}
> > +
> > +/**
> > + * css_get_next - lookup next cgroup under specified hierarchy.
> > + * @ss: pointer to subsystem
> > + * @id: current position of iteration.
> > + * @root: pointer to css. search tree under this.
> > + * @foundid: position of found object.
> > + *
> > + * Search next css under the specified hierarchy of rootid. Calling under
> > + * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
> > + */
> > +struct cgroup_subsys_state *
> > +css_get_next(struct cgroup_subsys *ss, int id,
> > +	     struct cgroup_subsys_state *root, int *foundid)
> > +{
> > +	struct cgroup_subsys_state *ret = NULL;
> > +	struct css_id *tmp;
> > +	int tmpid;
> > +	int rootid = css_id(root);
> > +	int depth = css_depth(root);
> > +
> > +	if (!rootid)
> > +		return NULL;
> > +
> > +	BUG_ON(!ss->use_id);
> > +	rcu_read_lock();
> > +	/* fill start point for scan */
> > +	tmpid = id;
> > +	while (1) {
> > +		/*
> > +		 * scan next entry from bitmap(tree), tmpid is updated after
> > +		 * idr_get_next().
> > +		 */
> > +		spin_lock(&ss->id_lock);
> > +		tmp = idr_get_next(&ss->idr, &tmpid);
> > +		spin_unlock(&ss->id_lock);
> > +
> > +		if (!tmp) {
> > +			ret = NULL;
> 
> "ret = NULL" is unnecessary.
> 
will check again.


> > +			break;
> > +		}
> > +		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
> > +			ret = rcu_dereference(tmp->css);
> > +			if (ret) {
> > +				*foundid = tmpid;
> > +				break;
> > +			}
> > +		}
> > +		/* continue to scan from next id */
> > +		tmpid = tmpid + 1;
> > +	}
> > +
> > +	rcu_read_unlock();
> > +	return ret;
> > +}
> > +
> > Index: mmotm-2.6.28-Jan7/include/linux/idr.h
> > ===================================================================
> > --- mmotm-2.6.28-Jan7.orig/include/linux/idr.h
> > +++ mmotm-2.6.28-Jan7/include/linux/idr.h
> > @@ -106,6 +106,7 @@ int idr_get_new(struct idr *idp, void *p
> >  int idr_get_new_above(struct idr *idp, void *ptr, int starting_id, int *id);
> >  int idr_for_each(struct idr *idp,
> >  		 int (*fn)(int id, void *p, void *data), void *data);
> > +void *idr_get_next(struct idr *idp, int *nextid);
> >  void *idr_replace(struct idr *idp, void *ptr, int id);
> >  void idr_remove(struct idr *idp, int id);
> >  void idr_remove_all(struct idr *idp);
> > Index: mmotm-2.6.28-Jan7/lib/idr.c
> > ===================================================================
> > --- mmotm-2.6.28-Jan7.orig/lib/idr.c
> > +++ mmotm-2.6.28-Jan7/lib/idr.c
> > @@ -579,6 +579,52 @@ int idr_for_each(struct idr *idp,
> >  EXPORT_SYMBOL(idr_for_each);
> >  
> >  /**
> > + * idr_get_next - lookup next object of id to given id.
> > + * @idp: idr handle
> > + * @id:  pointer to lookup key
> > + *
> > + * Returns pointer to registered object with id, which is next number to
> > + * given id.
> > + */
> > +
> > +void *idr_get_next(struct idr *idp, int *nextidp)
> > +{
> > +	struct idr_layer *p, *pa[MAX_LEVEL];
> > +	struct idr_layer **paa = &pa[0];
> > +	int id = *nextidp;
> > +	int n, max;
> > +
> > +	/* find first ent */
> > +	n = idp->layers * IDR_BITS;
> > +	max = 1 << n;
> > +	p = rcu_dereference(idp->top);
> > +	if (!p)
> > +		return NULL;
> > +
> > +	while (id < max) {
> > +		while (n > 0 && p) {
> > +			n -= IDR_BITS;
> > +			*paa++ = p;
> > +			p = rcu_dereference(p->ary[(id >> n) & IDR_MASK]);
> > +		}
> > +
> > +		if (p) {
> > +			*nextidp = id;
> > +			return p;
> > +		}
> > +
> > +		id += 1 << n;
> > +		while (n < fls(id)) {
> > +			n += IDR_BITS;
> > +			p = *--paa;
> > +		}
> > +	}
> > +	return NULL;
> > +}
> > +
> > +
> > +
> > +/**
> >   * idr_replace - replace pointer for given id
> >   * @idp: idr handle
> >   * @ptr: pointer you want associated with the id
> > 
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
