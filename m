Message-ID: <418DADDC.1030601@sgi.com>
Date: Sat, 06 Nov 2004 23:08:44 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration, revisited...
References: <418C03CD.2080501@sgi.com> <1099695742.4507.114.camel@desktop.cunninghams> <20041106174857.GA23420@logos.cnet>
In-Reply-To: <20041106174857.GA23420@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nigel Cunningham <ncunningham@linuxmail.org>, Hirokazu Takahashi <taka@valinux.co.jp>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

>>You may not even need any kernel patches to accomplish this. Bernard
>>Blackham wrote some code called cryopid: http://cryopid.berlios.de/. I
>>haven't tried it myself, but it sounds like it might be at least part of
>>what you're after.
> 
> 
> Hi Ray, Nigel,
> 
> And the swsusp code itself, isnt it what its doing? Stopping all processes, 
> saving their memory to disk, and resuming later on.
> 
> You should just need an API to stop a specific process? 
> 

I think that sending the process a SIGSTOP is probably good enough to stop
it for our purposes.  But in addition to that, the reason we stopped the
process is so we can start up another process on that node.  Now, we can
wait for memory pressure to grow to the point that kswap will force out
the stopped processes's pages, but, why should the VM have to go to the
effort to figure that out?  Why not tell them VM somehow, that we don't
want these pages in memory, and to please swap them out to make space for
the new program that is running?

Of course, one can argue that we don't know for sure that the new program
will use enough space to force the other process out, but we worry that in
that case, the new program could still end up with non-local memory allocation
and that is an anathema to the HPC world where we require the good performance
that local storage allocation provides.  We want the new process that is
run on the node to get as good performance as it would have gotten if it had
started on an idle node.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
