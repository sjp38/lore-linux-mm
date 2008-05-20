Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m4KIknfG022181
	for <linux-mm@kvack.org>; Tue, 20 May 2008 19:46:49 +0100
Received: from an-out-0708.google.com (ancc34.prod.google.com [10.100.29.34])
	by zps37.corp.google.com with ESMTP id m4KIkmuZ025073
	for <linux-mm@kvack.org>; Tue, 20 May 2008 11:46:48 -0700
Received: by an-out-0708.google.com with SMTP id c34so717001anc.78
        for <linux-mm@kvack.org>; Tue, 20 May 2008 11:46:47 -0700 (PDT)
Message-ID: <6599ad830805201146g5a2a8928l6a2f5adc51b15f15@mail.gmail.com>
Date: Tue, 20 May 2008 11:46:46 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
In-Reply-To: <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 2:08 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Does anyone have a better idea ?

As a way of printing plain text files, it seems fine.

My concern is that it means that cgroups no longer has any idea about
the typing of the data being returned, which will make it harder to
integrate with a binary stats API. You'd end up having to have a
separate reporting method for the same data to use it. That's why the
"read_map" function specifically doesn't take a seq_file, but instead
takes a key/value callback abstraction, which currently maps into a
seq_file. For the binary stats API, we can use the same reporting
functions, and just map into the binary API output.

Maybe we can somehow combine the read_map() abstraction with the
seq_file's start/stop/next operations.

Paul

> ==
>
> Currently, cgroup's seq_file interface just supports single_open.
> This patch allows arbitrary seq_ops if passed.
>
> For example, "status per cpu, status per node" can be very big
> in general and they tend to use its own start/next/stop ops.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>
> ---
>  include/linux/cgroup.h |    9 +++++++++
>  kernel/cgroup.c        |   32 +++++++++++++++++++++++++++++---
>  2 files changed, 38 insertions(+), 3 deletions(-)
>
> Index: mm-2.6.26-rc2-mm1/include/linux/cgroup.h
> ===================================================================
> --- mm-2.6.26-rc2-mm1.orig/include/linux/cgroup.h
> +++ mm-2.6.26-rc2-mm1/include/linux/cgroup.h
> @@ -232,6 +232,11 @@ struct cftype {
>         */
>        int (*read_seq_string) (struct cgroup *cont, struct cftype *cft,
>                         struct seq_file *m);
> +       /*
> +        * If this is not NULL, read ops will use this instead of
> +        * single_open(). Useful for showing very large data.
> +        */
> +       struct seq_operations *seq_ops;
>
>        ssize_t (*write) (struct cgroup *cgrp, struct cftype *cft,
>                          struct file *file,
> @@ -285,6 +290,10 @@ int cgroup_path(const struct cgroup *cgr
>
>  int cgroup_task_count(const struct cgroup *cgrp);
>
> +
> +struct cgroup *cgroup_of_seqfile(struct seq_file *m);
> +struct cftype *cftype_of_seqfile(struct seq_file *m);
> +
>  /* Return true if the cgroup is a descendant of the current cgroup */
>  int cgroup_is_descendant(const struct cgroup *cgrp);
>
> Index: mm-2.6.26-rc2-mm1/kernel/cgroup.c
> ===================================================================
> --- mm-2.6.26-rc2-mm1.orig/kernel/cgroup.c
> +++ mm-2.6.26-rc2-mm1/kernel/cgroup.c
> @@ -1540,6 +1540,16 @@ struct cgroup_seqfile_state {
>        struct cgroup *cgroup;
>  };
>
> +struct cgroup *cgroup_of_seqfile(struct seq_file *m)
> +{
> +       return ((struct cgroup_seqfile_state *)m->private)->cgroup;
> +}
> +
> +struct cftype *cftype_of_seqfile(struct seq_file *m)
> +{
> +       return  ((struct cgroup_seqfile_state *)m->private)->cft;
> +}
> +
>  static int cgroup_map_add(struct cgroup_map_cb *cb, const char *key, u64 value)
>  {
>        struct seq_file *sf = cb->state;
> @@ -1563,8 +1573,14 @@ static int cgroup_seqfile_show(struct se
>  static int cgroup_seqfile_release(struct inode *inode, struct file *file)
>  {
>        struct seq_file *seq = file->private_data;
> +       struct cgroup_seqfile_state *state = seq->private;
> +       struct cftype *cft = state->cft;
> +
>        kfree(seq->private);
> -       return single_release(inode, file);
> +       if (!cft->seq_ops)
> +               return single_release(inode, file);
> +       else
> +               return seq_release(inode, file);
>  }
>
>  static struct file_operations cgroup_seqfile_operations = {
> @@ -1585,7 +1601,7 @@ static int cgroup_file_open(struct inode
>        cft = __d_cft(file->f_dentry);
>        if (!cft)
>                return -ENODEV;
> -       if (cft->read_map || cft->read_seq_string) {
> +       if (cft->read_map || cft->read_seq_string || cft->seq_ops) {
>                struct cgroup_seqfile_state *state =
>                        kzalloc(sizeof(*state), GFP_USER);
>                if (!state)
> @@ -1593,7 +1609,17 @@ static int cgroup_file_open(struct inode
>                state->cft = cft;
>                state->cgroup = __d_cgrp(file->f_dentry->d_parent);
>                file->f_op = &cgroup_seqfile_operations;
> -               err = single_open(file, cgroup_seqfile_show, state);
> +
> +               if (!cft->seq_ops)
> +                       err = single_open(file, cgroup_seqfile_show, state);
> +               else {
> +                       err = seq_open(file, cft->seq_ops);
> +                       if (!err) {
> +                               struct seq_file *sf;
> +                               sf = ((struct seq_file *)file->private_data);
> +                               sf->private = state;
> +                       }
> +               }
>                if (err < 0)
>                        kfree(state);
>        } else if (cft->open)
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
