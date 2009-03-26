Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 002F86B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 19:08:20 -0400 (EDT)
Date: Thu, 26 Mar 2009 16:02:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
In-Reply-To: <20090326084723.GB8207@skywalker>
Message-ID: <alpine.LFD.2.00.0903261559200.3032@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <20090324125510.GA9434@duck.suse.cz> <20090324132637.GA14607@duck.suse.cz> <200903250130.02485.nickpiggin@yahoo.com.au> <20090324144709.GF23439@duck.suse.cz> <1237906563.24918.184.camel@twins>
 <20090324152959.GG23439@duck.suse.cz> <20090326084723.GB8207@skywalker>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>



On Thu, 26 Mar 2009, Aneesh Kumar K.V wrote:
> 
> >page faults doing allocation can take a
> > *long* time 
> 
> That is true

Btw, this is actually a feature rather than a bug.

We want to slow down the writer, which is why we also do dirty page 
balancing when marking a page dirty. 

Basically, if block allocation is a performance problem, then it should be 
a performance problem that is attributed to the process that _causes_ it, 
rather than to some random poor unrelated process that then later ends up 
writing the page out because it wants to use some memory.

This is why tracking dirty pages is so important. Yes, it also avoids 
various nasty overcommit situations, but the whole "make it hurt for the 
person responsible, rather than a random innocent bystander" is the more 
important part of it. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
