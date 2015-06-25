Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B13176B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 15:15:18 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so26709616wic.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 12:15:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18si54313938wjs.134.2015.06.25.12.15.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 12:15:17 -0700 (PDT)
Message-ID: <558C5342.9020702@suse.cz>
Date: Thu, 25 Jun 2015 21:15:14 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>	<20150608174551.GA27558@gmail.com>	<20150609084739.GQ26425@suse.de>	<20150609103231.GA11026@gmail.com>	<20150609112055.GS26425@suse.de>	<20150609124328.GA23066@gmail.com>	<5577078B.2000503@intel.com>	<20150621202231.GB6766@node.dhcp.inet.fi>	<20150625114819.GA20478@gmail.com> <CA+55aFykFDZBEP+fBeqF85jSVuhWVjL5SW_22FTCMrCeoihauw@mail.gmail.com>
In-Reply-To: <CA+55aFykFDZBEP+fBeqF85jSVuhWVjL5SW_22FTCMrCeoihauw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, H Peter Anvin <hpa@zytor.com>, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

On 25.6.2015 20:36, Linus Torvalds wrote:
> 
> On Jun 25, 2015 04:48, "Ingo Molnar" <mingo@kernel.org
> <mailto:mingo@kernel.org>> wrote:
>>
>>  - 1x, 2x, 3x, 4x means up to 4 adjacent 4K vmalloc()-ed pages are accessed, the
>>    first byte in each
> 
> So that test is a bit unfair. From previous timing of Intel TLB fills, I can
> tell you that Intel is particularly good at doing adjacent entries.
> 
> That's independent of the fact that page tables have very good locality (if they
> are the radix tree type - the hashed page tables that ppc uses are shit). So
> when filling adjacent entries, you take the cache misses for the page tables
> only once, but even aside from that, Intel send to do particularly well at the
> "next page" TLB fill case

AFAIK that's because they also cache partial translations, so if the first 3
levels are the same (as they mostly are for the "next page" scenario) it will
only have to look at the last level of pages tables. AMD does that too.

> Now, I think that's a reasonably common case, and I'm not saying that it's
> unfair to compare for that reason, but it does highlight the good case for TLB
> walking.
> 
> So I would suggest you highlight the bad case too: use invlpg to invalidate
> *one* TLB entry, and then walk four non-adjacent entries. And compare *that* to
> the full TLB flush.
> 
> Now, I happen to still believe in the full flush, but let's not pick benchmarks
> that might not show the advantages of the finer granularity.
> 
>         Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
