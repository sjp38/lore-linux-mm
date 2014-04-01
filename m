Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 377BC6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 14:19:08 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id v1so9351394yhn.26
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:19:07 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id f21si13373747yhc.124.2014.04.01.11.19.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 11:19:07 -0700 (PDT)
Message-ID: <533B0301.3010507@citrix.com>
Date: Tue, 1 Apr 2014 19:18:41 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>	<1395425902-29817-3-git-send-email-david.vrabel@citrix.com>	<533016CB.4090807@citrix.com>	<CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>	<CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>	<20140331122625.GR25087@suse.de> <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
In-Reply-To: <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On 31/03/14 16:41, Linus Torvalds wrote:
> On Mon, Mar 31, 2014 at 5:26 AM, Mel Gorman <mgorman@suse.de> wrote:
>>
>> Ok, so how do you suggest that _PAGE_NUMA could have been implemented
>> that did *not* use _PAGE_PROTNONE on x86, trapped a fault and was not
>> expensive as hell to handle?
> 
> So on x86, the obvious model is to use another bit. We've got several.
> The _PAGE_NUMA case only matters for when _PAGE_PRESENT is clear, and
> when that bit is clear the hardware doesn't care about any of the
> other bits. Currently we use:
> 
>   #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
>   #define _PAGE_BIT_FILE          _PAGE_BIT_DIRTY
> 
> which are bits 8 and 6 respectively, afaik.
> 
> and the only rule is that (a) we should *not* use a bit we already use
> when the page is not present (since that is ambiguous!) and (b) we
> should *not* use a bit that is used by the swap index cases. I think
> bit 7 should work, but maybe I missed something.

I don't think it's sufficient to avoid collisions with bits used only
with P=0.  The original value of this bit must be retained when the
_PAGE_NUMA bit is set/cleared.

Bit 7 is PAT[2] and whilst Linux currently sets up the PAT such that
PAT[2] is a 'don't care', there has been talk up adjusting the PAT to
include more types. So I'm not sure it's a good idea to use bit 7.

What's wrong with using e.g., bit 62? And not supporting this NUMA
rebalancing feature on 32-bit non-PAE builds?

David

> Can somebody tell me why _PAGE_NUMA is *not* that bit seven? Make
> "pte_present()" on x86 just check all of the present/numa/protnone
> bits, and if any of them is set, it's a "present" page.
> 
> Now, unlike x86, some other architectures do *not* have free bits, so
> there may be problems elsewhere.
> 
>             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
