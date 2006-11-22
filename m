Received: by nf-out-0910.google.com with SMTP id c2so462979nfe
        for <linux-mm@kvack.org>; Wed, 22 Nov 2006 02:02:31 -0800 (PST)
Message-ID: <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
Date: Wed, 22 Nov 2006 18:02:30 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Re: The VFS cache is not freed when there is not enough free memory to allocate
In-Reply-To: <1164185036.5968.179.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
	 <1164185036.5968.179.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/22/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Please see the
> threads on Mel Gorman's Anti-Fragmentation and Linear/Lumpy reclaim in
> the linux-mm archives.
>

Thanks to point this. Is it already included in Linus' git tree?

> > The patch drop the page cache and slab and then give a new chance to
> > get more free pages. Applied this patch, my test application can
> > allocate memory sucessfully and drop the cache and slab as well. See
> > below:
> > ================================
> > root:/mnt> ./t
> > Alloc 8 MB !
> > alloc successful
>
> Pure luck, there are workloads where there just would not have been any
> order 9 contiguous block freeable (think where each 9th order block
> would contain at least one active inode).
>
> > I know performance is important for linux, and VFS cache obviously
> > improve the performance when implement file operation. But for
> > embedded system, we'll try our best to make the application executable
> > rather than hanging system to guarantee the system performance.
> >
> > Any suggestions and solutions are really appreciated!
>
> Try Mel's patches and wait for the next Lumpy reclaim posting.
>
> The lack of a MMU on your system makes it very hard not to rely on
> higher order allocations, because even user-space allocs need to be
> physically contiguous. But please take that into consideration when
> writing software.

Well, the test application just use an exaggerated way to replicate the issue.

Actually, In the real work, the application such as mplayer, asterisk,
etc will run into
the above problem when run them at the second time. I think I have no
reason to modify those kind of applications.

My patch let kernel drop VFS cache in the low memory situation when
the application requests more memory allocation, I don't think it's
luck. You know, the application just wants to allocate 8
1Mbyte-blocks(order =9) and releasing VFS cache we can get almost
50Mbyte free memory.

The patch indeedly enabled many failed test cases on our side. But
yes, I don't think it's the final solution. I'll try Mel's patch and
update the results.

Thanks,
-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
