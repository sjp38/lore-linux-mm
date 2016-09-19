Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E90066B0253
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:41:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so8741027wmg.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 07:41:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nd5si18261672wjb.182.2016.09.19.07.41.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 07:41:08 -0700 (PDT)
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <87twdc4rzs.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org>
 <20160919143106.GX5871@two.firstfloor.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <78e34617-0c63-9f1f-f7c7-93dd64556307@suse.cz>
Date: Mon, 19 Sep 2016 16:41:07 +0200
MIME-Version: 1.0
In-Reply-To: <20160919143106.GX5871@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/19/2016 04:31 PM, Andi Kleen wrote:
> On Mon, Sep 19, 2016 at 08:37:36AM -0500, Christoph Lameter wrote:
>> On Sun, 18 Sep 2016, Andi Kleen wrote:
>>
>>>> Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
>>>> hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
>>>> OOM, though. Guess not...
>>>
>>> It's already trying to do that, perhaps just some flags need to be
>>> changed?
>>
>> SLUB tries order-N and falls back to order 0 on failure.
>
> Right it tries, but Linus apparently got an OOM in the order-N
> allocation. So somehow the flag combination that it passes first
> is not preventing the OOM killer.

But Linus' error was:

    Xorg invoked oom-killer:
gfp_mask=0x240c0d0(GFP_TEMPORARY|__GFP_COMP|__GFP_ZERO), order=3,
oom_score_adj=0

There's no __GFP_NOWARN | __GFP_NORETRY, so it clearly wasn't the 
opportunistic "initial higher-order allocation". The logical conclusion 
is that it was a genuine order-3 allocation. 1kB allocation using 
order-3 would silently fail without OOM or warning, and then fallback to 
order-0.

> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
