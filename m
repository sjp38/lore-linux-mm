Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16A586B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 15:02:35 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id j2so1620852vki.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 12:02:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u190sor478768vkb.206.2017.11.01.12.02.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 12:02:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
References: <20171101053244.5218-1-slandden@gmail.com> <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
From: Shawn Landden <slandden@gmail.com>
Date: Wed, 1 Nov 2017 12:02:33 -0700
Message-ID: <CA+49okox_Hvg-dGyjZc3u0qLz1S=LJjS4-WT6SxQ9qfPyp6BjQ@mail.gmail.com>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
Content-Type: multipart/alternative; boundary="001a1143f7a89ec141055cf0838f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--001a1143f7a89ec141055cf0838f
Content-Type: text/plain; charset="UTF-8"

On Wed, Nov 1, 2017 at 8:16 AM, Colin Walters <walters@verbum.org> wrote:

>
>
> On Wed, Nov 1, 2017, at 01:32 AM, Shawn Landden wrote:
> > It is common for services to be stateless around their main event loop.
> > If a process passes the EPOLL_KILLME flag to epoll_wait5() then it
> > signals to the kernel that epoll_wait5() may not complete, and the kernel
> > may send SIGKILL if resources get tight.
> >
>
> I've thought about something like this in the past too and would love
> to see it land.  Bigger picture, this also comes up in (server) container
> environments, see e.g.:
>
> https://docs.openshift.com/container-platform/3.3/admin_
> guide/idling_applications.html
>
> There's going to be a long slog getting apps to actually make use
> of this, but I suspect if it gets wrapped up nicely in some "framework"
> libraries for C/C++, and be bound in the language ecosystems like golang
> we could see a fair amount of adoption on the order of a year or two.
>
> However, while I understand why it feels natural to tie this to epoll,
> as the maintainer of glib2 which is used by a *lot* of things; I'm not
> sure we're going to port to epoll anytime soon.
>
> Why not just make this a prctl()?  It's not like it's really any less racy
> to do:
>
> prctl(PR_SET_IDLE)
> epoll()
>
> and this also allows:
>
> prctl(PR_SET_IDLE)
> poll()
>
> And as this is most often just going to be an optional hint it's easier to
> e.g. just ignore EINVAL
> from the prctl().
>
This solves the fact that epoll_pwait() already is a 6 argument (maximum
allowed) syscall. But what if the process has multiple epoll() instances in
multiple threads?

--001a1143f7a89ec141055cf0838f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Wed, Nov 1, 2017 at 8:16 AM, Colin Walters <span dir=3D=
"ltr">&lt;<a href=3D"mailto:walters@verbum.org" target=3D"_blank">walters@v=
erbum.org</a>&gt;</span> wrote:<br><div class=3D"gmail_extra"><div class=3D=
"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex"><span class=3D""><br>
<br>
On Wed, Nov 1, 2017, at 01:32 AM, Shawn Landden wrote:<br>
&gt; It is common for services to be stateless around their main event loop=
.<br>
&gt; If a process passes the EPOLL_KILLME flag to epoll_wait5() then it<br>
&gt; signals to the kernel that epoll_wait5() may not complete, and the ker=
nel<br>
&gt; may send SIGKILL if resources get tight.<br>
&gt;<br>
<br>
</span>I&#39;ve thought about something like this in the past too and would=
 love<br>
to see it land.=C2=A0 Bigger picture, this also comes up in (server) contai=
ner<br>
environments, see e.g.:<br>
<br>
<a href=3D"https://docs.openshift.com/container-platform/3.3/admin_guide/id=
ling_applications.html" rel=3D"noreferrer" target=3D"_blank">https://docs.o=
penshift.com/<wbr>container-platform/3.3/admin_<wbr>guide/idling_applicatio=
ns.html</a><br>
<br>
There&#39;s going to be a long slog getting apps to actually make use<br>
of this, but I suspect if it gets wrapped up nicely in some &quot;framework=
&quot;<br>
libraries for C/C++, and be bound in the language ecosystems like golang<br=
>
we could see a fair amount of adoption on the order of a year or two.<br>
<br>
However, while I understand why it feels natural to tie this to epoll,<br>
as the maintainer of glib2 which is used by a *lot* of things; I&#39;m not<=
br>
sure we&#39;re going to port to epoll anytime soon.<br>
<br>
Why not just make this a prctl()?=C2=A0 It&#39;s not like it&#39;s really a=
ny less racy to do:<br>
<br>
prctl(PR_SET_IDLE)<br>
epoll()<br>
<br>
and this also allows:<br>
<br>
prctl(PR_SET_IDLE)<br>
poll()<br>
<br>
And as this is most often just going to be an optional hint it&#39;s easier=
 to e.g. just ignore EINVAL<br>
from the prctl().<br></blockquote><div>This solves the fact that epoll_pwai=
t() already is a 6 argument (maximum allowed) syscall. But what if the proc=
ess has multiple epoll() instances in multiple threads? <br></div></div><br=
></div></div>

--001a1143f7a89ec141055cf0838f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
