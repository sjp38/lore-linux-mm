From: Jesse Barnes <jbarnes@sgi.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Date: Fri, 5 Nov 2004 17:36:24 -0800
References: <20041105200118.GA20321@logos.cnet> <20041106012018.GT8229@dualathlon.random> <418C2861.6030501@cyberone.com.au>
In-Reply-To: <418C2861.6030501@cyberone.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200411051736.24731.jbarnes@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrea Arcangeli <andrea@novell.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday, November 05, 2004 5:26 pm, Nick Piggin wrote:
> >If you move it in kswapd there's no way to prevent oom-killing from a
> >syscall allocation (I guess even right now it would go wrong in this
> >sense, but at least right now it's more fixable). I want to move the oom
> >kill outside the alloc_page paths. The oom killing is all about the page
> >faults not having a fail path, and in turn the oom killing should be
> >moved in the page fault code, not in the allocator. Everything else
> >should keep returning -ENOMEM to the caller.
>
> Probably a good idea. OTOH, some kernel allocations might really
> need to be performed and have no failure path. For example __GFP_REPEAT.

Ah, I see what you're saying, yes, that makes even more sense :)

> I think maybe __GFP_REPEAT allocations at least should be able to
> cause an OOM. Not sure though.
>
> >So to me moving the oom killer into kswapd looks a regression.
>
> Also, I think it would do the wrong thing on NUMA machines because
> that has a per-node kswapd.

Yep, Andrea's explaination is clear, I just had to read it a few times.  
Anyway, the fixes I posted are still necessary I think.

Thanks,
Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
