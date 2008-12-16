Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2FD2C6B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:07:53 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBGB9Ovk026023
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 20:09:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A71B945DD80
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 20:09:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57E2245DD78
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 20:09:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A8951DB803E
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 20:09:23 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 997171DB8042
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 20:09:22 +0900 (JST)
Message-ID: <9600.10.75.179.61.1229425761.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830812160224x7af92b4bl414612f9c353a6b7@mail.gmail.com>
References: 
    <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com><20081216181909.2d500446.kamezawa.hiroyu@jp.fujitsu.com>
    <6599ad830812160224x7af92b4bl414612f9c353a6b7@mail.gmail.com>
Date: Tue, 16 Dec 2008 20:09:21 +0900 (JST)
Subject: Re: [PATCH 7/9] cgroup: Support CSS ID
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage said:
> On Tue, Dec 16, 2008 at 1:19 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Patch for Per-CSS ID and private hierarchy code.
>>
>> This patch tries to assign a ID to each css. Attach unique ID to each
>> css and provides following functions.
>>
>>  - css_lookup(subsys, id)
>>   returns struct cgroup of id.
>>  - css_get_next(subsys, id, rootid, depth, foundid)
>>   returns the next cgroup under "root" by scanning bitmap (not by
>> tree-walk)
>
> Basic approach looks great - but there are a lot of typos in comments.
>
thanks, and sorry :(

>>
>> When cgrou_subsys->use_id is set, id field and bitmap for css is
>> maintained.
>
> When cgroup_subsyst.use_id is set, an id is maintained for each css
> (via an idr bitmap)
>
will do

>> kernel/cgroup.c just parepare
>
> The cgroups framework only prepares:
>
will do

>>        - css_id of root css for subsys
>>        - alloc/free id functions.
>> So, each subsys should allocate ID in attach() callback if necessary.
>>
>> There is several reasons to develop this.
>>        - Saving space .... For example, memcg's swap_cgroup is array of
>>          pointers to cgroup. But it is not necessary to be very fast.
>>          By replacing pointers(8bytes per ent) to ID (2byes per ent), we
>> can
>>          reduce much amount of memory usage.
>>
>>        - Scanning without lock.
>>          CSS_ID provides "scan id under this ROOT" function. By this,
>> scanning
>>          css under root can be written without locks.
>>          ex)
>>          do {
>>                rcu_read_lock();
>>                next = cgroup_get_next(subsys, id, root, &found);
>>                /* check sanity of next here */
>>                css_tryget();
>>                rcu_read_unlock();
>>                id = found + 1
>>         } while(...)
>>
>> Characteristics:
>>        - Each css has unique ID under subsys.
>>        - Lifetime of ID is controlled by subsys.
>>        - css ID contains "ID" and "Depth in hierarchy" and stack of
>> hierarchy
>>        - Allowed ID is 1-65535, ID 0 is UNUSED ID.
>>
>> +       /*
>> +        * set 1 if subsys uses ID. ID is not available before
>> cgroup_init()
>
> Make this a bool rather than an int?
>
ok, will use bool.

>> +        * (not available in early_init time.
>> +        */
>> +       int use_id;
>>  #define MAX_CGROUP_TYPE_NAMELEN 32
>>        const char *name;
>>
>
>> + * CSS ID is a ID for all css struct under subsys. Only works when
>> + * cgroup_subsys->use_id != 0. It can be used for look up and scanning
>> + * Cgroup ID is assined at cgroup allocation (create) and removed
>
> assined -> assigned
>
will fix

>> + * when refcnt to ID goes down to 0. Refcnt is inremented when subsys
>> want to
>> + * avoid reuse of ID for persistent objects.
>
> Although the CSS ID is RCU-safe, the subsystem may increment its
> refcount when it wishes to avoid reuse of that ID for a different CSS
> while it holds the reference outside of an RCU section.
>
>> In usual, refcnt to ID will be 0
>> + * when cgroup is removed.
>
> In the normal case, the refcount to the ID will be 0 when the cgroup is
> removed.
>
will fix.

>> + *
>> + * Note: At using ID, max depth of the hierarchy is determined by
>
> When using ID
>
>> + * cgroup_subsys->max_id_depth.
>> + */
>
> Is this comment stale? There's no cgroup_subsys.max_id_depth in this
> patch.
>
Ah, stale...

>> +
>> +/* called at create() */
>
> If the subsystem has specified use_id=true, is there any reason not to
> automatically allocate the ID on its behalf?
>
Hmm. Because "free" is called by subsys, I moved calls to "create" to
subsys. (free is not necessary to be called at destroy())

>> -
>> +#include <linux/idr.h>
>
> This is already included in cgroup.h
>
Ah, thanks. will check again.

>> +        * The cgroup to whiech this ID points. If cgroup is removed,
>
> "to which"
>
will fix..

> Mention RCU-safety of the cgroup pointer?
>
ok. mention about that.

>> +        */
>> +       unsigned short  stack[0]; /* Length of this field is defined by
>> depth */
>
> /* Array of length (depth+1) */
>
ok

>> +int css_is_ancestor(struct cgroup_subsys_state *css,
>> +                   struct cgroup_subsys_state *root)
>> +{
>> +       struct css_id *id = css->id;
>> +       struct css_id *ans = root->id;
>
> It might be clearer to name the css pointers "child" and "root" and
> the id pointers "child_id" and "root_id".
>
ok. will change.

>> +static int __get_and_prepare_newid(struct cgroup_subsys *ss,
>> +                               int depth, struct css_id **ret)
>> +{
>> +       struct css_id *newid;
>> +       int myid, error, size;
>> +
>> +       BUG_ON(!ss->use_id);
>> +
>> +       size = sizeof(struct css_id) + sizeof(unsigned short) * (depth +
>> 1);
>> +       newid = kzalloc(size, GFP_KERNEL);
>> +       if (!newid)
>> +               return -ENOMEM;
>> +       /* get id */
>> +       if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
>> +               error = -ENOMEM;
>> +               goto err_out;
>> +       }
>
> Is this safe? If the only place that we allocated ids was in
> cgroup_create() then it should be fine since allocation is
> synchronized. But if the subsystem can allocate at other times as
> well, then theoretically two threads could get past the idr_pre_get()
> stage and one of them could exhaust the pre-allocated objects.
>
maybe you're right. will fix this or move "create" to cgroup.c rather than
by subsys.


>> +       spin_lock(&ss->id_lock);
>> +       /* Don't use 0 */
>> +       error = idr_get_new_above(&ss->idr, newid, 1, &myid);
>> +       spin_unlock(&ss->id_lock);
>> +
>> +       /* Returns error when there are no free spaces for new ID.*/
>> +       if (error) {
>> +               error = -ENOSPC;
>> +               goto err_out;
>> +       }
>> +
>> +       newid->id = myid;
>> +       newid->depth = depth;
>> +       *ret = newid;
>> +       return 0;
>> +err_out:
>> +       kfree(newid);
>> +       return error;
>> +
>> +}
>> +
>> +
>> +static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
>> +{
>> +       struct css_id *newid;
>> +       struct cgroup_subsys_state *rootcss;
>> +       int err = -ENOMEM;
>> +
>> +       spin_lock_init(&ss->id_lock);
>> +       idr_init(&ss->idr);
>> +
>> +       rootcss = init_css_set.subsys[ss->subsys_id];
>> +       err = __get_and_prepare_newid(ss, 0, &newid);
>> +       if (err)
>> +               return err;
>> +
>> +       newid->stack[0] = newid->id;
>> +       newid->css = rootcss;
>> +       rootcss->id = newid;
>> +       return 0;
>> +}
>> +
>
>> + * css_lookup - lookup css by id
>> + * @id: the id of cgroup to be looked up
>> + *
>> + * Returns pointer to css if there is valid css with id, NULL if not.
>> + * Should be called under rcu_read_lock()
>> + */
>> +
>> +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int
>> id)
>> +{
>> +       struct cgroup_subsys_state *css = NULL;
>> +       struct css_id *cssid = NULL;
>> +
>> +       BUG_ON(!ss->use_id);
>> +       rcu_read_lock();
>
> Why do we need an additional rcu_read_lock() here? Since we've
> required that the caller be under rcu_read_lock()?
>
Just because I can't find to add a macro to check
==
 BUG_ON(rcu_read_lock_is_not_held)
==
I'll see rcu code again,

>> +               if (tmp->depth >= depth && tmp->stack[depth] == rootid)
>> {
>> +                       ret = rcu_dereference(tmp->css);
>> +                       /* Sanity check and check hierarchy */
>> +                       if (ret && !css_is_removed(ret))
>> +                               break;
>
> Is there much point checking for css_is_removed here? The caller will
> have to check it anyway since we're not synchronized against cgroup
> removal.
>
Ok, will remove this.

>> +               }
>> +               tmpid = tmpid + 1;
>
> Comment here?
>
will do.

Thank you for review!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
