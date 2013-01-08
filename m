Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0066C6B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 23:55:29 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id un15so11048727pbc.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 20:55:29 -0800 (PST)
Date: Tue, 8 Jan 2013 12:55:19 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC]x86: clearing access bit don't flush tlb
Message-ID: <20130108045519.GB2459@kernel.org>
References: <20130107081213.GA21779@kernel.org>
 <50EAE66B.1020804@redhat.com>
 <50EB4CB9.9010104@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50EB4CB9.9010104@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com, hughd@google.com

On Mon, Jan 07, 2013 at 02:31:21PM -0800, H. Peter Anvin wrote:
> On 01/07/2013 07:14 AM, Rik van Riel wrote:
> > On 01/07/2013 03:12 AM, Shaohua Li wrote:
> >>
> >> We use access bit to age a page at page reclaim. When clearing pte
> >> access bit,
> >> we could skip tlb flush for the virtual address. The side effect is if
> >> the pte
> >> is in tlb and pte access bit is unset, when cpu access the page again,
> >> cpu will
> >> not set pte's access bit. So next time page reclaim can reclaim hot pages
> >> wrongly, but this doesn't corrupt anything. And according to intel
> >> manual, tlb
> >> has less than 1k entries, which coverers < 4M memory. In today's system,
> >> several giga byte memory is normal. After page reclaim clears pte
> >> access bit
> >> and before cpu access the page again, it's quite unlikely this page's
> >> pte is
> >> still in TLB. Skiping the tlb flush for this case sounds ok to me.
> > 
> > Agreed. In current systems, it can take a minute to write
> > all of memory to disk, while context switch (natural TLB
> > flush) times are in the dozens-of-millisecond timeframes.
> > 
> 
> I'm confused.  We used to do this since time immemorial, so if we aren't
> doing that now, that meant something changed somewhere along the line.
> It would be good to figure out if that was an intentional change or
> accidental.

I searched a little bit, the change (doing TLB flush to clear access bit) is
made between 2.6.7 - 2.6.8, I can't find the changelog, but I found a patch:
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.7-rc2/2.6.7-rc2-mm2/broken-out/mm-flush-tlb-when-clearing-young.patch

The changelog declaims this is for arm/ppc/ppc64.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
