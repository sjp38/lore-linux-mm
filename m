Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 77EC26B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 01:01:33 -0500 (EST)
Date: Thu, 21 Feb 2013 16:31:04 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130221060104.GG10716@marvin.atrad.com.au>
References: <20130213031056.GA32135@marvin.atrad.com.au>
 <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
 <20130213042552.GC32135@marvin.atrad.com.au>
 <511BADEA.3070403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <511BADEA.3070403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Jonathan Woithe <jwoithe@atrad.com.au>

On Wed, Feb 13, 2013 at 07:14:50AM -0800, Dave Hansen wrote:
> On 02/12/2013 08:25 PM, Jonathan Woithe wrote:
> >> > Better yet would be to try to upgrade these machines to a more recent 
> >> > kernel to see if it is already fixed.  Are we allowed to upgrade or at 
> >> > least enable kmemleak?
> > Upgrading to a recent kernel would be a possibility if it was proven to fix
> > the problem; doing it "just to check" will be impossible I fear, at least on
> > the production systems.  Enabling KMEMLEAK on 2.6.35.x may be doable.
> > 
> > I will see whether I can gain access to a test system and if so, try a more
> > recent kernel to see if it makes any difference.
> > 
> > I'll advise which of these options proves practical as soon as possible and
> > report any findings which come out of them.

I am currently running a test using the 3.7.9 kernel (the latest stable
release at the time of downloading).  I am not yet convinced that the
problem is showing itself under this kernel; while the relevant kmalloc
statistics did climb over the first day or so, they seem to have settled for
the moment (which is more or less what I'd expect).  I intend to keep the
test running over the coming weekend and evaluate the slabinfo after that
(I've been taking daily snapshots of it).

My intention after this is to return to the kernel which has shown the
problem (2.6.35.11), compile it with kmemleak enabled and see if it shows up
anything interesting.

This 3.7.9 does have kmemleak enabled and it has thrown two reports.  Both
are tiny and insignificant, and both seem to relate to code which runs only
at boot time.  However, someone might be interested in them so I'll include
them at the end of this mail.

Regards
  jonathan

unreferenced object 0xf415f290 (size 8):
  comm "swapper/0", pid 1, jiffies 4294668872 (age 170230.022s)
  hex dump (first 8 bytes):
    68 6f 73 74 30 00 00 00                          host0...
  backtrace:
    [<c1a86f3c>] kmemleak_alloc+0x2c/0x60
    [<c111d11d>] __kmalloc_track_caller+0xbd/0x180
    [<c1539993>] kvasprintf+0x33/0x60
    [<c152eb42>] kobject_set_name_vargs+0x32/0x70
    [<c15db8c9>] dev_set_name+0x19/0x20
    [<c16182ee>] scsi_host_alloc+0x22e/0x2d0
    [<c16183a8>] scsi_register+0x18/0x80
    [<c1e4092d>] aha1542_detect+0x100/0x7c0
    [<c1e4104c>] init_this_scsi_driver+0x5f/0xc4
    [<c1001124>] do_one_initcall+0x34/0x170
    [<c1e0b55e>] kernel_init_freeable+0x118/0x1b3
    [<c1a856f0>] kernel_init+0x10/0xe0
    [<c1aba577>] ret_from_kernel_thread+0x1b/0x28
    [<ffffffff>] 0xffffffff
unreferenced object 0xf415f298 (size 8):
  comm "swapper/0", pid 1, jiffies 4294668873 (age 170230.021s)
  hex dump (first 8 bytes):
    68 6f 73 74 31 00 00 00                          host1...
  backtrace:
    [<c1a86f3c>] kmemleak_alloc+0x2c/0x60
    [<c111d11d>] __kmalloc_track_caller+0xbd/0x180
    [<c1539993>] kvasprintf+0x33/0x60
    [<c152eb42>] kobject_set_name_vargs+0x32/0x70
    [<c15db8c9>] dev_set_name+0x19/0x20
    [<c16182ee>] scsi_host_alloc+0x22e/0x2d0
    [<c16183a8>] scsi_register+0x18/0x80
    [<c1e4092d>] aha1542_detect+0x100/0x7c0
    [<c1e4104c>] init_this_scsi_driver+0x5f/0xc4
    [<c1001124>] do_one_initcall+0x34/0x170
    [<c1e0b55e>] kernel_init_freeable+0x118/0x1b3
    [<c1a856f0>] kernel_init+0x10/0xe0
    [<c1aba577>] ret_from_kernel_thread+0x1b/0x28
    [<ffffffff>] 0xffffffff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
