Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E57C36B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 12:07:06 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e29-v6so12987081oiy.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 09:07:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d89-v6sor5404010oic.136.2018.07.06.09.07.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 09:07:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180706100310.GB3483@gmail.com>
References: <153065162801.12250.4860144566061573514.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082435.GA29656@gmail.com> <CAPcyv4hw1a8+wwTYaQ0G0jWQzBCDaZ8zxYXw6gXtuWBYGX1LeQ@mail.gmail.com>
 <20180706100310.GB3483@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Jul 2018 09:06:59 -0700
Message-ID: <CAPcyv4gTVr7wiN5t4wUsqoWYpNajjj=77SEHC0Ew_gw0eDs93Q@mail.gmail.com>
Subject: Re: [PATCH] x86/numa_emulation: Fix uniform size build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Wei Yang <richard.weiyang@gmail.com>, kbuild test robot <lkp@intel.com>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jul 6, 2018 at 3:03 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dan Williams <dan.j.williams@intel.com> wrote:
>
>> > config attached.
>
> Doh, I intended to attach the config - attached now.
>
>> > These numa_emulation changes are a bit of a trainwreck - I'm removing both
>> > num_emulation commits from -tip for now, could you please resubmit a fixed/tested
>> > combo version?
>>
>> So I squashed the fix and let the 0day robot chew on it all day with no reports
>> as of yet. I just recompiled it here and am not seeing the link failure, can you
>> send me the details of the kernel config + gcc version that is failing?
>
> My guess: it's some weird Kconfig combination in this 32-bit config.
>
> Can you reproduce it with this config?

Yup, got it, thanks!

Turning on debuginfo I get:

arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform':
arch/x86/mm/numa_emulation.c:257: undefined reference to `__udivdi3'

Previously we were dividing by a power-of-2 constant MAX_NUM_NODES,
and I believe in my builds the compiler was still deducing the
constant from the "nr_nodes = MAX_NUM_NODES" assignment. Fix inbound,
and I believe it will make it even clearer the difference between the
typical split and the new uniform split capability.
