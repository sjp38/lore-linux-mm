Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CFFFD6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 16:35:35 -0400 (EDT)
Date: Mon, 13 Jul 2009 17:01:12 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for
	Linux
Message-ID: <20090713210112.GC3783@think>
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com> <4A5A3AC1.5080800@codemonkey.ws> <20090713201745.GA3783@think> <4A5B9B55.6000404@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A5B9B55.6000404@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Avi Kivity <avi@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 03:38:45PM -0500, Anthony Liguori wrote:
> Chris Mason wrote:
>> This depends on the extent to which tmem is integrated into the VM.  For
>> filesystem usage, the hooks are relatively simple because we already
>> have a lot of code sharing in this area.  Basically tmem is concerned
>> with when we free a clean page and when the contents of a particular
>> offset in the file are no longer valid.
>>   
>
> But filesystem usage is perhaps the least interesting part of tmem.
>
> The VMM already knows which pages in the guest are the result of disk IO  
> (it's the one that put it there, afterall).  It also knows when those  
> pages have been invalidated (or it can tell based on write-faulting).
>
> The VMM also knows when the disk IO has been rerequested by tracking  
> previous requests.  It can keep the old IO requests cached in memory and  
> use that to satisfy re-reads as long as the memory isn't needed for  
> something else.  Basically, we have tmem today with kvm and we use it by  
> default by using the host page cache to do I/O caching (via  
> cache=writethrough).

I'll definitely grant that caching with writethough adds more caching,
but it does need trim support before it is similar to tmem.  The caching
is transparent to the guest, but it is also transparent to qemu, and so
it is harder to manage and size (or even get a stat for how big it
currently is).

>
> The difference between our "tmem" is that instead of providing an  
> interface where the guest explicitly says, "I'm throwing away this  
> memory, I may need it later", and then asking again for it, the guest  
> throws away the page and then we can later satisfy the disk I/O request  
> that results from re-requesting the page instantaneously.
>
> This transparent approach is far superior too because it enables  
> transparent sharing across multiple guests.  This works well for CoW  
> images and would work really well if we had a file system capable of  
> block-level deduplification... :-)

Grin, I'm afraid that even if someone were to jump in and write the
perfect cow based filesystem and then find a willing contributor to code
up a dedup implementation, each cow image would be a different file
and so it would have its own address space.

Dedup and COW are an easy way to have hints about which pages are
supposed to be have the same contents, but they would have to go with
some other duplicate page sharing scheme.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
