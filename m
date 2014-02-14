Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id EDEC06B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 23:32:45 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so19134526qcy.25
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:32:45 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id fy9si2920531qab.85.2014.02.13.20.32.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 20:32:45 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 23:32:45 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E9E576E803C
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 23:32:37 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1E4WgYR1245456
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 04:32:42 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1E4WgZh011475
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 23:32:42 -0500
Date: Thu, 13 Feb 2014 20:32:35 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140214043235.GA21999@linux.vnet.ibm.com>
References: <52F88C16.70204@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
 <52F8C556.6090006@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
 <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <52FC98A6.1000701@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
 <20140214001438.GB1651@linux.vnet.ibm.com>
 <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Linus,

On 13.02.2014 [16:37:53 -0800], Linus Torvalds wrote:
> Is this whole thread still just for the crazy and pointless
> "max_sane_readahead()"?
> 
> Or is there some *real* reason we should care?

There is an open issue on powerpc with memoryless nodes (inasmuch as we
can have them, but the kernel doesn't support it properly). There is a
separate discussion going on on linuxppc-dev about what is necessary for
CONFIG_HAVE_MEMORYLESS_NODES to be supported.

> Because if it really is just for max_sane_readahead(), then for the
> love of God, let us just do this
> 
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
>         return min(nr, 128);
>  }
> 
> and bury this whole idiotic thread.

Agreed that for the readahead case the above is probably more than
sufficient.

Apologies for hijacking the thread, my comments below were purely about
the memoryless node support, not about readahead specifically.

Thanks,
Nish

> Seriously, if your IO subsystem needs more than 512kB of read-ahead to
> get full performance, your IO subsystem is just bad, and has latencies
> that are long enough that you should just replace it. There's no real
> reason to bend over backwards for that, and the whole complexity and
> fragility of the insane "let's try to figure out how much memory this
> node has" is just not worth it. The read-ahead should be small enough
> that we should never need to care, and large enough that you get
> reasonable IO throughput. The above does that.
> 
> Goddammit, there's a reason the whole "Gordian knot" parable is
> famous. We're making this all too damn complicated FOR NO GOOD REASON.
> 
> Just cut the rope, people. Our aim is not to generate some kind of job
> security by making things as complicated as possible.
> 
>                  Linus
> 
> On Thu, Feb 13, 2014 at 4:14 PM, Nishanth Aravamudan
> <nacc@linux.vnet.ibm.com> wrote:
> >
> > I'm working on this latter bit now. I tried to mirror ia64, but it looks
> > like they have CONFIG_USER_PERCPU_NUMA_NODE_ID, which powerpc doesn't.
> > It seems like CONFIG_USER_PERCPU_NUMA_NODE_ID and
> > CONFIG_HAVE_MEMORYLESS_NODES should be tied together in Kconfig?
> >
> > I'll keep working, but would appreciate any further insight.
> >
> > -Nish
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
