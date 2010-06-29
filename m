Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0A38A6B01B5
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 02:42:47 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o5T6gjrV013615
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 23:42:45 -0700
Received: from qwg8 (qwg8.prod.google.com [10.241.194.136])
	by hpaq6.eem.corp.google.com with ESMTP id o5T6ghls005475
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 23:42:44 -0700
Received: by qwg8 with SMTP id 8so1794286qwg.32
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 23:42:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100628050723.GR4306@balbir.in.ibm.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
	<20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com> <20100628050723.GR4306@balbir.in.ibm.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 28 Jun 2010 23:42:18 -0700
Message-ID: <AANLkTilnkhd8nrUvQ0BRSnO742abMcT0O2gMeEdwQysZ@mail.gmail.com>
Subject: Re: deterministic cgroup charging using file path
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 27, 2010 at 10:07 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-28 11:03:27=
]:
>
>> On Fri, 25 Jun 2010 13:43:45 -0700
>> Greg Thelen <gthelen@google.com> wrote:
>>
>> > For the upcoming Linux VM summit, I am interesting in discussing the
>> > following proposal.
>> >
>> > Problem: When tasks from multiple cgroups share files the charging can=
 be
>> > non-deterministic. =A0This requires that all such cgroups have unneces=
sarily high
>> > limits. =A0It would be nice if the charging was deterministic, using t=
he file's
>> > path to determine which cgroup to charge. =A0This would benefit chargi=
ng of
>> > commonly used files (eg: libc) as well as large databases shared by on=
ly a few
>> > tasks.
>> >
>> > Example: assume two tasks (T1 and T2), each in a separate cgroup. =A0E=
ach task
>> > wants to access a large (1GB) database file. =A0To catch memory leaks =
a tight
>> > memory limit on each task's cgroup is set. =A0However, the large datab=
ase file
>> > presents a problem. =A0If the file has not been cached, then the first=
 task to
>> > access the file is charged, thereby requiring that task's cgroup to ha=
ve a limit
>> > large enough to include the database file. =A0If the order of access i=
s unknown
>> > (due to process restart, etc), then all cgroups accessing the file nee=
d to have
>> > a limit large enough to include the database. =A0This is wasteful beca=
use the
>> > database won't be charged to both T1 and T2. =A0It would be useful to =
introduce
>> > determinism by declaring that a particular cgroup is charged for a par=
ticular
>> > set of files.
>> >
>> > /dev/cgroup/cg1/cg11 =A0# T1: want memory.limit =3D 30MB
>> > /dev/cgroup/cg1/cg12 =A0# T2: want memory.limit =3D 100MB
>> > /dev/cgroup/cg1 =A0 =A0 =A0 # want memory.limit =3D 1GB + 30MB + 100MB
>> >
>> > I have implemented a prototype that allows a file system hierarchy be =
charge a
>> > particular cgroup using a new bind mount option:
>> > + mount -t cgroup none /cgroup -o memory
>> > + mount --bind /tmp/db /tmp/db -o cgroup=3D/dev/cgroup/cg1
>> >
>> > Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1. =
=A0Access to
>> > other files behave normally - they charge the cgroup of the current ta=
sk.
>> >
>>
>> Interesting, but I want to use madvice() etc..for this kind of jobs, rat=
her than
>> deep hooks into the kernel.
>>
>> madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);
>>
>> Then, you can write a command as:
>>
>> =A0 file_recharge [path name] [cgroup]
>> =A0 - this commands move a file cache to specified cgroup.
>>
>> A daemon program which uses this command + inotify will give us much
>> flexible controls on file cache on memcg. Do you have some requirements
>> that this move-charge shouldn't be done in lazy manner ?
>>
>> Status:
>> We have codes for move-charge, inotify but have no code for new madvise.
>
> I have not see the approach yet, but ideally one would want to avoid
> changing the application, otherwise we are going to get very tightly
> bound in the API issues.

I agree that changing the application is undesirable.  I think the
madvise suggestion (above) would not involve changing applications -
it would only be used for a manager daemon in response to a inotify as
a mechanism change the charge of previously allocated file pages.

> I want to understand why do we need bind mounts?

I'm not certain that bind mounts are needed.  I chose to use bind
mounts as a way to create a file system namespace that charged to a
particular cgroup.  There are other mechanisms.  Another approach
would be to have a way to dentry attribute (d_cgroup) that is
inherited by child dentrys.  I tend to prefer the bind mount over the
dentry approach because is reduces the number of cgroup references.
However, there may be even better ways.

> I think this needs more discussion.

I agree that more discussion is required.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
