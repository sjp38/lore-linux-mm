Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E24B46B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 03:16:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H7Ge7I011485
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 16:16:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D4E45DE6F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:16:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B825045DD75
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:16:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF3EE18003
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:16:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A774CE18002
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:16:38 +0900 (JST)
Date: Thu, 17 Sep 2009 16:14:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3][mmotm] updateing size of kcore
Message-Id: <20090917161432.97e06050.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2375c9f90909162359m14ec7640m88ddd7ba54d6e793@mail.gmail.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	<1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	<20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	<20090917114509.a9eb9f2c.kamezawa.hiroyu@jp.fujitsu.com>
	<2375c9f90909162359m14ec7640m88ddd7ba54d6e793@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 14:59:35 +0800
AmA(C)rico Wang <xiyou.wangcong@gmail.com> wrote:

> On Thu, Sep 17, 2009 at 10:45 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > After memory hotplug (or other events in future), kcore size
> > can be modified.
> >
> > To update inode->i_size, we have to know inode/dentry but we
> > can't get it from inside /proc directly.
> > But considerinyg memory hotplug, kcore image is updated only when
> > it's opened. Then, updating inode->i_size at open() is enough.
> >
> > Cc: WANG Cong <xiyou.wangcong@gmail.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> This patch looks fine.
> 
> However, I am thinking if kcore is the only file under /proc whose size
> is changed dynamically? If no, that probably means we need to change
> generic proc code.
> 
I tried yesteray, and back to this ;)

One thing which makes me confused is that there is no way to get
inode or dentry from proc_dir_entry.

I tried to rewrite proc_getattr() for cheating "ls". But it just works for
"stat" and inode->i_size is used more widely. So, this implementation now.

But considering practically, inode->i_size itself is not meaningful in /proc
files even if it's correct. For example, /proc/vmstat or /proc/stat,
/proc/<pid>/maps... etc...

inode->i_size will be dynamically changed while reading. Now, most of users
know regular files under /proc is not a "real" file and handle them in proper
way. (programs can be used with pipe/stdin works well.)

I wonder /proc/kcore is a special one, which gdb/objdump/readelf may access.
Above 3 programs are for "usual" files and not considering pseudo files under
/proc. So, I think adding generic i->i_size support is an overkill until
there are users depends on that.

Thanks,
-Kame


> Thanks!
> 
> > ---
> > A fs/proc/kcore.c | A  A 5 +++++
> > A 1 file changed, 5 insertions(+)
> >
> > Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
> > ===================================================================
> > --- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
> > +++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
> > @@ -546,6 +546,11 @@ static int open_kcore(struct inode *inod
> > A  A  A  A  A  A  A  A return -EPERM;
> > A  A  A  A if (kcore_need_update)
> > A  A  A  A  A  A  A  A kcore_update_ram();
> > + A  A  A  if (i_size_read(inode) != proc_root_kcore->size) {
> > + A  A  A  A  A  A  A  mutex_lock(&inode->i_mutex);
> > + A  A  A  A  A  A  A  i_size_write(inode, proc_root_kcore->size);
> > + A  A  A  A  A  A  A  mutex_unlock(&inode->i_mutex);
> > + A  A  A  }
> > A  A  A  A return 0;
> > A }
> >
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
