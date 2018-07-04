Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0B1E6B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 04:47:54 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id g11-v6so1403045uam.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 01:47:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q126-v6sor1012253vka.231.2018.07.04.01.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 01:47:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com> <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Wed, 4 Jul 2018 11:47:52 +0300
Message-ID: <CAHp75Ve1JcxyVWUJagO8Jmj32sfBAjZcPKuG-xvYKMs0b_uCqA@mail.gmail.com>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, guro@fb.com, yang.s@alibaba-inc.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Wind Yu <yuzhoujian@didichuxing.com>

On Wed, Jul 4, 2018 at 5:25 AM, =E7=A6=B9=E8=88=9F=E9=94=AE <ufo19890607@gm=
ail.com> wrote:
> Hi Andy
> The const char array need to be used by the new func
> mem_cgroup_print_oom_context and some funcs in oom_kill.c in the
> second patch.

Did I understand correctly that the array is added by you in this solely pa=
tch?
Did I understand correctly that it's used only in one module
(oom_kill.c in new version)?

If both are true, just move it to the C file.

If you need a synchronization, a) put a comment, b) create another
enum item (like FOO_BAR_MAX) at the end and use it in the array as a
fixed size,

>
> Thanks
>
>>
>> On Sat, Jun 30, 2018 at 7:38 PM,  <ufo19890607@gmail.com> wrote:
>> > From: yuzhoujian <yuzhoujian@didichuxing.com>
>> >
>> > The current system wide oom report prints information about the victim
>> > and the allocation context and restrictions. It, however, doesn't
>> > provide any information about memory cgroup the victim belongs to. Thi=
s
>> > information can be interesting for container users because they can fi=
nd
>> > the victim's container much more easily.
>> >
>> > I follow the advices of David Rientjes and Michal Hocko, and refactor
>> > part of the oom report. After this patch, users can get the memcg's
>> > path from the oom report and check the certain container more quickly.
>> >
>> > The oom print info after this patch:
>> > oom-kill:constraint=3D<constraint>,nodemask=3D<nodemask>,oom_memcg=3D<=
memcg>,task_memcg=3D<memcg>,task=3D<comm>,pid=3D<pid>,uid=3D<uid>
>>
>>
>> > +static const char * const oom_constraint_text[] =3D {
>> > +       [CONSTRAINT_NONE] =3D "CONSTRAINT_NONE",
>> > +       [CONSTRAINT_CPUSET] =3D "CONSTRAINT_CPUSET",
>> > +       [CONSTRAINT_MEMORY_POLICY] =3D "CONSTRAINT_MEMORY_POLICY",
>> > +       [CONSTRAINT_MEMCG] =3D "CONSTRAINT_MEMCG",
>> > +};
>>
>> I'm not sure why we have this in the header.
>>
>> This produces a lot of noise when W=3D1.
>>
>> In file included from
>> /home/andy/prj/linux-topic-mfld/include/linux/memcontrol.h:31:0,
>>                 from /home/andy/prj/linux-topic-mfld/include/net/sock.h:=
58,
>>                 from /home/andy/prj/linux-topic-mfld/include/linux/tcp.h=
:23,
>>                 from /home/andy/prj/linux-topic-mfld/include/linux/ipv6.=
h:87,
>>                 from /home/andy/prj/linux-topic-mfld/include/net/ipv6.h:=
16,
>>                 from
>> /home/andy/prj/linux-topic-mfld/net/ipv4/netfilter/nf_log_ipv4.c:17:
>> /home/andy/prj/linux-topic-mfld/include/linux/oom.h:32:27: warning:
>> =E2=80=98oom_constraint_text=E2=80=99 defined but not used [-W
>> unused-const-variable=3D]
>> static const char * const oom_constraint_text[] =3D {
>>                           ^~~~~~~~~~~~~~~~~~~
>>  CC [M]  net/ipv4/netfilter/iptable_nat.o
>>
>>
>> If you need (but looking at the code you actually don't if I didn't
>> miss anything) it in several places, just export.
>> Otherwise put it back to memcontrol.c.
>>
>> --
>> With Best Regards,
>> Andy Shevchenko



--=20
With Best Regards,
Andy Shevchenko
