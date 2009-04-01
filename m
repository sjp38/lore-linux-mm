Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A49F66B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 17:21:09 -0400 (EDT)
Date: Wed, 1 Apr 2009 14:17:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] do_xip_mapping_read: fix length calculation
Message-Id: <20090401141700.f5ef3c08.akpm@linux-foundation.org>
In-Reply-To: <20090331153223.74b177bd@skybase>
References: <20090331153223.74b177bd@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cotte@de.ibm.com, npiggin@suse.de, jaredeh@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 15:32:23 +0200
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> The calculation of the value nr in do_xip_mapping_read is incorrect. If
> the copy required more than one iteration in the do while loop the
> copies variable will be non-zero. The maximum length that may be passed
> to the call to copy_to_user(buf+copied, xip_mem+offset, nr) is len-copied
> but the check only compares against (nr > len).
> 
> This bug is the cause for the heap corruption Carsten has been chasing
> for so long:
> 
> *** glibc detected *** /bin/bash: free(): invalid next size (normal): 0x00000000800e39f0 ***  
> ======= Backtrace: =========  
> /lib64/libc.so.6[0x200000b9b44]  
> /lib64/libc.so.6(cfree+0x8e)[0x200000bdade]  
> /bin/bash(free_buffered_stream+0x32)[0x80050e4e]  
> /bin/bash(close_buffered_stream+0x1c)[0x80050ea4]  
> /bin/bash(unset_bash_input+0x2a)[0x8001c366]  
> /bin/bash(make_child+0x1d4)[0x8004115c]  
> /bin/bash[0x8002fc3c]  
> /bin/bash(execute_command_internal+0x656)[0x8003048e]  
> /bin/bash(execute_command+0x5e)[0x80031e1e]  
> /bin/bash(execute_command_internal+0x79a)[0x800305d2]  
> /bin/bash(execute_command+0x5e)[0x80031e1e]  
> /bin/bash(reader_loop+0x270)[0x8001efe0]  
> /bin/bash(main+0x1328)[0x8001e960]  
> /lib64/libc.so.6(__libc_start_main+0x100)[0x200000592a8]  
> /bin/bash(clearerr+0x5e)[0x8001c092]  

Please get into the habit of adding Cc: <stable@kernel.org> to the
changelogs?

I believe I personally am pretty good at picking up stable things, but
other patch-mergers are quite unreliable.  We all need as much help as
we can get on this, because things are falling through cracks.

> With this bug fix the commit 0e4a9b59282914fe057ab17027f55123964bc2e2
> "ext2/xip: refuse to change xip flag during remount with busy inodes"
> can be removed again.

OK, please send a standalone patch to do this at an appropriate time. 
I guess that this second patch won't be needed in -stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
