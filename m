Date: Wed, 12 Sep 2007 15:47:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1189594373.21778.114.camel@twins>
Message-ID: <Pine.LNX.4.64.0709121540370.4067@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <200709050220.53801.phillips@phunq.net>
  <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <20070905114242.GA19938@wotan.suse.de>  <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
 <1189594373.21778.114.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Peter Zijlstra wrote:

> > assumes single critical user of memory. There are other consumers of 
> > memory and if you have a load that depends on other things than networking 
> > then you should not kill the other things that want memory.
> 
> The VM is a _critical_ user of memory. And I dare say it is the _most_
> important user. 

The users of memory are various subsystems. The VM itself of course also 
uses memory to manage memory but the important thing is that the VM 
provides services to other subsystems

> Every user of memory relies on the VM, and we only get into trouble if
> the VM in turn relies on one of these users. Traditionally that has only
> been the block layer, and we special cased that using mempools and
> PF_MEMALLOC.
> 
> Why do you object to me doing a similar thing for networking?

I have not seen you using mempools for the networking layer. I would not 
object to such a solution. It already exists for other subsystems.
 
> The problem of circular dependancies on and with the VM is rather
> limited to kernel IO subsystems, and we only have a limited amount of
> them. 

The kernel has to use the filesystems and other subsystems for I/O. These 
subsystems compete for memory in order to make progress. I would not 
consider strictly them part of the VM. The kernel reclaim may trigger I/O 
in multiple I/O subsystems simultaneously.

> You talk about something generic, do you mean an approach that is
> generic across all these subsystems?

Yes an approach that is fair and does not allow one single subsystem to 
hog all of memory.

> If so, my approach would be it, I can replace mempools as we have them
> with the reserve system I introduce.

Replacing the mempools for the block layer sounds pretty good. But how do 
these various subsystems that may live in different portions of the system 
for various devices avoid global serialization and livelock through your 
system? And how is fairness addresses? I may want to run a fileserver on 
some nodes and a HPC application that relies on a fiberchannel connection 
on other nodes. How do we guarantee that the HPC application is not 
impacted if the network services of the fileserver flood the system with 
messages and exhaust memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
