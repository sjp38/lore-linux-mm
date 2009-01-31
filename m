Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0361D6B0083
	for <linux-mm@kvack.org>; Sat, 31 Jan 2009 07:48:38 -0500 (EST)
Message-ID: <4984489C.8020309@buttersideup.com>
Date: Sat, 31 Jan 2009 12:48:28 +0000
From: Tim Small <tim@buttersideup.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com>	<m1wscc7fop.fsf@fess.ebiederm.org> <49836114.1090209@buttersideup.com> <m1iqnw1676.fsf@fess.ebiederm.org>
In-Reply-To: <m1iqnw1676.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Pavel Machek <pavel@suse.cz>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> At the point we are talking about software scrubbing it makes sense to assume
> a least common denominator memory controller, one that does not do automatic
> write-back of the corrected value, as all of the recent memory controllers
> do scrubbing in hardware.
>   

I was just trying to clarify the distinction between the two processes 
which have similar names, but aren't (IMO) actually that similar:

"Software Scrubbing"

Triggering a read, and subsequent rewrite of a particular RAM location 
which has suffered a correctable ECC error(s) i.e. hardware detects an 
error, then the OS takes care of the rewrite to "scrub" the error in the 
case that the hardware doesn't handle this automatically.

This should be a very-occasional error-path process, and performance is 
probably not critical..


"Background Scrubbing"

. This is a poor name, IMO (scrub infers some kind of write to me), 
which applies to a process whereby you ensure that the ECC check-bits 
are verified periodically for the whole of physical RAM, so that single 
bit errors in a given ECC block don't accumulate and turn into 
uncorrectable errors.  It may also lead to improved data collection for 
some failure modes.  Again, many memory controllers implement this 
feature in hardware, so we shouldn't do it twice where this is supported.

There is (AFAIK) no need to do any writes here, and in fact doing so is 
only likely to hurt performance, I think....  The design which springs 
to mind is of a background thread which (possibly at idle priority) 
reads RAM at a user-configurable rate (e.g. consume a max of n% of 
memory bandwidth, or read  all of RAM at least once every x minutes).  
Possible design issues:

. There will be some trade off between reducing impact on the system as 
a whole, and making firm guarantees about how often memory is checked.  
Difficult to know what the default would be, but probably 
no-firm-guarantee of minimum time (idle processing only) is likely to 
cause least problems for most users.
. An eye will need to be kept on the impact that this reading has on the 
performance of the rest of the system (e.g. cache pollution, and NUMA, 
as you previously mentioned), but my gut feeling is that for the 
majority of systems it shouldn't be significant.  If practical 
mechanisms are available on some CPUs to read RAM without populating the 
CPU cache, we should use those (but I've no idea if they exist or not).

Perhaps a good default would be to benchmark memory read bandwidth when 
the feature is turned on, and then operate at (e.g.) 0.5% of that bandwidth.


Cheers,

Tim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
