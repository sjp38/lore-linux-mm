Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 630B26B004D
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 14:04:26 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so4858365pbb.11
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 11:04:26 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id pt9si14710445pbb.240.2014.06.27.11.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 11:04:25 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so4795647pbc.26
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 11:04:25 -0700 (PDT)
Date: Fri, 27 Jun 2014 11:03:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shm: hang in shmem_fallocate
In-Reply-To: <53AD84CE.20806@oracle.com>
Message-ID: <alpine.LSU.2.11.1406271043270.28744@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz>
 <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53AC383F.3010007@oracle.com> <alpine.LSU.2.11.1406262236370.27670@eggly.anvils> <53AD84CE.20806@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jun 2014, Sasha Levin wrote:
> On 06/27/2014 01:59 AM, Hugh Dickins wrote:
> >> > First, this:
> >> > 
> >> > [  681.267487] BUG: unable to handle kernel paging request at ffffea0003480048
> >> > [  681.268621] IP: zap_pte_range (mm/memory.c:1132)
> > Weird, I don't think we've seen anything like that before, have we?
> > I'm pretty sure it's not a consequence of my "index = min(index, end)",
> > but what it portends I don't know.  Please confirm mm/memory.c:1132 -
> > that's the "if (PageAnon(page))" line, isn't it?  Which indeed matches
> > the code below.  So accessing page->mapping is causing an oops...
> 
> Right, that's the correct line.
> 
> At this point I'm pretty sure that it's somehow related to that one line
> patch since it reproduced fairly quickly after applying it, and when I
> removed it I didn't see it happening again during the overnight fuzzing.

Oh, I assumed it was a one-off: you're saying that you saw it more than
once with the min(index, end) patch in?  But not since removing it (did
you replace that by the newer patch? or by the older? or by nothing?).

I want to exclaim "That makes no sense!", but bugs don't make sense
anyway.  It's going to be a challenge to work out a connection though.
I think I want to ask for more attempts to reproduce, with and without
the min(index, end) patch (if you have enough time - there must be a
limit to the amount of time you can give me on this).

I rather hoped that the oops on PageAnon might shed light from another
direction on the outstanding page_mapped bug: both seem like page table
corruption of some kind (though I've not seen a plausible path to either).

And regarding the page_mapped bug: we've heard nothing since Dave
Hansen suggested a VM_BUG_ON_PAGE for that - has it gone away now?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
