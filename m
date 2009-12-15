Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B0656B0093
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:38:43 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF9ceNG001441
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 18:38:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17D2E45DE4F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:38:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E3D45DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:38:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C37831DB8038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:38:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 748641DB8037
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:38:39 +0900 (JST)
Date: Tue, 15 Dec 2009 18:35:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
  for notifications
Message-Id: <20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 11:11:16 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Could anybody review the patch?
> 
> Thank you.

some nitpicks.

> 
> On Sat, Dec 12, 2009 at 12:59 AM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:

> > + A  A  A  /*
> > + A  A  A  A * Unregister events and notify userspace.
> > + A  A  A  A * FIXME: How to avoid race with cgroup_event_remove_work()
> > + A  A  A  A * A  A  A  A which runs from workqueue?
> > + A  A  A  A */
> > + A  A  A  mutex_lock(&cgrp->event_list_mutex);
> > + A  A  A  list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> > + A  A  A  A  A  A  A  cgroup_event_remove(event);
> > + A  A  A  A  A  A  A  eventfd_signal(event->eventfd, 1);
> > + A  A  A  }
> > + A  A  A  mutex_unlock(&cgrp->event_list_mutex);
> > +
> > +out:
> > A  A  A  A return ret;
> > A }

How ciritical is this FIXME ?
But Hmm..can't we use RCU ?

> >
> > @@ -1136,6 +1187,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
> > A  A  A  A INIT_LIST_HEAD(&cgrp->release_list);
> > A  A  A  A INIT_LIST_HEAD(&cgrp->pidlists);
> > A  A  A  A mutex_init(&cgrp->pidlist_mutex);
> > + A  A  A  INIT_LIST_HEAD(&cgrp->event_list);
> > + A  A  A  mutex_init(&cgrp->event_list_mutex);
> > A }
> >
> > A static void init_cgroup_root(struct cgroupfs_root *root)
> > @@ -1935,6 +1988,16 @@ static const struct inode_operations cgroup_dir_inode_operations = {
> > A  A  A  A .rename = cgroup_rename,
> > A };
> >
> > +/*
> > + * Check if a file is a control file
> > + */
> > +static inline struct cftype *__file_cft(struct file *file)
> > +{
> > + A  A  A  if (file->f_dentry->d_inode->i_fop != &cgroup_file_operations)
> > + A  A  A  A  A  A  A  return ERR_PTR(-EINVAL);
> > + A  A  A  return __d_cft(file->f_dentry);
> > +}
> > +
> > A static int cgroup_create_file(struct dentry *dentry, mode_t mode,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct super_block *sb)
> > A {
> > @@ -2789,6 +2852,151 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
> > A  A  A  A return 0;
> > A }
> >
> > +static inline void cgroup_event_remove(struct cgroup_event *event)
> > +{
> > + A  A  A  struct cgroup *cgrp = event->cgrp;
> > +
> > + A  A  A  BUG_ON(event->cft->unregister_event(cgrp, event->cft, event->eventfd));

Hmm ? BUG ? If bug, please add document or comment.            

> > + A  A  A  eventfd_ctx_put(event->eventfd);
> > + A  A  A  remove_wait_queue(event->wqh, &event->wait);
> > + A  A  A  list_del(&event->list);

please add comment as /* event_list_mutex must be held */

> > + A  A  A  kfree(event);
> > +}
> > +
> > +static void cgroup_event_remove_work(struct work_struct *work)
> > +{
> > + A  A  A  struct cgroup_event *event = container_of(work, struct cgroup_event,
> > + A  A  A  A  A  A  A  A  A  A  A  remove);
> > + A  A  A  struct cgroup *cgrp = event->cgrp;
> > +
> > + A  A  A  mutex_lock(&cgrp->event_list_mutex);
> > + A  A  A  cgroup_event_remove(event);
> > + A  A  A  mutex_unlock(&cgrp->event_list_mutex);
> > +}
> > +
> > +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> > + A  A  A  A  A  A  A  int sync, void *key)
> > +{
> > + A  A  A  struct cgroup_event *event = container_of(wait,
> > + A  A  A  A  A  A  A  A  A  A  A  struct cgroup_event, wait);
> > + A  A  A  unsigned long flags = (unsigned long)key;
> > +
> > + A  A  A  if (flags & POLLHUP)
> > + A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A * This function called with spinlock taken, but
> > + A  A  A  A  A  A  A  A * cgroup_event_remove() may sleep, so we have
> > + A  A  A  A  A  A  A  A * to run it in a workqueue.
> > + A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  schedule_work(&event->remove);
> > +
> > + A  A  A  return 0;
> > +}

> > +
> > +static void cgroup_event_ptable_queue_proc(struct file *file,
> > + A  A  A  A  A  A  A  wait_queue_head_t *wqh, poll_table *pt)
> > +{
> > + A  A  A  struct cgroup_event *event = container_of(pt,
> > + A  A  A  A  A  A  A  A  A  A  A  struct cgroup_event, pt);
> > +
> > + A  A  A  event->wqh = wqh;
> > + A  A  A  add_wait_queue(wqh, &event->wait);
> > +}
> > +
> > +static int cgroup_write_event_control(struct cgroup *cont, struct cftype *cft,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  const char *buffer)
> > +{
> > + A  A  A  struct cgroup_event *event = NULL;
> > + A  A  A  unsigned int efd, cfd;
> > + A  A  A  struct file *efile = NULL;
> > + A  A  A  struct file *cfile = NULL;
> > + A  A  A  char *endp;
> > + A  A  A  int ret;
> > +
> > + A  A  A  efd = simple_strtoul(buffer, &endp, 10);
> > + A  A  A  if (*endp != ' ')
> > + A  A  A  A  A  A  A  return -EINVAL;
> > + A  A  A  buffer = endp + 1;
> > +
> > + A  A  A  cfd = simple_strtoul(buffer, &endp, 10);
> > + A  A  A  if ((*endp != ' ') && (*endp != '\0'))
> > + A  A  A  A  A  A  A  return -EINVAL;
> > + A  A  A  buffer = endp + 1;
> > +
> > + A  A  A  event = kzalloc(sizeof(*event), GFP_KERNEL);
> > + A  A  A  if (!event)
> > + A  A  A  A  A  A  A  return -ENOMEM;
> > + A  A  A  event->cgrp = cont;
> > + A  A  A  INIT_LIST_HEAD(&event->list);
> > + A  A  A  init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
> > + A  A  A  init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
> > + A  A  A  INIT_WORK(&event->remove, cgroup_event_remove_work);
> > +
> > + A  A  A  efile = eventfd_fget(efd);
> > + A  A  A  if (IS_ERR(efile)) {
> > + A  A  A  A  A  A  A  ret = PTR_ERR(efile);
> > + A  A  A  A  A  A  A  goto fail;
> > + A  A  A  }
> > +
> > + A  A  A  event->eventfd = eventfd_ctx_fileget(efile);
> > + A  A  A  if (IS_ERR(event->eventfd)) {
> > + A  A  A  A  A  A  A  ret = PTR_ERR(event->eventfd);
> > + A  A  A  A  A  A  A  goto fail;
> > + A  A  A  }
> > +
> > + A  A  A  cfile = fget(cfd);
> > + A  A  A  if (!cfile) {
> > + A  A  A  A  A  A  A  ret = -EBADF;
> > + A  A  A  A  A  A  A  goto fail;
> > + A  A  A  }
> > +
> > + A  A  A  /* the process need read permission on control file */
> > + A  A  A  ret = file_permission(cfile, MAY_READ);
> > + A  A  A  if (ret < 0)
> > + A  A  A  A  A  A  A  goto fail;
> > +
> > + A  A  A  event->cft = __file_cft(cfile);
> > + A  A  A  if (IS_ERR(event->cft)) {
> > + A  A  A  A  A  A  A  ret = PTR_ERR(event->cft);
> > + A  A  A  A  A  A  A  goto fail;
> > + A  A  A  }
> > +
> > + A  A  A  if (!event->cft->register_event || !event->cft->unregister_event) {
> > + A  A  A  A  A  A  A  ret = -EINVAL;
> > + A  A  A  A  A  A  A  goto fail;
> > + A  A  A  }
> > +
> > + A  A  A  ret = event->cft->register_event(cont, event->cft,
> > + A  A  A  A  A  A  A  A  A  A  A  event->eventfd, buffer);
> > + A  A  A  if (ret)
> > + A  A  A  A  A  A  A  goto fail;
> > +
> > + A  A  A  efile->f_op->poll(efile, &event->pt);

Not necessary to check return value ?

Thanks,
-Kame
> > +
> > + A  A  A  mutex_lock(&cont->event_list_mutex);
> > + A  A  A  list_add(&event->list, &cont->event_list);
> > + A  A  A  mutex_unlock(&cont->event_list_mutex);
> > +
> > + A  A  A  fput(cfile);
> > + A  A  A  fput(efile);
> > +
> > + A  A  A  return 0;
> > +
> > +fail:
> > + A  A  A  if (!IS_ERR(cfile))
> > + A  A  A  A  A  A  A  fput(cfile);
> > +
> > + A  A  A  if (event && event->eventfd && !IS_ERR(event->eventfd))
> > + A  A  A  A  A  A  A  eventfd_ctx_put(event->eventfd);
> > +
> > + A  A  A  if (!IS_ERR(efile))
> > + A  A  A  A  A  A  A  fput(efile);
> > +
> > + A  A  A  if (event)
> > + A  A  A  A  A  A  A  kfree(event);
> > +
> > + A  A  A  return ret;
> > +}
> > +
> > A /*
> > A * for the common functions, 'private' gives the type of file
> > A */
> > @@ -2814,6 +3022,11 @@ static struct cftype files[] = {
> > A  A  A  A  A  A  A  A .read_u64 = cgroup_read_notify_on_release,
> > A  A  A  A  A  A  A  A .write_u64 = cgroup_write_notify_on_release,
> > A  A  A  A },
> > + A  A  A  {
> > + A  A  A  A  A  A  A  .name = CGROUP_FILE_GENERIC_PREFIX "event_control",
> > + A  A  A  A  A  A  A  .write_string = cgroup_write_event_control,
> > + A  A  A  A  A  A  A  .mode = S_IWUGO,
> > + A  A  A  },
> > A };
> >
> > A static struct cftype cft_release_agent = {
> > --
> > 1.6.5.3
> >
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
