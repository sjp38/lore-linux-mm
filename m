Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 457E86B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 22:32:07 -0500 (EST)
Date: Fri, 2 Dec 2011 14:31:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-ID: <20111202033148.GA7046@dastard>
References: <20111201093644.GW7046@dastard>
 <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
 <20111201124634.GY7046@dastard>
 <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
 <20111202015921.GZ7046@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111202015921.GZ7046@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 02, 2011 at 12:59:21PM +1100, Dave Chinner wrote:
> On Thu, Dec 01, 2011 at 02:35:31PM -0800, David Rientjes wrote:
> > On Thu, 1 Dec 2011, Dave Chinner wrote:
> > 
> > > > /*
> > > >  * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
> > > >  * pid.
> > > >  */
> > > > #define OOM_SCORE_ADJ_MIN       (-1000)
> > > > 
> > > >  
> > > > IIUC, this task cannot be killed by oom-killer because of oom_score_adj settings.
> > > 
> > > It's not me or the test suite that setting this, so it's something
> > > the kernel must be doing automagically.
> > > 
> > 
> > The kernel does not set oom_score_adj to ever disable oom killing for a 
> > thread.  The only time the kernel touches oom_score_adj is when setting it 
> > to "1000" in ksm and swap to actually prefer a memory allocator for oom 
> > killing.
> > 
> > It's also possible to change this value via the deprecated 
> > /proc/pid/oom_adj interface until it is removed next year.  Check your 
> > dmesg for warnings about using the deprecated oom_adj interface or change 
> > the printk_once() in oom_adjust_write() to a normal printk() to catch it.
> 
> No warnings at all, as I've already said. If it is userspace,
> whatever is doing it is using the oom_score_adj interface correctly.

.....

> <sigh>
> 
> The reports all cycle around this loop:
> 
> 	linux-mm says userspace/distro problem
> 	distro says openssh problem
> 	openssh says kernel problem
> 
> And there doesn't appear to be any resolution in any of the reports,
> just circular finger pointing and frustrated users.
> 
> I can't find anything in the distro startup or udev scripts that
> modify the oom parameters, and the openssh guys say they only
> pass on the value inhereted from ssh's parent process, so it clearly
> not obvious where the bug lies at this point. It's been around for
> some time, though...
> 
> More digging to do...

A working sshd startup and login:

Dec  2 13:16:32 test-2 sshd[2119]: Set /proc/self/oom_score_adj from 0 to -1000
Dec  2 13:16:32 test-2 sshd[2119]: debug1: Bind to port 22 on 0.0.0.0.
Dec  2 13:16:32 test-2 sshd[2119]: Server listening on 0.0.0.0 port 22.
Dec  2 13:16:32 test-2 sshd[2119]: socket: Address family not supported by protocol
Dec  2 13:16:36 test-2 sshd[2119]: debug1: Forked child 2576.
Dec  2 13:16:36 test-2 sshd[2576]: Set /proc/self/oom_score_adj to 0

The child process sets itself back to 0 correctly. Now, a non-working
startup and login:

Dec  2 13:19:56 test-2 sshd[2126]: Set /proc/self/oom_score_adj from 0 to -1000
Dec  2 13:19:56 test-2 sshd[2126]: debug1: Bind to port 22 on 0.0.0.0.
Dec  2 13:19:56 test-2 sshd[2126]: Server listening on 0.0.0.0 port 22.
Dec  2 13:19:56 test-2 sshd[2126]: socket: Address family not supported by protocol
Dec  2 13:19:57 test-2 sshd[2126]: Received signal 15; terminating.
Dec  2 13:19:57 test-2 sshd[2317]: Set /proc/self/oom_score_adj from -1000 to -1000
Dec  2 13:19:57 test-2 sshd[2317]: debug1: Bind to port 22 on 0.0.0.0.
Dec  2 13:19:57 test-2 sshd[2317]: Server listening on 0.0.0.0 port 22.
Dec  2 13:19:57 test-2 sshd[2317]: socket: Address family not supported by protocol
Dec  2 13:20:01 test-2 sshd[2317]: debug1: Forked child 2322.
Dec  2 13:20:01 test-2 sshd[2322]: Set /proc/self/oom_score_adj to -1000

Somewhere in the statup process, a sshd process is getting a SIGTERM
and dying. It is then restarted immediately form a context that has
a /proc/self/oom_score_adj value of -1000, which is where the
problem lies. So, how does this occur? Looks like a distro problem -
I added 'echo "sshd restart" >> /var/log/auth.log' to the
/etc/init.d/ssh restart command, and this pops out now:

Dec  2 14:00:08 test-2 sshd[2037]: debug3: oom_adjust_setup
Dec  2 14:00:08 test-2 sshd[2037]: Set /proc/self/oom_score_adj from 0 to -1000
Dec  2 14:00:08 test-2 sshd[2037]: debug2: fd 3 setting O_NONBLOCK
Dec  2 14:00:08 test-2 sshd[2037]: debug1: Bind to port 22 on 0.0.0.0.
Dec  2 14:00:08 test-2 sshd[2037]: Server listening on 0.0.0.0 port 22.
Dec  2 14:00:08 test-2 sshd[2037]: socket: Address family not supported by protocol
sshd restart
Dec  2 14:00:11 test-2 sshd[2037]: Received signal 15; terminating.
Dec  2 14:00:11 test-2 sshd[2330]: debug3: oom_adjust_setup
Dec  2 14:00:11 test-2 sshd[2330]: Set /proc/self/oom_score_adj from -1000 to -1000

So, something in a startup script is causing an sshd restart from a
context where the oom_score_adj = -1000. There's only two
possibilities here - the dhcp client bringing the network interface
up or a udev event after the sshd has been started.

Bingo:

$ sudo ifup --verbose eth0
Configuring interface eth0=eth0 (inet)
run-parts --verbose /etc/network/if-pre-up.d
run-parts: executing /etc/network/if-pre-up.d/bridge
run-parts: executing /etc/network/if-pre-up.d/uml-utilities

dhclient -v -pf /var/run/dhclient.eth0.pid -lf
/var/lib/dhcp/dhclient.eth0.leases eth0
Internet Systems Consortium DHCP Client 4.1.1-P1
Copyright 2004-2010 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

Listening on LPF/eth0/00:e4:b6:63:63:6e
Sending on   LPF/eth0/00:e4:b6:63:63:6e
Sending on   Socket/fallback
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 6
DHCPOFFER from 192.168.1.254
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPACK from 192.168.1.254
bound to 192.168.1.61 -- renewal in 17198 seconds.
run-parts --verbose /etc/network/if-up.d
run-parts: executing /etc/network/if-up.d/mountnfs
run-parts: executing /etc/network/if-up.d/ntpdate
run-parts: executing /etc/network/if-up.d/openssh-server
run-parts: executing /etc/network/if-up.d/uml-utilities
$

and /etc/network/if-up.d/openssh-server does a restart on the
ssh server.

And this is set in /etc/network/interfaces:

allow-hotplug eth0

which means udev can execute the ifup command whenteh device
appears, asynchronously to the startup scripts that are running.

So, it's a distro bug - sshd should never be started from from udev
context because of this inherited oom_score_adj thing.
Interestingly, the ifup ssh restart script says this:

# We'd like to use 'reload' here, but it has some problems; see #502444.
if [ -x /usr/sbin/invoke-rc.d ]; then
        invoke-rc.d ssh restart >/dev/null 2>&1 || true
else
        /etc/init.d/ssh restart >/dev/null 2>&1 || true
fi

Bug 502444 describes the exact startup race condition that I've just
found. It does a ssh server restart because reload causes the sshd
server to fail to start if a start is currently in progress.  So,
rather than solving the start vs reload race condition, it got a
bandaid (use restart to restart sshd from the reload context) and
left it as a landmine.....

<sigh>

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
