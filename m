Date: Wed, 15 Mar 2006 01:59:06 +0100 (MET)
From: "Michael Kerrisk" <mtk-manpages@gmx.net>
MIME-Version: 1.0
References: <20060314164138.5912ce82.akpm@osdl.org>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-ID: <10343.1142384346@www015.gmx.net>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

> Von: Andrew Morton <akpm@osdl.org>
> 
> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > Use CAP_SYS_NICE for controlling migration permissions.
> >
> 
> ahem.  Kind of eleventh-hour.  Are we really sure?

Hi Andrew,

I see that Christoph already commented, but just to aff.
Not sure if you are on linux-mm.  In case not, the message 
below provides some context that might help.

Cheers,

Michael

--- Weitergeleitete Nachricht ---
Von: "Michael Kerrisk" <mtk-manpages@gmx.net>
An: Christoph Lameter <clameter@sgi.com>
Kopie: ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
Betreff: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Datum: Wed, 15 Mar 2006 01:25:27 +0100 (MET)

Christoph,

> > err = do_migrate_pages(mm, &old, &new, 
> >         capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
> > 
> > while in the implemantation of mbind() we have:
> > 
> > if ((flags & MPOL_MF_MOVE_ALL( && !capable(CAP_SYS_RESOURCE))
> >         return -EPERM;
> > 
> > Is it really intended to associate two *different* capabilities 
> > with the operation of MPOL_MF_MOVE_ALL in this fashion?  At
> > first glance, it seems rather inconsistent to do so.
> 
> You are likely right. Which one is the more correct capability to use?

Umm -- maybe CAP_SYS_NICE!

Whichever it is, I think it should be consistent.  See below
for why I mention CAP_SYS_NICE.

In case it helps you decide which to use, here's a list of 
what I know each of these capabilities already allows:

CAP_SYS_NICE
Raise process nice value (nice(), setpriority()); 
change nice value for arbitrary processes (setpriority()); 
set SCHED_RR and SCHED_FIFO real-time scheduling policies for 
calling process, set scheduling policies and priorities 
for arbitrary processes (sched_setscheduler(), sched_setparam()); 
set CPU affinity for arbitrary processes (sched_setaffinity())

It seems to me that setting scheduling policy and 
priorities is also the kind of thing that might be performed 
in apps that also use the NUMA API, so it would seem consistent 
to use CAP_SYS_NICE for NUMA also.

CAP_SYS_RESOURCE
Use reserved space on file systems; 
make ioctl() calls controlling ext3 journaling; 
override disk quota limits; 
increase hard resource limits (setrlimit()); 
override RLIMIT_NPROC resource limit (fork()); 
raise msg_qbytes limit for a message queue above limit in 
/proc/sys/kernel/msgmnb; 
bypass various POSIX message queue limits defined by files under 
/proc/sys/fs/mqueue


CAP_SYS_ADMIN
Allow system calls that open files to exceed /proc/sys/fs/file-max 
limit; 
perform various system administration operations including: 
quotactl() (control disk quotas), mount() and umount(), 
swapon() and swapoff(), pivot_root(), sethostname() and setdomainname(); 
override RLIMIT_NPROC resource limit; 
set trusted and security extended attributes; 
perform IPC_SET and IPC_RMID operations on 
arbitrary System V IPC objects; 
forge PID when passing credentials via Unix domain socket;
employ TIOCCONS ioctl() 

Cheers,

Michael

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7 

Want to help with man page maintenance?  
Grab the latest tarball at
ftp://ftp.win.tue.nl/pub/linux-local/manpages/, 
read the HOWTOHELP file and grep the source 
files for 'FIXME'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
