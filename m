Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 779BD6B00B8
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:43:23 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so366917pbc.38
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 08:43:23 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id il2si1490316pbc.134.2014.04.02.08.43.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 08:43:22 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so362563pab.41
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 08:43:22 -0700 (PDT)
Date: Wed, 2 Apr 2014 08:42:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch]x86: clearing access bit don't flush tlb
In-Reply-To: <20140402130143.GA1869@suse.de>
Message-ID: <alpine.LSU.2.11.1404020830470.19355@eggly.anvils>
References: <20140326223034.GA31713@kernel.org> <20140402130143.GA1869@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mel@csn.ul.ie

On Wed, 2 Apr 2014, Mel Gorman wrote:
> On Thu, Mar 27, 2014 at 06:30:34AM +0800, Shaohua Li wrote:
> > 
> > I posted this patch a year ago or so, but it gets lost. Repost it here to check
> > if we can make progress this time.
> > 
> > We use access bit to age a page at page reclaim. When clearing pte access bit,
> > we could skip tlb flush in X86. The side effect is if the pte is in tlb and pte
> > access bit is unset in page table, when cpu access the page again, cpu will not
> > set page table pte's access bit. Next time page reclaim will think this hot
> > page is old and reclaim it wrongly, but this doesn't corrupt data.
> > 
> > And according to intel manual, tlb has less than 1k entries, which covers < 4M
> > memory. In today's system, several giga byte memory is normal. After page
> > reclaim clears pte access bit and before cpu access the page again, it's quite
> > unlikely this page's pte is still in TLB. And context swich will flush tlb too.
> > The chance skiping tlb flush to impact page reclaim should be very rare.
> > 
> > Originally (in 2.5 kernel maybe), we didn't do tlb flush after clear access bit.
> > Hugh added it to fix some ARM and sparc issues. Since I only change this for
> > x86, there should be no risk.
> > 
> > And in some workloads, TLB flush overhead is very heavy. In my simple
> > multithread app with a lot of swap to several pcie SSD, removing the tlb flush
> > gives about 20% ~ 30% swapout speedup.
> > 
> > Signed-off-by: Shaohua Li <shli@fusionio.com>
> 
> I'm aware of the discussion on the more complex version and the outcome
> of that. While I think the corner case is real, I think it's also very
> unlikely and as this is an x86-only thing which will be safe from
> corruption at least;
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Shaohua, you almost certainly should resend this to Andrew with the
> ack's you collected so that he does not have to dig into the history
> trying to figure out what the exact story is.

And you can add my

Acked-by: Hugh Dickins <hughd@google.com>

to your collection too: you and I discussed this at LSF/MM, and nowadays
I agree that the corner case that originally worried me (highly-accessed
page not getting its accessed bit updated and then temporarily unmapped)
is too unlikely a case to refuse the optimization: it might happen
occasionally, but I doubt anybody will notice.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
