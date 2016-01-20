Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDE16B0009
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 18:07:27 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id q21so36420409iod.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:07:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160120214546.GX6033@dastard>
References: <20160112022548.GD6033@dastard>
	<CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
	<20160112033708.GE6033@dastard>
	<CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
	<CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
	<20160115202131.GH6330@kvack.org>
	<CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
	<20160120195957.GV6033@dastard>
	<CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
	<20160120204449.GC12249@kvack.org>
	<20160120214546.GX6033@dastard>
Date: Wed, 20 Jan 2016 15:07:26 -0800
Message-ID: <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=089e0112d074afd1c50529cc0c44
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Benjamin LaHaise <bcrl@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

--089e0112d074afd1c50529cc0c44
Content-Type: text/plain; charset=UTF-8

On Jan 20, 2016 1:46 PM, "Dave Chinner" <david@fromorbit.com> wrote:
> >
> > > That said, I also agree that it would be interesting to hear what the
> > > performance impact is for existing performance-sensitive users. Could
> > > we make that "aio_may_use_threads()" case be unconditional, making
> > > things simpler?
> >
> > Making it unconditional is a goal, but some work is required before that
> > can be the case.  The O_DIRECT issue is one such matter -- it requires
some
> > changes to the filesystems to ensure that they adhere to the
non-blocking
> > nature of the new interface (ie taking i_mutex is a Bad Thing that users
> > really do not want to be exposed to; if taking it blocks, the code
should
> > punt to a helper thread).
>
> Filesystems *must take locks* in the IO path.

I agree.

I also would prefer to make the aio code have as little interaction and
magic flags with the filesystem code as humanly possible.

I wonder if we could make the rough rule be that the only synchronous case
the aio code ever has is more or less entirely in the generic vfs caches?
IOW, could we possibly aim to make the rule be that if we call down to the
filesystem layer, we do that within a thread?

We could do things like that for the name loopkup for openat() too, where
we could handle the successful RCU loopkup synchronously, but then if we
fall out of RCU mode we'd do the thread.

    Linus

--089e0112d074afd1c50529cc0c44
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jan 20, 2016 1:46 PM, &quot;Dave Chinner&quot; &lt;<a href=3D"mailto:dav=
id@fromorbit.com">david@fromorbit.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; That said, I also agree that it would be interesting to hear=
 what the<br>
&gt; &gt; &gt; performance impact is for existing performance-sensitive use=
rs. Could<br>
&gt; &gt; &gt; we make that &quot;aio_may_use_threads()&quot; case be uncon=
ditional, making<br>
&gt; &gt; &gt; things simpler?<br>
&gt; &gt;<br>
&gt; &gt; Making it unconditional is a goal, but some work is required befo=
re that<br>
&gt; &gt; can be the case.=C2=A0 The O_DIRECT issue is one such matter -- i=
t requires some<br>
&gt; &gt; changes to the filesystems to ensure that they adhere to the non-=
blocking<br>
&gt; &gt; nature of the new interface (ie taking i_mutex is a Bad Thing tha=
t users<br>
&gt; &gt; really do not want to be exposed to; if taking it blocks, the cod=
e should<br>
&gt; &gt; punt to a helper thread).<br>
&gt;<br>
&gt; Filesystems *must take locks* in the IO path.</p>
<p dir=3D"ltr">I agree.</p>
<p dir=3D"ltr">I also would prefer to make the aio code have as little inte=
raction and magic flags with the filesystem code as humanly possible.</p>
<p dir=3D"ltr">I wonder if we could make the rough rule be that the only sy=
nchronous case the aio code ever has is more or less entirely in the generi=
c vfs caches? IOW, could we possibly aim to make the rule be that if we cal=
l down to the filesystem layer, we do that within a thread?</p>
<p dir=3D"ltr">We could do things like that for the name loopkup for openat=
() too, where we could handle the successful RCU loopkup synchronously, but=
 then if we fall out of RCU mode we&#39;d do the thread.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 Linus</p>

--089e0112d074afd1c50529cc0c44--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
