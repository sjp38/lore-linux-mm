Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0P4VnBb276610
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 15:31:53 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0P4KfTm249676
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 15:20:44 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0P4HCsM028444
	for <linux-mm@kvack.org>; Thu, 25 Jan 2007 15:17:12 +1100
Message-ID: <45B82F41.9040705@linux.vnet.ibm.com>
Date: Thu, 25 Jan 2007 09:47:05 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <45B75208.90208@linux.vnet.ibm.com> <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Christoph Lameter wrote:
> On Wed, 24 Jan 2007, Vaidyanathan Srinivasan wrote:
> 
>> With your patch, MMAP of a file that will cross the pagecache limit hangs the
>> system.  As I mentioned in my previous mail, without subtracting the
>> NR_FILE_MAPPED, the reclaim will infinitely try and fail.
> 
> Well mapped pages are still pagecache pages.
> 

Yes, but they can be classified under a process RSS pages.  Whether it
is an anon page or shared mem or mmap of pagecache, it would show up
under RSS.  Those pages can be limited by RSS limiter similar to the
one we are discussing in pagecache limiter.  In my opinion, once a
file page is mapped by the process, then it should be treated at par
with anon pages.  Application programs generally do not mmap a file
page if the reuse for the content is very low.

>> I have tested your patch with the attached fix on my PPC64 box.
> 
> Interesting. What is your reason for wanting to limit the size of the
> pagecache?

1. Systems primarily running database workloads would benefit if
background house keeping applications like backup processes do not
fill the pagecache.  Databases use O_DIRECT and we do not want the
kernel to even remove cold pages belonging to that application to make
room for pagecache that is going to be used by an unimportant backup
application.  The objective is to have some limit on pagecache usage
and make the backup application take all the performance hit and have
zero impact on the main database workload.

Solutions:

* The backup applications could use O_DIRECT as well, but this is not
very flexible since there are restrictions in using O_DIRECT.

Please review http://lkml.org/lkml/2007/1/4/55 for issues with O_DIRECT

* Improve fadvice to specify caching behavior.  Rightnow we only model
the readahead behavior.  However this would need a change in all
applications and more command line options.

* The technique we are discussing right now can serve the purpose

2. In the context of 'containers' and per container resource
management, there is a need to restrict resources utilized by each of
the process groups within the container.  Resources like CPU time,
RSS, pagecache usage, IO bandwidth etc may have to be controlled for
each process groups.

Some of today's open virtualisation solutions like UML instances, KVM
instances among others also have a need to control CPU time, RSS and
(unmapped) pagecache pages to be able to successfully execute
commercial workloads within their virtual environments.  Each of these
instances are normal Linux process within the host kernel.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
