Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 41D696B0083
	for <linux-mm@kvack.org>; Sat, 31 Jan 2009 08:43:32 -0500 (EST)
Date: Sat, 31 Jan 2009 11:43:27 -0200
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: marching through all physical memory in software
Message-ID: <20090131134327.GB28763@khazad-dum.debian.net>
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org> <49836114.1090209@buttersideup.com> <m1iqnw1676.fsf@fess.ebiederm.org> <4984489C.8020309@buttersideup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4984489C.8020309@buttersideup.com>
Sender: owner-linux-mm@kvack.org
To: Tim Small <tim@buttersideup.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Pavel Machek <pavel@suse.cz>, Doug Thompson <norsk5@yahoo.com>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, 31 Jan 2009, Tim Small wrote:
> Eric W. Biederman wrote:
> > At the point we are talking about software scrubbing it makes sense to assume
> > a least common denominator memory controller, one that does not do automatic
> > write-back of the corrected value, as all of the recent memory controllers
> > do scrubbing in hardware.
> >   
> 
> I was just trying to clarify the distinction between the two processes 
> which have similar names, but aren't (IMO) actually that similar:
> 
> "Software Scrubbing"
> 
> Triggering a read, and subsequent rewrite of a particular RAM location 
> which has suffered a correctable ECC error(s) i.e. hardware detects an 
> error, then the OS takes care of the rewrite to "scrub" the error in the 
> case that the hardware doesn't handle this automatically.
> 
> This should be a very-occasional error-path process, and performance is 
> probably not critical..
> 
> 
> "Background Scrubbing"
> 
> . This is a poor name, IMO (scrub infers some kind of write to me), 
> which applies to a process whereby you ensure that the ECC check-bits 
> are verified periodically for the whole of physical RAM, so that single 
> bit errors in a given ECC block don't accumulate and turn into 
> uncorrectable errors.  It may also lead to improved data collection for 
> some failure modes.  Again, many memory controllers implement this 
> feature in hardware, so we shouldn't do it twice where this is supported.

It is implined in the background scrubbing, that if a background scrub
page read causes an ECC correctable error to be flagged, the normal
"fix through scrub" behaviour of the memory controller will be
triggered (possibly, the software scrubbing described above).

And if an uncorretable error is detected during the scrub, we have to
do something about it as well.  And that won't be that easy: locate
whatever process is using that page, and so something smart to it...
or do some emergency evasive actions if it is one of the kernel's data
scructures, etc.

So, as you said, "background scrubbing" and "software scrubbing" really are
very different things, and one has to expect that background scrubbing will
eventually trigger software scrubbing, major system emergency handling
(uncorrectable errors in kernel memory) or minor system emergency
handling (uncorrectable errors in process memory).

> There is (AFAIK) no need to do any writes here, and in fact doing so is 

One might want the possibility of doing inconditional writes, because
it helps with memory bitrot on crappy hardware where the refresh
cycles aren't enough to avoid bitrot.  But you definately won't want
it most of the time.

You can also implement software-based ECC using a background scrubber
and setting aside pages to store the ECC information.  Now, THAT is
probably not worth bothering with due to the performance impact, but
who knows...

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
