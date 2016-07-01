Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 296D16B026A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:14:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so244504525pfa.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:14:15 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id tp2si4810481pab.52.2016.07.01.09.14.14
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 09:14:14 -0700 (PDT)
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
 <5775F418.2000803@sr71.net>
 <CA+55aFw8nwUAgqMy8LMEKg7roTWazR1gz+DkROgRbUHseDTk1g@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577696D5.2010609@sr71.net>
Date: Fri, 1 Jul 2016 09:14:13 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFw8nwUAgqMy8LMEKg7roTWazR1gz+DkROgRbUHseDTk1g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 07/01/2016 09:07 AM, Linus Torvalds wrote:
> But I also started worrying about us just losing sight of the dirty
> bit in particular. It's not enough that we ignore the dirty bit - we'd
> still want to make sure that the underlying backing page gets marked
> dirty, even if the CPU is buggy and ends doing it "delayed" after
> we've already unmapped the page.
> 
> So I get this feeling that we may need a fair chunk of your
> patch-series anyway.

As I understand it, the erratum only affects a thread which is about to
page fault.  The write associated with the dirty bit being set never
actually gets executed.  So, the bit really *is* stray and isn't
something we need to preserve.

Otherwise, we'd be really screwed because we couldn't ever simply clear it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
