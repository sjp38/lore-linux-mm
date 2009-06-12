Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 824626B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:10:03 -0400 (EDT)
Message-ID: <4A326ECB.3070607@cs.helsinki.fi>
Date: Fri, 12 Jun 2009 18:05:47 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <alpine.LFD.2.01.0906120800450.3237@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.01.0906120800450.3237@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Linus Torvalds wrote:
> 
> On Fri, 12 Jun 2009, Pekka J Enberg wrote:
>>  
>> +	if (system_state != SYSTEM_RUNNING)
>> +		local_flags &= ~__GFP_WAIT;
>> +
>> +	might_sleep_if(local_flags & __GFP_WAIT);
> 
> This is pointless.
> 
> You're doing the "might_sleep_if()" way too late. At that point, you've 
> already lost 99% of all coverage, since now none of the cases of just 
> finding a free slab entry on the list will ever trigger that 
> "might_sleep()" case.
> 
> So you need to do this _early_, at the entry-point, not late, at cache 
> re-fill time.
> 
> So rather than removing the might_sleep_if() at the early point, and then 
> moving it to this late stage (because you only do the local_flags fixups 
> late), you need to move the local-flags fixup early instead, and do the 
> might_sleep_it() there.
> 
> The whole point of "might_sleep()" is that it triggers every time if 
> something is called in the wrong context - not just for the cases where it 
> actually _does_ sleep.

OK, makes sense. So what do you think of this patch then:

http://patchwork.kernel.org/patch/29733/

It's what Ben has been proposing all along in a slightly edited form.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
