Date: Wed, 16 Oct 2002 17:49:43 +0200
From: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021016154943.GA13695@hswn.dk>
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20021016183907.B29405@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maneesh Soni <maneesh@in.ibm.com>
Cc: linux-mm@kvack.org, akpm@digeo.com, Dipankar Sarma <dipankar@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Maneesh,

sorry about not getting back with more info sooner. Daytime jobs can
be all-consuming.


I tried doing what Andrew suggested, and enabling all memory debugging
options. This did not produce anything.

The setup here:

Workstation where I see the problem is a PII/350, 392 MB RAM and
some swap. Just about all the software packages are from Red Hat 8
(recently upgraded from a 7.x installation).

SCSI disk off an Symbios Logic 53c875 controller is used for Linux.
There is an IDE disk in the system and the kernel has support for it,
but it is not used normally (nothing mounted).

Network is with an Intel eepro100 adapter, gets an IP via DHCP.

root-fs is a local filesystem on the scsi disk, reiserfs formatted.
/home is NFS-mounted from a Linux server running kernel 2.4.19

The kernel sources are located in /usr/src which is on the local
(combined root+usr) filesystem, but I normally go there via a
symlink in my home-dir, ~/kernel/linux-2.5-mm/ is the directory
for the 2.5+mm directory I use.

The system runs apmd, atd, crond, autofs (for mounting /home), gpm,
lpd, nfs-server (the /usr/src directory is exported), nfs-client,
ntpd, portmap, sshd, xfs and xinetd. A DHCP client is also running.
No X server has been running while I've tested these hangs.

To recreate it, I've booted up the 2.5.2-mm2 kernel, starting up
all the normal services. Log in (automounts home directory), 
cd ~/kernel/linux-2.5-mm, make oldconfig, make clean, make

The system then hangs after a few minutes of working through the
kernel compile. Not the same place everytime.

I've got some time tonight, so I will try un-doing the patch you
mention and see if that changes anything.

Thanks,

Henrik


On Wed, Oct 16, 2002 at 06:39:07PM +0530, Maneesh Soni wrote:
> On Sun, Oct 13, 2002 at 10:34:40PM +0000, Henrik Storner wrote:
> > On Sun, Oct 13, 2002 at 12:31:52PM -0700, Andrew Morton wrote:
> > > Henrik Storner wrote:
> > > > 
> > > > I gave 2.5.42-mm2 a test run yesterday, and it hung the box solid
> > > > while doing a kernel compile. The compile stopped dead in the middle
> > > > of a file, and there was no response when trying to access another
> > > > console (no X running). Alt-sysrq worked, so it wasn't completely dead
> > > > - sync/umount/reboot worked.
> > > > 
> > > > Nothing in the logs - no oops or other kernel messages.
> > > > 
> > > > Rebooted and repeated the experiment with the same result,
> > > > so it appears to be reproducible.
> > > > 
> > > > Stock 2.5.42 has worked OK for a day now, including kernel
> > > > compiles - the system has performed flawlessly for a
> > > > couple of years as my normal workstation.
> > > > 
> > > > PII processor, 384 MB RAM, SCSI disk (ncr53c8xx driver),
> > > > Intel eepro/100 network adapter. Kernel config at
> > > > http://www.hswn.dk/config-2.5.42-mm2
> > > 
> > > Very odd.
> > > 
> > > If you have time, could you please enable "load all symbols"
> > > in the kernel hacking menu and capture a sysrq-T trace?
> > > Thanks.
> > 
> > Did so - built it again from a fresh kernel tree, just to be sure.
> > Compiler is gcc 3.2 from Red Hat 8, by the way.
> > 
> > Bug is still there. sysrq-T scrolls off the screen too fast for me to
> > read, but the last screenful has several processes like this (could
> > see sh, make, sh, gcc):
> > 
> > Call Trace:
> 
> Hello Henrik,
> 
> I tired recreating the hang, but it didnot occur. I could guess from the
> call trace that you are using reiserfs and nfs but I not very clear how
> are you recreating it. I created a resierfs partition and exported it. Then
> tried to compile a kernel over it. I used the config file from the site
> you mentioned.
> 
> It will be nice if you can list the exact recreation steps mentioning the
> filesystems you are using.
> 
> As the hang looks like a loop in d_lookup can you  try
> recreating it *without* dcache_rcu.patch. You can backout this patch
> 
> http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm2/broken-out/dcache_rcu.patch
> 
> 
> Thanks
> Maneesh
> 
> -- 
> Maneesh Soni
> IBM Linux Technology Center, 
> IBM India Software Lab, Bangalore.
> Phone: +91-80-5044999 email: maneesh@in.ibm.com
> http://lse.sourceforge.net/
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/

-- 
Henrik Storner <henrik@hswn.dk> 
Hvis du vil have god, palidelig info om Open Source og Linux, sa 
overvej at stotte Linux Weekly News med et abonnement.
                                   http://lwn.net/Articles/10688/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
