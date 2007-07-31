Date: Tue, 31 Jul 2007 07:54:09 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [SPARC32] NULL pointer derefference
In-Reply-To: <65dd6fd50707302210y5b79a70di58eb2d46f3958025@mail.gmail.com>
Message-ID: <Pine.LNX.4.61.0707310738240.4116@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
 <65dd6fd50707302210y5b79a70di58eb2d46f3958025@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

>
> I feel like I ought to help out with this since it's my change which
> broke things, but I don't have access to a Sparc32 box.  Does anyone
> have a remotely rebootable machine I can use?
>
> Ollie
>

sun4c Sparc32 are probably a bit thin on the ground. Im my experience, 
they also have a habit of locking up (power up reset required) when 
debugging kernel issues.

However, I think I am getting somewhere.

The problem would apear to be that sun4c_update_mmu_cache is beeing called 
(either directly from the fault handling code or via update_mmu_cache) 
before the mm->context has been set up. The only place I found that sets 
this is sun4c_switch_mm (called from the scheduler as switch_mm).

In other words, the vma system is not operational untill after the task 
gets scheduled.

There may be a way around this - by calling sun4c_alloc_context when the 
mm gets set up. I will give it a go and see what happens.

David, are there any issues that you are aware of in calling 
sun4c_alloc_context without switching to it?

Regards
 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
