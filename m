Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200705242241.35373.ak@suse.de>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <200705242241.35373.ak@suse.de>
Content-Type: text/plain
Date: Thu, 24 May 2007 17:05:44 -0400
Message-Id: <1180040744.5327.110.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 22:41 +0200, Andi Kleen wrote:
> > 
> > Basic "problem":  currently [~2.6.21], files mmap()ed SHARED
> > do not follow mem policy applied to the mapped regions.  Instead, 
> > shared, file backed pages are allocated using the allocating
> > tasks' task policy.  This is inconsistent with the way that anon
> > and shmem pages are handled, violating, for me, the Principle
> > of Least Astonishment.
> 
> Do you have some specific use cases? Did this actually improve
> some application significantly? 

Same use cases for using mbind() at all.  I want to specify the
placement of memory backing any of my address space.  A shared mapping
of a regular file is, IMO, morally equivalent to a shared memory region,
with the added semantic that is it automatically initialized from the
file contents, and any changes persist after the file is closed.  [One
related semantic that Linux is missing is to initialize the shared
mapping from the file, but not writeback any changes--e.g.,
MAP_NOWRITEBACK.  Some "enterprise unix" support this, presumably at
ISV/customer request.]

> 
> The main basic issue is that it seems weird semantics to have the policy randomly
> disappear when everybody closes the file depending on whether the system
> decides to flush the inode or not. But using EAs or similar
> also looked like overkill.

IMO, it's also weird that the system ignores my mbind()s on regular
files mmap()ed shared, or just because I only do read accesses
[admittedly I don't address the latter "feature"].  It seems like a
fundamental correctness issue to me.  I guess I'm just used to
applications [and language run time environments] that evaluate the
topology of the system, or subset thereof, that they're running on and
mbind() all of the components of the address space accordingly.

I have a more difficult time envisioning a use for policies stored with
the file, except in the case of embedded or other fixed hardware
configurations where you can determine a priori how you want your memory
placed, and don't want to have to add the binding into each application.
I believe that this is the use case that Steve Longerbeam had in mind a
few years ago when he proposed this.  As I responded to Christoph, if we
want to store policy with the file itself and have it automatically
installed when the file is opened or mmap'd, we'd need such a mechanism
as I propose below it.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
