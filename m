Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C43E46B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 12:59:37 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m130so3499894ioa.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:59:37 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id q194si8235066ioe.102.2016.07.27.09.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 09:59:37 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id m101so75894354ioi.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:59:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160726205944.GM4541@io.lakedaemon.net>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net> <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
From: Nick Kralevich <nnk@google.com>
Date: Wed, 27 Jul 2016 09:59:35 -0700
Message-ID: <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: "Roberts, William C" <william.c.roberts@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

On Tue, Jul 26, 2016 at 1:59 PM, Jason Cooper <jason@lakedaemon.net> wrote:
>> > One thing I didn't make clear in my commit message is why this is good. Right
>> > now, if you know An address within in a process, you know all offsets done with
>> > mmap(). For instance, an offset To libX can yield libY by adding/subtracting an
>> > offset. This is meant to make rops a bit harder, or In general any mapping offset
>> > mmore difficult to find/guess.
>
> Are you able to quantify how many bits of entropy you're imposing on the
> attacker?  Is this a chair in the hallway or a significant increase in
> the chances of crashing the program before finding the desired address?

Quantifying the effect of many security changes is extremely
difficult, especially for a probabilistic defense like ASLR. I would
urge us to not place too high of a proof bar on this change.
Channeling Spender / grsecurity team, ASLR gets it's benefit not from
it's high benefit, but from it's low cost of implementation
(https://forums.grsecurity.net/viewtopic.php?f=7&t=3367). This patch
certainly meets the low cost of implementation bar.

In the Project Zero Stagefright post
(http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html),
we see that the linear allocation of memory combined with the low
number of bits in the initial mmap offset resulted in a much more
predictable layout which aided the attacker. The initial random mmap
base range was increased by Daniel Cashman in
d07e22597d1d355829b7b18ac19afa912cf758d1, but we've done nothing to
address page relative attacks.

Inter-mmap randomization will decrease the predictability of later
mmap() allocations, which should help make data structures harder to
find in memory. In addition, this patch will also introduce unmapped
gaps between pages, preventing linear overruns from one mapping to
another another mapping. I am unable to quantify how much this will
improve security, but it should be > 0.

I like Dave Hansen's suggestion that this functionality be limited to
64 bits, where concerns about running out of address space are
essentially nil. I'd be supportive of this change if it was limited to
64 bits.

-- Nick

-- 
Nick Kralevich | Android Security | nnk@google.com | 650.214.4037

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
