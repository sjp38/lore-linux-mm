Message-ID: <47E2CAAC.6020903@de.ibm.com>
Date: Thu, 20 Mar 2008 21:35:56 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC/PATCH 01/15] preparation: provide hook to enable
 pgstes	in	user pagetable
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com> <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com> <47E29EC6.5050403@goop.org> <1206040405.8232.24.camel@nimitz.home.sr71.net>
In-Reply-To: <1206040405.8232.24.camel@nimitz.home.sr71.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christian Ehrhardt <EHRHARDT@de.ibm.com>, hollisb@us.ibm.com, arnd@arndb.de, borntrae@linux.vnet.ibm.com, kvm-devel@lists.sourceforge.net, heicars2@linux.vnet.ibm.com, jeroney@us.ibm.com, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, rvdheij@gmail.com, Olaf Schnapper <os@de.ibm.com>, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> Well, and more fundamentally: do we really want dup_mm() able to be
> called from other code?
> 
> Maybe we need a bit more detailed justification why fork() itself isn't
> good enough.  It looks to me like they basically need an arch-specific
> argument to fork, telling the new process's page tables to take the
> fancy new bit.
> 
> I'm really curious how this new stuff is going to get used.  Are you
> basically replacing fork() when creating kvm guests?
No. The trick is, that we do need bigger page tables when running 
guests: our page tables are usually 2k, but when running a guest 
they're 4k to track both guest and host dirty&reference information. 
This looks like this:
*----------*
*2k PTE's  *
*----------*
*2k PGSTE  *
*----------*
We don't want to waste precious memory for all page tables. We'd like 
to have one kernel image that runs regular server workload _and_ 
guests. Therefore, we need to reallocate the page table after fork() 
once we know that task is going to be a hypervisor. That's what this 
code does: reallocate a bigger page table to accomondate the extra 
information. The task needs to be single-threaded when calling for 
extended page tables.

Btw: at fork() time, we cannot tell whether or not the user's going to 
be a hypervisor. Therefore we cannot do this in fork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
