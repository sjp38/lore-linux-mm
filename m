Message-Id: <6.1.1.1.0.20061128072553.01ed05e0@10.64.204.105>
Date: Tue, 28 Nov 2006 08:29:59 -0500
From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: The VFS cache is not freed when there is not enough free
  memory to allocate
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick wrote:

>And your patch is just a hack that happens to mask the issue in the case 
>you tested, and it will probably blow up in production at some stage

Ok - that would be bad - back to the drawing board.

Maybe we need to take a step back, and describe the original problem, and 
someone can maybe point us in the correct direction, so we can figure out 
the proper way to fix things.

As Aubrey stated:
>When there is no enough free memory, the kernel kprints an OOM, and kills 
>the application, instead of freeing VFS cache, no matter how big the value 
>of /proc/sys/vm/vfs_cache_pressure is set to.

This seems to happen with application allocations as small as one page. 
Larger allocations just make this happen faster.

By doing a periodic "echo 3 > /proc/sys/vm/drop_caches" in a different 
terminal, seems to make the problem go away.

 From what I understand, as documented in 
./Documentation/filesystem/proc.txt we should be able to control the size 
of vfs cache, but it does not seem to work. vfs cache on noMMU seems to 
grow, and grow, and grow, until a) you drop caches manually, or b) the 
system does a OOM.

Any pointers to the correct place to start investigating this would be 
appreciated.

-Robin 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
