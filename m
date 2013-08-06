Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F3EA46B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 23:26:35 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id oy10so4005383veb.34
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 20:26:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375632446-2581-4-git-send-email-tj@kernel.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
	<1375632446-2581-4-git-send-email-tj@kernel.org>
Date: Tue, 6 Aug 2013 08:56:34 +0530
Message-ID: <CAKTCnz=DdG6QD0yPJ1poRZk0NYrYHdkmabvCXY-AR2qC1GSzYA@mail.gmail.com>
Subject: Re: [PATCH 3/5] cgroup, memcg: move cgroup_event implementation to memcg
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Aug 4, 2013 at 9:37 PM, Tejun Heo <tj@kernel.org> wrote:
> cgroup_event is way over-designed and tries to build a generic
> flexible event mechanism into cgroup - fully customizable event
> specification for each user of the interface.  This is utterly
> unnecessary and overboard especially in the light of the planned
> unified hierarchy as there's gonna be single agent.  Simply generating

[off-topic] Has the unified hierarchy been agreed upon? I did not
follow that thread

> events at fixed points, or if that's too restrictive, configureable
> cadence or single set of configureable points should be enough.
>

Nit-pick: typo on the spelling of configurable

> Thankfully, memcg is the only user and gets to keep it.  Replacing it
> with something simpler on sane_behavior is strongly recommended.
>
> This patch moves cgroup_event and "cgroup.event_control"
> implementation to mm/memcontrol.c.  Clearing of events on cgroup
> destruction is moved from cgroup_destroy_locked() to
> mem_cgroup_css_offline(), which shouldn't make any noticeable
> difference.
>
> Note that "cgroup.event_control" will now exist only on the hierarchy
> with memcg attached to it.  While this change is visible to userland,
> it is unlikely to be noticeable as the file has never been meaningful
> outside memcg.
>

Tejun, I think the framework was designed to be flexible. Do you see
cgroup subsystems never using this?

> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Balbir Singh <bsingharora@gmail.com>
> ---
>  kernel/cgroup.c | 237 -------------------------------------------------------
>  mm/memcontrol.c | 238 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 238 insertions(+), 237 deletions(-)
>
...
> +/*
> + * cgroup_event represents events which userspace want to receive.
> + */
> +struct cgroup_event {
> +       /*
> +        * css which the event belongs to.
> +        */
> +       struct cgroup_subsys_state *css;
> +       /*
> +        * Control file which the event associated.
> +        */
> +       struct cftype *cft;
> +       /*
> +        * eventfd to signal userspace about the event.
> +        */
> +       struct eventfd_ctx *eventfd;
> +       /*
> +        * Each of these stored in a list by the cgroup.
> +        */
> +       struct list_head list;
> +       /*
> +        * All fields below needed to unregister event when
> +        * userspace closes eventfd.
> +        */
> +       poll_table pt;
> +       wait_queue_head_t *wqh;
> +       wait_queue_t wait;
> +       struct work_struct remove;
> +};
> +
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
>
> @@ -5926,6 +5956,194 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  }
>  #endif
>
> +/*
> + * Unregister event and free resources.
> + *
> + * Gets called from workqueue.
> + */
> +static void cgroup_event_remove(struct work_struct *work)
> +{
> +       struct cgroup_event *event = container_of(work, struct cgroup_event,
> +                       remove);
> +       struct cgroup_subsys_state *css = event->css;
> +       struct cgroup *cgrp = css->cgroup;
> +
> +       remove_wait_queue(event->wqh, &event->wait);
> +
> +       event->cft->unregister_event(css, event->cft, event->eventfd);
> +
> +       /* Notify userspace the event is going away. */
> +       eventfd_signal(event->eventfd, 1);
> +
> +       eventfd_ctx_put(event->eventfd);
> +       kfree(event);
> +       __cgroup_dput(cgrp);
> +}
> +
> +/*
> + * Gets called on POLLHUP on eventfd when user closes it.
> + *
> + * Called with wqh->lock held and interrupts disabled.
> + */
> +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> +               int sync, void *key)
> +{
> +       struct cgroup_event *event = container_of(wait,
> +                       struct cgroup_event, wait);
> +       struct cgroup *cgrp = event->css->cgroup;
> +       unsigned long flags = (unsigned long)key;
> +
> +       if (flags & POLLHUP) {
> +               /*
> +                * If the event has been detached at cgroup removal, we
> +                * can simply return knowing the other side will cleanup
> +                * for us.
> +                *
> +                * We can't race against event freeing since the other
> +                * side will require wqh->lock via remove_wait_queue(),
> +                * which we hold.
> +                */
> +               spin_lock(&cgrp->event_list_lock);
> +               if (!list_empty(&event->list)) {
> +                       list_del_init(&event->list);
> +                       /*
> +                        * We are in atomic context, but cgroup_event_remove()
> +                        * may sleep, so we have to call it in workqueue.
> +                        */
> +                       schedule_work(&event->remove);
> +               }
> +               spin_unlock(&cgrp->event_list_lock);
> +       }
> +
> +       return 0;
> +}
> +
> +static void cgroup_event_ptable_queue_proc(struct file *file,
> +               wait_queue_head_t *wqh, poll_table *pt)
> +{
> +       struct cgroup_event *event = container_of(pt,
> +                       struct cgroup_event, pt);
> +
> +       event->wqh = wqh;
> +       add_wait_queue(wqh, &event->wait);
> +}
> +
> +/*
> + * Parse input and register new memcg event handler.
> + *
> + * Input must be in format '<event_fd> <control_fd> <args>'.
> + * Interpretation of args is defined by control file implementation.
> + */
> +static int cgroup_write_event_control(struct cgroup_subsys_state *css,
> +                                     struct cftype *cft, const char *buffer)
> +{
> +       struct cgroup *cgrp = css->cgroup;
> +       struct cgroup_event *event;
> +       struct cgroup *cgrp_cfile;
> +       unsigned int efd, cfd;
> +       struct file *efile;
> +       struct file *cfile;
> +       char *endp;
> +       int ret;
> +

Can we assert that buffer is NOT NULL here?

> +       efd = simple_strtoul(buffer, &endp, 10);
> +       if (*endp != ' ')
> +               return -EINVAL;
> +       buffer = endp + 1;
> +
> +       cfd = simple_strtoul(buffer, &endp, 10);
> +       if ((*endp != ' ') && (*endp != '\0'))
> +               return -EINVAL;

Shouldn't we be using kstroull(), I thought the simple functions were
obsolete now.

> +       buffer = endp + 1;
> +
> +       event = kzalloc(sizeof(*event), GFP_KERNEL);
> +       if (!event)
> +               return -ENOMEM;
> +       event->css = css;
> +       INIT_LIST_HEAD(&event->list);
> +       init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
> +       init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
> +       INIT_WORK(&event->remove, cgroup_event_remove);
> +
> +       efile = eventfd_fget(efd);
> +       if (IS_ERR(efile)) {
> +               ret = PTR_ERR(efile);
> +               goto out_kfree;
> +       }
> +
> +       event->eventfd = eventfd_ctx_fileget(efile);
> +       if (IS_ERR(event->eventfd)) {
> +               ret = PTR_ERR(event->eventfd);
> +               goto out_put_efile;
> +       }
> +
> +       cfile = fget(cfd);
> +       if (!cfile) {
> +               ret = -EBADF;
> +               goto out_put_eventfd;
> +       }
> +
> +       /* the process need read permission on control file */
> +       /* AV: shouldn't we check that it's been opened for read instead? */
> +       ret = inode_permission(file_inode(cfile), MAY_READ);
> +       if (ret < 0)
> +               goto out_put_cfile;
> +
> +       cgrp_cfile = __cgroup_from_dentry(cfile->f_dentry, &event->cft);
> +       if (!cgrp_cfile) {
> +               ret = -EINVAL;
> +               goto out_put_cfile;
> +       }
> +
> +       /*
> +        * The file to be monitored must be in the same cgroup as
> +        * cgroup.event_control is.
> +        */
> +       if (cgrp_cfile != cgrp) {
> +               ret = -EINVAL;
> +               goto out_put_cfile;
> +       }
> +
> +       if (!event->cft->register_event || !event->cft->unregister_event) {
> +               ret = -EINVAL;
> +               goto out_put_cfile;
> +       }
> +
> +       ret = event->cft->register_event(css, event->cft,
> +                       event->eventfd, buffer);
> +       if (ret)
> +               goto out_put_cfile;
> +
> +       efile->f_op->poll(efile, &event->pt);
> +
> +       /*
> +        * Events should be removed after rmdir of cgroup directory, but before
> +        * destroying subsystem state objects. Let's take reference to cgroup
> +        * directory dentry to do that.
> +        */
> +       dget(cgrp->dentry);
> +
> +       spin_lock(&cgrp->event_list_lock);
> +       list_add(&event->list, &cgrp->event_list);
> +       spin_unlock(&cgrp->event_list_lock);
> +
> +       fput(cfile);
> +       fput(efile);
> +
> +       return 0;
> +
> +out_put_cfile:
> +       fput(cfile);
> +out_put_eventfd:
> +       eventfd_ctx_put(event->eventfd);
> +out_put_efile:
> +       fput(efile);
> +out_kfree:
> +       kfree(event);
> +
> +       return ret;
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>         {
>                 .name = "usage_in_bytes",
> @@ -5973,6 +6191,12 @@ static struct cftype mem_cgroup_files[] = {
>                 .read_u64 = mem_cgroup_hierarchy_read,
>         },
>         {
> +               .name = "cgroup.event_control",
> +               .write_string = cgroup_write_event_control,
> +               .flags = CFTYPE_NO_PREFIX,
> +               .mode = S_IWUGO,

So everyone has write permissions? I guess we don't want to break this

> +       },
> +       {
>                 .name = "swappiness",
>                 .read_u64 = mem_cgroup_swappiness_read,
>                 .write_u64 = mem_cgroup_swappiness_write,
> @@ -6305,6 +6529,20 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
>  static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  {
>         struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +       struct cgroup *cgrp = css->cgroup;

With the new refactoring, I presume css and cgroup always co-exist, so
css->cgroup cannot change.

> +       struct cgroup_event *event, *tmp;
> +
> +       /*
> +        * Unregister events and notify userspace.
> +        * Notify userspace about cgroup removing only after rmdir of cgroup
> +        * directory to avoid race between userspace and kernelspace.
> +        */
> +       spin_lock(&cgrp->event_list_lock);
> +       list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> +               list_del_init(&event->list);
> +               schedule_work(&event->remove);
> +       }
> +       spin_unlock(&cgrp->event_list_lock);
>
>         kmem_cgroup_css_offline(memcg);
>
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
