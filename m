From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
Date: Mon, 13 Jul 2009 15:38:45 -0500
Message-ID: <4A5B9B55.6000404__21224.0835921422$1247517615$gmane$org@codemonkey.ws>
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com> <4A5A3AC1.5080800@codemonkey.ws> <20090713201745.GA3783@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C1CB6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 16:13:07 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so886372qwf.44
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 13:38:49 -0700 (PDT)
In-Reply-To: <20090713201745.GA3783@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Avi Kivity <avi@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggi
List-Id: linux-mm.kvack.org

Chris Mason wrote:
> This depends on the extent to which tmem is integrated into the VM.  For
> filesystem usage, the hooks are relatively simple because we already
> have a lot of code sharing in this area.  Basically tmem is concerned
> with when we free a clean page and when the contents of a particular
> offset in the file are no longer valid.
>   

But filesystem usage is perhaps the least interesting part of tmem.

The VMM already knows which pages in the guest are the result of disk IO 
(it's the one that put it there, afterall).  It also knows when those 
pages have been invalidated (or it can tell based on write-faulting).

The VMM also knows when the disk IO has been rerequested by tracking 
previous requests.  It can keep the old IO requests cached in memory and 
use that to satisfy re-reads as long as the memory isn't needed for 
something else.  Basically, we have tmem today with kvm and we use it by 
default by using the host page cache to do I/O caching (via 
cache=writethrough).

The difference between our "tmem" is that instead of providing an 
interface where the guest explicitly says, "I'm throwing away this 
memory, I may need it later", and then asking again for it, the guest 
throws away the page and then we can later satisfy the disk I/O request 
that results from re-requesting the page instantaneously.

This transparent approach is far superior too because it enables 
transparent sharing across multiple guests.  This works well for CoW 
images and would work really well if we had a file system capable of 
block-level deduplification... :-)

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
