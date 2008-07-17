Date: Thu, 17 Jul 2008 16:39:30 -0400
From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 11110] New: Core dumps do not include writable unmodified MAP_PRIVATE maps
Message-ID: <20080717203930.GA24299@hmsendeavour.rdu.redhat.com>
References: <bug-11110-10286@http.bugzilla.kernel.org/> <20080717132317.96e73124.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080717132317.96e73124.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, drow@false.org, Roland McGrath <roland@redhat.com>, Oleg Nesterov <oleg@tv-sign.ru>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 17, 2008 at 01:23:17PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 17 Jul 2008 11:57:08 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11110
> > 
> >            Summary: Core dumps do not include writable unmodified
> >                     MAP_PRIVATE maps
> >            Product: Process Management
> >            Version: 2.5
> >      KernelVersion: 2.6.26
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: process_other@kernel-bugs.osdl.org
> >         ReportedBy: drow@false.org
> >                 CC: davem@davemloft.net
> > 
> > 
> > Latest working kernel version: Not sure.
> > Earliest failing kernel version: Been failing at least since April 2006. 
> > Passed at some point previous to that, probably 2.4.
> > Distribution: Debian
> > Hardware Environment: x86_64 SMP
> > Software Environment: GDB testsuite
> > Problem Description:
> > 
> > The test corefile.exp fails because it maps a file and then core dumps,
> > expecting the mapped contents to be in the core dump.  The mapping is made with
> > these options:
> > 
> >   buf2 = (char *) mmap (0, MAPSIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd,
> > 0);
> > 
> > Any page that has been touched will be dumped, any unmodified page will not be.
> > 
> > I've discussed this with David Miller a couple of times; last time I recall was
> > in January 2007.
> > 
> > Steps to reproduce:
> > 
> >   Run coremaker from the GDB testsuite (attached).  Load the core file into GDB
> > and try to print buf2.
> > 
> 
> Does anyone recall whether this is deliberate behaviour, or did we just goof?
> 
> Thanks.

I'm not 100% sure, and I can see why the kernel might skip over untouched pages,
but that seems like a bug to me.  The memory is mapped, it should be readable by
gdb after a core dump, and since its a mapped file, it can't be assumed to be
zero, like heap memory that hasn't been faulted in yet.

Just my $0.02
Neil

-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
