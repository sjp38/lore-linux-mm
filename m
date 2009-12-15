Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 88D3D6B0096
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 05:30:32 -0500 (EST)
Received: by fxm25 with SMTP id 25so4113730fxm.6
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 02:30:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
	 <20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 15 Dec 2009 12:30:27 +0200
Message-ID: <cc557aab0912150230g54863bb8rabc8b8c1c58d5a55@mail.gmail.com>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
	for notifications
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 11:35 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 15 Dec 2009 11:11:16 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> Could anybody review the patch?
>>
>> Thank you.
>
> some nitpicks.
>
>>
>> On Sat, Dec 12, 2009 at 12:59 AM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>
>> > + =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Unregister events and notify userspace.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* FIXME: How to avoid race with cgroup_ev=
ent_remove_work()
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0which runs f=
rom workqueue?
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cgrp->event_list_mutex);
>> > + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(event, tmp, &cgrp->eve=
nt_list, list) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cgroup_event_remove=
(event);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(even=
t->eventfd, 1);
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cgrp->event_list_mutex);
>> > +
>> > +out:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> > =C2=A0}
>
> How ciritical is this FIXME ?

There is potential race. I have never seen it. When userspace closes
eventfd associated
with cgroup event, cgroup_event_remove() will not be called
immediately. It will be called
later from workqueue. If somebody removes cgroup before the workqueue calls
cgroup_event_remove() we will get problem.
It's unlikely, but theoretically possible.

> But Hmm..can't we use RCU ?

I'll play with it.

>> >
>> > @@ -1136,6 +1187,8 @@ static void init_cgroup_housekeeping(struct cgro=
up *cgrp)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&cgrp->release_list);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&cgrp->pidlists);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_init(&cgrp->pidlist_mutex);
>> > + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&cgrp->event_list);
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_init(&cgrp->event_list_mutex);
>> > =C2=A0}
>> >
>> > =C2=A0static void init_cgroup_root(struct cgroupfs_root *root)
>> > @@ -1935,6 +1988,16 @@ static const struct inode_operations cgroup_dir=
_inode_operations =3D {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.rename =3D cgroup_rename,
>> > =C2=A0};
>> >
>> > +/*
>> > + * Check if a file is a control file
>> > + */
>> > +static inline struct cftype *__file_cft(struct file *file)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 if (file->f_dentry->d_inode->i_fop !=3D &cgroup=
_file_operations)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(-EIN=
VAL);
>> > + =C2=A0 =C2=A0 =C2=A0 return __d_cft(file->f_dentry);
>> > +}
>> > +
>> > =C2=A0static int cgroup_create_file(struct dentry *dentry, mode_t mode=
,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct super_block *sb)
>> > =C2=A0{
>> > @@ -2789,6 +2852,151 @@ static int cgroup_write_notify_on_release(stru=
ct cgroup *cgrp,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> > =C2=A0}
>> >
>> > +static inline void cgroup_event_remove(struct cgroup_event *event)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp =3D event->cgrp;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 BUG_ON(event->cft->unregister_event(cgrp, event=
->cft, event->eventfd));
>
> Hmm ? BUG ? If bug, please add document or comment.

I'll remove it, since we check it in cgroup_write_event_control().

>> > + =C2=A0 =C2=A0 =C2=A0 eventfd_ctx_put(event->eventfd);
>> > + =C2=A0 =C2=A0 =C2=A0 remove_wait_queue(event->wqh, &event->wait);
>> > + =C2=A0 =C2=A0 =C2=A0 list_del(&event->list);
>
> please add comment as /* event_list_mutex must be held */

Ok.

>> > + =C2=A0 =C2=A0 =C2=A0 kfree(event);
>> > +}
>> > +
>> > +static void cgroup_event_remove_work(struct work_struct *work)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(wor=
k, struct cgroup_event,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 remove);
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp =3D event->cgrp;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cgrp->event_list_mutex);
>> > + =C2=A0 =C2=A0 =C2=A0 cgroup_event_remove(event);
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cgrp->event_list_mutex);
>> > +}
>> > +
>> > +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int sync, void *key=
)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(wai=
t,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 struct cgroup_event, wait);
>> > + =C2=A0 =C2=A0 =C2=A0 unsigned long flags =3D (unsigned long)key;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 if (flags & POLLHUP)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* This functi=
on called with spinlock taken, but
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* cgroup_even=
t_remove() may sleep, so we have
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* to run it i=
n a workqueue.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&even=
t->remove);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 return 0;
>> > +}
>
>> > +
>> > +static void cgroup_event_ptable_queue_proc(struct file *file,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *=
wqh, poll_table *pt)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(pt,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 struct cgroup_event, pt);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 event->wqh =3D wqh;
>> > + =C2=A0 =C2=A0 =C2=A0 add_wait_queue(wqh, &event->wait);
>> > +}
>> > +
>> > +static int cgroup_write_event_control(struct cgroup *cont, struct cft=
ype *cft,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *buf=
fer)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D NULL;
>> > + =C2=A0 =C2=A0 =C2=A0 unsigned int efd, cfd;
>> > + =C2=A0 =C2=A0 =C2=A0 struct file *efile =3D NULL;
>> > + =C2=A0 =C2=A0 =C2=A0 struct file *cfile =3D NULL;
>> > + =C2=A0 =C2=A0 =C2=A0 char *endp;
>> > + =C2=A0 =C2=A0 =C2=A0 int ret;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 efd =3D simple_strtoul(buffer, &endp, 10);
>> > + =C2=A0 =C2=A0 =C2=A0 if (*endp !=3D ' ')
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
>> > + =C2=A0 =C2=A0 =C2=A0 buffer =3D endp + 1;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 cfd =3D simple_strtoul(buffer, &endp, 10);
>> > + =C2=A0 =C2=A0 =C2=A0 if ((*endp !=3D ' ') && (*endp !=3D '\0'))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
>> > + =C2=A0 =C2=A0 =C2=A0 buffer =3D endp + 1;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 event =3D kzalloc(sizeof(*event), GFP_KERNEL);
>> > + =C2=A0 =C2=A0 =C2=A0 if (!event)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> > + =C2=A0 =C2=A0 =C2=A0 event->cgrp =3D cont;
>> > + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&event->list);
>> > + =C2=A0 =C2=A0 =C2=A0 init_poll_funcptr(&event->pt, cgroup_event_ptab=
le_queue_proc);
>> > + =C2=A0 =C2=A0 =C2=A0 init_waitqueue_func_entry(&event->wait, cgroup_=
event_wake);
>> > + =C2=A0 =C2=A0 =C2=A0 INIT_WORK(&event->remove, cgroup_event_remove_w=
ork);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 efile =3D eventfd_fget(efd);
>> > + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(efile)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(efi=
le);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 event->eventfd =3D eventfd_ctx_fileget(efile);
>> > + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(event->eventfd)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(eve=
nt->eventfd);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 cfile =3D fget(cfd);
>> > + =C2=A0 =C2=A0 =C2=A0 if (!cfile) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EBADF;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 /* the process need read permission on control =
file */
>> > + =C2=A0 =C2=A0 =C2=A0 ret =3D file_permission(cfile, MAY_READ);
>> > + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 event->cft =3D __file_cft(cfile);
>> > + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(event->cft)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(eve=
nt->cft);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 if (!event->cft->register_event || !event->cft-=
>unregister_event) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 ret =3D event->cft->register_event(cont, event-=
>cft,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 event->eventfd, buffer);
>> > + =C2=A0 =C2=A0 =C2=A0 if (ret)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 efile->f_op->poll(efile, &event->pt);
>
> Not necessary to check return value ?

You are right. We need to check return value for POLLHUP.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
