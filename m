Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id CFAC36B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:02:18 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so18869556qcv.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:02:17 -0800 (PST)
Received: from service88.mimecast.com (service88.mimecast.com. [195.130.217.12])
        by mx.google.com with ESMTP id z20si23243645qax.23.2015.01.12.09.02.16
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 09:02:16 -0800 (PST)
Date: Mon, 12 Jan 2015 17:02:11 +0000
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150112170210.GA1288@e106634-lin.cambridge.arm.com>
References: <54B01335.4060901@arm.com>
 <20150109214649.GF2785@htj.dyndns.org>
MIME-Version: 1.0
In-Reply-To: <20150109214649.GF2785@htj.dyndns.org>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, vdavydov@parallels.com, hannes@cmpxchg.org, Will.Deacon@arm.com, linux-mm@kvack.org, suzuki.poulose@arm.com

On Fri, Jan 09, 2015 at 09:46:49PM +0000, Tejun Heo wrote:
> On Fri, Jan 09, 2015 at 05:43:17PM +0000, Suzuki K. Poulose wrote:
> > We have hit a hang on ARM64 defconfig, while running LTP tests on 3.19-=
rc3.
> > We are
> > in the process of a git bisect and will update the results as and
> > when we find the commit.
> >
> > During the ksm ltp run, the test hangs trying to mount memcg with the
> > following strace
> > output:
> >
> > mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ? ERESTARTNOIN=
TR (To
> > be restarted)
> > mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D ? ERESTARTNOIN=
TR (To
> > be restarted)
> > [ ... repeated forever ... ]
> >
> > At this point, one can try mounting the memcg to verify the problem.
> > # mount -t cgroup -o memory memcg memcg_dir
> > --hangs--
> >
> > Strangely, if we run the mount command from a cold boot (i.e. without
> > running LTP first),
> > then it succeeds.
>
> I don't know what LTP is doing and this could actually be hitting on
> an actual bug but if it's trying to move memcg back from unified
> hierarchy to an old one, that might hang - it should prolly made to
> just fail at that point.  Anyways, any chance you can find out what
> happened, in terms of cgroup mounting, to memcg upto that point?
>

This is what the test(ksm03) does, roughly from strace :

faccessat(AT_FDCWD, "/sys/kernel/mm/ksm/", F_OK) =3D 0
faccessat(AT_FDCWD, "/sys/kernel/mm/ksm/merge_across_nodes", F_OK) =3D -1 E=
NOENT (No such file or directory)
mkdirat(AT_FDCWD, "/dev/cgroup", 0777)  =3D 0
mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") =3D 0

--- set memory limit. Create a new set /dev/cgroups/1 and moves test to tha=
t group ---
mkdirat(AT_FDCWD, "/dev/cgroup/1", 0777) =3D 0
openat(AT_FDCWD, "/dev/cgroup/1/memory.limit_in_bytes", O_WRONLY|O_CREAT|O_=
TRUNC, 0666) =3D 3
fstat(3, {st_dev=3Dmakedev(0, 24), st_ino=3D41, st_mode=3DS_IFREG|0644, st_=
nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0, st_siz=
e=3D0, st_atime=3D2015/01/12-15:10:13, st_mtime=3D2015/01/12-15:10:13, st_c=
time=3D2015/01/12-15:10:13}) =3D 0
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D 0x7fb2903000
write(3, "1073741824", 10)              =3D 10
close(3)                                =3D 0
munmap(0x7fb2903000, 65536)             =3D 0
getpid()                                =3D 1324
openat(AT_FDCWD, "/dev/cgroup/1/tasks", O_WRONLY|O_CREAT|O_TRUNC, 0666) =3D=
 3
fstat(3, {st_dev=3Dmakedev(0, 24), st_ino=3D37, st_mode=3DS_IFREG|0644, st_=
nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0, st_siz=
e=3D0, st_atime=3D2015/01/12-15:10:13, st_mtime=3D2015/01/12-15:10:13, st_c=
time=3D2015/01/12-15:10:13}) =3D 0
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D 0x7fb2903000
write(3, "1324", 4)                     =3D 4
close(3)                                =3D 0
munmap(0x7fb2903000, 65536)             =3D 0

clone(child_stack=3D0, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGC=
HLD, child_tidptr=3D0x7fb2a7f0d0) =3D 1325
clone(child_stack=3D0, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGC=
HLD, child_tidptr=3D0x7fb2a7f0d0) =3D 1326
clone(child_stack=3D0, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGC=
HLD, child_tidptr=3D0x7fb2a7f0d0) =3D 1327

--- Creates 3 children, perform a lot of memory operations with shared page=
s
    verify the ksm for activity and wait for children to exit ---

wait4(-1, [{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 0}], WSTOPPED|WCONTINUED,=
 NULL) =3D 1325
wait4(-1, [{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 0}], WSTOPPED|WCONTINUED,=
 NULL) =3D 1326
wait4(-1, [{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 0}], WSTOPPED|WCONTINUED,=
 NULL) =3D 1327
wait4(-1, 0x7fe5625f3c, WSTOPPED|WCONTINUED, NULL) =3D -1 ECHILD (No child =
processes)

--- cleanup: Move tasks under /dev/cgroups/1/ to /dev/cgroups/ and delete s=
ubdir, umount cgroup ---

faccessat(AT_FDCWD, "/sys/kernel/mm/ksm/merge_across_nodes", F_OK) =3D -1 E=
NOENT (No such file or directory)
openat(AT_FDCWD, "/dev/cgroup/tasks", O_WRONLY) =3D 205
openat(AT_FDCWD, "/dev/cgroup/1/tasks", O_RDONLY) =3D 206
fstat(206, {st_dev=3Dmakedev(0, 24), st_ino=3D37, st_mode=3DS_IFREG|0644, s=
t_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0, st_s=
ize=3D0, st_atime=3D2015/01/12-15:10:13, st_mtime=3D2015/01/12-15:10:13, st=
_ctime=3D2015/01/12-15:10:13}) =3D 0
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D 0x7fb1c53000
read(206, "1324\n", 4096)               =3D 5
write(205, "1324", 4)                   =3D 4
read(206, "", 4096)                     =3D 0
close(205)                              =3D 0
close(206)                              =3D 0
munmap(0x7fb1c53000, 65536)             =3D 0
unlinkat(AT_FDCWD, "/dev/cgroup/1", AT_REMOVEDIR) =3D 0
umount2("/dev/cgroup", 0)               =3D 0
unlinkat(AT_FDCWD, "/dev/cgroup", AT_REMOVEDIR) =3D 0
exit_group(0)                           =3D ?


The next invocation of the same test fails to mount the cgroup memory.

Thanks
Suzuki

> Thanks.
>
> --
> tejun
>

-- IMPORTANT NOTICE: The contents of this email and any attachments are con=
fidential and may also be privileged. If you are not the intended recipient=
, please notify the sender immediately and do not disclose the contents to =
any other person, use it for any purpose, or store or copy the information =
in any medium.  Thank you.

ARM Limited, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Regist=
ered in England & Wales, Company No:  2557590
ARM Holdings plc, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, R=
egistered in England & Wales, Company No:  2548782

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
