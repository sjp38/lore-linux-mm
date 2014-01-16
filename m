Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id D88416B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:51:27 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so822290eaj.23
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:51:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si11299888eeo.107.2014.01.15.17.51.26
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:51:27 -0800 (PST)
From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH v3 3/3] audit: Audit proc cmdline value
Date: Wed, 15 Jan 2014 20:51:20 -0500
Message-ID: <2708398.uWbqeU3VZe@x2>
In-Reply-To: <CAFftDdobF51kR6BWn=QpATTXRe7jr69OgcujSL3-jEtZd+ECBw@mail.gmail.com>
References: <1389808934-4446-1-git-send-email-wroberts@tresys.com> <34747889.Jh8c2aBYNA@x2> <CAFftDdobF51kR6BWn=QpATTXRe7jr69OgcujSL3-jEtZd+ECBw@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, akpm@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>

On Wednesday, January 15, 2014 05:44:29 PM William Roberts wrote:
> On Wed, Jan 15, 2014 at 5:33 PM, Steve Grubb <sgrubb@redhat.com> wrote:
> > On Wednesday, January 15, 2014 05:08:13 PM William Roberts wrote:
> >> On Wed, Jan 15, 2014 at 4:54 PM, Steve Grubb <sgrubb@redhat.com> wrote:
> >> > On Wednesday, January 15, 2014 01:02:14 PM William Roberts wrote:
> >> >> During an audit event, cache and print the value of the process's
> >> >> cmdline value (proc/<pid>/cmdline). This is useful in situations
> >> >> where processes are started via fork'd virtual machines where the
> >> >> comm field is incorrect. Often times, setting the comm field still
> >> >> is insufficient as the comm width is not very wide and most
> >> >> virtual machine "package names" do not fit. Also, during execution,
> >> >> many threads have their comm field set as well. By tying it back to
> >> >> the global cmdline value for the process, audit records will be more
> >> >> complete in systems with these properties. An example of where this
> >> >> is useful and applicable is in the realm of Android. With Android,
> >> >> their is no fork/exec for VM instances. The bare, preloaded Dalvik
> >> >> VM listens for a fork and specialize request. When this request comes
> >> >> in, the VM forks, and the loads the specific application
> >> >> (specializing).
> >> >> This was done to take advantage of COW and to not require a load of
> >> >> basic packages by the VM on very app spawn. When this spawn occurs,
> >> >> the package name is set via setproctitle() and shows up in procfs.
> >> >> Many of these package names are longer then 16 bytes, the historical
> >> >> width of task->comm. Having the cmdline in the audit records will
> >> >> couple the application back to the record directly. Also, on my
> >> >> Debian development box, some audit records were more useful then
> >> >> what was printed under comm.
> >> >> 
> >> >> The cached cmdline is tied to the life-cycle of the audit_context
> >> >> structure and is built on demand.
> >> > 
> >> > I don't think its a good idea to do this for a number of reasons.
> >> > 1) don't we have a record type for command line and its arguments?
> >> > Shouldn't we use that auxiliary record if we do this?
> >> 
> >> Doing this in userspace means each and every user-space would have to be
> >> patched to support this. Other people from various systems have jumped in
> >> adding how this would be beneficial to their cause. The data is right
> >> here in the kernel.
> > 
> > I don't mean doing it in user space, I was thinking of perhaps using the
> > EXECVE auxiliary record type. It looks something like this:
> > 
> > type=EXECVE msg=audit(1303335094.212:83): argc=2 a0="ping"
> > a1="koji.fedoraproject.org"
> > 
> > Its a record type we already have with a format that can be parsed.
> 
> Their is no execve in my use case, so this record would never, ever
> be emitted.

Well, that record has mostly the same fields that you are publishing except 
they are formatted in a way that is usable. What I was suggesting is populate 
the fields and add the auxiliary record.


> >> > 2) we don't want each and every syscall record to grow huge(r).
> >> > Remember
> >> > the command line can be virtually unlimited in length. Adding this will
> >> > consume disk space and we will be able to keep less records than we
> >> > currently do.
> >> 
> >> We cap it at 128 chars in v3 patch, and then this value can be altered
> >> out
> >> of tree and tuned for various systems.
> > 
> > That still adds up on systems where people really do use audit.
> 
> Yes, but is less then setting comm width to 128, and its only
> transient use, not static and un yielding in its use.

I think that would be more efficient in terms of disk space usage. We don't need 
all the arguments for every syscall audit event. We just need the program name 
in full.


> >> > 3) User space will now have to parse this field, too. If everything is
> >> > in
> >> > 1
> >> > field, how can you tell the command from its arguments considering the
> >> > command name could have spaces in it. What if the arguments have spaces
> >> > in them?
> >> 
> >> How did bash figure this out to run the command?
> > 
> > It was shell escaped and quoted when bash saw it. Its not when the kernel
> > sees it.
> > 
> >> All the fields in audit are KVP based, the parsing is pretty straight
> >> forward.
> > 
> > Try this,
> > 
> > cp /bin/ls 'test test test'
> > auditctll -a always,exit -F arch=b64 -S stat -k test
> > ./test\ test\ test './test\ test\ test'
> > auditctl -D
> > ausearch --start recent --key test
> > 
> >> On the event of weird chars, it gets hex escaped.
> > 
> > and its all in 1 lump with no escaping to figure out what is what.
> 
> Un-escape it. ausearch does this with paths. Then if you need to parse
> it, do it.

How can you? When you unescape cmdline for the example I gave, you will have 
"./test test test ./test test test".  Which program ran and how many arguments 
were passed? If we are trying to improve on what comm= provides by having the 
full information, I have to be able to find out exactly what the program name 
was so it can be used for searching. If that can't be done, then we don't need 
this addition in its current form.

-Steve


> >> > Its far better to fix cmd to be bigger than 16 characters than add all
> >> > this
> >> > extra information that is not needed in the audit logs.
> >> 
> >> Rather then use some transient noon-pageable kernel memory for this,
> >> you are suggesting using static,
> >> non-page-able kernel memory for the whole life of every process? What
> >> about
> >> cases where audit is disabled. This will greatly bloat the kernel. I
> >> have brought up cranking up the
> >> width but the general reaction is, this is not a good idea.
> > 
> > That is what the problem is. 16 bytes is useless for anything.
> 
> Well I agree with that statement, its not going to change anytime
> soon. And also has the
> drawbacks ive mentioned. Also, their is another limitation. What if a
> thread sets its title. Its
> possible for each thread to have its own comm field. This cmdlien
> value ties it back to a global entity. Any
> thread can change it, but the value will be the same across all threads.
> 
> >> >> Example denial prior to patch (Ubuntu):
> >> >> CALL msg=audit(1387828084.070:361): arch=c000003e syscall=82
> >> >> success=yes
> >> >> exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
> >> >> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0
> >> >> fsgid=0
> >> >> ses=4294967295 tty=(none) comm="console-kit-dae"
> >> >> exe="/usr/sbin/console-kit-daemon"
> >> >> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)
> >> >> 
> >> >> After Patches (Ubuntu):
> >> >> type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82
> >> >> success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1
> >> >> pid=1329
> >> >> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0
> >> >> fsgid=0
> >> >> ses=4294967295 tty=(none) comm="console-kit-dae"
> >> >> exe="/usr/sbin/console-kit-daemon"
> >> >> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255
> >> >> cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper" key=(null)
> >> >> 
> >> >> Example denial prior to patch (Android):
> >> >> type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54
> >> >> per=840000
> >> >> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224
> >> >> pid=1858
> >> >> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002
> >> >> egid=1002
> >> >> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> >> >> exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)
> >> >> 
> >> >> After Patches (Android):
> >> >> type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54
> >> >> per=840000
> >> >> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224
> >> >> pid=1858
> >> >> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002
> >> >> egid=1002
> >> >> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> >> >> exe="/system/bin/app_process" cmdline="com.android.bluetooth"
> >> >> subj=u:r:bluetooth:s0 key=(null)
> >> >> 
> >> >> Signed-off-by: William Roberts <wroberts@tresys.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
