Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 297496B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 03:53:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cx13so118882979pac.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 00:53:23 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id o81si2963355pfa.34.2016.07.04.00.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 00:53:21 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 66so15778581pfy.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 00:53:21 -0700 (PDT)
Date: Mon, 4 Jul 2016 16:53:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] mm/page_owner: track page free call chain
Message-ID: <20160704075324.GE898@swordfish>
References: <20160702161656.14071-1-sergey.senozhatsky@gmail.com>
 <20160702161656.14071-4-sergey.senozhatsky@gmail.com>
 <20160704045714.GC14840@js1304-P5Q-DELUXE>
 <20160704050730.GC898@swordfish>
 <20160704052955.GD14840@js1304-P5Q-DELUXE>
 <20160704054524.GD898@swordfish>
 <20160704072944.GA15729@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160704072944.GA15729@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/04/16 16:29), Joonsoo Kim wrote:
[..]
> > well, yes. current hits bad_page(), page_owner helps to find out who
> > stole and spoiled it from under current.
> > 
> > CPU a							CPU b
> > 
> > 	alloc_page()
> > 	put_page() << legitimate
> > 							alloc_page()
> > err:
> > 	put_page() << legitimate, again.
> > 	           << but is actually buggy.
> > 
> > 							put_page() << double free. but we need
> > 								   << to report put_page() from
> > 								   << CPU a.
> 
> Okay. I think that this patch make finding offending user easier
> but it looks like it is a partial solution to detect double-free.
> See following example.
> 
> CPU a							CPU b
> 
> 	alloc_page()
> 	put_page() << legitimate
>  							alloc_page()
> err:
> 	put_page() << legitimate, again.
> 	           << but is actually buggy.
> 
> 	alloc_page()
> 
> 							put_page() <<
> 							legitimate,
> 							again.
> 	put_page() << Will report the bug and
> 	        page_owner have legitimate call stack.

good case. I think it will report "put_page()" from CPU b (the path that
actually dropped page refcount to zero and freed it), and alloc_page()
from CPU a. _might_ sound like a clue.

I agree, there are cases when this approach will not work out perfectly.
tracing refcount modification is probably the only reliable solution,
but given that sometimes it's unclear how to reproduce the bug, one can
end up looking at tons of traces.

> In kasan, quarantine is used to provide some delay for real free and
> it makes use-after-free detection more robust. Double-free also can be
> benefit from it. Anyway, I will not object more since it looks
> the simplest way to improve doublue-free detection for the page
> at least for now.

thanks!

there are things in the patch (it's an RFC after all) that I don't like.
in particular, I cut the corner in __dump_page_owner(). it now shows the
same text for both _ALLOC and _FREE handlers. I didn't want to add
additional ->order to page_ext. I can update the text to, e.g.
		page allocated via order ...	page_ext->order
and
		page freed, WAS allocated via order ...   page_ext->order

or extend page_ext and keep alloc and free ->order separately.
do you have any preferences here?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
