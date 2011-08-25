Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E445E6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 17:02:59 -0400 (EDT)
Date: Thu, 25 Aug 2011 17:02:38 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and reading
 from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4
 to 2.6.37 (and beyond)
Message-ID: <20110825210238.GE27162@redhat.com>
References: <bug-41552-10286@https.bugzilla.kernel.org/>
 <20110822122443.c04839c8.akpm@linux-foundation.org>
 <20110822194854.GA15087@redhat.com>
 <BLU165-W10DB18F4AB061C7617C060FF110@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU165-W10DB18F4AB061C7617C060FF110@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Petersen <mpete_06@hotmail.com>
Cc: bugme-daemon@bugzilla.kernel.org, axboe@kernel.dk, linux-mm@kvack.org, linux-scsi@vger.kernel.org, akpm@linux-foundation.org

On Wed, Aug 24, 2011 at 03:11:57PM -0500, Mark Petersen wrote:
> 
> I was finally able to run it with the deadline scheduler, and got the same performance.

You mean you see 40% regression even with deadline? If yes, then it is not a
IO scheduler specific issue.

> Unfortunately, I am not able to use the blktrace tool as it requires a version of libc that we do not have on the system (we have 2.5 and it requires at least 2.7).  Is there anything else I can use to trace it?
> 

You can try using tracing functionality. 

- mount -t debugfs none /sys/kernel/debug
- Enable tracing on the disk you are doing IO to.
  echo 1 > /sys/block/sda/trace/enable
- Enable block traces
  echo blk > /sys/kernel/debug/tracing/current_tracer
- cat /sys/kernel/debug/tracing/trace_pipe > /tmp/trace_output

Let it run for few seconds. Interrupt and kill cat process.
/tmp/trace_output should have useful tracing info.

Thanks
Vivek
 

> Thanks,
> Mark
> 
> > Date: Mon, 22 Aug 2011 15:48:54 -0400
> > From: vgoyal@redhat.com
> > To: mpete_06@hotmail.com
> > CC: bugme-daemon@bugzilla.kernel.org; axboe@kernel.dk; linux-mm@kvack.org; linux-scsi@vger.kernel.org; akpm@linux-foundation.org
> > Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and reading from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4 to 2.6.37 (and beyond)
> > 
> > On Mon, Aug 22, 2011 at 12:24:43PM -0700, Andrew Morton wrote:
> > > 
> > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > bugzilla web interface).
> > > 
> > > On Mon, 22 Aug 2011 15:20:41 GMT
> > > bugzilla-daemon@bugzilla.kernel.org wrote:
> > > 
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=41552
> > > > 
> > > >            Summary: Performance of writing and reading from multiple
> > > >                     drives decreases by 40% when going from Linux Kernel
> > > >                     2.6.36.4 to 2.6.37 (and beyond)
> > > >            Product: IO/Storage
> > > >            Version: 2.5
> > > >     Kernel Version: 2.6.37
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: normal
> > > >           Priority: P1
> > > >          Component: SCSI
> > > >         AssignedTo: linux-scsi@vger.kernel.org
> > > >         ReportedBy: mpete_06@hotmail.com
> > > >         Regression: No
> > > > 
> > > > 
> > > > We have an application that will write and read from every sector on a drive. 
> > > > The application can perform these tasks on multiple drives at the same time. 
> > > > It is designed to run on top of the Linux Kernel, which we periodically update
> > > > so that we can get the latest device drivers.  When performing the last update
> > > > from 2.6.33.2 to 2.6.37, we found that the performance of a set of drives
> > > > decreased by some 40% (took 3 hours and 11 minutes to write and read from 5
> > > > drives on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was able to
> > > > determine that the issue was in the 2.6.37 Kernel as I was able to run it with
> > > > the 2.6.36.4 kernel, and it had the better performance.   After seeing that I/O
> > > > throttling was introduced in the 2.6.37 Kernel, I naturally suspected that. 
> > > > However, by default, all the throttling was turned off (I attached the actual
> > > > .config that was used to build the kernel).  I then tried to turn on the
> > > > throttling and set it to a high number to see what would happen.  When I did
> > > > that, I was able to reduce the time from 3 hours and 11 minutes to 2 hours and
> > > > 50 minutes.  There seems to be something there that changed that is impacting
> > > > performance on multiple drives.  When we do this same test with only one drive,
> > > > the performance is identical between the systems.  This issue still occurs on
> > > > Kernel 3.0.2.
> > > > 
> > > 
> > > Are you able to determine whether this regression is due to slower
> > > reading, to slower writing or to both?
> > 
> > Mark,
> > 
> > As your initial comment says that you see 40% regression even when block
> > throttling infrastructure is not enabled, I think it is not related to
> > throttling as blk_throtl_bio() is null when BLK_DEV_THROTTLING=n.
> > 
> > What IO scheduler are you using? Can you try switching IO scheduler to
> > deadline and see if regression is still there. Trying to figure out if
> > it has anything to do with IO scheduler.
> > 
> > What file system are you using with what options? Are you using device
> > mapper to create some special configuration on multiple disks?
> > 
> > Also can you take a trace (blktrace) of any of the disks for 30 seconds
> > both without regression and after regression and upload it somewhere.
> > Staring at it might give some clues. 
> > 
> > Thanks
> > Vivek
>  		 	   		  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
