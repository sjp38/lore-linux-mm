Date: Tue, 11 Mar 2008 19:49:26 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080311184926.GI27593@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307175148.3a49d8d3@mandriva.com.br> <20080308004654.GQ7365@one.firstfloor.org> <20080310150316.752e4489@mandriva.com.br> <20080310180843.GC28780@one.firstfloor.org> <20080311142624.1dbd3af5@mandriva.com.br> <20080311173540.GG27593@one.firstfloor.org> <20080311150048.4376c73a@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080311150048.4376c73a@mandriva.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> | Oops. Thanks. I'll double check that. mask allocator indeed doesn't
> | handle __GFP_COMP and nobody should be passing that into dma_alloc_coherent
> | anyways. But the bug you got was for the small size wasn't it?
> 
>  No, it triggers the BUG_ON() which checks the gfp, not the one
> which checks MASK_MIN_SIZE.

I see. I misdiagnosed your original problem then. But fixing the 
size < 16 bytes case was a good idea anyways, someone else would
have triggered that.

> 
>  On the other hand I'm not sure whether it does the right thing
> (ie, pass size in bytes instead of order) it does:

> 
> """
> pg = get_order(size);
> [...]
> res = dma_alloc_coherent(dev, PAGE_SIZE << pg, dma, gfp_flags);

With the mask allocator it can be changed to pass size directly
and save some memory. Before that it didn't make any difference.

Can you perhaps send me a complete patch fixing that for sound and the 
__GFP_COMP with description and Signed-off-by etc.? I can add it to my 
patchkit then and you would be correctly attributed. Otherwise I can do it 
myself too if you prefer. I'll also do a grep over the tree for other
such bogus __GFP_COMP users. That was an issue I hadn't considered before.

> if (res != NULL)
> 	inc_snd_pages(pg);
> """
> 
>  Maybe it could be changed to:

Agreed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
