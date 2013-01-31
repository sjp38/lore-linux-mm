Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6FB316B000D
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 23:27:13 -0500 (EST)
Received: by mail-ve0-f171.google.com with SMTP id b10so1703874vea.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 20:27:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1301301855350.25423@eggly.anvils>
References: <1359591980-29542-1-git-send-email-walken@google.com>
	<1359591980-29542-3-git-send-email-walken@google.com>
	<alpine.LNX.2.00.1301301855350.25423@eggly.anvils>
Date: Wed, 30 Jan 2013 20:27:11 -0800
Message-ID: <CANN689Et6381+mDby_HK9SP24hooSojoR__7w0AMvDv1K_aH-A@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: accelerate mm_populate() treatment of THP pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 30, 2013 at 7:05 PM, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 30 Jan 2013, Michel Lespinasse wrote:
>
>> This change adds a page_mask argument to follow_page.
>>
>> follow_page sets *page_mask to HPAGE_PMD_NR - 1 when it encounters a THP page,
>> and to 0 in other cases.
>>
>> __get_user_pages() makes use of this in order to accelerate populating
>> THP ranges - that is, when both the pages and vmas arrays are NULL,
>> we don't need to iterate HPAGE_PMD_NR times to cover a single THP page
>> (and we also avoid taking mm->page_table_lock that many times).
>>
>> Other follow_page() call sites can safely ignore the value returned in
>> *page_mask.
>>
>> Signed-off-by: Michel Lespinasse <walken@google.com>
>
> I certainly like the skipping.
>
> And (b) why can't we just omit the additional arg, and get it from the
> page found?  You've explained the unreliability of the !FOLL_GET case
> to me privately, but that needs to be spelt out in the commit comment
> (and I'd love if we found a counter-argument, the extra arg of interest
> to almost no-one does irritate me).

Right. My understanding is that after calling follow_page() without
the FOLL_GET flag, you really can't do much with the returned page
pointer other than checking it for IS_ERR(). We don't get a reference
to the page, so it could get migrated away as soon as follow_page()
releases the page table lock. In the most extreme case, the memory
corresponding to that page could get offlined / dereferencing the page
pointer could fail.

I actually think the follow_page API is very error prone in this way,
as the returned page pointer is very tempting to use, but can't be
safely used. I almost wish we could return something like
ERR_PTR(-ESTALE) or whatever, just to make remove any temptations of
dereferencing that page pointer.

Now I agree the extra argument isn't pretty, but I don't have any
better ideas for communicating the size of the page that got touched.

> But (a) if the additional arg has to exist, then I'd much prefer it
> to be page_size than page_mask - I realize there's a tiny advantage to
> subtracting 1 from an immediate than from a variable, but I don't think
> it justifies the peculiar interface.  mask makes people think of masking.

Yes, I started with a page_size in bytes and then I moved to the
page_mask. I agree the performance advantage is tiny, and I don't mind
switching back to bytes if people are happier with it.

I think one benefit of the page_mask implementation might be that it's
easier for people to see that page_increment will end up in the
[1..HPAGE_PMD_NR] range. Would a page size in 4k page units work out ?
(I'm just not sure how to call such a quantity, though).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
