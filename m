Date: Thu, 17 Oct 2002 20:08:43 +0530
From: Maneesh Soni <maneesh@in.ibm.com>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021017200843.D29405@in.ibm.com>
Reply-To: maneesh@in.ibm.com
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20021016154943.GA13695@hswn.dk>; from henrik@hswn.dk on Wed, Oct 16, 2002 at 05:49:43PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Henrik_St=F8rner?= <henrik@hswn.dk>
Cc: linux-mm@kvack.org, akpm@digeo.com, Dipankar Sarma <dipankar@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 16, 2002 at 05:49:43PM +0200, Henrik Storner wrote:

> The kernel sources are located in /usr/src which is on the local
> (combined root+usr) filesystem, but I normally go there via a
> symlink in my home-dir, ~/kernel/linux-2.5-mm/ is the directory
> for the 2.5+mm directory I use.
> 
> The system runs apmd, atd, crond, autofs (for mounting /home), gpm,
> lpd, nfs-server (the /usr/src directory is exported), nfs-client,
> ntpd, portmap, sshd, xfs and xinetd. A DHCP client is also running.
> No X server has been running while I've tested these hangs.
> 
> To recreate it, I've booted up the 2.5.2-mm2 kernel, starting up
> all the normal services. Log in (automounts home directory), 
> cd ~/kernel/linux-2.5-mm, make oldconfig, make clean, make
> 
> The system then hangs after a few minutes of working through the
> kernel compile. Not the same place everytime.


I tried similar setup that is making link to an local reiserfs partition 
on an NFS mounted partition. NFS server was running on a system with 2.4.19
kernel. I had the following setup

[root@llm04 root]# mount
/dev/sda6 on / type ext2 (rw)
none on /proc type proc (rw)
/dev/sda1 on /boot type ext2 (rw)
/dev/sda2 on /home type ext2 (rw)
/dev/sda5 on /usr type ext2 (rw)
none on /dev/shm type tmpfs (rw)
/dev/sdc3 on /mnt/sdc3 type reiserfs (rw)
/dev/sdb1 on /bm type ext2 (rw)
192.168.1.10:/home/maneesh/test on /mnt/sdc2 type nfs (rw,addr=192.168.1.10)

[root@llm04 tmp]# l
total 8
drwxr-xr-x    5 nfsnobod nfsnobod     4096 Oct 17 16:35 dbench
lrwxrwxrwx    1 root     root           10 Oct 17 16:08 dbench-link-to-ext2-local -> /bm/dbench
lrwxrwxrwx    1 root     root           17 Oct 17 15:03 dbench-link-to-rfs-local -> /mnt/sdc3/dbench/
lrwxrwxrwx    1 root     root           23 Oct 17 15:05 linux-2542-link-to-rfs-local -> /mnt/sdc3/linux-2.5.42/
drwxrwxr-x   17 1046     101          4096 Oct 17 14:39 linux-2.5.43
lrwxrwxrwx    1 root     root           19 Oct 17 15:08 linux-2543-link-to-ext2-local -> /src1/linux-2.5.43/

With this setup I could run make properly. Even dbench also runs fine if
ran through the link. 

The problem I am seeing is only when I am running dbench directly over the
nfs mounted partition (i.e, no sym link). I see dbench giving errors and 
_sometimes_ hanging the system. 

Where as if I ran the nfs-server on the same machine like yesterday I see
hang occuring all the time.

With your setup I didnot see that you don't need nfs-server running. So just
to narrow down the problem can you stop nfs-server and then do the make.

Thanks
Maneesh

-- 
Maneesh Soni
IBM Linux Technology Center, 
IBM India Software Lab, Bangalore.
Phone: +91-80-5044999 email: maneesh@in.ibm.com
http://lse.sourceforge.net/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
