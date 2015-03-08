Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id AF7E56B0038
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 14:46:10 -0400 (EDT)
Received: by iecat20 with SMTP id at20so44229167iec.6
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:46:10 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id ad4si7264686igd.18.2015.03.08.11.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 11:46:10 -0700 (PDT)
Received: by igdh15 with SMTP id h15so15665115igd.3
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:46:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-5-git-send-email-mgorman@suse.de>
	<20150307163657.GA9702@gmail.com>
	<CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
	<20150308100223.GC15487@gmail.com>
	<CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
Date: Sun, 8 Mar 2015 11:46:10 -0700
Message-ID: <CA+55aFwE4K7wmPWKR2SMb9us0LQEoGeLeErrPdB--bSbwf7yzg@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sun, Mar 8, 2015 at 11:35 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>> As a second hack (not to be applied), could we change:
>>
>>  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
>>
>> to:
>>
>>  #define _PAGE_BIT_PROTNONE      (_PAGE_BIT_GLOBAL+1)
>>
>> to double check that the position of the bit does not matter?
>
> Agreed. We should definitely try that.

There's a second reason to do that, actually: the __supported_pte_mask
thing, _and_ the pageattr stuff in __split_large_page() etc play games
with _PAGE_GLOBAL. As does drivers/lguest for some reason.

So looking at this all, there's a lot of room for confusion with _PAGE_GLOBAL.

That kind of confusion would certainly explain the whole "the changes
_look_ like they do the same thing, but don't" - because of silly
semantic conflicts with PROTNONE vs GLOBAL.

                                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
