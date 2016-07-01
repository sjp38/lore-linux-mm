Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB99828E4
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:25:03 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j185so30861147ith.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:25:03 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id g84si2035077oib.116.2016.07.01.09.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 09:25:02 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id s66so117401255oif.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:25:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577696D5.2010609@sr71.net>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
 <5775F418.2000803@sr71.net> <CA+55aFw8nwUAgqMy8LMEKg7roTWazR1gz+DkROgRbUHseDTk1g@mail.gmail.com>
 <577696D5.2010609@sr71.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Jul 2016 09:25:01 -0700
Message-ID: <CA+55aFwHGgiog+wFFDLXKjs4zVjMp-FLduGsEr800F5ruJ_aRA@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Jul 1, 2016 at 9:14 AM, Dave Hansen <dave@sr71.net> wrote:
>
> As I understand it, the erratum only affects a thread which is about to
> page fault.  The write associated with the dirty bit being set never
> actually gets executed.  So, the bit really *is* stray and isn't
> something we need to preserve.

Ok, good.

> Otherwise, we'd be really screwed because we couldn't ever simply clear it.

Oh, we could do the whole "clear the pte, then flush the tlb, then go
back and clear the stale dirty bits and move them into the backing
page".

I was afraid we might have to do something like that.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
