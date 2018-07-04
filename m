Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8293A6B0269
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:25:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id q192-v6so171598lfe.3
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:25:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i20-v6sor661380lfe.76.2018.07.03.19.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 19:25:42 -0700 (PDT)
MIME-Version: 1.0
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com> <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
In-Reply-To: <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Wed, 4 Jul 2018 10:25:30 +0800
Message-ID: <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andy.shevchenko@gmail.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Andy
The const char array need to be used by the new func
mem_cgroup_print_oom_context and some funcs in oom_kill.c in the
second patch.

Thanks

>
> On Sat, Jun 30, 2018 at 7:38 PM,  <ufo19890607@gmail.com> wrote:
> > From: yuzhoujian <yuzhoujian@didichuxing.com>
> >
> > The current system wide oom report prints information about the victim
> > and the allocation context and restrictions. It, however, doesn't
> > provide any information about memory cgroup the victim belongs to. This
> > information can be interesting for container users because they can fin=
d
> > the victim's container much more easily.
> >
> > I follow the advices of David Rientjes and Michal Hocko, and refactor
> > part of the oom report. After this patch, users can get the memcg's
> > path from the oom report and check the certain container more quickly.
> >
> > The oom print info after this patch:
> > oom-kill:constraint=3D<constraint>,nodemask=3D<nodemask>,oom_memcg=3D<m=
emcg>,task_memcg=3D<memcg>,task=3D<comm>,pid=3D<pid>,uid=3D<uid>
>
>
> > +static const char * const oom_constraint_text[] =3D {
> > +       [CONSTRAINT_NONE] =3D "CONSTRAINT_NONE",
> > +       [CONSTRAINT_CPUSET] =3D "CONSTRAINT_CPUSET",
> > +       [CONSTRAINT_MEMORY_POLICY] =3D "CONSTRAINT_MEMORY_POLICY",
> > +       [CONSTRAINT_MEMCG] =3D "CONSTRAINT_MEMCG",
> > +};
>
> I'm not sure why we have this in the header.
>
> This produces a lot of noise when W=3D1.
>
> In file included from
> /home/andy/prj/linux-topic-mfld/include/linux/memcontrol.h:31:0,
>                 from /home/andy/prj/linux-topic-mfld/include/net/sock.h:5=
8,
>                 from /home/andy/prj/linux-topic-mfld/include/linux/tcp.h:=
23,
>                 from /home/andy/prj/linux-topic-mfld/include/linux/ipv6.h=
:87,
>                 from /home/andy/prj/linux-topic-mfld/include/net/ipv6.h:1=
6,
>                 from
> /home/andy/prj/linux-topic-mfld/net/ipv4/netfilter/nf_log_ipv4.c:17:
> /home/andy/prj/linux-topic-mfld/include/linux/oom.h:32:27: warning:
> =E2=80=98oom_constraint_text=E2=80=99 defined but not used [-W
> unused-const-variable=3D]
> static const char * const oom_constraint_text[] =3D {
>                           ^~~~~~~~~~~~~~~~~~~
>  CC [M]  net/ipv4/netfilter/iptable_nat.o
>
>
> If you need (but looking at the code you actually don't if I didn't
> miss anything) it in several places, just export.
> Otherwise put it back to memcontrol.c.
>
> --
> With Best Regards,
> Andy Shevchenko
