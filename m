Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 98B1F6B006A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:11:19 -0500 (EST)
Received: by fxm25 with SMTP id 25so4051014fxm.6
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 01:11:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
Date: Tue, 15 Dec 2009 11:11:16 +0200
Message-ID: <cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
	for notifications
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Could anybody review the patch?

Thank you.

On Sat, Dec 12, 2009 at 12:59 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> This patch introduces write-only file "cgroup.event_control" in every
> cgroup.
>
> To register new notification handler you need:
> - create an eventfd;
> - open a control file to be monitored. Callbacks register_event() and
> =C2=A0unregister_event() must be defined for the control file;
> - write "<event_fd> <control_fd> <args>" to cgroup.event_control.
> =C2=A0Interpretation of args is defined by control file implementation;
>
> eventfd will be woken up by control file implementation or when the
> cgroup is removed.
>
> To unregister notification handler just close eventfd.
>
> If you need notification functionality for a control file you have to
> implement callbacks register_event() and unregister_event() in the
> struct cftype.
>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
> =C2=A0include/linux/cgroup.h | =C2=A0 20 +++++
> =C2=A0kernel/cgroup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0215 ++++++++++++=
+++++++++++++++++++++++++++++++++++-
> =C2=A02 files changed, 234 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 0008dee..7ad3078 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -220,6 +220,10 @@ struct cgroup {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* For RCU-protected deletion */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rcu_head rcu_head;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* List of events which userspace want to recieve =
*/
> + =C2=A0 =C2=A0 =C2=A0 struct list_head event_list;
> + =C2=A0 =C2=A0 =C2=A0 struct mutex event_list_mutex;
> =C2=A0};
>
> =C2=A0/*
> @@ -362,6 +366,22 @@ struct cftype {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*trigger)(struct cgroup *cgrp, unsigned i=
nt event);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*release)(struct inode *inode, struct fil=
e *file);
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* register_event() callback will be used to =
add new userspace
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* waiter for changes related to the cftype. =
Implement it if
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* you want to provide this functionality. Us=
e eventfd_signal()
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* on eventfd to send notification to userspa=
ce.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 int (*register_event)(struct cgroup *cgrp, struct =
cftype *cft,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct eventfd_ctx *eventfd, const char *args);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* unregister_event() callback will be called=
 when userspace
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* close the eventfd. This callback must be i=
mplemented, if you
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* provide register_event().
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 int (*unregister_event)(struct cgroup *cgrp, struc=
t cftype *cft,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct eventfd_ctx *eventfd);
> =C2=A0};
>
> =C2=A0struct cgroup_scanner {
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 0249f4b..f7ec3ca 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4,6 +4,10 @@
> =C2=A0* =C2=A0Based originally on the cpuset system, extracted by Paul Me=
nage
> =C2=A0* =C2=A0Copyright (C) 2006 Google, Inc
> =C2=A0*
> + * =C2=A0Notifiactions support
> + * =C2=A0Copyright (C) 2009 Nokia Corporation
> + * =C2=A0Author: Kirill A. Shutemov
> + *
> =C2=A0* =C2=A0Copyright notices from the original cpuset code:
> =C2=A0* =C2=A0--------------------------------------------------
> =C2=A0* =C2=A0Copyright (C) 2003 BULL SA.
> @@ -51,6 +55,8 @@
> =C2=A0#include <linux/pid_namespace.h>
> =C2=A0#include <linux/idr.h>
> =C2=A0#include <linux/vmalloc.h> /* TODO: replace with more sophisticated=
 array */
> +#include <linux/eventfd.h>
> +#include <linux/poll.h>
>
> =C2=A0#include <asm/atomic.h>
>
> @@ -146,6 +152,36 @@ struct css_id {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned short stack[0]; /* Array of Length (d=
epth+1) */
> =C2=A0};
>
> +/*
> + * cgroup_event represents event which userspace want to recieve.
> + */
> +struct cgroup_event {
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Cgroup which the event belongs to.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Control file which the event associated.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 struct cftype *cft;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* eventfd to signal userspace about the even=
t.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *eventfd;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Each of these stored in a list by the cgro=
up.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 struct list_head list;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* All fields below needed to unregister even=
t when
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* userspace closes eventfd.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 poll_table pt;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wqh;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_t wait;
> + =C2=A0 =C2=A0 =C2=A0 struct work_struct remove;
> +};
> +static void cgroup_event_remove(struct cgroup_event *event);
>
> =C2=A0/* The list of hierarchy roots */
>
> @@ -734,14 +770,29 @@ static struct inode *cgroup_new_inode(mode_t mode, =
struct super_block *sb)
> =C2=A0static int cgroup_call_pre_destroy(struct cgroup *cgrp)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cgroup_subsys *ss;
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event, *tmp;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_subsys(cgrp->root, ss)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ss->pre_destro=
y) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D ss->pre_destroy(ss, cgrp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (ret)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Unregister events and notify userspace.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* FIXME: How to avoid race with cgroup_event=
_remove_work()
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0which runs from=
 workqueue?
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cgrp->event_list_mutex);
> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(event, tmp, &cgrp->event_=
list, list) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cgroup_event_remove(ev=
ent);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(event->=
eventfd, 1);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cgrp->event_list_mutex);
> +
> +out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> @@ -1136,6 +1187,8 @@ static void init_cgroup_housekeeping(struct cgroup =
*cgrp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&cgrp->release_list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&cgrp->pidlists);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_init(&cgrp->pidlist_mutex);
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&cgrp->event_list);
> + =C2=A0 =C2=A0 =C2=A0 mutex_init(&cgrp->event_list_mutex);
> =C2=A0}
>
> =C2=A0static void init_cgroup_root(struct cgroupfs_root *root)
> @@ -1935,6 +1988,16 @@ static const struct inode_operations cgroup_dir_in=
ode_operations =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.rename =3D cgroup_rename,
> =C2=A0};
>
> +/*
> + * Check if a file is a control file
> + */
> +static inline struct cftype *__file_cft(struct file *file)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (file->f_dentry->d_inode->i_fop !=3D &cgroup_fi=
le_operations)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(-EINVAL=
);
> + =C2=A0 =C2=A0 =C2=A0 return __d_cft(file->f_dentry);
> +}
> +
> =C2=A0static int cgroup_create_file(struct dentry *dentry, mode_t mode,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct super_block *sb)
> =C2=A0{
> @@ -2789,6 +2852,151 @@ static int cgroup_write_notify_on_release(struct =
cgroup *cgrp,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +static inline void cgroup_event_remove(struct cgroup_event *event)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp =3D event->cgrp;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(event->cft->unregister_event(cgrp, event->c=
ft, event->eventfd));
> + =C2=A0 =C2=A0 =C2=A0 eventfd_ctx_put(event->eventfd);
> + =C2=A0 =C2=A0 =C2=A0 remove_wait_queue(event->wqh, &event->wait);
> + =C2=A0 =C2=A0 =C2=A0 list_del(&event->list);
> + =C2=A0 =C2=A0 =C2=A0 kfree(event);
> +}
> +
> +static void cgroup_event_remove_work(struct work_struct *work)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(work, =
struct cgroup_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 remove);
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp =3D event->cgrp;
> +
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cgrp->event_list_mutex);
> + =C2=A0 =C2=A0 =C2=A0 cgroup_event_remove(event);
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cgrp->event_list_mutex);
> +}
> +
> +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int sync, void *key)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(wait,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct cgroup_event, wait);
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags =3D (unsigned long)key;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (flags & POLLHUP)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* This function =
called with spinlock taken, but
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* cgroup_event_r=
emove() may sleep, so we have
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* to run it in a=
 workqueue.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&event->=
remove);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static void cgroup_event_ptable_queue_proc(struct file *file,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wqh=
, poll_table *pt)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D container_of(pt,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct cgroup_event, pt);
> +
> + =C2=A0 =C2=A0 =C2=A0 event->wqh =3D wqh;
> + =C2=A0 =C2=A0 =C2=A0 add_wait_queue(wqh, &event->wait);
> +}
> +
> +static int cgroup_write_event_control(struct cgroup *cont, struct cftype=
 *cft,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *buffer)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup_event *event =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int efd, cfd;
> + =C2=A0 =C2=A0 =C2=A0 struct file *efile =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 struct file *cfile =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 char *endp;
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 efd =3D simple_strtoul(buffer, &endp, 10);
> + =C2=A0 =C2=A0 =C2=A0 if (*endp !=3D ' ')
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 buffer =3D endp + 1;
> +
> + =C2=A0 =C2=A0 =C2=A0 cfd =3D simple_strtoul(buffer, &endp, 10);
> + =C2=A0 =C2=A0 =C2=A0 if ((*endp !=3D ' ') && (*endp !=3D '\0'))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 buffer =3D endp + 1;
> +
> + =C2=A0 =C2=A0 =C2=A0 event =3D kzalloc(sizeof(*event), GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 if (!event)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 event->cgrp =3D cont;
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&event->list);
> + =C2=A0 =C2=A0 =C2=A0 init_poll_funcptr(&event->pt, cgroup_event_ptable_=
queue_proc);
> + =C2=A0 =C2=A0 =C2=A0 init_waitqueue_func_entry(&event->wait, cgroup_eve=
nt_wake);
> + =C2=A0 =C2=A0 =C2=A0 INIT_WORK(&event->remove, cgroup_event_remove_work=
);
> +
> + =C2=A0 =C2=A0 =C2=A0 efile =3D eventfd_fget(efd);
> + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(efile)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(efile)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 event->eventfd =3D eventfd_ctx_fileget(efile);
> + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(event->eventfd)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(event-=
>eventfd);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 cfile =3D fget(cfd);
> + =C2=A0 =C2=A0 =C2=A0 if (!cfile) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EBADF;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 /* the process need read permission on control fil=
e */
> + =C2=A0 =C2=A0 =C2=A0 ret =3D file_permission(cfile, MAY_READ);
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> +
> + =C2=A0 =C2=A0 =C2=A0 event->cft =3D __file_cft(cfile);
> + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(event->cft)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ERR(event-=
>cft);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!event->cft->register_event || !event->cft->un=
register_event) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D event->cft->register_event(cont, event->cf=
t,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 event->eventfd, buffer);
> + =C2=A0 =C2=A0 =C2=A0 if (ret)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
> +
> + =C2=A0 =C2=A0 =C2=A0 efile->f_op->poll(efile, &event->pt);
> +
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cont->event_list_mutex);
> + =C2=A0 =C2=A0 =C2=A0 list_add(&event->list, &cont->event_list);
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cont->event_list_mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 fput(cfile);
> + =C2=A0 =C2=A0 =C2=A0 fput(efile);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +
> +fail:
> + =C2=A0 =C2=A0 =C2=A0 if (!IS_ERR(cfile))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fput(cfile);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (event && event->eventfd && !IS_ERR(event->even=
tfd))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_ctx_put(event-=
>eventfd);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!IS_ERR(efile))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fput(efile);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (event)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(event);
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> =C2=A0/*
> =C2=A0* for the common functions, 'private' gives the type of file
> =C2=A0*/
> @@ -2814,6 +3022,11 @@ static struct cftype files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D cgro=
up_read_notify_on_release,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D cgr=
oup_write_notify_on_release,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D CGROUP_FILE_=
GENERIC_PREFIX "event_control",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write_string =3D cgro=
up_write_event_control,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .mode =3D S_IWUGO,
> + =C2=A0 =C2=A0 =C2=A0 },
> =C2=A0};
>
> =C2=A0static struct cftype cft_release_agent =3D {
> --
> 1.6.5.3
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
