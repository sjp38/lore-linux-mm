Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE0C6B00F0
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 18:16:17 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id xb12so1766891pbc.23
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 15:16:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id yl8si17578716pab.176.2013.11.11.15.16.14
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 15:16:16 -0800 (PST)
Received: by mail-we0-f169.google.com with SMTP id q58so5329885wes.28
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 15:16:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131109151639.GB14249@redhat.com>
References: <20131108184515.GA11555@redhat.com> <1383940173-16480-1-git-send-email-snanda@chromium.org>
 <20131109151639.GB14249@redhat.com>
From: Sameer Nanda <snanda@chromium.org>
Date: Mon, 11 Nov 2013 15:15:52 -0800
Message-ID: <CANMivWax_gbt8np_1CMGwZCAB2FR8so7-nimt01PDGy8DWasSA@mail.gmail.com>
Subject: Re: [PATCH v3] mm, oom: Fix race when selecting process to kill
Content-Type: multipart/alternative; boundary=f46d043be1b0006c2404eaeeebcb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, Luigi Semenzato <semenzato@google.com>, murzin.v@gmail.com, dserrg@gmail.com, "msb@chromium.org" <msb@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--f46d043be1b0006c2404eaeeebcb
Content-Type: text/plain; charset=UTF-8

On Sat, Nov 9, 2013 at 7:16 AM, Oleg Nesterov <oleg@redhat.com> wrote:

> On 11/08, Sameer Nanda wrote:
> >
> > @@ -413,12 +413,20 @@ void oom_kill_process(struct task_struct *p, gfp_t
> gfp_mask, int order,
> >                                             DEFAULT_RATELIMIT_BURST);
> > @@ -456,10 +463,18 @@ void oom_kill_process(struct task_struct *p, gfp_t
> gfp_mask, int order,
> >                       }
> >               }
> >       } while_each_thread(p, t);
> > -     read_unlock(&tasklist_lock);
> >
> >       rcu_read_lock();
> > +
> >       p = find_lock_task_mm(victim);
> > +
> > +     /*
> > +      * Since while_each_thread is currently not RCU safe, this unlock
> of
> > +      * tasklist_lock may need to be moved further down if any
> additional
> > +      * while_each_thread loops get added to this function.
> > +      */
> > +     read_unlock(&tasklist_lock);
>
> Well, ack... but with this change find_lock_task_mm() relies on tasklist,
> so it makes sense to move rcu_read_lock() down before for_each_process().
> Otherwise this looks confusing, but I won't insist.
>

Agreed that this looks a bit confusing.  I will respin the patch.


>
> Oleg.
>
>


-- 
Sameer

--f46d043be1b0006c2404eaeeebcb
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Sat, Nov 9, 2013 at 7:16 AM, Oleg Nesterov <span dir=3D"ltr">&lt=
;<a href=3D"mailto:oleg@redhat.com" target=3D"_blank" class=3D"cremed">oleg=
@redhat.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On 11/08, Sameer Nanda wro=
te:<br>
&gt;<br>
</div><div class=3D"im">&gt; @@ -413,12 +413,20 @@ void oom_kill_process(st=
ruct task_struct *p, gfp_t gfp_mask, int order,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 DEFAULT_RATELIMIT_BURST);<br>
</div><div class=3D"im">&gt; @@ -456,10 +463,18 @@ void oom_kill_process(st=
ruct task_struct *p, gfp_t gfp_mask, int order,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt; =C2=A0 =C2=A0 =C2=A0 } while_each_thread(p, t);<br>
&gt; - =C2=A0 =C2=A0 read_unlock(&amp;tasklist_lock);<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();<br>
&gt; +<br>
&gt; =C2=A0 =C2=A0 =C2=A0 p =3D find_lock_task_mm(victim);<br>
&gt; +<br>
&gt; + =C2=A0 =C2=A0 /*<br>
&gt; + =C2=A0 =C2=A0 =C2=A0* Since while_each_thread is currently not RCU s=
afe, this unlock of<br>
&gt; + =C2=A0 =C2=A0 =C2=A0* tasklist_lock may need to be moved further dow=
n if any additional<br>
&gt; + =C2=A0 =C2=A0 =C2=A0* while_each_thread loops get added to this func=
tion.<br>
&gt; + =C2=A0 =C2=A0 =C2=A0*/<br>
&gt; + =C2=A0 =C2=A0 read_unlock(&amp;tasklist_lock);<br>
<br>
</div>Well, ack... but with this change find_lock_task_mm() relies on taskl=
ist,<br>
so it makes sense to move rcu_read_lock() down before for_each_process().<b=
r>
Otherwise this looks confusing, but I won&#39;t insist.<br></blockquote><di=
v><br></div><div>Agreed that this looks a bit confusing. =C2=A0I will respi=
n the patch.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">


<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Oleg.<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r>Sameer
</div></div>

--f46d043be1b0006c2404eaeeebcb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
