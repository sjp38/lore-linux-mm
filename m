Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7FF36B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 00:17:10 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o614H4Uu002281
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 21:17:05 -0700
Received: from vws3 (vws3.prod.google.com [10.241.21.131])
	by wpaz5.hot.corp.google.com with ESMTP id o614GYmv029833
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 21:17:03 -0700
Received: by vws3 with SMTP id 3so2293539vws.39
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 21:17:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100629153059.c49db3b6.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
	<20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTik3l5jZlxqmDkkHdEFle4MJFcKLh1kPVNrK6CyE@mail.gmail.com>
	<20100629153059.c49db3b6.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 30 Jun 2010 21:16:43 -0700
Message-ID: <AANLkTik1eArS38wVYmnTNDal1AmLbWmvDCTH2Uv_95Dm@mail.gmail.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
	path
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 28, 2010 at 11:30 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Jun 2010 22:31:03 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> On Sun, Jun 27, 2010 at 7:03 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Fri, 25 Jun 2010 13:43:45 -0700
>> > Greg Thelen <gthelen@google.com> wrote:
>
>> >> /dev/cgroup/cg1/cg11 =A0# T1: want memory.limit =3D 30MB
>> >> /dev/cgroup/cg1/cg12 =A0# T2: want memory.limit =3D 100MB
>> >> /dev/cgroup/cg1 =A0 =A0 =A0 # want memory.limit =3D 1GB + 30MB + 100M=
B
>> >>
>> >> I have implemented a prototype that allows a file system hierarchy be=
 charge a
>> >> particular cgroup using a new bind mount option:
>> >> + mount -t cgroup none /cgroup -o memory
>> >> + mount --bind /tmp/db /tmp/db -o cgroup=3D/dev/cgroup/cg1
>> >>
>> >> Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1. =
=A0Access to
>> >> other files behave normally - they charge the cgroup of the current t=
ask.
>> >>
>> >
>> > Interesting, but I want to use madvice() etc..for this kind of jobs, r=
ather than
>> > deep hooks into the kernel.
>> >
>> > madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);
>> >
>> > Then, you can write a command as:
>> >
>> > =A0file_recharge [path name] [cgroup]
>> > =A0- this commands move a file cache to specified cgroup.
>> >
>> > A daemon program which uses this command + inotify will give us much
>> > flexible controls on file cache on memcg. Do you have some requirement=
s
>> > that this move-charge shouldn't be done in lazy manner ?
>> >
>> > Status:
>> > We have codes for move-charge, inotify but have no code for new madvis=
e.
>> >
>> >
>> > Thanks,
>> > -Kame
>>
>> This is an interesting approach. =A0I like the idea of minimizing kernel
>> changes. =A0I want to make sure I understand the idea using terms from
>> my above example.
>>
>> 1. The daemon establishes inotify() watches on /tmp/db and all sub
>> directories to catch any accesses.
>>
>> 2. If cg11(T1) is the first process to mmap a portion of a /tmp/db
>> file (pages_1) then cg11 will be charged. =A0T1 will not use madvise()
>> because cg11 does not want to be charged. =A0cg11 will be temporarily
>> charged for pages_1.
>>
> yes.
>
>> 3. inotify() will inform the proposed daemon that T1 opened /tmp/db,
>> so the daemon will use file_recharge, which runs the following within
>> the cg1 cgroup:
>> - fd =3D open("/tmp/db/.../path_to_file")
>> - va =3D mmap(NULL, size=3Dstat(fd).st_size, fd)
>> - madvise(fd, va, st_size, MEMORY_RECHARGE_THIS_PAGES_TO_ME). =A0This
>> will move the charge of pages_1 from cg11 to cg1.
>>
>> Did I state this correctly?
>>
> yes.
>
>
>> I am concerned that the follow-on step does not move the pages to cg1:
>> 4. T1 then touches more /tmp/db pages (pages_2) using the same mmap.
>> This charges cg11. =A0I assume that inotify() would not notify the
>> daemon for this case because the file is still open.
> you're right.
>
>> So the pages will not be moved to cg1. =A0Or are you suggesting
>> that inotify() enhanced to advertise charge events?
>
> IIUC, now, inotify() doesn't support mmap. But it has read/write notifica=
tion.
> So, let's think about mmapped pages.
>
> For easy implementation, I suggest file_recharge should map the whole fil=
e
> and move them all under it. But maybe this is an answer you want.
>
> If I write an _easy_ daemon, which will do...
>
> =3D=3D
> =A0register inotify and add watches.
> =A0The wathces will see OPEN and IN_DELETE_SELF.
>
> =A0run 2 threads.
>
> Thread1:
> =A0while(1) {
> =A0 =A0 =A0read() // check events from inotify.
> =A0 =A0 =A0maintain opened-file information.
> =A0}
>
> Thread2:
> =A0while (1) {
> =A0 =A0 =A0check opend-file information.
> =A0 =A0 =A0select a file // you may implement some scheduling, here.
> =A0 =A0 =A0open,
> =A0 =A0 =A0mmap
> =A0 =A0 =A0mincore() .... checks the file is cached.
> =A0 =A0 =A0madvice()
> =A0 =A0 =A0// if you want, touch pages and add Access bit to them.
> =A0 =A0 =A0close(),
>
> =A0 =A0 =A0sleep if necessary.
> =A0}
> =3D=3D
> batch-style cron-job rather than sleep will not be very bad for usual use=
.
> But we may need some interface to implement something clever algorithm.

I have to collect some data about expected usages of this feature.  I
will have more information tomorrow.  Depending on the how quickly the
charges need to be corrected or the number of opened files, this
daemon may end up doing a lot of polling to correct memory charges.

>> If the number of directories within /tmp/db is large, then inotify()
>> maybe expensive. =A0I don't think this is a problem.
>>
>> Another worry I have is that if for some reason the daemon is started
>> after the job, or if the daemon crashes and is restarted, then files
>> may have been opened and charged to cg11 without the inotify being
>> setup.
> yes.
>
>> The daemon would have problems finding the pages that were
>> charged to cg11 and need to be moved to cg1. =A0The daemon could scan
>> the open file table of T1, but any files that are no longer opened may
>> be charged to cg11 with no way for the daemon to find them.
>>
>
> Above thread-1 can maintain "opened-file" database.
> Or you can run a recovery-scirpt to open /proc/<xxxx>/fd of processes
> to trigger OPEN events.

If a file has been unlinked, then the OPEN events would need to scan
/proc/xxx/fd to find an open file handle to open.  This is probably a
corner case, but I wanted to mention it.

> But yes, some in-kernel approach may be required. as...new interface to m=
emcg
> rather than madvise.
>
> /memory.move_file_caches
> - when you open this and write()/ioctl() file descriptor to this file,
> =A0all on-memory pages of files will be moved to this cgroup.

Are you suggesting that this move_file_caches interface would
associate the given file, dentry, or inode with the cgroup so that
future charges are charged to the intended cgroup?  Or (I suspect)
that the daemon would this need to be periodically use this routine to
correct any incorrect charges.

> Hmm...we may be able to add an interface to know last-pagecache-update ti=
me.
> (Because access-time is tend to be omitted at mount....)

Are you thinking that we could introduce a cgroup-wide attribute
(maybe a timestamp, or increasing sequence number, or even just a bit)
that would be set whenever a cgroup statistic (page cache usage in
this case) was updated?  This bit would be cleared whenever all needed
migrations occurred.  The daemon could poll this bit to know if any
migrations were needed.

Another aspect that I am thinking would have to be added to the daemon
would be oom handling.  If cg11 is charged for non-reclaimable files
(tmpfs) that belong to cg1, then the task may oom.  The daemon would
have to listen for oom and then immediately migration the charge from
cg11 to cg1 to lower memory pressure in cg11.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
