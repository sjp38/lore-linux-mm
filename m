Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED6A6B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:42:20 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id f11so16904182qae.21
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 13:42:20 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id p70si2206088qga.195.2014.02.13.13.42.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 13:42:20 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 16:42:19 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 21302C90043
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:42:15 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1DLgHog57933860
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:42:18 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1DLgGSl032022
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:42:17 -0500
Date: Thu, 13 Feb 2014 13:42:11 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140213214211.GC12409@linux.vnet.ibm.com>
References: <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com>
 <52F4B8A4.70405@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
 <52F88C16.70204@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
 <52F8C556.6090006@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
 <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <20140213130643.0cf5fb083056cdd159d1aac4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140213130643.0cf5fb083056cdd159d1aac4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 13.02.2014 [13:06:43 -0800], Andrew Morton wrote:
> On Thu, 13 Feb 2014 00:05:31 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > On Thu, 13 Feb 2014, Raghavendra K T wrote:
> > 
> > > I was able to test (1) implementation on the system where readahead problem
> > > occurred. Unfortunately it did not help.
> > > 
> > > Reason seem to be that CONFIG_HAVE_MEMORYLESS_NODES dependency of
> > > numa_mem_id(). The PPC machine I am facing problem has topology like
> > > this:
> > > 
> > > numactl -H
> > > ---------
> > > available: 2 nodes (0-1)
> > > node 0 cpus: 0 1 2 3 4 5 6 7 12 13 14 15 16 17 18 19 20 21 22 23 24 25
> > > ...
> > > node 0 size: 0 MB
> > > node 0 free: 0 MB
> > > node 1 cpus: 8 9 10 11 32 33 34 35 ...
> > > node 1 size: 8071 MB
> > > node 1 free: 2479 MB
> > > node distances:
> > > node   0   1
> > >   0:  10  20
> > >   1:  20  10
> > > 
> > > So it seems numa_mem_id() does not help for all the configs..
> > > Am I missing something ?
> > > 
> > 
> > You need the patch from http://marc.info/?l=linux-mm&m=139093411119013 
> > first.
> 
> That (un-signed-off) powerpc patch appears to be moribund.  What's up?

Gah, thanks for catching that Andrew, not sure what went wrong. I've
appended my S-o-b. I've asked Ben to take a look, but I think he's still
catching up on his queue after travelling.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
