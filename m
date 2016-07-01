Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F11436B0253
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 00:39:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so214447628pfx.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 21:39:54 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id kb6si2093146pab.202.2016.06.30.21.39.54
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 21:39:54 -0700 (PDT)
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5775F418.2000803@sr71.net>
Date: Thu, 30 Jun 2016 21:39:52 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 06/30/2016 07:55 PM, Linus Torvalds wrote:
> On Thu, Jun 30, 2016 at 5:12 PM, Dave Hansen <dave@sr71.net> wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
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

We actually don't even use Dirty today.  It's (implicitly) used to
determine pte_none(), but it ends up being masked out for the
swp_offset/type() calculations entirely, much to my surprise.

I think what you suggest will work if we don't consider A/D in
pte_none().  I think there are a bunch of code path where assume that
!pte_present() && !pte_none() means swap.

> The swap-entry representation was a bit tight on 32-bit page table
> entries, but in 64-bit ones, I think we have tons of bits, don't we?
> So we could decide just to not use those two bits on x86.

Yeah, we've definitely got space.  I'll go poke around and make sure
that this works everywhere.  I agree that throwing 32-bit non-PAE under
the bus is definitely worth it here.  Nobody will care about that in a
million years.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
