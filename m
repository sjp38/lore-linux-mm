Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
	16gb
From: keith <kmannth@us.ibm.com>
In-Reply-To: <20040824144312.09b4af42.akpm@osdl.org>
References: <200408242051.i7OKplP0009870@fire-1.osdl.org>
	 <20040824144312.09b4af42.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1093389067.5677.1839.camel@knk>
Mime-Version: 1.0
Date: Tue, 24 Aug 2004 16:11:07 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-24 at 14:43, Andrew Morton wrote:
> bugme-daemon@osdl.org wrote:
> >
> > http://bugme.osdl.org/show_bug.cgi?id=3268
> > 
> >            Summary: Lowmemory exhaustion problem with v2.6.8.1-mm4 16gb
> >     Kernel Version:  2.6.8.1-mm4
> >             Status: NEW
> >           Severity: high
> >              Owner: akpm@digeo.com
> >          Submitter: kmannth@us.ibm.com
> >                 CC: mbligh@aracnet.com
> > 
> > 
> > Distribution:  SuSE SLES9 base
> > Hardware Environment:  IBM x445 8-way  32gb and 16 gb 
> > Software Environment:   2.6.8.1-mm4
> > Problem Description:  I run out of lowmemory very easily using /dev/shm/
> > I have 64g and Numa/Discontig enabled in my kernel.  
> > 
> > Steps to reproduce:  Fill up 1/2 or more of /dev/shm (on my system it is about
> > 1/3-1/2 of my total system memory) with lots of kernel builds.  Observe system
> > breakdown.  (If you want the script I will email it to you).  I have seen this
> > with both 32 gigs and 16 gigs...
> > 
> > For example if I boot with 16gb and I start 45 kernel builds in /dev/shm they
> > system take about 30-60 seconds to run out of lowmemory.  
> > The oom killer comes in and starts shutting down processes.  The system is unsuable.
> >   There is tons of highmem left but no lowmem.  Is there something about
> > /dev/shm that might cause this? 
> > 
> > I turned some various vm debug optoins that printed out some info that I will
> > attach.  I will attach the config file and as much of the kernel messages as I
> > can.
> 
> I assume this is because we're using up all of lowmem with filesystem metadata.
> 
> Hugh?
> 

As a note. I am able to run this test with Reiser just fine.  It looks
like the shmfs code always calls kmem_cache_alloc when it needs to
allocate a new inode.  
  If the kmem_cache_alloc calls are filling up lowmem shouldn't the
alloc calls fail eventually instead of sending out the oom killer to all
the processes in the system?  Is it possible to fail an kmem_cache_alloc
call?
  
Keith Mannthey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
