Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2386B033C
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 13:47:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a3so101731990oii.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:47:46 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id g23si10126159ote.249.2017.04.24.10.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 10:47:45 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id x184so144781537oia.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:47:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name> <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
 <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Apr 2017 10:47:43 -0700
Message-ID: <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
Subject: Re: get_zone_device_page() in get_page() and page_cache_get_speculative()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Mon, Apr 24, 2017 at 10:30 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Apr 24, 2017 at 10:23:59AM -0700, Dan Williams wrote:
>> On Sun, Apr 23, 2017 at 4:31 PM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>> > On Thu, Apr 20, 2017 at 02:46:51PM -0700, Dan Williams wrote:
>> >> On Sat, Mar 18, 2017 at 2:52 AM, tip-bot for Kirill A. Shutemov
>> >> <tipbot@zytor.com> wrote:
>> >> > Commit-ID:  2947ba054a4dabbd82848728d765346886050029
>> >> > Gitweb:     http://git.kernel.org/tip/2947ba054a4dabbd82848728d765346886050029
>> >> > Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> >> > AuthorDate: Fri, 17 Mar 2017 00:39:06 +0300
>> >> > Committer:  Ingo Molnar <mingo@kernel.org>
>> >> > CommitDate: Sat, 18 Mar 2017 09:48:03 +0100
>> >> >
>> >> > x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
>> >> >
>> >> > This patch provides all required callbacks required by the generic
>> >> > get_user_pages_fast() code and switches x86 over - and removes
>> >> > the platform specific implementation.
>> >> >
>> >> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> >> > Cc: Andrew Morton <akpm@linux-foundation.org>
>> >> > Cc: Aneesh Kumar K . V <aneesh.kumar@linux.vnet.ibm.com>
>> >> > Cc: Borislav Petkov <bp@alien8.de>
>> >> > Cc: Catalin Marinas <catalin.marinas@arm.com>
>> >> > Cc: Dann Frazier <dann.frazier@canonical.com>
>> >> > Cc: Dave Hansen <dave.hansen@intel.com>
>> >> > Cc: H. Peter Anvin <hpa@zytor.com>
>> >> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> >> > Cc: Peter Zijlstra <peterz@infradead.org>
>> >> > Cc: Rik van Riel <riel@redhat.com>
>> >> > Cc: Steve Capper <steve.capper@linaro.org>
>> >> > Cc: Thomas Gleixner <tglx@linutronix.de>
>> >> > Cc: linux-arch@vger.kernel.org
>> >> > Cc: linux-mm@kvack.org
>> >> > Link: http://lkml.kernel.org/r/20170316213906.89528-1-kirill.shutemov@linux.intel.com
>> >> > [ Minor readability edits. ]
>> >> > Signed-off-by: Ingo Molnar <mingo@kernel.org>
>> >>
>> >> I'm still trying to spot the bug, but bisect points to this patch as
>> >> the point at which my unit tests start failing with the following
>> >> signature:
>> >>
>> >> [   35.423841] WARNING: CPU: 8 PID: 245 at lib/percpu-refcount.c:155
>> >> percpu_ref_switch_to_atomic_rcu+0x1f5/0x200
>> >
>> > Okay, I've tracked it down. The issue is triggered by replacment
>> > get_page() with page_cache_get_speculative().
>> >
>> > page_cache_get_speculative() doesn't have get_zone_device_page(). :-|
>> >
>> > And I think it's your bug, Dan: it's wrong to have
>> > get_/put_zone_device_page() in get_/put_page(). I must be handled by
>> > page_ref_* machinery to catch all cases where we manipulate with page
>> > refcount.
>>
>> The page_ref conversion landed in 4.6 *after* the ZONE_DEVICE
>> implementation that landed in 4.5, so there was a missed conversion of
>> the zone-device reference counting to page_ref.
>
> Fair enough.
>
> But get_page_unless_zero() definitely predates ZONE_DEVICE. :)
>

It does, but that's deliberate. A ZONE_DEVICE page never has a zero
reference count, it's always owned by the device, never by the page
allocator. ZONE_DEVICE overrides the ->lru list_head to store private
device information and we rely on the behavior that a non-zero
reference means the page is not added to any lru or page cache list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
