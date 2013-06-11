Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 584A76B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 21:01:28 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id i7so5326906oag.30
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 18:01:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130611001747.GA16971@teo>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
	<20130610151258.GA14295@dhcp22.suse.cz>
	<20130611001747.GA16971@teo>
Date: Tue, 11 Jun 2013 10:01:27 +0900
Message-ID: <CAH9JG2W0Rx46yTyfe5ndCFTt8ghuuWPAKp9EcjHm21nJzoEvtg@mail.gmail.com>
Subject: Re: [PATCH] memcg: event control at vmpressure.
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: multipart/alternative; boundary=089e0149c800d520d704ded66fe5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org

--089e0149c800d520d704ded66fe5
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Jun 11, 2013 at 9:17 AM, Anton Vorontsov <anton@enomsg.org> wrote:

> On Mon, Jun 10, 2013 at 05:12:58PM +0200, Michal Hocko wrote:
> > > +           if (level >= ev->level && level != vmpr->current_level) {
> > >                     eventfd_signal(ev->efd, 1);
> > >                     signalled = true;
> > > +                   vmpr->current_level = level;
> >
> > This would mean that you send a signal for, say, VMPRESSURE_LOW, then
> > the reclaim finishes and two days later when you hit the reclaim again
> > you would simply miss the event, right?
> >
> > So, unless I am missing something, then this is plain wrong.
>
> Yup, in it current version, it is not acceptable. For example, sometimes
> we do want to see all the _LOW events, since _LOW level shows not just the
> level itself, but the activity (i.e. reclaiming process).
>
> There are a few ways to make both parties happy, though.
>
> If the app wants to implement the time-based throttling, then just close
> the fd and sleep for needed amount of time (or do not read from the
> eventfd -- kernel then will just increment the eventfd counter, so there
> won't be context switches at the least). Doing the time-based throttling
> in the kernel won't buy us much, I believe.
>
> Or, if you still want the "one-shot"/"edge-triggered" events (which might
> make perfect sense for medium and critical levels), then I'd propose to
> add some additional flag when you register the event, so that the old
> behaviour would be still available for those who need it. This approach I
> think is the best one.
>
> Ok we will prepare this way and resend it.

Thank you,
Kyungmin Park

--089e0149c800d520d704ded66fe5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Jun 11, 2013 at 9:17 AM, Anton V=
orontsov <span dir=3D"ltr">&lt;<a href=3D"mailto:anton@enomsg.org" target=
=3D"_blank">anton@enomsg.org</a>&gt;</span> wrote:<br><blockquote style=3D"=
margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-color:rgb(204,204,204=
);border-left-width:1px;border-left-style:solid" class=3D"gmail_quote">
<div class=3D"im">On Mon, Jun 10, 2013 at 05:12:58PM +0200, Michal Hocko wr=
ote:<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 if (level &gt;=3D ev-&gt;level &amp;&amp; l=
evel !=3D vmpr-&gt;current_level) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eventfd_signal(ev-&gt;efd=
, 1);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 signalled =3D true;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmpr-&gt;current_level =3D =
level;<br>
&gt;<br>
&gt; This would mean that you send a signal for, say, VMPRESSURE_LOW, then<=
br>
&gt; the reclaim finishes and two days later when you hit the reclaim again=
<br>
&gt; you would simply miss the event, right?<br>
&gt;<br>
&gt; So, unless I am missing something, then this is plain wrong.<br>
<br>
</div>Yup, in it current version, it is not acceptable. For example, someti=
mes<br>
we do want to see all the _LOW events, since _LOW level shows not just the<=
br>
level itself, but the activity (i.e. reclaiming process).<br>
<br>
There are a few ways to make both parties happy, though.<br>
<br>
If the app wants to implement the time-based throttling, then just close<br=
>
the fd and sleep for needed amount of time (or do not read from the<br>
eventfd -- kernel then will just increment the eventfd counter, so there<br=
>
won&#39;t be context switches at the least). Doing the time-based throttlin=
g<br>
in the kernel won&#39;t buy us much, I believe.<br>
<br>
Or, if you still want the &quot;one-shot&quot;/&quot;edge-triggered&quot; e=
vents (which might<br>
make perfect sense for medium and critical levels), then I&#39;d propose to=
<br>
add some additional flag when you register the event, so that the old<br>
behaviour would be still available for those who need it. This approach I<b=
r>
think is the best one.<br>
<br></blockquote><div>Ok we will prepare this way and=A0resend it.</div><di=
v>=A0</div><div>Thank you,</div><div>Kyungmin Park=A0</div></div>

--089e0149c800d520d704ded66fe5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
