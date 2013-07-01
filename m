Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5BBDD6B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 14:51:54 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id d10so4111288vea.38
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 11:51:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130701184503.GG17812@cmpxchg.org>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
 <20130701180101.GA5460@ac100> <20130701184503.GG17812@cmpxchg.org>
From: Aaron Staley <aaron@picloud.com>
Date: Mon, 1 Jul 2013 11:51:33 -0700
Message-ID: <CAMcjixaDnnn+b7-JRS-67KyQgWhc4NQHtfLxXvXOS9k34iJfcw@mail.gmail.com>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
 container are killed by OOM
Content-Type: multipart/alternative; boundary=047d7b3a8522d2110804e077b8ff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>, "containers@lists.linux-foundation.org" <containers@lists.linux-foundation.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--047d7b3a8522d2110804e077b8ff
Content-Type: text/plain; charset=ISO-8859-1

Hi Johannes,

It does appear to still be happening on Linux 3.8.  Does it remain an open
issue?

Regards,
Aaron


On Mon, Jul 1, 2013 at 11:45 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, Jul 01, 2013 at 01:01:01PM -0500, Serge Hallyn wrote:
> > Quoting Aaron Staley (aaron@picloud.com):
> > > This is better explained here:
> > >
> http://serverfault.com/questions/516074/why-are-applications-in-a-memory-limited-lxc-container-writing-large-files-to-di
> > > (The
> > > highest-voted answer believes this to be a kernel bug.)
> >
> > Hi,
> >
> > in irc it has been suggested that indeed the kernel should be slowing
> > down new page creates while waiting for old page cache entries to be
> > written out to disk, rather than ooming.
> >
> > With a 3.0.27-1-ac100 kernel, doing dd if=/dev/zero of=xxx bs=1M
> > count=100 is immediately killed.  In contrast, doing the same from a
> > 3.0.8 kernel did the right thing for me.  But I did reproduce your
> > experiment below on ec2 with the same result.
> >
> > So, cc:ing linux-mm in the hopes someone can tell us whether this
> > is expected behavior, known mis-behavior, or an unknown bug.
>
> It's a known issue that was fixed/improved in e62e384 'memcg: prevent
> OOM with too many dirty pages', included in 3.6+.
>
> > > Summary: I have set up a system where I am using LXC to create multiple
> > > virtualized containers on my system with limited resources.
> Unfortunately, I'm
> > > running into a troublesome scenario where the OOM killer is hard
> killing
> > > processes in my LXC container when I write a file with size exceeding
> the
> > > memory limitation (set to 300MB). There appears to be some issue with
> the
> > > file buffering respecting the containers memory limit.
> > >
> > >
> > > Reproducing:
> > >
> > > /done on a c1.xlarge instance running on Amazon EC2
> > >
> > > Create 6 empty lxc containers (in my case I did lxc-create -n testcon
> -t
> > > ubuntu -- -r precise)
> > >
> > > Modify the configuration of each container to set lxc.cgroup.memory.
> > > limit_in_bytes = 300M
> > >
> > > Within each container run:
> > > dd if=/dev/zero of=test2 bs=100k count=5010
> > > parallel
> > >
> > > This will with high probability activate the OOM (as seen in demsg);
> often
> > > the dd processes themselves will be killed.
> > >
> > > This has been verified to have problems on:
> > > Linux 3.8.0-25-generic #37-Ubuntu SMP and Linux ip-10-8-139-98
> > > 3.2.0-29-virtual #46-Ubuntu SMP Fri Jul 27 17:23:50 UTC 2012 x86_64
> x86_64
> > > x86_64 GNU/Linux
> > >
> > > Please let me know your thoughts.
> > >
> > > Regards,
> > > Aaron Staley
> > > _______________________________________________
> > > Containers mailing list
> > > Containers@lists.linux-foundation.org
> > > https://lists.linuxfoundation.org/mailman/listinfo/containers
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Aaron Staley
*PiCloud, Inc.*

--047d7b3a8522d2110804e077b8ff
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Johannes,<div><br></div><div>It does appear to still be=
 happening on Linux 3.8. =A0Does it remain an open issue?</div><div><br></d=
iv><div>Regards,</div><div>Aaron</div></div><div class=3D"gmail_extra"><br>=
<br>

<div class=3D"gmail_quote">On Mon, Jul 1, 2013 at 11:45 AM, Johannes Weiner=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_bla=
nk">hannes@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">

<div class=3D"im">On Mon, Jul 01, 2013 at 01:01:01PM -0500, Serge Hallyn wr=
ote:<br>
&gt; Quoting Aaron Staley (<a href=3D"mailto:aaron@picloud.com">aaron@piclo=
ud.com</a>):<br>
&gt; &gt; This is better explained here:<br>
&gt; &gt; <a href=3D"http://serverfault.com/questions/516074/why-are-applic=
ations-in-a-memory-limited-lxc-container-writing-large-files-to-di" target=
=3D"_blank">http://serverfault.com/questions/516074/why-are-applications-in=
-a-memory-limited-lxc-container-writing-large-files-to-di</a><br>


&gt; &gt; (The<br>
&gt; &gt; highest-voted answer believes this to be a kernel bug.)<br>
&gt;<br>
&gt; Hi,<br>
&gt;<br>
&gt; in irc it has been suggested that indeed the kernel should be slowing<=
br>
&gt; down new page creates while waiting for old page cache entries to be<b=
r>
&gt; written out to disk, rather than ooming.<br>
&gt;<br>
&gt; With a 3.0.27-1-ac100 kernel, doing dd if=3D/dev/zero of=3Dxxx bs=3D1M=
<br>
&gt; count=3D100 is immediately killed. =A0In contrast, doing the same from=
 a<br>
&gt; 3.0.8 kernel did the right thing for me. =A0But I did reproduce your<b=
r>
&gt; experiment below on ec2 with the same result.<br>
&gt;<br>
&gt; So, cc:ing linux-mm in the hopes someone can tell us whether this<br>
&gt; is expected behavior, known mis-behavior, or an unknown bug.<br>
<br>
</div>It&#39;s a known issue that was fixed/improved in e62e384 &#39;memcg:=
 prevent<br>
OOM with too many dirty pages&#39;, included in 3.6+.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; &gt; Summary: I have set up a system where I am using LXC to create mu=
ltiple<br>
&gt; &gt; virtualized containers on my system with limited resources. Unfor=
tunately, I&#39;m<br>
&gt; &gt; running into a troublesome scenario where the OOM killer is hard =
killing<br>
&gt; &gt; processes in my LXC container when I write a file with size excee=
ding the<br>
&gt; &gt; memory limitation (set to 300MB). There appears to be some issue =
with the<br>
&gt; &gt; file buffering respecting the containers memory limit.<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Reproducing:<br>
&gt; &gt;<br>
&gt; &gt; /done on a c1.xlarge instance running on Amazon EC2<br>
&gt; &gt;<br>
&gt; &gt; Create 6 empty lxc containers (in my case I did lxc-create -n tes=
tcon -t<br>
&gt; &gt; ubuntu -- -r precise)<br>
&gt; &gt;<br>
&gt; &gt; Modify the configuration of each container to set lxc.cgroup.memo=
ry.<br>
&gt; &gt; limit_in_bytes =3D 300M<br>
&gt; &gt;<br>
&gt; &gt; Within each container run:<br>
&gt; &gt; dd if=3D/dev/zero of=3Dtest2 bs=3D100k count=3D5010<br>
&gt; &gt; parallel<br>
&gt; &gt;<br>
&gt; &gt; This will with high probability activate the OOM (as seen in dems=
g); often<br>
&gt; &gt; the dd processes themselves will be killed.<br>
&gt; &gt;<br>
&gt; &gt; This has been verified to have problems on:<br>
&gt; &gt; Linux 3.8.0-25-generic #37-Ubuntu SMP and Linux ip-10-8-139-98<br=
>
&gt; &gt; 3.2.0-29-virtual #46-Ubuntu SMP Fri Jul 27 17:23:50 UTC 2012 x86_=
64 x86_64<br>
&gt; &gt; x86_64 GNU/Linux<br>
&gt; &gt;<br>
&gt; &gt; Please let me know your thoughts.<br>
&gt; &gt;<br>
&gt; &gt; Regards,<br>
&gt; &gt; Aaron Staley<br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; Containers mailing list<br>
&gt; &gt; <a href=3D"mailto:Containers@lists.linux-foundation.org">Containe=
rs@lists.linux-foundation.org</a><br>
&gt; &gt; <a href=3D"https://lists.linuxfoundation.org/mailman/listinfo/con=
tainers" target=3D"_blank">https://lists.linuxfoundation.org/mailman/listin=
fo/containers</a><br>
&gt;<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div>Aaron Staley</div><div><i>PiCloud, Inc.</i></div>
</div>

--047d7b3a8522d2110804e077b8ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
