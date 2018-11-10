Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8669D6B078B
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 07:26:49 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id e124so1436061vsc.7
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 04:26:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71sor3521970vkq.57.2018.11.10.04.26.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 04:26:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181110032005.GA22238@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAG48ez0kQ4d566bXTFOYANDgii-stL-Qj-oyaBzvfxdV=PU-7g@mail.gmail.com> <20181110032005.GA22238@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Sat, 10 Nov 2018 04:26:46 -0800
Message-ID: <CAKOZuethC7+YrRyyGciUCfhSSa9cCcAFJ8g_qEw9uh3TBbyOcg@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: multipart/alternative; boundary="000000000000e74e36057a4e94da"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, "jreck@google.com" <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, "jlayton@kernel.org" <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, "Lei.Yang@windriver.com" <Lei.Yang@windriver.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "marcandre.lureau@redhat.com" <marcandre.lureau@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, "minchan@kernel.org" <minchan@kernel.org>, "shuah@kernel.org" <shuah@kernel.org>, "valdis.kletnieks@vt.edu" <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

--000000000000e74e36057a4e94da
Content-Type: text/plain; charset="UTF-8"

On Friday, November 9, 2018, Joel Fernandes <joel@joelfernandes.org> wrote:

> On Fri, Nov 09, 2018 at 10:19:03PM +0100, Jann Horn wrote:
> > On Fri, Nov 9, 2018 at 10:06 PM Jann Horn <jannh@google.com> wrote:
> > > On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
> > > <joel@joelfernandes.org> wrote:
> > > > Android uses ashmem for sharing memory regions. We are looking
> forward
> > > > to migrating all usecases of ashmem to memfd so that we can possibly
> > > > remove the ashmem driver in the future from staging while also
> > > > benefiting from using memfd and contributing to it. Note staging
> drivers
> > > > are also not ABI and generally can be removed at anytime.
> > > >
> > > > One of the main usecases Android has is the ability to create a
> region
> > > > and mmap it as writeable, then add protection against making any
> > > > "future" writes while keeping the existing already mmap'ed
> > > > writeable-region active.  This allows us to implement a usecase where
> > > > receivers of the shared memory buffer can get a read-only view, while
> > > > the sender continues to write to the buffer.
> > > > See CursorWindow documentation in Android for more details:
> > > > https://developer.android.com/reference/android/database/
> CursorWindow
> > > >
> > > > This usecase cannot be implemented with the existing F_SEAL_WRITE
> seal.
> > > > To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE
> seal
> > > > which prevents any future mmap and write syscalls from succeeding
> while
> > > > keeping the existing mmap active.
> > >
> > > Please CC linux-api@ on patches like this. If you had done that, I
> > > might have criticized your v1 patch instead of your v3 patch...
> > >
> > > > The following program shows the seal
> > > > working in action:
> > > [...]
> > > > Cc: jreck@google.com
> > > > Cc: john.stultz@linaro.org
> > > > Cc: tkjos@google.com
> > > > Cc: gregkh@linuxfoundation.org
> > > > Cc: hch@infradead.org
> > > > Reviewed-by: John Stultz <john.stultz@linaro.org>
> > > > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > > > ---
> > > [...]
> > > > diff --git a/mm/memfd.c b/mm/memfd.c
> > > > index 2bb5e257080e..5ba9804e9515 100644
> > > > --- a/mm/memfd.c
> > > > +++ b/mm/memfd.c
> > > [...]
> > > > @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file,
> unsigned int seals)
> > > >                 }
> > > >         }
> > > >
> > > > +       if ((seals & F_SEAL_FUTURE_WRITE) &&
> > > > +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
> > > > +               /*
> > > > +                * The FUTURE_WRITE seal also prevents growing and
> shrinking
> > > > +                * so we need them to be already set, or requested
> now.
> > > > +                */
> > > > +               int test_seals = (seals | *file_seals) &
> > > > +                                (F_SEAL_GROW | F_SEAL_SHRINK);
> > > > +
> > > > +               if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
> > > > +                       error = -EINVAL;
> > > > +                       goto unlock;
> > > > +               }
> > > > +
> > > > +               spin_lock(&file->f_lock);
> > > > +               file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> > > > +               spin_unlock(&file->f_lock);
> > > > +       }
> > >
> > > So you're fiddling around with the file, but not the inode? How are
> > > you preventing code like the following from re-opening the file as
> > > writable?
> > >
> > > $ cat memfd.c
> > > #define _GNU_SOURCE
> > > #include <unistd.h>
> > > #include <sys/syscall.h>
> > > #include <printf.h>
> > > #include <fcntl.h>
> > > #include <err.h>
> > > #include <stdio.h>
> > >
> > > int main(void) {
> > >   int fd = syscall(__NR_memfd_create, "testfd", 0);
> > >   if (fd == -1) err(1, "memfd");
> > >   char path[100];
> > >   sprintf(path, "/proc/self/fd/%d", fd);
> > >   int fd2 = open(path, O_RDWR);
> > >   if (fd2 == -1) err(1, "reopen");
> > >   printf("reopen successful: %d\n", fd2);
> > > }
> > > $ gcc -o memfd memfd.c
> > > $ ./memfd
> > > reopen successful: 4
> > > $
> > >
> > > That aside: I wonder whether a better API would be something that
> > > allows you to create a new readonly file descriptor, instead of
> > > fiddling with the writability of an existing fd.
> >
> > My favorite approach would be to forbid open() on memfds, hope that
> > nobody notices the tiny API break, and then add an ioctl for "reopen
> > this memfd with reduced permissions" - but that's just my personal
> > opinion.
>
> I did something along these lines and it fixes the issue, but I forbid open
> of memfd only when the F_SEAL_FUTURE_WRITE seal is in place. So then its
> not
> an ABI break because this is a brand new seal. That seems the least
> intrusive
> solution and it works. Do you mind testing it and I'll add your and
> Tested-by
> to the new fix? The patch is based on top of this series.
>

Please don't forbid reopens entirely. You're taking a feature that works
generally (reopens) and breaking it in one specific case (memfd write
sealed files). The open modes are available in .open in the struct file:
you can deny *only* opens for write instead of denying reopens generally.

--000000000000e74e36057a4e94da
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br>On Friday, November 9, 2018, Joel Fernandes &lt;<a href=3D"mailto:j=
oel@joelfernandes.org">joel@joelfernandes.org</a>&gt; wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">On Fri, Nov 09, 2018 at 10:19:03PM +0100, Jann Horn wro=
te:<br>
&gt; On Fri, Nov 9, 2018 at 10:06 PM Jann Horn &lt;<a href=3D"mailto:jannh@=
google.com">jannh@google.com</a>&gt; wrote:<br>
&gt; &gt; On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)<br>
&gt; &gt; &lt;<a href=3D"mailto:joel@joelfernandes.org">joel@joelfernandes.=
org</a>&gt; wrote:<br>
&gt; &gt; &gt; Android uses ashmem for sharing memory regions. We are looki=
ng forward<br>
&gt; &gt; &gt; to migrating all usecases of ashmem to memfd so that we can =
possibly<br>
&gt; &gt; &gt; remove the ashmem driver in the future from staging while al=
so<br>
&gt; &gt; &gt; benefiting from using memfd and contributing to it. Note sta=
ging drivers<br>
&gt; &gt; &gt; are also not ABI and generally can be removed at anytime.<br=
>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; One of the main usecases Android has is the ability to creat=
e a region<br>
&gt; &gt; &gt; and mmap it as writeable, then add protection against making=
 any<br>
&gt; &gt; &gt; &quot;future&quot; writes while keeping the existing already=
 mmap&#39;ed<br>
&gt; &gt; &gt; writeable-region active.=C2=A0 This allows us to implement a=
 usecase where<br>
&gt; &gt; &gt; receivers of the shared memory buffer can get a read-only vi=
ew, while<br>
&gt; &gt; &gt; the sender continues to write to the buffer.<br>
&gt; &gt; &gt; See CursorWindow documentation in Android for more details:<=
br>
&gt; &gt; &gt; <a href=3D"https://developer.android.com/reference/android/d=
atabase/CursorWindow" target=3D"_blank">https://developer.android.com/<wbr>=
reference/android/database/<wbr>CursorWindow</a><br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; This usecase cannot be implemented with the existing F_SEAL_=
WRITE seal.<br>
&gt; &gt; &gt; To support the usecase, this patch adds a new F_SEAL_FUTURE_=
WRITE seal<br>
&gt; &gt; &gt; which prevents any future mmap and write syscalls from succe=
eding while<br>
&gt; &gt; &gt; keeping the existing mmap active.<br>
&gt; &gt;<br>
&gt; &gt; Please CC linux-api@ on patches like this. If you had done that, =
I<br>
&gt; &gt; might have criticized your v1 patch instead of your v3 patch...<b=
r>
&gt; &gt;<br>
&gt; &gt; &gt; The following program shows the seal<br>
&gt; &gt; &gt; working in action:<br>
&gt; &gt; [...]<br>
&gt; &gt; &gt; Cc: <a href=3D"mailto:jreck@google.com">jreck@google.com</a>=
<br>
&gt; &gt; &gt; Cc: <a href=3D"mailto:john.stultz@linaro.org">john.stultz@li=
naro.org</a><br>
&gt; &gt; &gt; Cc: <a href=3D"mailto:tkjos@google.com">tkjos@google.com</a>=
<br>
&gt; &gt; &gt; Cc: <a href=3D"mailto:gregkh@linuxfoundation.org">gregkh@lin=
uxfoundation.org</a><br>
&gt; &gt; &gt; Cc: <a href=3D"mailto:hch@infradead.org">hch@infradead.org</=
a><br>
&gt; &gt; &gt; Reviewed-by: John Stultz &lt;<a href=3D"mailto:john.stultz@l=
inaro.org">john.stultz@linaro.org</a>&gt;<br>
&gt; &gt; &gt; Signed-off-by: Joel Fernandes (Google) &lt;<a href=3D"mailto=
:joel@joelfernandes.org">joel@joelfernandes.org</a>&gt;<br>
&gt; &gt; &gt; ---<br>
&gt; &gt; [...]<br>
&gt; &gt; &gt; diff --git a/mm/memfd.c b/mm/memfd.c<br>
&gt; &gt; &gt; index 2bb5e257080e..5ba9804e9515 100644<br>
&gt; &gt; &gt; --- a/mm/memfd.c<br>
&gt; &gt; &gt; +++ b/mm/memfd.c<br>
&gt; &gt; [...]<br>
&gt; &gt; &gt; @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file =
*file, unsigned int seals)<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0}<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if ((seals &amp; F_SEAL_FUTURE_W=
RITE) &amp;&amp;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0!(*file_seals &amp=
; F_SEAL_FUTURE_WRITE)) {<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<b=
r>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * T=
he FUTURE_WRITE seal also prevents growing and shrinking<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * s=
o we need them to be already set, or requested now.<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<=
br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int =
test_seals =3D (seals | *file_seals) &amp;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (F_SEAL_GROW | F_SEAL_=
SHRINK);<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (=
test_seals !=3D (F_SEAL_GROW | F_SEAL_SHRINK)) {<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0error =3D -EINVAL;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0goto unlock;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br=
>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin=
_lock(&amp;file-&gt;f_lock);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0file=
-&gt;f_mode &amp;=3D ~(FMODE_WRITE | FMODE_PWRITE);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin=
_unlock(&amp;file-&gt;f_lock);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; So you&#39;re fiddling around with the file, but not the inode? H=
ow are<br>
&gt; &gt; you preventing code like the following from re-opening the file a=
s<br>
&gt; &gt; writable?<br>
&gt; &gt;<br>
&gt; &gt; $ cat memfd.c<br>
&gt; &gt; #define _GNU_SOURCE<br>
&gt; &gt; #include &lt;unistd.h&gt;<br>
&gt; &gt; #include &lt;sys/syscall.h&gt;<br>
&gt; &gt; #include &lt;printf.h&gt;<br>
&gt; &gt; #include &lt;fcntl.h&gt;<br>
&gt; &gt; #include &lt;err.h&gt;<br>
&gt; &gt; #include &lt;stdio.h&gt;<br>
&gt; &gt;<br>
&gt; &gt; int main(void) {<br>
&gt; &gt;=C2=A0 =C2=A0int fd =3D syscall(__NR_memfd_create, &quot;testfd&qu=
ot;, 0);<br>
&gt; &gt;=C2=A0 =C2=A0if (fd =3D=3D -1) err(1, &quot;memfd&quot;);<br>
&gt; &gt;=C2=A0 =C2=A0char path[100];<br>
&gt; &gt;=C2=A0 =C2=A0sprintf(path, &quot;/proc/self/fd/%d&quot;, fd);<br>
&gt; &gt;=C2=A0 =C2=A0int fd2 =3D open(path, O_RDWR);<br>
&gt; &gt;=C2=A0 =C2=A0if (fd2 =3D=3D -1) err(1, &quot;reopen&quot;);<br>
&gt; &gt;=C2=A0 =C2=A0printf(&quot;reopen successful: %d\n&quot;, fd2);<br>
&gt; &gt; }<br>
&gt; &gt; $ gcc -o memfd memfd.c<br>
&gt; &gt; $ ./memfd<br>
&gt; &gt; reopen successful: 4<br>
&gt; &gt; $<br>
&gt; &gt;<br>
&gt; &gt; That aside: I wonder whether a better API would be something that=
<br>
&gt; &gt; allows you to create a new readonly file descriptor, instead of<b=
r>
&gt; &gt; fiddling with the writability of an existing fd.<br>
&gt; <br>
&gt; My favorite approach would be to forbid open() on memfds, hope that<br=
>
&gt; nobody notices the tiny API break, and then add an ioctl for &quot;reo=
pen<br>
&gt; this memfd with reduced permissions&quot; - but that&#39;s just my per=
sonal<br>
&gt; opinion.<br>
<br>
I did something along these lines and it fixes the issue, but I forbid open=
<br>
of memfd only when the F_SEAL_FUTURE_WRITE seal is in place. So then its no=
t<br>
an ABI break because this is a brand new seal. That seems the least intrusi=
ve<br>
solution and it works. Do you mind testing it and I&#39;ll add your and Tes=
ted-by<br>
to the new fix? The patch is based on top of this series.<br>
</blockquote><div>=C2=A0</div><div>Please don&#39;t forbid reopens entirely=
. You&#39;re taking a feature that works generally (reopens) and breaking i=
t in one specific case (memfd write sealed files). The open modes are avail=
able in .open in the struct file: you can deny *only* opens for write inste=
ad of denying reopens generally.</div>

--000000000000e74e36057a4e94da--
