Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8BD08E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:12:35 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v8-v6so2866138ybl.5
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:12:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c68-v6sor2730864ywf.553.2018.09.21.12.12.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 12:12:34 -0700 (PDT)
Received: from mail-yb1-f172.google.com (mail-yb1-f172.google.com. [209.85.219.172])
        by smtp.gmail.com with ESMTPSA id z125-v6sm9920395ywg.57.2018.09.21.12.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 12:12:32 -0700 (PDT)
Received: by mail-yb1-f172.google.com with SMTP id d14-v6so787971ybs.8
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:12:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180917161245.c4bb8546d2c6069b0506c5dd@linux-foundation.org>
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180917161245.c4bb8546d2c6069b0506c5dd@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 21 Sep 2018 12:12:30 -0700
Message-ID: <CAGXu5jLRuWOMPTfXAFFiVSb6CUKaa_TD4gncef+MT84pcazW6w@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 17, 2018 at 4:12 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sat, 15 Sep 2018 09:23:02 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> Data exfiltration attacks via speculative execution and
>> return-oriented-programming attacks rely on the ability to infer the
>> location of sensitive data objects. The kernel page allocator, has
>> predictable first-in-first-out behavior for physical pages. Pages are
>> freed in physical address order when first onlined. There are also
>> mechanisms like CMA that can free large contiguous areas at once
>> increasing the predictability of allocations in physical memory.
>>
>> In addition to the security implications this randomization also
>> stabilizes the average performance of direct-mapped memory-side caches.
>> This includes memory-side caches like the one on the Knights Landing
>> processor and those generally described by the ACPI HMAT (Heterogeneous
>> Memory Attributes Table [1]). Cache conflicts are spread over a random
>> distribution rather than localized.
>>
>> Given the performance sensitivity of the page allocator this
>> randomization is only performed for MAX_ORDER (4MB by default) pages. A
>> kernel parameter, page_alloc.shuffle_page_order, is included to change
>> the page size where randomization occurs.
>>
>> [1]: See ACPI 6.2 Section 5.2.27.5 Memory Side Cache Information Structure
>
> I'm struggling to understand the justification of all of this.  Are
> such attacks known to exist?  Or reasonably expected to exist in the
> future?  What is the likelihood and what is their cost?  Or is this all
> academic and speculative and possibly pointless?

While we already have a base-address randomization
(CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
memory layouts would certainly be using the predictability of
allocation ordering (i.e. for attacks where the base address isn't
important: only the relative positions between allocated memory). This
is common in lots of heap-style attacks. They try to gain control over
ordering by spraying allocations, etc.

I'd really like to see this because it gives us something similar to
CONFIG_SLAB_FREELIST_RANDOM but for the page allocator. (This may be
worth mentioning in the series, especially as a comparison to its
behavior and this.)

> ie, something must have motivated you to do this work rather than
> <something-else>.  Please spell out that motivation.

I'd be curious to hear more about the mentioned cache performance
improvements. I love it when a security feature actually _improves_
performance. :)

Thanks for working on this!

-Kees

-- 
Kees Cook
Pixel Security
