Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B60B66B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 19:06:47 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7130743ied.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 16:06:46 -0700 (PDT)
Date: Fri, 2 Nov 2012 16:06:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/31] numa/core patches
In-Reply-To: <50933CB6.6000909@redhat.com>
Message-ID: <alpine.LNX.2.00.1211021558030.11106@eggly.anvils>
References: <20121025121617.617683848@chello.nl> <508A52E1.8020203@redhat.com> <1351242480.12171.48.camel@twins> <20121028175615.GC29827@cmpxchg.org> <508F73C5.7050409@redhat.com> <20121031004838.GA1657@cmpxchg.org> <alpine.LNX.2.00.1210302350140.5084@eggly.anvils>
 <50912478.2040403@redhat.com> <alpine.LNX.2.00.1210311005220.5685@eggly.anvils> <alpine.LNX.2.00.1211010636140.3648@eggly.anvils> <50933CB6.6000909@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, CAI Qian <caiqian@redhat.com>

On Fri, 2 Nov 2012, Zhouping Liu wrote:
> On 11/01/2012 09:41 PM, Hugh Dickins wrote:
> > 
> > Here's a patch fixing and tidying up that and a few other things there.
> > But I'm not signing it off yet, partly because I've barely tested it
> > (quite probably I didn't even have any numa pmd migration happening
> > at all), and partly because just a moment ago I ran across this
> > instructive comment in __collapse_huge_page_isolate():
> > 	/* cannot use mapcount: can't collapse if there's a gup pin */
> > 	if (page_count(page) != 1) {
> > 
> > Hmm, yes, below I've added the page_mapcount() check I proposed to
> > do_huge_pmd_numa_page(), but is even that safe enough?  Do we actually
> > need a page_count() check (for 2?) to guard against get_user_pages()?
> > I suspect we do, but then do we have enough locking to stabilize such
> > a check?  Probably, but...
> > 
> > This will take more time, and I doubt get_user_pages() is an issue in
> > your testing, so please would you try the patch below, to see if it
> > does fix the BUGs you are seeing?  Thanks a lot.
> 
> Hugh, I have tested the patch for 5 more hours,
> the issue can't be reproduced again,
> so I think it has fixed the issue, thank you :)

Thanks a lot for testing and reporting back, that's good news.

However, I've meanwhile become convinced that more fixes are needed here,
to be safe against get_user_pages() (including get_user_pages_fast());
to get the Mlocked count right; and to recover correctly when !pmd_same
with an Unevictable page.

Won't now have time to update the patch today,
but these additional fixes shouldn't hold up your testing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
