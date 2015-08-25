Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 727219003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:20:04 -0400 (EDT)
Received: by laba3 with SMTP id a3so99369239lab.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:20:03 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id oa2si16116359lbb.128.2015.08.25.07.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 07:20:02 -0700 (PDT)
Received: by labgv11 with SMTP id gv11so31471925lab.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:20:02 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/3 v6] mm/vmalloc: Cache the vmalloc memory info
References: <20150824075018.GB20106@gmail.com>
	<20150824125402.28806.qmail@ns.horizon.com>
	<20150825095638.GA24750@gmail.com>
Date: Tue, 25 Aug 2015 16:19:59 +0200
In-Reply-To: <20150825095638.GA24750@gmail.com> (Ingo Molnar's message of
	"Tue, 25 Aug 2015 11:56:38 +0200")
Message-ID: <87io83wiuo.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

On Tue, Aug 25 2015, Ingo Molnar <mingo@kernel.org> wrote:

> * George Spelvin <linux@horizon.com> wrote:
>
>> (I hope I'm not annoying you by bikeshedding this too much, although I
>> think this is improving.)
>
> [ I don't mind, although I wish other, more critical parts of the kernel got this
>   much attention as well ;-) ]
>

Since we're beating dead horses, let me point out one possibly
unintentional side-effect of initializing just one of vmap_info{,_cache}_gen:

$ nm -n vmlinux | grep -E 'vmap_info(_cache)?_gen'
ffffffff81e4e5e0 d vmap_info_gen
ffffffff820d5700 b vmap_info_cache_gen

[Up-thread, you wrote "I also moved the function-static cache next to the
flag and seqlock - this should further compress the cache footprint."]

One should probably ensure that they end up in the same cacheline if one
wants the fast-path to be as fast as possible - the easiest way to
ensure that is to put them in a small struct, and that might as well
contain the spinlock and the cache itself as well.

It's been fun seeing this evolve, but overall, I tend to agree with
Peter: It's a lot of complexity for little gain. If we're not going to
just kill the Vmalloc* fields (which is probably too controversial)
I'd prefer Linus' simpler version.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
