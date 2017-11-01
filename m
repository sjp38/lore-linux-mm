Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3581A6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 16:54:28 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id h142so1778883vkf.14
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:54:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor578854uab.43.2017.11.01.13.54.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 13:54:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509565071.2650718.1158454064.7E910622@webmail.messagingengine.com>
References: <20171101053244.5218-1-slandden@gmail.com> <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
 <CA+49okox_Hvg-dGyjZc3u0qLz1S=LJjS4-WT6SxQ9qfPyp6BjQ@mail.gmail.com> <1509565071.2650718.1158454064.7E910622@webmail.messagingengine.com>
From: Shawn Landden <slandden@gmail.com>
Date: Wed, 1 Nov 2017 13:54:26 -0700
Message-ID: <CA+49okp99s_X6Y8Vt-UuUtJvj5RZ83iK2Nw+F1Hx7sj5E==Nwg@mail.gmail.com>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
Content-Type: multipart/alternative; boundary="94eb2c191064c450f8055cf213e2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--94eb2c191064c450f8055cf213e2
Content-Type: text/plain; charset="UTF-8"

On Wed, Nov 1, 2017 at 12:37 PM, Colin Walters <walters@verbum.org> wrote:

> On Wed, Nov 1, 2017, at 03:02 PM, Shawn Landden wrote:
> >
> > This solves the fact that epoll_pwait() already is a 6 argument (maximum
> allowed) syscall. But what if the process has multiple epoll() instances in
> multiple threads?
>
> Well, that's a subset of the general question of - what is the interaction
> of this system call and threading?  It looks like you've prototyped this
> out in userspace with systemd, but from a quick glance at the current git,
> systemd's threading is limited doing sync()/fsync() and gethostbyname()
> async.
>
> But languages with a GC tend to at least use a background thread for that,
> and of course lots of modern userspace makes heavy use of multithreading
> (or variants like goroutines).
>
> A common pattern though is to have a "main thread" that acts as a control
> point and runs the mainloop (particularly for anything with a GUI).
>  That's
> going to be the thing calling prctl(SET_IDLE) - but I think its idle state
> should implicitly
> affect the whole process, since for a lot of apps those other threads are
> going to
> just be "background".
>
> It'd probably then be an error to use prctl(SET_IDLE) in more than one
> thread
> ever?  (Although that might break in golang due to the way goroutines can
> be migrated across threads)
>
> That'd probably be a good "generality test" - what would it take to have
> this system call be used for a simple golang webserver app that's e.g.
> socket activated by systemd, or a Kubernetes service?  Or another
> really interesting case would be qemu; make it easy to flag VMs as always
> having this state (most of my testing VMs are like this; it's OK if they
> get
> destroyed, I just reinitialize them from the gold state).
>
> Going back to threading - a tricky thing we should handle in general
> is when userspace libraries create threads that are unknown to the app;
> the "async gethostbyname()" is a good example.  To be conservative we'd
> likely need to "fail non-idle", but figure out some way tell the kernel
> for e.g. GC threads that they're still idle.
>
prctl() still seems like it wouldn't work with threads. How about
fnctl(F_SETFD, FD_KILLME) ?
Attached only to epoll fds would be my preference, but allowing it to be
attached to all fds would
allow poll() and select() to work.

--94eb2c191064c450f8055cf213e2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Wed, Nov 1, 2017 at 12:37 PM, Colin Walters <span dir=
=3D"ltr">&lt;<a href=3D"mailto:walters@verbum.org" target=3D"_blank">walter=
s@verbum.org</a>&gt;</span> wrote:<br><div class=3D"gmail_extra"><div class=
=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px =
0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><span cl=
ass=3D"gmail-">On Wed, Nov 1, 2017, at 03:02 PM, Shawn Landden wrote:<br>
&gt;<br>
&gt; This solves the fact that epoll_pwait() already is a 6 argument (maxim=
um allowed) syscall. But what if the process has multiple epoll() instances=
 in multiple threads?<br>
<br>
</span>Well, that&#39;s a subset of the general question of - what is the i=
nteraction<br>
of this system call and threading?=C2=A0 It looks like you&#39;ve prototype=
d this<br>
out in userspace with systemd, but from a quick glance at the current git,<=
br>
systemd&#39;s threading is limited doing sync()/fsync() and gethostbyname()=
 async.<br>
<br>
But languages with a GC tend to at least use a background thread for that,<=
br>
and of course lots of modern userspace makes heavy use of multithreading<br=
>
(or variants like goroutines).<br>
<br>
A common pattern though is to have a &quot;main thread&quot; that acts as a=
 control<br>
point and runs the mainloop (particularly for anything with a GUI).=C2=A0 =
=C2=A0That&#39;s<br>
going to be the thing calling prctl(SET_IDLE) - but I think its idle state =
should implicitly<br>
affect the whole process, since for a lot of apps those other threads are g=
oing to<br>
just be &quot;background&quot;.<br>
<br>
It&#39;d probably then be an error to use prctl(SET_IDLE) in more than one =
thread<br>
ever?=C2=A0 (Although that might break in golang due to the way goroutines =
can<br>
be migrated across threads)<br>
<br>
That&#39;d probably be a good &quot;generality test&quot; - what would it t=
ake to have<br>
this system call be used for a simple golang webserver app that&#39;s e.g.<=
br>
socket activated by systemd, or a Kubernetes service?=C2=A0 Or another<br>
really interesting case would be qemu; make it easy to flag VMs as always<b=
r>
having this state (most of my testing VMs are like this; it&#39;s OK if the=
y get<br>
destroyed, I just reinitialize them from the gold state).<br>
<br>
Going back to threading - a tricky thing we should handle in general<br>
is when userspace libraries create threads that are unknown to the app;<br>
the &quot;async gethostbyname()&quot; is a good example.=C2=A0 To be conser=
vative we&#39;d<br>
likely need to &quot;fail non-idle&quot;, but figure out some way tell the =
kernel<br>
for e.g. GC threads that they&#39;re still idle.<br>
</blockquote></div>prctl() still seems like it wouldn&#39;t work with threa=
ds. How about fnctl(F_SETFD, FD_KILLME) ?</div><div class=3D"gmail_extra">A=
ttached only to epoll fds would be my preference, but allowing it to be att=
ached to all fds would</div><div class=3D"gmail_extra">allow poll() and sel=
ect() to work.<br></div></div>

--94eb2c191064c450f8055cf213e2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
