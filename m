Date: Fri, 12 Jan 2007 13:45:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
In-Reply-To: <20070112214021.GA4300@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0701121341320.3087@schroedinger.engr.sgi.com>
References: <20070112160104.GA5766@localhost.localdomain>
 <Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com>
 <20070112214021.GA4300@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2007, Ravikiran G Thirumalai wrote:

> > Does the system scale the right way if you stay within the bounds of node 
> > memory? I.e. allocate 1.5GB from each process?
> 
> Yes. We see problems only when we oversubscribe memory.

Ok in that case we can have more than 2 processors trying to acquire the 
same zone lock. If they have all exhausted their node local memory and are 
all going off node then all processor may be hitting the last node that 
has some  memory left which will cause a very high degree of contention.

Moreover mostatomic operations are to remote memory which is also 
increasing the problem by making the atomic ops take longer. Typically 
mature NUMA system have implemented hardware provisions that can deal with 
such high degrees of contention. If this is simply a SMP system that was
turned into a NUMA box then this is a new hardware scenario for the 
engineers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
