Message-ID: <468023CA.2090401@google.com>
Date: Mon, 25 Jun 2007 13:21:30 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/7] cpuset write dirty map
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com> <46646A33.6090107@google.com> <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> 
> What testing was done? Would you include the results of tests in your next 
> post?

	Sorry for the delay in responding -- I was chasing phantom failures.

	I created a stress test which involved using cpusets and mems_allowed
to split memory so that all daemons had memory set aside for them, and
my memory stress test had a separate set of memory. The stress test was
mmaping 7GB of a very large file on disk. It then scans the entire 7GB
of memory reading and modifying each byte. 7GB is more than the amount
of physical memory made available to the stress test.

	Using iostat I can see the initial period of reading from disk,
followed by a period of simultaneous reads and writes as dirty bytes are
pushed to make room for new reads.

	In a separate log-in, in the other cpuset, I am running:

while `true`; do date | tee -a date.txt; sleep 5; done

	date.txt resides on the same disk as the large file mentioned above.
The above while-loop serves the dual purpose of providing me visual
clues of progress along with the opportunity for the "tee" command to
become throttled writing to the disk.

	The effect of this patchset is straightforward. Without it there are
long hangs between appearances of the date. With it the dates are all 5
(or sometimes 6) seconds apart.

	I also added printks to the kernel to verify that, without these
patches, the tee was being throttled (along with lots of other things),
and with the patch only pdflush is being throttled.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
