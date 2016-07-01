Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEAC6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 22:56:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d132so104892007oig.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 19:56:00 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id 194si567229oie.137.2016.06.30.19.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 19:55:59 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id r2so93462370oih.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 19:55:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160701001218.3D316260@viggo.jf.intel.com>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 30 Jun 2016 19:55:58 -0700
Message-ID: <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu, Jun 30, 2016 at 5:12 PM, Dave Hansen <dave@sr71.net> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
> Landing) has an erratum where a processor thread setting the Accessed
> or Dirty bits may not do so atomically against its checks for the
> Present bit.  This may cause a thread (which is about to page fault)
> to set A and/or D, even though the Present bit had already been
> atomically cleared.

So I don't think your approach is wrong, but I suspect this is
overkill, and what we should instead just do is to not use the A/D
bits at all in the swap representation.

The swap-entry representation was a bit tight on 32-bit page table
entries, but in 64-bit ones, I think we have tons of bits, don't we?
So we could decide just to not use those two bits on x86.

It's not like anybody will ever care about 32-bit page tables on
Knights Landing anyway.

So rather than add this kind of complexity and worry, how about just
simplifying the problem?

Or was there some discussion or implication I missed?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
