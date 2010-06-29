Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A9C4D600227
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 01:31:29 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o5T5VQFi003975
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 22:31:26 -0700
Received: from vws3 (vws3.prod.google.com [10.241.21.131])
	by hpaq2.eem.corp.google.com with ESMTP id o5T5VN2a016932
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 22:31:25 -0700
Received: by vws3 with SMTP id 3so1431817vws.39
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 22:31:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
	<20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 28 Jun 2010 22:31:03 -0700
Message-ID: <AANLkTik3l5jZlxqmDkkHdEFle4MJFcKLh1kPVNrK6CyE@mail.gmail.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
	path
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 27, 2010 at 7:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 25 Jun 2010 13:43:45 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> For the upcoming Linux VM summit, I am interesting in discussing the
>> following proposal.
>>
>> Problem: When tasks from multiple cgroups share files the charging can b=
e
>> non-deterministic. =A0This requires that all such cgroups have unnecessa=
rily high
>> limits. =A0It would be nice if the charging was deterministic, using the=
 file's
>> path to determine which cgroup to charge. =A0This would benefit charging=
 of
>> commonly used files (eg: libc) as well as large databases shared by only=
 a few
>> tasks.
>>
>> Example: assume two tasks (T1 and T2), each in a separate cgroup. =A0Eac=
h task
>> wants to access a large (1GB) database file. =A0To catch memory leaks a =
tight
>> memory limit on each task's cgroup is set. =A0However, the large databas=
e file
>> presents a problem. =A0If the file has not been cached, then the first t=
ask to
>> access the file is charged, thereby requiring that task's cgroup to have=
 a limit
>> large enough to include the database file. =A0If the order of access is =
unknown
>> (due to process restart, etc), then all cgroups accessing the file need =
to have
>> a limit large enough to include the database. =A0This is wasteful becaus=
e the
>> database won't be charged to both T1 and T2. =A0It would be useful to in=
troduce
>> determinism by declaring that a particular cgroup is charged for a parti=
cular
>> set of files.
>>
>> /dev/cgroup/cg1/cg11 =A0# T1: want memory.limit =3D 30MB
>> /dev/cgroup/cg1/cg12 =A0# T2: want memory.limit =3D 100MB
>> /dev/cgroup/cg1 =A0 =A0 =A0 # want memory.limit =3D 1GB + 30MB + 100MB
>>
>> I have implemented a prototype that allows a file system hierarchy be ch=
arge a
>> particular cgroup using a new bind mount option:
>> + mount -t cgroup none /cgroup -o memory
>> + mount --bind /tmp/db /tmp/db -o cgroup=3D/dev/cgroup/cg1
>>
>> Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1. =A0=
Access to
>> other files behave normally - they charge the cgroup of the current task=
.
>>
>
> Interesting, but I want to use madvice() etc..for this kind of jobs, rath=
er than
> deep hooks into the kernel.
>
> madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);
>
> Then, you can write a command as:
>
> =A0file_recharge [path name] [cgroup]
> =A0- this commands move a file cache to specified cgroup.
>
> A daemon program which uses this command + inotify will give us much
> flexible controls on file cache on memcg. Do you have some requirements
> that this move-charge shouldn't be done in lazy manner ?
>
> Status:
> We have codes for move-charge, inotify but have no code for new madvise.
>
>
> Thanks,
> -Kame

This is an interesting approach.  I like the idea of minimizing kernel
changes.  I want to make sure I understand the idea using terms from
my above example.

1. The daemon establishes inotify() watches on /tmp/db and all sub
directories to catch any accesses.

2. If cg11(T1) is the first process to mmap a portion of a /tmp/db
file (pages_1) then cg11 will be charged.  T1 will not use madvise()
because cg11 does not want to be charged.  cg11 will be temporarily
charged for pages_1.

3. inotify() will inform the proposed daemon that T1 opened /tmp/db,
so the daemon will use file_recharge, which runs the following within
the cg1 cgroup:
- fd =3D open("/tmp/db/.../path_to_file")
- va =3D mmap(NULL, size=3Dstat(fd).st_size, fd)
- madvise(fd, va, st_size, MEMORY_RECHARGE_THIS_PAGES_TO_ME).  This
will move the charge of pages_1 from cg11 to cg1.

Did I state this correctly?

I am concerned that the follow-on step does not move the pages to cg1:
4. T1 then touches more /tmp/db pages (pages_2) using the same mmap.
This charges cg11.  I assume that inotify() would not notify the
daemon for this case because the file is still open.  So the pages
will not be moved to cg1.  Or are you suggesting that inotify()
enhanced to advertise charge events?

If the number of directories within /tmp/db is large, then inotify()
maybe expensive.  I don't think this is a problem.

Another worry I have is that if for some reason the daemon is started
after the job, or if the daemon crashes and is restarted, then files
may have been opened and charged to cg11 without the inotify being
setup.  The daemon would have problems finding the pages that were
charged to cg11 and need to be moved to cg1.  The daemon could scan
the open file table of T1, but any files that are no longer opened may
be charged to cg11 with no way for the daemon to find them.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
