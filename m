Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 2657E6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 10:34:05 -0500 (EST)
Message-ID: <509D226B.30904@linux.intel.com>
Date: Fri, 09 Nov 2012 07:34:03 -0800
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com>
In-Reply-To: <20121109051247.GA499@dirshya.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: svaidy@linux.vnet.ibm.com
Cc: Mel Gorman <mgorman@suse.de>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/8/2012 9:14 PM, Vaidyanathan Srinivasan wrote:
> * Mel Gorman <mgorman@suse.de> [2012-11-08 18:02:57]:
> 
>> On Wed, Nov 07, 2012 at 01:22:13AM +0530, Srivatsa S. Bhat wrote:
>>> ------------------------------------------------------------
> 
> Hi Mel,
> 
> Thanks for detailed review and comments.  The goal of this patch
> series is to brainstorm on ideas that enable Linux VM to record and
> exploit memory region boundaries.
> 
> The first approach that we had last year (hierarchy) has more runtime
> overhead.  This approach of sorted-buddy was one of the alternative
> discussed earlier and we are trying to find out if simple requirements
> of biasing memory allocations can be achieved with this approach.
> 
> Smart reclaim based on this approach is a key piece we still need to
> design.  Ideas from compaction will certainly help.

reclaim may be needed for the embedded use case
but at least we are also looking at memory power savings that come for content-preserving power states.
For that, Linux should *statistically* not be actively using (e.g. read or write from it) a percentage of memory...
and statistically clustering is quite sufficient for that.

(for example, if you don't use a DIMM for a certain amount of time,
the link and other pieces can go to a lower power state,
even on todays server systems.
In a many-dimm system..  if each app is, on a per app basis,
preferring one dimm for its allocations, the process scheduler will
help us naturally keeping the other dimms "dark")

If you have to actually free the memory, it is a much much harder problem,
increasingly so if the region you MUST free is quite large.

if one solution can solve both cases, great, but lets not make both not happen
because one of the cases is hard...
(and please lets not use moving or freeing of pages as a solution for at least the
content preserving case)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
