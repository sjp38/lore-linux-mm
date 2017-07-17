Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFCE6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 03:49:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b20so18493752wmd.6
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 00:49:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i65si9018606wmg.60.2017.07.17.00.49.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 00:49:43 -0700 (PDT)
Date: Mon, 17 Jul 2017 08:49:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170717074941.sti4dqm3ysy5upen@suse.de>
References: <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <CALCETrWbvt2n2PLtsVM5RgCKz+RZ30STFS2xZ=dacPZRwokFHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrWbvt2n2PLtsVM5RgCKz+RZ30STFS2xZ=dacPZRwokFHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Sat, Jul 15, 2017 at 09:41:35AM -0700, Andrew Lutomirski wrote:
> On Sat, Jul 15, 2017 at 8:55 AM, Mel Gorman <mgorman@suse.de> wrote:
> > The patch looks fine to be but when writing the patch, I wondered why the
> > original code disabled preemption before inc_mm_tlb_gen. I didn't spot
> > the reason for it but given the importance of properly synchronising with
> > switch_mm, I played it safe. However, this should be ok on top and
> > maintain the existing sequences
> 
> LGTM.  You could also fold it into your patch or even put it before
> your patch, too.
> 

Thanks.

> FWIW, I didn't have any real reason to inc_mm_tlb_gen() with
> preemption disabled.  I think I did it because the code it replaced
> was also called with preemption off.  That being said, it's
> effectively a single instruction, so it barely matters latency-wise.
> (Hmm.  Would there be a performance downside if a thread got preempted
> between inc_mm_tlb_gen() and doing the flush? 

There isn't a preemption point until the point where irqs are
disabled/enabled for the local TLB flush so it doesn't really matter.
It can still be preempted by an interrupt but that's not surprising. I
don't think it matters that much either way so I'll leave it at it is.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
