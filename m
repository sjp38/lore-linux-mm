Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5671C6B0071
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 14:53:06 -0500 (EST)
Received: by iwn9 with SMTP id 9so7922111iwn.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 11:53:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1011071753560.26056@swampdragon.chaosbits.net>
References: <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<20101028133036.GA30565@elte.hu>
	<20101028170132.GY27796@think>
	<alpine.LNX.2.00.1011050032440.16015@swampdragon.chaosbits.net>
	<alpine.LNX.2.00.1011050047220.16015@swampdragon.chaosbits.net>
	<20101105014334.GF13830@dastard>
	<alpine.LNX.2.00.1011071753560.26056@swampdragon.chaosbits.net>
Date: Tue, 9 Nov 2010 22:47:38 +0300
Message-ID: <AANLkTinZCBs_JO0Ug58uJdWEuqx=xzzBn2nJzdYr7+hb@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

I have almost same problem (system is less interactive, but no freeze happe=
ns).
Here are tests I use (written by Alexander Nekrasov):
logrotate.sh (hard writer): http://pastebin.com/PPnSvP2f
writetest (small writer): http://pastebin.com/616JvWEK

If you run "writetest 15 realtime" timings will be OK, but if you also
run "logrotate.sh 300 3" you will see that RT processes start trashing
(timings periodically increase from 50ms to 2000-4000ms).
I do tests on 2.6.31, but same happens on 2.6.36. CFQ with default
settings is used. I've played with page-background.c and noticed, that
writeback still works for RT processes (no write through/disk wait). I
even tried to increase dirty_ratio for RT processes. Also I've limited
memory consumed by dd (logrotate.sh), since I had situation when it
consumed too much and kernel started to reclaim pages.

It doesn't want to work on ext3 (compiled and mounted like Linus
suggested in this thread), but works fine on ext4 with
"data=3Dwriteback" and on XFS. I'm not sure if it means that problem in
ext3 and in journaling (in case of ext4 without data=3Dwriteback).
I'm not sure if "data=3Dwriteback" (makes ext4 journaling similar to
XFS) really fixes the problem, probably it increases FS bandwidth, so
we just don't see the problem, but it can still present.

On Sun, Nov 7, 2010 at 8:16 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Fri, 5 Nov 2010, Dave Chinner wrote:
>
>> On Fri, Nov 05, 2010 at 12:48:17AM +0100, Jesper Juhl wrote:
>> > On Fri, 5 Nov 2010, Jesper Juhl wrote:
>> >
>> > > On Thu, 28 Oct 2010, Chris Mason wrote:
>> > >
>> > > > On Thu, Oct 28, 2010 at 03:30:36PM +0200, Ingo Molnar wrote:
>> > > > >
>> > > > > "Many seconds freezes" and slowdowns wont be fixed via the VFS s=
calability patches
>> > > > > i'm afraid.
>> > > > >
>> > > > > This has the appearance of some really bad IO or VM latency prob=
lem. Unfixed and
>> > > > > present in stable kernel versions going from years ago all the w=
ay to v2.6.36.
>> > > >
>> > > > Hmmm, the workload you're describing here has two special parts. =
=A0First
>> > > > it dramatically overloads the disk, and then it has guis doing thi=
ngs
>> > > > waiting for the disk.
>> > > >
>> > >
>> > > Just want to chime in with a 'me too'.
>> > >
>> > > I see something similar on Arch Linux when doing 'pacman -Syyuv' and=
 there
>> > > are many (as in more than 5-10) updates to apply. While the update i=
s
>> > > running (even if that's all the system is doing) system responsivene=
ss is
>> > > terrible - just starting 'chromium' which is usually instant (at lea=
st
>> > > less than 2 sec at worst) can take upwards of 10 seconds and the mou=
se
>> > > cursor in X starts to jump a bit as well and switching virtual deskt=
ops
>> > > noticably lags when redrawing the new desktop if there's a full scre=
en app
>> > > like gimp or OpenOffice open there. This is on a Lenovo Thinkpad R61=
i
>> > > which has a 'Intel(R) Core(TM)2 Duo CPU T7250 @ 2.00GHz' CPU, 2GB of
>> > > memory and 499996 kilobytes of swap.
>> > >
>> > Forgot to mention the kernel I currently experience this with :
>> >
>> > [jj@dragon ~]$ uname -a
>> > Linux dragon 2.6.35-ARCH #1 SMP PREEMPT Sat Oct 30 21:22:26 CEST 2010 =
x86_64 Intel(R) Core(TM)2 Duo CPU T7250 @ 2.00GHz GenuineIntel GNU/Linux
>>
>> I think anyone reporting a interactivity problem also needs to
>> indicate what their filesystem is, what mount paramters they are
>> using, what their storage config is, whether barriers are active or
>> not, what elevator they are using, whether one or more of the
>> applications are issuing fsync() or sync() calls, and so on.
>>
> Some details below.
>
> [jj@dragon ~]$ mount
> proc on /proc type proc (rw,relatime)
> sys on /sys type sysfs (rw,relatime)
> udev on /dev type devtmpfs
> (rw,nosuid,relatime,size=3D10240k,nr_inodes=3D255749,mode=3D755)
> /dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad2765513e on / type ext4 (rw=
,commit=3D0)
> devpts on /dev/pts type devpts (rw)
> shm on /dev/shm type tmpfs (rw,nosuid,nodev)
>
> [root@dragon ~]# hdparm -v /dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad=
2765513e
>
> /dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad2765513e:
> =A0multcount =A0 =A0 =3D 16 (on)
> =A0IO_support =A0 =A0=3D =A01 (32-bit)
> =A0readonly =A0 =A0 =A0=3D =A00 (off)
> =A0readahead =A0 =A0 =3D 256 (on)
> =A0geometry =A0 =A0 =A0=3D 9729/255/63, sectors =3D 25220160, start =3D 1=
19644560
>
> [root@dragon ~]# dmesg | grep -i ext4
> EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
> EXT4-fs (sda4): re-mounted. Opts: (null)
> EXT4-fs (sda4): re-mounted. Opts: (null)
> EXT4-fs (sda4): re-mounted. Opts: commit=3D0
>
> The elevator in use is CFQ.
>
> The app that's causing the system to behave this way (the 'pacman' packag=
e
> manager in Arch Linux) makes a few calls (2-4) =A0to fsync() during its r=
un,
> but that's all.
>
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0 http://www.chaosbi=
ts.net/
> Plain text mails only, please =A0 =A0 =A0http://www.expita.com/nomime.htm=
l
> Don't top-post =A0http://www.catb.org/~esr/jargon/html/T/top-post.html
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
