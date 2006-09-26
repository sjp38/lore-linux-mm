Date: Mon, 25 Sep 2006 17:31:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual memmap sparsity: Dealing with fragmented MAX_ORDER blocks
In-Reply-To: <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609251721140.25322@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <45181B4F.6060602@shadowen.org> <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Christoph Lameter wrote:

>    Looking through the i386 commands I see a VERR mnemonic that
>    I guess will do what you need on i386 and x86_64 in order to do
>    what we need without a page table walk.

I think I guessed wrong VERR does something with segments???

We could sidestep the issue by not marking the huge page 
non present but pointing it to a pte page with all pointers to the 
zero page.

All page flags will be cleared of the page structs in the zero page and 
thus we cannot reference an invalid address. Therefore:

static inline int page_is_buddy(struct page *page, struct page *buddy,
                                                                int order)
{
#ifdef CONFIG_HOLES_IN_ZONE
        if (!pfn_valid(page_to_pfn(buddy)))
                return 0;
#endif

        if (page_zone_id(page) != page_zone_id(buddy))
                return 0;

        if (PageBuddy(buddy) && page_order(buddy) == order) {
                BUG_ON(page_count(buddy) != 0);
                return 1;
        }
        return 0;
}

can become

static inline int page_is_buddy(struct page *page, struct page *buddy,
                                                                int order)
{
        if (page_zone_id(page) != page_zone_id(buddy))
                return 0;

        if (PageBuddy(buddy) && page_order(buddy) == order) {
                BUG_ON(page_count(buddy) != 0);
                return 1;
        }
        return 0;
}

for all cases.

Also note that page_zone_id(page) no longer needs to be using a lookup of
page->flags. We just need to insure that both pages are in the same 
MAX_ORDER group. For that to be true the upper portion of the addresses
must match.

int page_zone_id(struct page *page)
{
	return pfn_page >> MAX_ORDER;
}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
