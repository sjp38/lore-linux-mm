Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB736B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:11:19 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id s53so9067557ota.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:11:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor11861177otk.115.2018.11.13.09.11.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 09:11:17 -0800 (PST)
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com. [209.85.210.53])
        by smtp.gmail.com with ESMTPSA id m207sm1350625oig.2.2018.11.13.09.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 09:11:15 -0800 (PST)
Received: by mail-ot1-f53.google.com with SMTP id z33so11987729otz.11
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:11:00 -0800 (PST)
MIME-Version: 1.0
References: <d45addefdf05b84af96fb494d52b4ec4@natalenko.name>
In-Reply-To: <d45addefdf05b84af96fb494d52b4ec4@natalenko.name>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 20:10:16 +0300
Message-ID: <CAGqmi77Ok0usUt5gfyPMYx22FdgqntSrwiap7=DT81HZuvNm_Q@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleksandr@natalenko.name
Cc: linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 19:33, Oleks=
andr Natalenko <oleksandr@natalenko.name>:
>
> So,
>
> > =E2=80=A6snip=E2=80=A6
> > +static int ksm_seeker_thread(void *nothing)
> > +{
> > +     pid_t last_pid =3D 1;
> > +     pid_t curr_pid;
> > +     struct task_struct *task;
> > +
> > +     set_freezable();
> > +     set_user_nice(current, 5);
> > +
> > +     while (!kthread_should_stop()) {
> > +             wait_while_offlining();
> > +
> > +             try_to_freeze();
> > +
> > +             if (!ksm_mode_always()) {
> > +                     wait_event_freezable(ksm_seeker_thread_wait,
> > +                             ksm_mode_always() || kthread_should_stop(=
));
> > +                     continue;
> > +             }
> > +
> > +             /*
> > +              * import one task's vma per run
> > +              */
> > +             read_lock(&tasklist_lock);
> > +
> > +             /* Try always get next task */
> > +             for_each_process(task) {
> > +                     curr_pid =3D task_pid_nr(task);
> > +                     if (curr_pid =3D=3D last_pid) {
> > +                             task =3D next_task(task);
> > +                             break;
> > +                     }
> > +
> > +                     if (curr_pid > last_pid)
> > +                             break;
> > +             }
> > +
> > +             last_pid =3D task_pid_nr(task);
> > +             ksm_import_task_vma(task);
>
> This seems to be a bad idea. ksm_import_task_vma() may sleep with
> tasklist_lock being held. Thus, IIUC, you'll get this:

Yep, that one of the reason why i move code from ksmd thread, i'm not
fully understood how to properly fix that.
But i misunderstood problem symptoms.

> [ 1754.410322] BUG: scheduling while atomic: ksmd_seeker/50/0x00000002
> =E2=80=A6
> [ 1754.410444] Call Trace:
> [ 1754.410455]  dump_stack+0x5c/0x80
> [ 1754.410460]  __schedule_bug.cold.19+0x38/0x51
> [ 1754.410464]  __schedule+0x11dc/0x2080
> [ 1754.410483]  schedule+0x32/0xb0
> [ 1754.410487]  rwsem_down_write_failed+0x15d/0x240
> [ 1754.410496]  call_rwsem_down_write_failed+0x13/0x20
> [ 1754.410499]  down_write+0x20/0x30
> [ 1754.410502]  ksm_import_task_vma+0x22/0x70
> [ 1754.410505]  ksm_seeker_thread+0x134/0x1c0
> [ 1754.410512]  kthread+0x113/0x130
> [ 1754.410518]  ret_from_fork+0x35/0x40
>
> I think you may want to get a reference to task_struct before releasing
> tasklist_lock, and then put it after ksm_import_task_vma() does its job.

Maybe i misunderstood something, but currently i do exactly that.

> > +             read_unlock(&tasklist_lock);
> > +
> > +             schedule_timeout_interruptible(
> > +                     msecs_to_jiffies(ksm_thread_seeker_sleep_millisec=
s));
> > +     }
> > +     return 0;
> > +}
> > =E2=80=A6snip=E2=80=A6
>
> --
>    Oleksandr Natalenko (post-factum)


That's good that you got that in any way (because i can't reproduce current=
ly).

You mean try do something, like that right?

read_lock(&tasklist_lock);
  <get reference to task>
  task_lock(task);
read_unlock(&tasklist_lock);
    last_pid =3D task_pid_nr(task);
    ksm_import_task_vma(task);
  task_unlock(task);

Thanks!
