Date: Mon, 20 Aug 2007 01:10:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
In-Reply-To: <20070819225320.6562fbd1.pj@sgi.com>
Message-ID: <alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com>
 <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
 <46C8E604.8040101@google.com> <20070819193431.dce5d4cf.pj@sgi.com>
 <46C92AF4.20607@google.com> <20070819225320.6562fbd1.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Ethan Solomita <solo@google.com>, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 19 Aug 2007, Paul Jackson wrote:

> > 	BTW, a slightly different MPOL_INTERLEAVE implementation would help, 
> > wherein we save the nodemask originally specified by the user and do the 
> > remap from the original nodemask rather than the current nodemask.
> 
> I kinda like this idea; though keep in mind that since I don't use
> mempolicy mechanisms, I am not loosing any sleep over minor(?)
> compatibility breakages.  It would take someone familiar with the
> actual users or usages of MPOL_INTERLEAVE to know if or how much
> this would bite actual users/usages.
> 

Like I've already said, there is absolutely no reason to add a new MPOL 
variant for this case.  As Christoph already mentioned, PF_SPREAD_PAGE 
gets similar results.  So just modify mpol_rebind_policy() so that if 
/dev/cpuset/<cpuset>/memory_spread_page is true, you rebind the 
interleaved nodemask to all nodes in the new nodemask.  That's the 
well-defined cpuset interface for getting an interleaved behavior already.

Let's not create new memory policies that only work for a very specific 
and configurable case when the basic underlying mechanism to that policy 
is already present in the cpuset interface, namely, PF_SPREAD_PAGE.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
