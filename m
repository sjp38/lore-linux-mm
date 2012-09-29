Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 5A7AC6B006C
	for <linux-mm@kvack.org>; Sat, 29 Sep 2012 09:48:20 -0400 (EDT)
Date: Sat, 29 Sep 2012 15:48:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20120929134811.GC26989@redhat.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Sat, Sep 29, 2012 at 02:37:18AM +0300, Kirill A. Shutemov wrote:
> Cons:
>  - increases TLB pressure;

I generally don't like using 4k tlb entries ever. This only has the
advantage of saving 2MB-4KB RAM (globally), and a chpxchg at the first
system-wide zero page fault. I like apps to only use 2M TLB entries
whenever possible (that is going to payoff big as the number of 2M TLB
entries is going to increase over time).

I did some research with tricks using 4k ptes up to half the pmd was
filled before converting it to a THP (to save some memory and cache),
and it didn't look good, so my rule of thumb was "THP sometime costs,
even the switch from half pte filled to transhuge pmd still costs, so
to diminish the risk of slowdowns we should use 2M TLB entries
immediately, whenever possible".

Now the rule of thumb doesn't fully apply here, 1) there's no
compaction costs to offset, 2) chances are the zero page isn't very
performance critical anyway... only some weird apps uses it (but
sometime they have a legitimate reason for using it, this is why we
support it).

There would be a small cache benefit here... but even then some first
level caches are virtually indexed IIRC (always physically tagged to
avoid the software to notice) and virtually indexed ones won't get any
benefit.

It wouldn't provide even the memory saving tradeoff by dropping the
zero pmd at the first fault (not at the last). And it's better to
replace it at the first fault then the last (that matches the current
design).

Another point is that the previous patch is easier to port to other
archs by not requiring arch features to track the zero pmd.

I guess it won't make a whole lot of difference but my preference is
for the previous implementation that always guaranteed huge TLB
entries whenever possible. Said that I'm fine either ways so if
somebody has strong reasons for wanting this one, I'd like to hear
about it.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
