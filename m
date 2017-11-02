Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28BC96B0069
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:36:17 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s9so2407421vka.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:36:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 106sor1052003uae.170.2017.11.02.00.36.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 00:36:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b98ae797-ce25-79bd-e405-35565256f673@I-love.SAKURA.ne.jp>
References: <20171101053244.5218-1-slandden@gmail.com> <b98ae797-ce25-79bd-e405-35565256f673@I-love.SAKURA.ne.jp>
From: Shawn Landden <slandden@gmail.com>
Date: Thu, 2 Nov 2017 00:36:15 -0700
Message-ID: <CA+49okrqFFyY+pPj83552wyP=nM=XBSNU-yZ+5nz5scYqA2Gew@mail.gmail.com>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
Content-Type: multipart/alternative; boundary="f403043c418416bffd055cfb0b1d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--f403043c418416bffd055cfb0b1d
Content-Type: text/plain; charset="UTF-8"

On Wed, Nov 1, 2017 at 3:10 PM, Tetsuo Handa <penguin-kernel@i-love.sakura.
ne.jp> wrote:

> On 2017/11/01 14:32, Shawn Landden wrote:
> > @@ -1029,6 +1030,22 @@ bool out_of_memory(struct oom_control *oc)
> >               return true;
> >       }
> >
> > +     /*
> > +      * Check death row.
> > +      */
> > +     if (!list_empty(eventpoll_deathrow_list())) {
> > +             struct list_head *l = eventpoll_deathrow_list();
>
> Unsafe traversal. List can become empty at this moment.
>
> > +             struct task_struct *ts = list_first_entry(l,
> > +                                      struct task_struct, se.deathrow);
> > +
> > +             pr_debug("Killing pid %u from EPOLL_KILLME death row.",
> > +                     ts->pid);
> > +
> > +             /* We use SIGKILL so as to cleanly interrupt ep_poll() */
> > +             kill_pid(task_pid(ts), SIGKILL, 1);
>
> send_sig() ?
>
> > +             return true;
> > +     }
> > +
> >       /*
> >        * The OOM killer does not compensate for IO-less reclaim.
> >        * pagefault_out_of_memory lost its gfp context so we have to
> >
>
> And why is
>
>   static int oom_fd = open("/proc/self/oom_score_adj", O_WRONLY);
>
> and then toggling between
>
>   write(fd, "1000", 4);
>
> and
>
>   write(fd, "0", 1);
>
> not sufficient? Adding prctl() that do this might be handy though.
>
I want to do special process accounting. Also, in Android using this type
of memory management is mandatory, and to do that other processes would
have to make delivery of their messages (like a wake-up for user input)
contingent on setting this. oom_score 1000 could gain all this special
handling however.

--f403043c418416bffd055cfb0b1d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Wed, Nov 1, 2017 at 3:10 PM, Tetsuo Handa <span dir=3D"=
ltr">&lt;<a href=3D"mailto:penguin-kernel@i-love.sakura.ne.jp" target=3D"_b=
lank">penguin-kernel@i-love.sakura.<wbr>ne.jp</a>&gt;</span> wrote:<br><div=
 class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex"><span>On 2017/11/01 14:32, Shawn Landden wrote:<br>
&gt; @@ -1029,6 +1030,22 @@ bool out_of_memory(struct oom_control *oc)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * Check death row.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!list_empty(eventpoll_deathro<wbr>w_list())) =
{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *l =
=3D eventpoll_deathrow_list();<br>
<br>
</span>Unsafe traversal. List can become empty at this moment.<br>
<span><br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *t=
s =3D list_first_entry(l,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct task=
_struct, se.deathrow);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_debug(&quot;Killin=
g pid %u from EPOLL_KILLME death row.&quot;,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0ts-&gt;pid);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We use SIGKILL so =
as to cleanly interrupt ep_poll() */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kill_pid(task_pid(ts)=
, SIGKILL, 1);<br>
<br>
</span>send_sig() ?<br>
<span><br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * The OOM killer does not compensate for IO=
-less reclaim.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * pagefault_out_of_memory lost its gfp cont=
ext so we have to<br>
&gt;<br>
<br>
</span>And why is<br>
<br>
=C2=A0 static int oom_fd =3D open(&quot;/proc/self/oom_score_adj<wbr>&quot;=
, O_WRONLY);<br>
<br>
and then toggling between<br>
<br>
=C2=A0 write(fd, &quot;1000&quot;, 4);<br>
<br>
and<br>
<br>
=C2=A0 write(fd, &quot;0&quot;, 1);<br>
<br>
not sufficient? Adding prctl() that do this might be handy though.<br></blo=
ckquote><div>I want to do special process accounting. Also, in Android usin=
g this type of memory management is mandatory, and to do that other process=
es would have to make delivery of their messages (like a wake-up for user i=
nput) contingent on setting this. oom_score 1000 could gain all this specia=
l handling however.<br></div></div><br></div></div>

--f403043c418416bffd055cfb0b1d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
