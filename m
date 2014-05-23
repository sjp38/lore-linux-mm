Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 039226B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 05:46:20 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id r5so7798297qcx.35
        for <linux-mm@kvack.org>; Fri, 23 May 2014 02:46:20 -0700 (PDT)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id s5si2890293qas.87.2014.05.23.02.46.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 02:46:20 -0700 (PDT)
Received: by mail-qc0-f178.google.com with SMTP id l6so7589492qcy.37
        for <linux-mm@kvack.org>; Fri, 23 May 2014 02:46:20 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 May 2014 17:46:20 +0800
Message-ID: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com>
Subject: memory hot-add: the kernel can notify udev daemon before creating the
 sys file state?
From: DX Cui <rijcos@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c306680c8eea04fa0e1af4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c306680c8eea04fa0e1af4
Content-Type: text/plain; charset=UTF-8

Hi all,
I'm debugging a strange memory hotplug issue on CentOS
6.5(2.6.32-431.17.1.el6): when a chunk of memory is hot-added, it seems the
kernel *occasionally* can send a MEMORY ADD event to the udev daemon before
the kernel actually creates the sys file 'state'!
As a result, udev can't reliably make new memory online by this udev rule:
SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"

Please see the end of the mail for the strace log of udevd when I run udevd
manually:

When udevd gets a MEMORY ADD event for /sys/devices/system/memory/memory23,
it tries to write "online" to /sys/devices/system/memory/memory23/state,
but the file hasn't been created by the kernel yet. In this case, when I
manually check the file at once with ls, it has been created, and I can
manually echo online into it to make it online correctly.

Please note: this bad behavior of the kernel is only occasional, which may
imply there is a race condition somewhere?

BTW, it looks the issue does't exist in 3.10+ kernels. Is this a known
issue already fixed in new kernels?

I'm trying to dig into the code and I hope I can get some suggestions here.
Thanks!

-- DX

The strace log is:
1427  1400822167.053704 socket(PF_NETLINK, SOCK_DGRAM|SOCK_CLOEXEC, 15) = 5
...
1427  1400822372.247210 recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK,
pid=0, groups=00000001},
msg_iov(1)=[{"add@/devices/system/memory/memory23\0ACTION=add\0DEVPATH=/devices/system/memory/memory23\0SUBSYSTEM=memory\0SEQNUM=1358\0\0\0\0\0\0\0\0\0\0\0\0\\0\0\0\0\0\0\0"...,
8192}], msg_controllen=32, {cmsg_len=28, cmsg_level=SOL_SOCKET,
cmsg_type=SCM_CREDENTIALS{pid=0, uid=0, gid=0}}, msg_flags=0}, 0) = 116
1427  1400822372.247298 lseek(10, 0, SEEK_CUR) = 1332
1427  1400822372.247320 write(10,
"N\5\0\0\0\0\0\0\37\0/devices/system/memory/memory23", 41) = 41
1427  1400822372.247352 gettimeofday({1400822372, 247358}, NULL) = 0
1427  1400822372.247387 writev(2, [{"udevd[1427]: seq 1358 queued, 'add'
'memory'\n", 45}], 1) = 45
1427  1400822372.247428 sendto(3, "<30>May 23 06:19:32 udevd[1427]: seq
1358 queued, 'add' 'memory'\n", 65, MSG_NOSIGNAL, NULL, 0) = 65
1427  1400822372.247511 sendmsg(5, {msg_name(12)={sa_family=AF_NETLINK,
pid=-4139, groups=00000000},
msg_iov(2)=[{"udev-147\0\0\0\0\0\0\0\0\312\376\35\352
\0[\0\312\n\234<\0\0\0\0", 32},
{"UDEV_LOG=7\0ACTION=add\0DEVPATH=/devices/system/memory/memory23\0SUBSYSTEM=memory\0SEQNUM=1358\0",
91}], msg_controllen=0, msg_flags=0}, 0 <unfinished ...>
1456  1400822372.247568 <... ppoll resumed> ) = 1 ([{fd=11,
revents=POLLIN}])
1427  1400822372.247578 <... sendmsg resumed> ) = 123
1456  1400822372.247595 recvmsg(11,  <unfinished ...>
1427  1400822372.247602 gettimeofday( <unfinished ...>
1456  1400822372.247615 <... recvmsg resumed>
{msg_name(12)={sa_family=AF_NETLINK, pid=1427, groups=00000000},
msg_iov(1)=[{"udev-147\0\0\0\0\0\0\0\0\312\376\35\352
\0[\0\312\n\234<\0\0\0\0UDEV_LOG=7\0ACTION=add\0DEVPATH=/devices/system/memory/memory23\0SUBSYSTEM=memory\0SEQNUM=1358\0\0\0\0\0\0\0\\0\0\0\0\0"...,
8192}], msg_controllen=32, {cmsg_len=28, cmsg_level=SOL_SOCKET,
cmsg_type=SCM_CREDENTIALS{pid=1427, uid=0, gid=0}}, msg_flags=0}, 0) = 123
1427  1400822372.247658 <... gettimeofday resumed> {1400822372, 247610},
NULL) = 0
1456  1400822372.247688 gettimeofday( <unfinished ...>
1427  1400822372.247695 writev(2, [{"udevd[1427]: passed 123 bytes to
monitor 0x7f71f4c6a6c0\n", 56}], 1 <unfinished ...>
1456  1400822372.247715 <... gettimeofday resumed> {1400822372, 247706},
NULL) = 0
1427  1400822372.247722 <... writev resumed> ) = 56
1456  1400822372.247738 writev(2, [{"udevd-work[1456]: seq 1358 running\n",
35}], 1 <unfinished ...>
1427  1400822372.247750 sendto(3, "<30>May 23 06:19:32 udevd[1427]: passed
123 bytes to monitor 0x7f71f4c6a6c0\n", 76, MSG_NOSIGNAL, NULL, 0
<unfinished ...>1456  1400822372.247785 <... writev resumed> ) = 35
1427  1400822372.247792 <... sendto resumed> ) = 76
1456  1400822372.247805 sendto(3, "<30>May 23 06:19:32 udevd-work[1456]:
seq 1358 running\n", 55, MSG_NOSIGNAL, NULL, 0 <unfinished ...>
1427  1400822372.247816 poll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN},
{fd=6, events=POLLIN}, {fd=7, events=POLLIN}, {fd=8, events=POLLIN}], 5, -1
<unfinished ...>
1456  1400822372.247847 <... sendto resumed> ) = 55
1456  1400822372.247861 alarm(180)      = 0
1456  1400822372.247892 gettimeofday({1400822372, 247898}, NULL) = 0
1456  1400822372.247917 writev(2, [{"udevd-work[1456]: ATTR
'/sys/devices/system/memory/memory23/state' writing 'online'
/etc/udev/rules.d/100-balloons.rules:1\n", 123}], 1) = 123
1456  1400822372.247946 sendto(3, "<30>May 23 06:19:32 udevd-work[1456]:
ATTR '/sys/devices/system/memory/memory23/state' writing 'online'
/etc/udev/rules.d/100-balloons.rules:1\n", 143, MSG_NOSIGNAL, NULL, 0) = 143
1456  1400822372.247992 open("/sys/devices/system/memory/memory23/state",
O_WRONLY|O_CREAT|O_TRUNC, 0666) = -1 ENOENT (No such file or directory)

--001a11c306680c8eea04fa0e1af4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi all,<br></div><div>I&#39;m debugging a strange mem=
ory hotplug issue on CentOS 6.5(2.6.32-431.17.1.el6): when a chunk of memor=
y is hot-added, it seems the kernel *occasionally* can send a MEMORY ADD ev=
ent to the udev daemon before the kernel actually creates the sys file &#39=
;state&#39;!</div>

<div>As a result, udev can&#39;t reliably make new memory online by this ud=
ev rule:</div><div>SUBSYSTEM=3D=3D&quot;memory&quot;, ACTION=3D=3D&quot;add=
&quot;, ATTR{state}=3D&quot;online&quot;</div><div><br></div><div>Please se=
e the end of the mail for the strace log of udevd when I run udevd manually=
:</div>

<div><br></div><div>When udevd gets a MEMORY ADD event for /sys/devices/sys=
tem/memory/memory23, it tries to write &quot;online&quot; to /sys/devices/s=
ystem/memory/memory23/state, but the file hasn&#39;t been created by the ke=
rnel yet. In this case, when I manually check the file at once with ls, it =
has been created, and I can manually echo online into it to make it online =
correctly.</div>

<div><br></div><div>Please note: this bad behavior of the kernel is only oc=
casional, which may imply there is a race condition somewhere?=C2=A0</div><=
div><br></div><div>BTW, it looks the issue does&#39;t exist in 3.10+ kernel=
s. Is this a known issue already fixed in new kernels?</div>

<div><br></div><div>I&#39;m trying to dig into the code and I hope I can ge=
t some suggestions here. Thanks!</div><div><br></div><div>-- DX</div><div><=
br></div><div>The strace log is:</div><div>1427 =C2=A01400822167.053704 soc=
ket(PF_NETLINK, SOCK_DGRAM|SOCK_CLOEXEC, 15) =3D 5</div>

<div>...</div><div>1427 =C2=A01400822372.247210 recvmsg(5, {msg_name(12)=3D=
{sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000001}, msg_iov(1)=3D[{&quot;=
add@/devices/system/memory/memory23\0ACTION=3Dadd\0DEVPATH=3D/devices/syste=
m/memory/memory23\0SUBSYSTEM=3Dmemory\0SEQNUM=3D1358\0\0\0\0\0\0\0\0\0\0\0\=
0\\0\0\0\0\0\0\0&quot;..., 8192}], msg_controllen=3D32, {cmsg_len=3D28, cms=
g_level=3DSOL_SOCKET, cmsg_type=3DSCM_CREDENTIALS{pid=3D0, uid=3D0, gid=3D0=
}}, msg_flags=3D0}, 0) =3D 116</div>

<div>1427 =C2=A01400822372.247298 lseek(10, 0, SEEK_CUR) =3D 1332</div><div=
>1427 =C2=A01400822372.247320 write(10, &quot;N\5\0\0\0\0\0\0\37\0/devices/=
system/memory/memory23&quot;, 41) =3D 41</div><div>1427 =C2=A01400822372.24=
7352 gettimeofday({1400822372, 247358}, NULL) =3D 0</div>

<div>1427 =C2=A01400822372.247387 writev(2, [{&quot;udevd[1427]: seq 1358 q=
ueued, &#39;add&#39; &#39;memory&#39;\n&quot;, 45}], 1) =3D 45</div><div>14=
27 =C2=A01400822372.247428 sendto(3, &quot;&lt;30&gt;May 23 06:19:32 udevd[=
1427]: seq 1358 queued, &#39;add&#39; &#39;memory&#39;\n&quot;, 65, MSG_NOS=
IGNAL, NULL, 0) =3D 65</div>

<div>1427 =C2=A01400822372.247511 sendmsg(5, {msg_name(12)=3D{sa_family=3DA=
F_NETLINK, pid=3D-4139, groups=3D00000000}, msg_iov(2)=3D[{&quot;udev-147\0=
\0\0\0\0\0\0\0\312\376\35\352 \0[\0\312\n\234&lt;\0\0\0\0&quot;, 32}, {&quo=
t;UDEV_LOG=3D7\0ACTION=3Dadd\0DEVPATH=3D/devices/system/memory/memory23\0SU=
BSYSTEM=3Dmemory\0SEQNUM=3D1358\0&quot;, 91}], msg_controllen=3D0, msg_flag=
s=3D0}, 0 &lt;unfinished ...&gt;</div>

<div>1456 =C2=A01400822372.247568 &lt;... ppoll resumed&gt; ) =3D 1 ([{fd=
=3D11, revents=3DPOLLIN}])</div><div>1427 =C2=A01400822372.247578 &lt;... s=
endmsg resumed&gt; ) =3D 123</div><div>1456 =C2=A01400822372.247595 recvmsg=
(11, =C2=A0&lt;unfinished ...&gt;</div>

<div>1427 =C2=A01400822372.247602 gettimeofday( &lt;unfinished ...&gt;</div=
><div>1456 =C2=A01400822372.247615 &lt;... recvmsg resumed&gt; {msg_name(12=
)=3D{sa_family=3DAF_NETLINK, pid=3D1427, groups=3D00000000}, msg_iov(1)=3D[=
{&quot;udev-147\0\0\0\0\0\0\0\0\312\376\35\352 \0[\0\312\n\234&lt;\0\0\0\0U=
DEV_LOG=3D7\0ACTION=3Dadd\0DEVPATH=3D/devices/system/memory/memory23\0SUBSY=
STEM=3Dmemory\0SEQNUM=3D1358\0\0\0\0\0\0\0\\0\0\0\0\0&quot;..., 8192}], msg=
_controllen=3D32, {cmsg_len=3D28, cmsg_level=3DSOL_SOCKET, cmsg_type=3DSCM_=
CREDENTIALS{pid=3D1427, uid=3D0, gid=3D0}}, msg_flags=3D0}, 0) =3D 123</div=
>

<div>1427 =C2=A01400822372.247658 &lt;... gettimeofday resumed&gt; {1400822=
372, 247610}, NULL) =3D 0</div><div>1456 =C2=A01400822372.247688 gettimeofd=
ay( &lt;unfinished ...&gt;</div><div>1427 =C2=A01400822372.247695 writev(2,=
 [{&quot;udevd[1427]: passed 123 bytes to monitor 0x7f71f4c6a6c0\n&quot;, 5=
6}], 1 &lt;unfinished ...&gt;</div>

<div>1456 =C2=A01400822372.247715 &lt;... gettimeofday resumed&gt; {1400822=
372, 247706}, NULL) =3D 0</div><div>1427 =C2=A01400822372.247722 &lt;... wr=
itev resumed&gt; ) =3D 56</div><div>1456 =C2=A01400822372.247738 writev(2, =
[{&quot;udevd-work[1456]: seq 1358 running\n&quot;, 35}], 1 &lt;unfinished =
...&gt;</div>

<div>1427 =C2=A01400822372.247750 sendto(3, &quot;&lt;30&gt;May 23 06:19:32=
 udevd[1427]: passed 123 bytes to monitor 0x7f71f4c6a6c0\n&quot;, 76, MSG_N=
OSIGNAL, NULL, 0 &lt;unfinished ...&gt;1456 =C2=A01400822372.247785 &lt;...=
 writev resumed&gt; ) =3D 35</div>

<div>1427 =C2=A01400822372.247792 &lt;... sendto resumed&gt; ) =3D 76</div>=
<div>1456 =C2=A01400822372.247805 sendto(3, &quot;&lt;30&gt;May 23 06:19:32=
 udevd-work[1456]: seq 1358 running\n&quot;, 55, MSG_NOSIGNAL, NULL, 0 &lt;=
unfinished ...&gt;</div>

<div>1427 =C2=A01400822372.247816 poll([{fd=3D4, events=3DPOLLIN}, {fd=3D5,=
 events=3DPOLLIN}, {fd=3D6, events=3DPOLLIN}, {fd=3D7, events=3DPOLLIN}, {f=
d=3D8, events=3DPOLLIN}], 5, -1 &lt;unfinished ...&gt;</div><div>1456 =C2=
=A01400822372.247847 &lt;... sendto resumed&gt; ) =3D 55</div>

<div>1456 =C2=A01400822372.247861 alarm(180) =C2=A0 =C2=A0 =C2=A0=3D 0</div=
><div>1456 =C2=A01400822372.247892 gettimeofday({1400822372, 247898}, NULL)=
 =3D 0</div><div>1456 =C2=A01400822372.247917 writev(2, [{&quot;udevd-work[=
1456]: ATTR &#39;/sys/devices/system/memory/memory23/state&#39; writing &#3=
9;online&#39; /etc/udev/rules.d/100-balloons.rules:1\n&quot;, 123}], 1) =3D=
 123</div>

<div>1456 =C2=A01400822372.247946 sendto(3, &quot;&lt;30&gt;May 23 06:19:32=
 udevd-work[1456]: ATTR &#39;/sys/devices/system/memory/memory23/state&#39;=
 writing &#39;online&#39; /etc/udev/rules.d/100-balloons.rules:1\n&quot;, 1=
43, MSG_NOSIGNAL, NULL, 0) =3D 143</div>

<div>1456 =C2=A01400822372.247992 open(&quot;/sys/devices/system/memory/mem=
ory23/state&quot;, O_WRONLY|O_CREAT|O_TRUNC, 0666) =3D -1 ENOENT (No such f=
ile or directory)</div></div>

--001a11c306680c8eea04fa0e1af4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
