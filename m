Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1EA96B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:02:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m26so16326174wrm.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:02:01 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id r76si202365wme.69.2017.04.24.11.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:02:00 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id r190so75548641wme.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:02:00 -0700 (PDT)
Date: Mon, 24 Apr 2017 21:01:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: get_zone_device_page() in get_page() and
 page_cache_get_speculative()
Message-ID: <20170424180158.y26m3kgzhpmawbhg@node.shutemov.name>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
 <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name>
 <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Mon, Apr 24, 2017 at 10:47:43AM -0700, Dan Williams wrote:
> On Mon, Apr 24, 2017 at 10:30 AM, Kirill A. Shutemov
> >> >> [   35.423841] WARNING: CPU: 8 PID: 245 at lib/percpu-refcount.c:155
> >> >> percpu_ref_switch_to_atomic_rcu+0x1f5/0x200
> >> >
> >> > Okay, I've tracked it down. The issue is triggered by replacment
> >> > get_page() with page_cache_get_speculative().
> >> >
> >> > page_cache_get_speculative() doesn't have get_zone_device_page(). :-|
> >> >
> >> > And I think it's your bug, Dan: it's wrong to have
> >> > get_/put_zone_device_page() in get_/put_page(). I must be handled by
> >> > page_ref_* machinery to catch all cases where we manipulate with page
> >> > refcount.
> >>
> >> The page_ref conversion landed in 4.6 *after* the ZONE_DEVICE
> >> implementation that landed in 4.5, so there was a missed conversion of
> >> the zone-device reference counting to page_ref.
> >
> > Fair enough.
> >
> > But get_page_unless_zero() definitely predates ZONE_DEVICE. :)
> >
> 
> It does, but that's deliberate. A ZONE_DEVICE page never has a zero
> reference count, it's always owned by the device, never by the page
> allocator. ZONE_DEVICE overrides the ->lru list_head to store private
> device information and we rely on the behavior that a non-zero
> reference means the page is not added to any lru or page cache list.

So, what do you propose? Use get_page() instead of
page_cache_get_speculative() in GUP_fast() if the page belong to zone
device?

I don't like it. This situation, when we only can use subset of
helpers to manipulate page refcount creates situation waiting to explode.

I think it's still better to do it on page_ref_* level.

BTW, why do we need to pin pgmap from get_page() in first place?
I don't have enough background in ZONE_DEVICE.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
