Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B14C7900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 03:24:09 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p957O6cR026265
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 00:24:06 -0700
Received: from iadx2 (iadx2.prod.google.com [10.12.150.2])
	by wpaz1.hot.corp.google.com with ESMTP id p957O2FU013556
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 00:24:04 -0700
Received: by iadx2 with SMTP id x2so1624002iad.6
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 00:24:02 -0700 (PDT)
Date: Wed, 5 Oct 2011 00:23:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
In-Reply-To: <1317798564.3099.12.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1110050012490.18906@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel> <20111001000900.BD9248B8@kernel> <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com> <1317798564.3099.12.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Wed, 5 Oct 2011, Eric Dumazet wrote:

> > This would be great if all the /proc/pid/numa_maps consumers were human, 
> > but unfortuantely that's not the case.  
> > 
> > I understand that this patchset was probably the result of me asking for 
> > the pagesize= to be specified in each line and using pagesize=4K and 
> > pagesize=2M as examples, but that exact usage is probably not what we 
> > want.
> > 
> > As long as there are scripts that go through and read this information 
> > (we have some internally), expressing them with differing units just makes 
> > it more difficult to parse.  I'd rather them just be the byte count.
> > 
> > That way, 1G pages would just show pagesize=1073741824.  I don't think 
> > that's too long and is much easier to parse systematically.
> > 
> 
> Hmm... Thats sounds strange.
> 
> Are you saying you cant change your scripts [But you'll have to anyway
> to parse pagesize=] ?
> 

pagesize= isn't absolutely required, you can already get the thp stats 
from /proc/pid/smaps.  A script can then parse /proc/pid/numa_maps for the 
same vmas to determine the NUMA locality.  Adding pagesize= to numa_maps 
then doesn't change the script at all if it's robust.

> I routinely use "cat /proc/xxx/numa_maps", and am stuck when a kernel
> displays nothing (it happened on some debian released kernels)
> 
> Seeing pagesize=1GB is slightly better for human, and not that hard to
> parse for a program.
> 

Why on earth do we want to convert a byte value into a string so a script 
can convert it the other way around?  Do you have a hard time parsing 
4096, 2097152, and 1073741824 to be 4K, 2M, and 1G respectively?  Then you 
better not use the hugepage sysfs interface to configure multiple hugepage 
sizes because they're all specified in kB!

> By the way, "pagesize=4KiB" are just noise if you ask me, thats the
> default PAGE_SIZE. This also breaks old scripts :)
> 

-ENOPARSE.  It better not break any old script, I don't know why it would.  
Anything that emits a field=value tuple should be parsed as such.  I doubt 
you can find a well-distributed example since numa_maps output includes 
file, mapped, mapmax, anon, and dirty fields and not a single line of 
output would have all of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
