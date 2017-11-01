Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5186B026D
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:21:23 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so3726353pgu.17
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:21:23 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u2si655638plm.60.2017.11.01.15.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:21:22 -0700 (PDT)
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223154.67F15B2A@viggo.jf.intel.com>
 <CALCETrW06XjaWYD1O_HPXPDrHS96FZz9=OkPCQ3vsKrAxnr8+A@mail.gmail.com>
 <20171101101147.x2gvag62zpzydgr3@node.shutemov.name>
 <CALCETrVhKwGPN-=sL5SoSg1ussO+oCfzH1cJ+ZSWb69Y51XjXg@mail.gmail.com>
 <20171101105629.xne4hbivhu6ex3bx@node.shutemov.name>
 <CALCETrVX6-wk08StxPSafJH5q7awXXwbE9Pz_Axf+17cH7BOdA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e232dad3-9076-0d9e-103a-858b0b0300bf@linux.intel.com>
Date: Wed, 1 Nov 2017 15:21:21 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrVX6-wk08StxPSafJH5q7awXXwbE9Pz_Axf+17cH7BOdA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/01/2017 04:18 AM, Andy Lutomirski wrote:
>>> How about just adding a VM_WARN_ON_ONCE, then?
>> What's wrong with xor? The function will continue to work this way even if
>> CR4.PGE is disabled.
> That's true.  OTOH, since no one is actually proposing doing that,
> there's an argument that people should get warned and therefore be
> forced to think about it.

What this patch does in the end is make sure that
__native_flush_tlb_global_irq_disabled() works, no matter the intiial
state of CR4.PGE, *and* it makes it WARN if it gets called in an
unexpected initial state (CR4.PGE).

That's the best of both worlds IMNHO.  Makes people think, and does the
right thing no matter what.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
