Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89E0E82958
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:07:12 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s63so226605106ioi.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:07:12 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id t13si2013200ott.132.2016.07.01.09.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 09:07:11 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id d132so13402441oig.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:07:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5775F418.2000803@sr71.net>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com> <5775F418.2000803@sr71.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Jul 2016 09:07:10 -0700
Message-ID: <CA+55aFw8nwUAgqMy8LMEKg7roTWazR1gz+DkROgRbUHseDTk1g@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu, Jun 30, 2016 at 9:39 PM, Dave Hansen <dave@sr71.net> wrote:
>
> I think what you suggest will work if we don't consider A/D in
> pte_none().  I think there are a bunch of code path where assume that
> !pte_present() && !pte_none() means swap.

Hmm.

Thinking about it some more, I still think it's a good idea to avoid
A/D bits in the swap entries and in pte_none() and friends, and it
might simplify some of this all.

But I also started worrying about us just losing sight of the dirty
bit in particular. It's not enough that we ignore the dirty bit - we'd
still want to make sure that the underlying backing page gets marked
dirty, even if the CPU is buggy and ends doing it "delayed" after
we've already unmapped the page.

So I get this feeling that we may need a fair chunk of your patch-series anyway.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
