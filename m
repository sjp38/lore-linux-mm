Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9252C6B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 03:34:19 -0400 (EDT)
Date: Fri, 22 May 2009 09:34:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090522073436.GA3612@elte.hu>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A15A8C7.2030505@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>


* Rik van Riel <riel@redhat.com> wrote:

> Larry H. wrote:
>> This patch adds support for the SENSITIVE flag to the low level page
>> allocator. An additional GFP flag is added for use with higher level
>> allocators (GFP_SENSITIVE, which implies GFP_ZERO).
>
> Sensitive to what?  Allocation failures?
>
> Kidding, I read the rest of your emails.  However,
> chances are whoever runs into the code later on
> will not read everything.
>
> Would GFP_CONFIDENTIAL & PG_confidential be a better
> name, since it indicates the page stores confidential
> information, which should not be leaked?

The whole kernel contains data that 'should not be leaked'.

_If_ any of this is done, i'd _very_ strongly suggest to describe it 
by what it does, not by what its subjective security attribute is.

'PG_eyes_only' or 'PG_eagle_azf_compartmented' is silly naming. It 
is silly because it hardcodes one particular expectation/model of 
'security'.

GFP_NON_PERSISTENT & PG_non_persistent is a _lot_ better, because it 
is a technical description of how information spreads. (which is the 
underlying principle of every security model)

That name alone tells us everyting what this does: it does not allow 
this data to reach or touch persistent storage. It wont be swapped 
and it wont by saved by hibernation. It will also be cleared when 
freed, to achieve its goal of never touching persistent storage.

What (if any) security relevance this has, is left to the user of 
such facilities.

In-kernel crypto key storage using GFP_NON_PERSISTENT makes some 
sense - as long as the kernel stack itself is mared 
GFP_NON_PERSISTENT as well ... which is quite hairy from a 
performance point of view: we _dont_ want to clear the full stack 
page for every kernel thread exiting.

For user-space keys it is easier to isolate the spreading of that 
data, because the kernel never reads it. So MAP_NON_PERSISTENT makes 
some sense.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
