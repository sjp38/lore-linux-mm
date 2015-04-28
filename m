Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id B57F76B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:49:51 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so8309020lbb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:49:50 -0700 (PDT)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com. [209.85.215.51])
        by mx.google.com with ESMTPS id wx3si18120560lbb.142.2015.04.28.16.49.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:49:49 -0700 (PDT)
Received: by layy10 with SMTP id y10so8221487lay.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:49:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw2KMm=E9OYQkhJqL+9pmUoaqdO9m4jJZFw3Jr4=Br4Eg@mail.gmail.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi> <55400CA7.3050902@redhat.com>
 <CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
 <CA+55aFz6CfnVgGABpGZ4ywqaOyt2E3KFO9zY_H_nH1R=nria-A@mail.gmail.com>
 <CALCETrXEP+00uezAo5dYTRFLFH0hfk9KxgDTd2zSusUgJz8NDg@mail.gmail.com> <CA+55aFw2KMm=E9OYQkhJqL+9pmUoaqdO9m4jJZFw3Jr4=Br4Eg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Apr 2015 16:49:28 -0700
Message-ID: <CALCETrW7Syc6bZTptj2umGugu9CZ56wZkGF4abEwhpBYQgAOqw@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 4:38 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Apr 28, 2015 at 4:23 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> I think we can do it without that by keeping the mapping in reverse as
>> I sort of outlined -- for each cpu, store a mapping from mm to pcid.
>> When things fall out of the list, no big deal.
>
> So you do it by just having a per-cpu array of (say, 64 entries), you
> now end up having to search that every time you do a task switch to
> find the asid for the mm. And even then you've limited yourself to
> just six bits, because doing the same for a possible full 12-bit asid
> would not be possible.
>
> It's actually much simpler if you just do it the other way.

I'm unconvinced.  I doubt that trying to keep more than 4-8 PCIDs
alive in a cpu's TLB is ever a win.  After all, the TLB isn't that
big, and, if we're only the 7th most recent mm to have been loaded on
a cpu, I doubt any of our TLB entries are still likely to be there.

Given that, even if we need 16 bytes of generation counter and such in
the per-cpu array, that's at most 128 bytes.  In practice, we really
ought to be able to get it down to closer to 8 bytes with some care or
we could only use 4 PCIDs, at which point the whole per-cpu structure
fits in a single cache line.  We can search it with 4-8 branches and
no additional L1 misses.

Sure, with 64 entries this would be expensive, but I think that's excessive.

Also, this approach keeps the cost of blowing away stale PCIDs when we
need to invalidate a TLB entry on an inactive PCID down to a single
write as opposed to digging through the per-mm array to poke at the
state for each cpu it might be cached in.  But maybe I missed some
trick that avoids needing to do that.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
