Date: Wed, 30 Jan 2008 10:32:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] reject '\n' in a cgroup name
Message-Id: <20080130103215.ac42254e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830801272349p4b076ba5u8c491a92128fb1a9@mail.gmail.com>
References: <20080124052049.A2A8A1E3C0D@siro.lan>
	<6599ad830801272349p4b076ba5u8c491a92128fb1a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jan 2008 23:49:04 -0800
"Paul Menage" <menage@google.com> wrote:

> Looks sensible - maybe we should ban all characters not in [a-zA-Z0-9._-] ?
> 
Hmm, ' ' (white space) please.

but it seems that the cgroup rejects multibyte charactor names. 
(I myself don't like it but..)

So, please add a section for 'acceptable names for cgroup' to cgroup
documentation.

Thanks,
-Kame


> Paul
> 
> On Jan 23, 2008 9:20 PM, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> > hi,
> >
> > the following patch rejects '\n' in a cgroup name.
> > otherwise /proc/$$/cgroup is not parsable.
> >
> > example:
> >         imawoto% cat /proc/$$/cgroup
> >         memory:/
> >         imawoto% mkdir -p "
> >         memory:/foo"
> >         imawoto% echo $$ >| "
> >         memory:/foo/tasks"
> >         imawoto% cat /proc/$$/cgroup
> >         memory:/
> >         memory:/foo
> >         imawoto%
> >
> > YAMAMOTO Takashi
> >
> >
> > Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> > ---
> >
> > --- linux-2.6.24-rc8-mm1/kernel/cgroup.c.BACKUP 2008-01-23 14:43:29.000000000 +0900
> > +++ linux-2.6.24-rc8-mm1/kernel/cgroup.c        2008-01-24 13:56:28.000000000 +0900
> > @@ -2216,6 +2216,10 @@ static long cgroup_create(struct cgroup
> >         struct cgroup_subsys *ss;
> >         struct super_block *sb = root->sb;
> >
> > +       /* reject a newline.  otherwise /proc/$$/cgroup is not parsable. */
> > +       if (strchr(dentry->d_name.name, '\n'))
> > +               return -EINVAL;
> > +
> >         cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
> >         if (!cgrp)
> >                 return -ENOMEM;
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
