Date: Mon, 10 Jul 2000 10:34:07 -0700
From: Philipp Rumpf <prumpf@uzix.org>
Subject: Re: sys_exit() and zap_page_range()
Message-ID: <20000710103407.C3826@fruits.uzix.org>
References: <3965EC8E.5950B758@uow.edu.au>, <3965EC8E.5950B758@uow.edu.au> <20000709103011.A3469@fruits.uzix.org> <396910CE.64A79820@uow.edu.au>, <396910CE.64A79820@uow.edu.au> <20000710025342.A3826@fruits.uzix.org> <3969ED88.7238630B@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3969ED88.7238630B@uow.edu.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 11, 2000 at 01:36:40AM +1000, Andrew Morton wrote:
> Philipp Rumpf wrote:
> > 
> > On Sun, Jul 09, 2000 at 11:54:54PM +0000, Andrew Morton wrote:
> > > Philipp Rumpf wrote:
> > > Hi, Philipp.
> > >
> > > > Here's a simple way:
> > >
> > > Already done it :)  It's apparent that not _all_ callers of z_p_r need
> > > this treatment, so I've added an extra 'do_reschedule' flag.  I've also
> > > moved the TLB flushing into this function.
> > 
> > It is ?  I must be missing something, but it looks to me like all calls
> > to z_p_r can be done out of syscalls, with pretty much any size the user
> > wants.
> 
> Possibly - but I don't want to put reschedules into places unless
> they're demonstrated to cause scheduling stalls.

I disagree with that.  It's a complicated rule.  "Anything a malicious user
can cause to take a lot of time" is a simple rule, and certainly includes
all instances of z_p_r.

> Probably just haven't run the right tests :(

map = mmap(NULL, 0x80000000, PROT_READ|PROT_WRITE, MAP_PRIVATE,
	open("/dev/zero", O_RDONLY), 0);

switch(test) {
case 0:
	munmap(map);
	break;
case 1:
	exit(0);
	break;
case 2:
	read(open("/dev/zero", O_RDONLY), map, 0x8000000);
	break;
}

	Philipp Rumpf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
