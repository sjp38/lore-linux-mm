Date: Tue, 26 Sep 2000 11:07:36 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000926110736.E1638@redhat.com>
References: <20000925143523.B19257@hq.fsmlabs.com> <Pine.LNX.3.96.1000925164556.9644A-100000@kanga.kvack.org> <20000925151250.B20586@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925151250.B20586@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 03:12:50PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 03:12:50PM -0600, yodaiken@fsmlabs.com wrote:
> > > 
> > > I'm not too sure of what you have in mind, but if it is
> > >      "process creates vast virtual space to generate many page table
> > >       entries -- using mmap"
> > > the answer is, virtual address space quotas and mmap should kill 
> > > the process on low mem for page tables.
> > 
> > No.  Page tables are not freed after munmap (and for good reason).  The
> > counting of page table "beans" is critical.
> 
> I've seen the assertion before, reasons would be interesting.

Reason 1: under DoS attack, you want to target not the process using
the most resources, but the *user* using the most resources (else a
fork-bomb style attack can work around your OOM-killer algorithms).

Reason 2: if you've got tasks stuck in low-level page allocation
routines, then you can't immediately kill -9 them, so reactive OOM
killing always has vulnerabilities --- to be robust in preventing
resource exhaustion you want limits on the use of those resources
before they are exhausted --- the necessary accounting being part of
what we refer to as "beancounter".

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
