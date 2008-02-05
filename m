Date: Tue, 5 Feb 2008 14:44:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
In-Reply-To: <1202249070.5332.58.camel@localhost>
Message-ID: <alpine.DEB.1.00.0802051437050.9587@chino.kir.corp.google.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>  <20080202090914.GA27723@one.firstfloor.org>  <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>  <1202149243.5028.61.camel@localhost> <20080205041755.3411b5cc.pj@sgi.com>
 <alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>  <20080205145141.ae658c12.pj@sgi.com>  <alpine.DEB.1.00.0802051259090.26206@chino.kir.corp.google.com>  <20080205153326.5c820dbc.pj@sgi.com> <1202249070.5332.58.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Paul Jackson <pj@sgi.com>, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Lee Schermerhorn wrote:

> The patch I just posted doesn't depend on the numactl changes and seems
> quite minimal to me.  I think it cleans up the differences between
> set_mempolicy() and mbind(), as well.  However, some may take exception
> to the change in behavior--silently ignoring dis-allowed nodes in
> set_mempolicy().
> 

If the intent of the set_mempolicy() call is going to be preserved in the 
struct mempolicy with Paul's change, then we're going to allow disallowed 
nodes anyway.  So the only nodemask errors that we should return are ones 
that are empty; nodemasks that include offlined nodes should be allowed to 
support node hotplug.  Likewise, memoryless nodes should still be saved as 
the intent of the syscall.

The change to save the intent or silently ignore disallowed nodes would 
also require applications to issue a successive get_mempolicy() call to 
know what their current mempolicy is, since it will be able to change with 
a cpusets change or node hotplug event.  There is no longer this assurance 
that if set_mempolicy() returns without an error that the memory policy is 
effected.  But in the presence of subsystems such as cpusets that allow 
those mempolicies to change from beneath the application, there is no way 
around that: the nodemask that the mempolicy acts on can dynamically 
change at any time.

So I don't see any problem with silently ignoring disallowed nodes and 
encourage it so that the kernel accomodates the intent of the mempolicy in 
the future if and when it can be effected.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
