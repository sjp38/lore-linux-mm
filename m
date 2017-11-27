Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 705ED6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:36:57 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id p23so12360617oie.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:36:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r15sor9510180oth.166.2017.11.27.11.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:36:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87vahv8whv.fsf@linux.intel.com>
References: <23066.59196.909026.689706@gargle.gargle.HOWL> <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <87vahv8whv.fsf@linux.intel.com>
From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Mon, 27 Nov 2017 20:36:55 +0100
Message-ID: <CAM43=SPgi9aXGFWYwpqeN26s5aUTdk7F6C+5wgrQOTq2QmvTzA@mail.gmail.com>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon, Nov 27, 2017 at 6:25 PM, Andi Kleen <ak@linux.intel.com> wrote:
> It's an arbitrary scaling limit on the how many mappings the process
> has. The more memory you have the bigger a problem it is. We've
> ran into this problem too on larger systems.
>
> The reason the limit was there originally because it allows a DoS
> attack against the kernel by filling all unswappable memory up with VMAs.
>
> The old limit was designed for much smaller systems than we have
> today.
>
> There needs to be some limit, but it should be on the number of memory
> pinned by the VMAs, and needs to scale with the available memory,
> so that large systems are not penalized.

Fully agreed.  One problem with the current limit is that number of VMAs
is only weakly related to the amount of memory one has mapped, and is
also prone to grow due to memory fragmentation.  I've seen processes
differ by 3X number of VMAs, even though they ran the same code and
had similar memory sizes; they only differed on how long they had been
running and which servers they ran on (and how long those had been up).

> Unfortunately just making it part of the existing mlock limit could
> break some existing setups which max out the mlock limit with something
> else. Maybe we need a new rlimit for this?
>
> -Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
