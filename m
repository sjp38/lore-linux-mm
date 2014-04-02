Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id BDBC36B009B
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 07:34:02 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so40298lbg.35
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 04:34:01 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w10si1020946lal.21.2014.04.02.04.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Apr 2014 04:34:00 -0700 (PDT)
Message-ID: <533BF59C.1080203@parallels.com>
Date: Wed, 2 Apr 2014 15:33:48 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com> <1395425902-29817-3-git-send-email-david.vrabel@citrix.com> <533016CB.4090807@citrix.com> <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com> <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com> <20140331122625.GR25087@suse.de> <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com> <533B0301.3010507@citrix.com> <CA+55aFw2wReYNaxtTRYjEWTRsV=bMAFq8YK3=qX-PCvQjY72Kw@mail.gmail.com> <20140401190344.GX4872@moon>
In-Reply-To: <20140401190344.GX4872@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Vrabel <david.vrabel@citrix.com>, Mel Gorman <mgorman@suse.de>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On 04/01/2014 11:03 PM, Cyrill Gorcunov wrote:
> On Tue, Apr 01, 2014 at 11:43:11AM -0700, Linus Torvalds wrote:
>> On Tue, Apr 1, 2014 at 11:18 AM, David Vrabel <david.vrabel@citrix.com> wrote:
>>>
>>> I don't think it's sufficient to avoid collisions with bits used only
>>> with P=0.  The original value of this bit must be retained when the
>>> _PAGE_NUMA bit is set/cleared.
>>>
>>> Bit 7 is PAT[2] and whilst Linux currently sets up the PAT such that
>>> PAT[2] is a 'don't care', there has been talk up adjusting the PAT to
>>> include more types. So I'm not sure it's a good idea to use bit 7.
>>>
>>> What's wrong with using e.g., bit 62? And not supporting this NUMA
>>> rebalancing feature on 32-bit non-PAE builds?
>>
>> Sounds good to me, but it's not available in 32-bit PAE. The high bits
>> are all reserved, afaik.
>>
>> But you'd have to be insane to care about NUMA balancing on 32-bit,
>> even with PAE. So restricting it to x86-64 and using the high bits (I
>> think bits 52-62 are all available to SW) sounds fine to me.
>>
>> Same goes for soft-dirty. I think it's fine if we say that you won't
>> have soft-dirty with a 32-bit kernel. Even with PAE.
> 
> Well, at the moment we use soft-dirty for x86-64 only in criu but there
> were plans to implement complete 32bit support as well. While personally
> I don't mind dropping soft-dirty for non x86-64 case, I would like
> to hear Pavel's opinion, Pavel?

We (Parallels) don't have plans on C/R on 32-bit kernels, but I speak only
for Parallels. However, people I know who need 32-bit C/R use ARM :)

> (n.b, i'm still working on cleaning up _page bits, it appeared to
>  be harder than I've been expecting).
> .

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
