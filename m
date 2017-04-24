Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A87036B0317
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 13:30:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o52so9621764wrb.10
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:30:24 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id m75si148938wmi.75.2017.04.24.10.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 10:30:23 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id 6so7655767wrb.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:30:23 -0700 (PDT)
Date: Mon, 24 Apr 2017 20:30:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: get_zone_device_page() in get_page() and
 page_cache_get_speculative()
Message-ID: <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Mon, Apr 24, 2017 at 10:23:59AM -0700, Dan Williams wrote:
> On Sun, Apr 23, 2017 at 4:31 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> > On Thu, Apr 20, 2017 at 02:46:51PM -0700, Dan Williams wrote:
> >> On Sat, Mar 18, 2017 at 2:52 AM, tip-bot for Kirill A. Shutemov
> >> <tipbot@zytor.com> wrote:
> >> > Commit-ID:  2947ba054a4dabbd82848728d765346886050029
> >> > Gitweb:     http://git.kernel.org/tip/2947ba054a4dabbd82848728d765346886050029
> >> > Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> > AuthorDate: Fri, 17 Mar 2017 00:39:06 +0300
> >> > Committer:  Ingo Molnar <mingo@kernel.org>
> >> > CommitDate: Sat, 18 Mar 2017 09:48:03 +0100
> >> >
> >> > x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
> >> >
> >> > This patch provides all required callbacks required by the generic
> >> > get_user_pages_fast() code and switches x86 over - and removes
> >> > the platform specific implementation.
> >> >
> >> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> > Cc: Andrew Morton <akpm@linux-foundation.org>
> >> > Cc: Aneesh Kumar K . V <aneesh.kumar@linux.vnet.ibm.com>
> >> > Cc: Borislav Petkov <bp@alien8.de>
> >> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> >> > Cc: Dann Frazier <dann.frazier@canonical.com>
> >> > Cc: Dave Hansen <dave.hansen@intel.com>
> >> > Cc: H. Peter Anvin <hpa@zytor.com>
> >> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> >> > Cc: Peter Zijlstra <peterz@infradead.org>
> >> > Cc: Rik van Riel <riel@redhat.com>
> >> > Cc: Steve Capper <steve.capper@linaro.org>
> >> > Cc: Thomas Gleixner <tglx@linutronix.de>
> >> > Cc: linux-arch@vger.kernel.org
> >> > Cc: linux-mm@kvack.org
> >> > Link: http://lkml.kernel.org/r/20170316213906.89528-1-kirill.shutemov@linux.intel.com
> >> > [ Minor readability edits. ]
> >> > Signed-off-by: Ingo Molnar <mingo@kernel.org>
> >>
> >> I'm still trying to spot the bug, but bisect points to this patch as
> >> the point at which my unit tests start failing with the following
> >> signature:
> >>
> >> [   35.423841] WARNING: CPU: 8 PID: 245 at lib/percpu-refcount.c:155
> >> percpu_ref_switch_to_atomic_rcu+0x1f5/0x200
> >
> > Okay, I've tracked it down. The issue is triggered by replacment
> > get_page() with page_cache_get_speculative().
> >
> > page_cache_get_speculative() doesn't have get_zone_device_page(). :-|
> >
> > And I think it's your bug, Dan: it's wrong to have
> > get_/put_zone_device_page() in get_/put_page(). I must be handled by
> > page_ref_* machinery to catch all cases where we manipulate with page
> > refcount.
> 
> The page_ref conversion landed in 4.6 *after* the ZONE_DEVICE
> implementation that landed in 4.5, so there was a missed conversion of
> the zone-device reference counting to page_ref.

Fair enough.

But get_page_unless_zero() definitely predates ZONE_DEVICE. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
