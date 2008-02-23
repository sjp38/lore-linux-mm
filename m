Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m1NFMcAo017445
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 07:22:38 -0800
Received: from py-out-1112.google.com (pyhf31.prod.google.com [10.34.233.31])
	by zps19.corp.google.com with ESMTP id m1NFMbOM021331
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 07:22:38 -0800
Received: by py-out-1112.google.com with SMTP id f31so862740pyh.19
        for <linux-mm@kvack.org>; Sat, 23 Feb 2008 07:22:37 -0800 (PST)
Message-ID: <6599ad830802230722u573ca4d6n46c4fce3cdcc149d@mail.gmail.com>
Date: Sat, 23 Feb 2008 07:22:37 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/2] cgroup map files: Add cgroup map data type
In-Reply-To: <20080223000419.d446ac74.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080221212854.408662000@menage.corp.google.com>
	 <20080221213444.898896000@menage.corp.google.com>
	 <20080223000419.d446ac74.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, yamamoto@valinux.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2008 at 12:04 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>  > +static int cgroup_map_add(struct cgroup_map_cb *cb, const char *key, u64 value)
>  > +{
>  > +     struct seq_file *sf = cb->state;
>  > +     return seq_printf(sf, "%s %llu\n", key, value);
>  > +}
>
>  We don't know what type the architecture uses to implement u64.  This will
>  warn on powerpc, sparc64, maybe others.

OK, I'll add an (unsigned long long) cast.

>
>
>  > +static int cgroup_seqfile_show(struct seq_file *m, void *arg)
>  > +{
>  > +     struct cgroup_seqfile_state *state = m->private;
>  > +     struct cftype *cft = state->cft;
>  > +     if (cft->read_map) {
>  > +             struct cgroup_map_cb cb = {
>  > +                     .fill = cgroup_map_add,
>  > +                     .state = m,
>  > +             };
>  > +             return cft->read_map(state->cgroup, cft, &cb);
>  > +     } else {
>  > +             BUG();
>
>  That's not really needed.  Just call cft->read_map unconditionally.  if
>  it's zero we'll get a null-pointer deref which will have just the same
>  effect as a BUG.

OK. The long-term plan is to have other kinds of files also handled by
this function, so eventually it would look something like:

if (cft->read_map) {
...
} else if (cft->read_something_else) {
...
}
...
} else {
  BUG();
}

But I guess I can save that for the future.

>  >  static int cgroup_file_open(struct inode *inode, struct file *file)
>  >  {
>  >       int err;
>  > @@ -1499,7 +1539,18 @@ static int cgroup_file_open(struct inode
>  >       cft = __d_cft(file->f_dentry);
>  >       if (!cft)
>  >               return -ENODEV;
>  > -     if (cft->open)
>  > +     if (cft->read_map) {
>
>  But above a NULL value is illegal.  Why are we testing it here?
>
>

The existence of cft->read_map causes us to open a seq_file. Otherwise
we do nothing special and carry on down the normal open path.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
