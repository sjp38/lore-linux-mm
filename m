Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB5BoTs4001120
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 20:50:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AC5545DE4F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:50:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6599245DE51
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:50:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 40D191DB803A
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:50:29 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EB1011DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:50:28 +0900 (JST)
Message-ID: <7442.10.75.179.62.1228477828.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830812050311m3728ab69v465ed5d032792973@mail.gmail.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com><20081205172959.8285271f.kamezawa.hiroyu@jp.fujitsu.com>
    <6599ad830812050311m3728ab69v465ed5d032792973@mail.gmail.com>
Date: Fri, 5 Dec 2008 20:50:28 +0900 (JST)
Subject: Re: [RFC][PATCH 2/4] cgroup ID
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Paul Menage said:
> Hi Kamezawa,
>
> I definitely agree with the idea of being able to traverse the cgroup
> hierarchy without doing a cgroup_lock() and I've included some
> comments below. But having said that, maybe there's a simpler
> solution?
>
> A while ago I posted some patches that added a per-hierarchy lock
> which could be taken to prevent creation or destruction of cgroups in
> a given hierarchy; it was lighter-weight than the full cgroup_lock().
> Is that sufficient to avoid the deadlock that you mentioned in your
> patch description?
>
yes, maybe. I just think hierarchy-walk support in cgroup level is
proper way, I think. currnet cgroup_lock() is too rough.

One concern I have is that ID is very robust to scan things rather than
list, which can be modified. Can you design hierarchy walk which the caller
of walker can sleep ? like following,

==
     next = cgroup_get_next(cur, root);
     .......
     cur = next;
     sleep;
     continue from next
==
memcg's code rememver next by its own refcnt of memcg. But it's unclear
way.

Another concern is, css_get() to do above will prevent rmdir() of cgroup
by "Unknown Reason". I don't want to return -EBUSY at rmdir(next) for
remembering "next" by css_get().


> The idea of having a short id for each cgroup to save space in the
> swap cgroup sounds sensible - but I'm not sure that we need the RCU
> support to make the id persist beyond the lifetime of the cgroup
> itself.
>
Ah, maybe explaination was not enough.

Now, I don't clear swap_cgroup entry at pre_destroy() because scanning all
swp_cgroup entry is heavy...so, ID is recorded after removal of cgroup.
If memcg scans all swap_cgroup entry at destroy(), memcg doesn't require
such lifetime of ID. Hmm....what difficult here is cost of scanning depends
on size of swap.


> On Fri, Dec 5, 2008 at 12:29 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> +/*
>> + * Cgroup ID for *internal* identification and lookup. For
>> user-land,"path"
>> + * of cgroup works well.
>> + */
>
> This comment seems misplaced and possibly unnecessary. Should it be
> with the struct cgroup_id definition in cgroup.c?
>
yes...

>>
>> +/*
>> + * For supporting cgroup lookup and hierarchy management.
>> + */
>
> A lot more commenting would be useful here.
>
will do.

>> +/* An interface for usual lookup */
>> +struct cgroup *cgroup_lookup(int id);
>> +/* get next cgroup under tree (for scan) */
>> +struct cgroup *
>> +cgroup_get_next(int id, int rootid, int depth, int *foundid);
>> +/* get id and depth of cgroup */
>> +int cgroup_id(struct cgroup *cgroup);
>> +int cgroup_depth(struct cgroup *cgroup);
>> +/* For delayed freeing of IDs */
>> +int cgroup_id_tryget(int id);
>> +void cgroup_id_put(int id);
>> +
>>  #else /* !CONFIG_CGROUPS */
>>
>>  /*
>> + * CGROUP ID
>> + */
>
> More comments needed about the exact semantics of these fields.
>
Sure, I will add.

>> +struct cgroup_id {
>> +       struct cgroup *myself;
>
> Can you call this cgroup for consistency with other struct cgroup
> pointers?
>
Ok, rename that.

>> +       unsigned int  id;
>> +       unsigned int  depth;
>> +       atomic_t      refcnt;
>> +       struct rcu_head rcu_head;
>> +       unsigned int  hierarchy_code[MAX_CGROUP_DEPTH];
>
> How about "stack" for this array?
>
Ah, ok. hierarchy_code is too long...

>> +};
>> +
>> +void free_cgroupid_cb(struct rcu_head *head)
>> +{
>> +       struct cgroup_id *id;
>> +
>> +       id = container_of(head, struct cgroup_id, rcu_head);
>> +       kfree(id);
>> +}
>> +
>> +void free_cgroupid(struct cgroup_id *id)
>> +{
>> +       call_rcu(&id->rcu_head, free_cgroupid_cb);
>> +}
>> +
>
> Rather than having a separate RCU callback for the cgroup_id
> structure, how about marking it as "dead" when you unlink the cgroup
> from the tree, and freeing it in the cgroup_diput() callback at the
> same time the struct cgroup is freed? Or is the issue that you need
> the id to persist longer than the cgroup itself, to prevent re-use?
>
yes...for swap_cgroup, I'd like to prevent reuse.
But it depencs on choice of design. If memcg clears all record about
swap at destroy(), this ID can be freed at with cgroup.


>> +static DEFINE_IDR(cgroup_idr);
>> +DEFINE_SPINLOCK(cgroup_idr_lock);
>
> Any reason to not have a separate idr and idr_lock per hierarchy?
>
That's because checking whether "cgroup_idr" is alive or not makes
the whole code complex. (because of peristency of ID)
I tried put this into cgroup_rootfs struct and ...found it's complicated.


>> +
>> +static int cgrouproot_setup_idr(struct cgroupfs_root *root)
>> +{
>> +       struct cgroup_id *newid;
>> +       int err = -ENOMEM;
>> +       int myid;
>> +
>> +       newid = kzalloc(sizeof(*newid), GFP_KERNEL);
>> +       if (!newid)
>> +               goto out;
>> +       if (!idr_pre_get(&cgroup_idr, GFP_KERNEL))
>> +               goto free_out;
>> +
>> +       spin_lock_irq(&cgroup_idr_lock);
>> +       err = idr_get_new_above(&cgroup_idr, newid, 1, &myid);
>> +       spin_unlock_irq(&cgroup_idr_lock);
>> +
>> +       /* This one is new idr....*/
>> +       BUG_ON(err);
>
> There's really no way this can fail?
>
Maybe, unless id over INT_MAX.


>> +/*
>> + * should be called while "cgrp" is valid.
>> + */
>
> Can you be more specific here? Clearly calling a function with a
> pointer to an object that might have been freed is a bad idea; if
> that's all you mean then I don't think it needs to be called out in a
> comment.
>
Hmm, "Should be called when !cgroup_is_removed()" ?
But removing above comment is maybe sane...

>> +static int cgroup_prepare_id(struct cgroup *parent, struct cgroup_id
>> **id)
>> +{
>> +       struct cgroup_id *newid;
>> +       int myid, error;
>> +
>> +       /* check depth */
>> +       if (parent->id->depth + 1 >= MAX_CGROUP_DEPTH)
>> +               return -ENOSPC;
>> +       newid = kzalloc(sizeof(*newid), GFP_KERNEL);
>> +       if (!newid)
>> +               return -ENOMEM;
>> +       /* get id */
>> +       if (unlikely(!idr_pre_get(&cgroup_idr, GFP_KERNEL))) {
>> +               error = -ENOMEM;
>> +               goto err_out;
>> +       }
>> +       spin_lock_irq(&cgroup_idr_lock);
>> +       /* Don't use 0 */
>> +       error = idr_get_new_above(&cgroup_idr, newid, 1, &myid);
>> +       spin_unlock_irq(&cgroup_idr_lock);
>> +       if (error)
>> +               goto err_out;
>
> This code is pretty similar to a big chunk of cgrouproot_setup_idr() -
> can they share the common code?
>
Yes, I'll try.


>> +static void cgroup_id_attach(struct cgroup_id *cgid,
>> +                            struct cgroup *cg, struct cgroup *parent)
>> +{
>> +       struct cgroup_id *parent_id = rcu_dereference(parent->id);
>
> It doesn't seem as though it should be necessary to rcu_dereference()
> parent->id - parent can't be going away in this case.
>
yes. will fix.

>> +       int i;
>> +
>> +       cgid->depth = parent_id->depth + 1;
>> +       /* Inherit hierarchy code from parent */
>> +       for (i = 0; i < cgid->depth; i++) {
>> +               cgid->hierarchy_code[i] =
>> +                       parent_id->hierarchy_code[i];
>> +               cgid->hierarchy_code[cgid->depth] = cgid->id;
>
> I think this line is supposed to be outside the for() loop.
>
yes...

Thank you for review.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
