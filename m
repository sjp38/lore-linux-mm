Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DEAAA6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 14:40:24 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so1056630pdj.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:40:24 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id fu1si1988606pbc.284.2013.12.12.11.40.22
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 11:40:23 -0800 (PST)
Message-ID: <52AA10E5.9040708@sr71.net>
Date: Thu, 12 Dec 2013 11:39:17 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] mm: slab: move around slab ->freelist for cmpxchg
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com> <20131211224025.70B40B9C@viggo.jf.intel.com> <00000142e7ea519d-8906d225-c99c-44b5-b381-b573c75fd097-000000@email.amazonses.com>
In-Reply-To: <00000142e7ea519d-8906d225-c99c-44b5-b381-b573c75fd097-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On 12/12/2013 09:46 AM, Christoph Lameter wrote:
> On Wed, 11 Dec 2013, Dave Hansen wrote:
>> The write-argument to cmpxchg_double() must be 16-byte aligned.
>> We used to align 'struct page' itself in order to guarantee this,
>> but that wastes 8-bytes per page.  Instead, we take 8-bytes
>> internal to the page before page->counters and move freelist
>> between there and the existing 8-bytes after counters.  That way,
>> no matter how 'stuct page' itself is aligned, we can ensure that
>> we have a 16-byte area with which to to this cmpxchg.
> 
> Well this adds additional branching to the fast paths.

I don't think it *HAS* to inherently.  The reason here is really that we
swap the _order_ of the arguments to the cmpxchg() since their order in
memory changes.  Essentially, we do:

| flags | freelist  | counters |          |
| flags |           | counters | freelist |

I did this so I wouldn't have to make a helper for ->counters.  But, if
we also move counters around, we can do:

| flags | counters | freelist |          |
| flags |          | counters | freelist |

I believe we can do that all with plain pointer arithmetic and masks so
that it won't cost any branches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
