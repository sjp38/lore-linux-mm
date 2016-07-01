Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEF936B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:06:57 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f6so17127303ith.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:06:57 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id p137si573611oic.252.2016.06.30.20.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 20:06:57 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id s66so93640343oif.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:06:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
From: Brian Gerst <brgerst@gmail.com>
Date: Thu, 30 Jun 2016 23:06:55 -0400
Message-ID: <CAMzpN2iLBKF7vK3TuTPwYn2nZOw2q_Pn=q+g6pNuVs0k6Xd5LQ@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu, Jun 30, 2016 at 10:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Jun 30, 2016 at 5:12 PM, Dave Hansen <dave@sr71.net> wrote:
>>
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
>> Landing) has an erratum where a processor thread setting the Accessed
>> or Dirty bits may not do so atomically against its checks for the
>> Present bit.  This may cause a thread (which is about to page fault)
>> to set A and/or D, even though the Present bit had already been
>> atomically cleared.
>
> So I don't think your approach is wrong, but I suspect this is
> overkill, and what we should instead just do is to not use the A/D
> bits at all in the swap representation.
>
> The swap-entry representation was a bit tight on 32-bit page table
> entries, but in 64-bit ones, I think we have tons of bits, don't we?
> So we could decide just to not use those two bits on x86.
>
> It's not like anybody will ever care about 32-bit page tables on
> Knights Landing anyway.

Could this affect a 32-bit guest VM?

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
