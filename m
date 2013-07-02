Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 436496B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 03:00:39 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z11so4280172wgg.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2013 00:00:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130701125345.c4a383c7b8345f9c5ae54023@linux-foundation.org>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
	<CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
	<51A71B49.3070003@cn.fujitsu.com>
	<CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
	<20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp>
	<CAJGZr0+9VUweN1Ssdq6P9Lug1GnTB3+RPv77JLRmnw=rpd9+Dw@mail.gmail.com>
	<51D0C500.4060108@jp.fujitsu.com>
	<CAJGZr0Jwy6OLADBO9GExWVbwG_LMk41ZsSMZKvWmwcA9StVZQA@mail.gmail.com>
	<20130701125345.c4a383c7b8345f9c5ae54023@linux-foundation.org>
Date: Tue, 2 Jul 2013 11:00:37 +0400
Message-ID: <CAJGZr0+vcPmG7e54caYm+FM3g4NibZgut8Gf8n73A3HE3HKw3g@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=f46d043bdf74fb9a1604e081e625
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, riel@redhat.com, kexec@lists.infradead.org, hughd@google.com, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, vgoyal@redhat.com, linux-mm@kvack.org, zhangyanfei@cn.fujitsu.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

--f46d043bdf74fb9a1604e081e625
Content-Type: text/plain; charset=ISO-8859-1

2013/7/1 Andrew Morton <akpm@linux-foundation.org>

> On Mon, 1 Jul 2013 18:34:43 +0400 Maxim Uvarov <muvarov@gmail.com> wrote:
>
> > 2013/7/1 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> >
> > > (2013/06/29 1:40), Maxim Uvarov wrote:
> > >
> > >> Did test on 1TB machine. Total vmcore capture and save took 143
> minutes
> > >> while vmcore size increased from 9Gb to 59Gb.
> > >>
> > >> Will do some debug for that.
> > >>
> > >> Maxim.
> > >>
> > >
> > > Please show me your kdump configuration file and tell me what you did
> in
> > > the test and how you confirmed the result.
> > >
> > >
> > Hello Hatayama,
> >
> > I re-run tests in dev env. I took your latest kernel patchset from
> > patchwork for vmcore + devel branch of makedumpfile + fix to open and
> write
> > to /dev/null. Run this test on 1Tb memory machine with memory used by
> some
> > user space processes. crashkernel=384M.
> >
> > Please see my results for makedumpfile process work:
> > [gzip compression]
> > -c -d31 /dev/null
> > real 37.8 m
> > user 29.51 m
> > sys 7.12 m
> >
> > [no compression]
> > -d31 /dev/null
> > real 27 m
> > user 23 m
> > sys   4 m
> >
> > [no compression, disable cyclic mode]
> > -d31 --non-cyclic /dev/null
> > real 26.25 m
> > user 23 m
> > sys 3.13 m
> >
> > [gzip compression]
> > -c -d31 /dev/null
> > % time     seconds  usecs/call     calls    errors syscall
> > ------ ----------- ----------- --------- --------- ----------------
> >  54.75   38.840351         110    352717           mmap
> >  44.55   31.607620          90    352716         1 munmap
> >   0.70    0.497668           0  25497667           brk
> >   0.00    0.000356           0    111920           write
> >   0.00    0.000280           0    111904           lseek
> >   0.00    0.000025           4         7           open
> >   0.00    0.000000           0       473           read
> >   0.00    0.000000           0         7           close
> >   0.00    0.000000           0         3           fstat
> >   0.00    0.000000           0         1           getpid
> >   0.00    0.000000           0         1           execve
> >   0.00    0.000000           0         1           uname
> >   0.00    0.000000           0         2           unlink
> >   0.00    0.000000           0         1           arch_prctl
> > ------ ----------- ----------- --------- --------- ----------------
> > 100.00   70.946300              26427420         1 total
> >
>
> I have no point of comparison here.  Is this performance good, or is
> the mmap-based approach still a lot more expensive?
>
>
> Compressing to non-mmap version improvement is 30 minutes against 130
minutes for total dump process. And kernel load is very minimal. So
definitely we need these patches.

-- 
Best regards,
Maxim Uvarov

--f46d043bdf74fb9a1604e081e625
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2013/7/1 Andrew Morton <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@li=
nux-foundation.org</a>&gt;</span><br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Mon, 1 Jul 2013 18:34:43 +0400 M=
axim Uvarov &lt;<a href=3D"mailto:muvarov@gmail.com">muvarov@gmail.com</a>&=
gt; wrote:<br>
<br>
&gt; 2013/7/1 HATAYAMA Daisuke &lt;<a href=3D"mailto:d.hatayama@jp.fujitsu.=
com">d.hatayama@jp.fujitsu.com</a>&gt;<br>
&gt;<br>
&gt; &gt; (2013/06/29 1:40), Maxim Uvarov wrote:<br>
&gt; &gt;<br>
&gt; &gt;&gt; Did test on 1TB machine. Total vmcore capture and save took 1=
43 minutes<br>
&gt; &gt;&gt; while vmcore size increased from 9Gb to 59Gb.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Will do some debug for that.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Maxim.<br>
&gt; &gt;&gt;<br>
&gt; &gt;<br>
&gt; &gt; Please show me your kdump configuration file and tell me what you=
 did in<br>
&gt; &gt; the test and how you confirmed the result.<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; Hello Hatayama,<br>
&gt;<br>
&gt; I re-run tests in dev env. I took your latest kernel patchset from<br>
&gt; patchwork for vmcore + devel branch of makedumpfile + fix to open and =
write<br>
&gt; to /dev/null. Run this test on 1Tb memory machine with memory used by =
some<br>
&gt; user space processes. crashkernel=3D384M.<br>
&gt;<br>
&gt; Please see my results for makedumpfile process work:<br>
&gt; [gzip compression]<br>
&gt; -c -d31 /dev/null<br>
&gt; real 37.8 m<br>
&gt; user 29.51 m<br>
&gt; sys 7.12 m<br>
&gt;<br>
&gt; [no compression]<br>
&gt; -d31 /dev/null<br>
&gt; real 27 m<br>
&gt; user 23 m<br>
&gt; sys =A0 4 m<br>
&gt;<br>
&gt; [no compression, disable cyclic mode]<br>
&gt; -d31 --non-cyclic /dev/null<br>
&gt; real 26.25 m<br>
&gt; user 23 m<br>
&gt; sys 3.13 m<br>
&gt;<br>
&gt; [gzip compression]<br>
&gt; -c -d31 /dev/null<br>
&gt; % time =A0 =A0 seconds =A0usecs/call =A0 =A0 calls =A0 =A0errors sysca=
ll<br>
&gt; ------ ----------- ----------- --------- --------- ----------------<br=
>
&gt; =A054.75 =A0 38.840351 =A0 =A0 =A0 =A0 110 =A0 =A0352717 =A0 =A0 =A0 =
=A0 =A0 mmap<br>
&gt; =A044.55 =A0 31.607620 =A0 =A0 =A0 =A0 =A090 =A0 =A0352716 =A0 =A0 =A0=
 =A0 1 munmap<br>
&gt; =A0 0.70 =A0 =A00.497668 =A0 =A0 =A0 =A0 =A0 0 =A025497667 =A0 =A0 =A0=
 =A0 =A0 brk<br>
&gt; =A0 0.00 =A0 =A00.000356 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0111920 =A0 =A0 =
=A0 =A0 =A0 write<br>
&gt; =A0 0.00 =A0 =A00.000280 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0111904 =A0 =A0 =
=A0 =A0 =A0 lseek<br>
&gt; =A0 0.00 =A0 =A00.000025 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 7 =A0 =
=A0 =A0 =A0 =A0 open<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 473 =A0 =A0=
 =A0 =A0 =A0 read<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 7 =A0 =
=A0 =A0 =A0 =A0 close<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 3 =A0 =
=A0 =A0 =A0 =A0 fstat<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 1 =A0 =
=A0 =A0 =A0 =A0 getpid<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 1 =A0 =
=A0 =A0 =A0 =A0 execve<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 1 =A0 =
=A0 =A0 =A0 =A0 uname<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 2 =A0 =
=A0 =A0 =A0 =A0 unlink<br>
&gt; =A0 0.00 =A0 =A00.000000 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 1 =A0 =
=A0 =A0 =A0 =A0 arch_prctl<br>
&gt; ------ ----------- ----------- --------- --------- ----------------<br=
>
&gt; 100.00 =A0 70.946300 =A0 =A0 =A0 =A0 =A0 =A0 =A026427420 =A0 =A0 =A0 =
=A0 1 total<br>
&gt;<br>
<br>
</div></div>I have no point of comparison here. =A0Is this performance good=
, or is<br>
the mmap-based approach still a lot more expensive?<br>
<br>
<br>
</blockquote></div>Compressing to non-mmap version improvement is 30 minute=
s against 130 minutes for total dump process. And kernel load is very minim=
al. So definitely we need these patches. <br><br>-- <br>Best regards,<br>
Maxim Uvarov

--f46d043bdf74fb9a1604e081e625--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
