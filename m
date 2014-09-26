Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id F0B6F6B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 09:40:04 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so10259574igc.14
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 06:40:04 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id j1si2365405igo.8.2014.09.26.06.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 06:40:04 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so222860iec.9
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 06:40:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54255D58.1040802@vmware.com>
References: <54246506.50401@hurleysoftware.com>
	<20140925143555.1f276007@as>
	<5424AAD0.9010708@hurleysoftware.com>
	<542512AD.9070304@vmware.com>
	<20140926054005.5c7985c0@as>
	<542543D8.8020604@vmware.com>
	<CAF6AEGvOkPq5LQR76-VbspYyCvUxL1=W-dLc4g_aWX2wkUmRpg@mail.gmail.com>
	<54255D58.1040802@vmware.com>
Date: Fri, 26 Sep 2014 09:40:03 -0400
Message-ID: <CAF6AEGteJcYdQekMPW3vc9S6_=URqJus7-Faq-RrdTp_ETN1eQ@mail.gmail.com>
Subject: Re: page allocator bug in 3.16?
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: Chuck Ebbert <cebbert.lkml@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickens <hughd@google.com>, Linux kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Fri, Sep 26, 2014 at 8:34 AM, Thomas Hellstrom <thellstrom@vmware.com> w=
rote:
> On 09/26/2014 02:28 PM, Rob Clark wrote:
>> On Fri, Sep 26, 2014 at 6:45 AM, Thomas Hellstrom <thellstrom@vmware.com=
> wrote:
>>> On 09/26/2014 12:40 PM, Chuck Ebbert wrote:
>>>> On Fri, 26 Sep 2014 09:15:57 +0200
>>>> Thomas Hellstrom <thellstrom@vmware.com> wrote:
>>>>
>>>>> On 09/26/2014 01:52 AM, Peter Hurley wrote:
>>>>>> On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
>>>>>>> There are six ttm patches queued for 3.16.4:
>>>>>>>
>>>>>>> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_sc=
an.patch
>>>>>>> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
>>>>>>> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patc=
h
>>>>>>> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.pat=
ch
>>>>>>> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
>>>>>>> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functio=
ns.patch
>>>>>> Thanks for info, Chuck.
>>>>>>
>>>>>> Unfortunately, none of these fix TTM dma allocation doing CMA dma al=
location,
>>>>>> which is the root problem.
>>>>>>
>>>>>> Regards,
>>>>>> Peter Hurley
>>>>> The problem is not really in TTM but in CMA, There was a guy offering=
 to
>>>>> fix this in the CMA code but I guess he didn't probably because he
>>>>> didn't receive any feedback.
>>>>>
>>>> Yeah, the "solution" to this problem seems to be "don't enable CMA on
>>>> x86". Maybe it should even be disabled in the config system.
>>> Or, as previously suggested, don't use CMA for order 0 (single page)
>>> allocations....
>> On devices that actually need CMA pools to arrange for memory to be in
>> certain ranges, I think you probably do want to have order 0 pages
>> come from the CMA pool.
>
> But can the DMA subsystem or more specifically dma_alloc_coherent()
> really guarantee such things? Isn't it better for such devices to use
> CMA directly?

Well, I was thinking more specifically about a use-case that was
mentioned several times during the early CMA discussions, about video
decoders/encoders which needed Y and UV split across memory banks to
achieve sufficient bandwidth.  I assume they must use CMA directly for
this (since they'd need multiple pools per device), but not really
100% sure about that.

So perhaps, yeah, if you shunt order 0 allocations away from CMA at
the DMA layer, maybe it is ok.  If there actually is a valid use-case
for CMA on sane hardware, then maybe this is the better way, and let
the insane hw folks hack around it.

(plus, well, the use-case I was mentioning isn't really about order 0
allocations anyway)

BR,
-R


> /Thomas
>
>
>>
>> Seems like disabling CMA on x86 (where it should be unneeded) is the
>> better way, IMO
>>
>> BR,
>> -R
>>
>>
>>> /Thomas
>>>
>>> _______________________________________________
>>> dri-devel mailing list
>>> dri-devel@lists.freedesktop.org
>>> https://urldefense.proofpoint.com/v1/url?u=3Dhttp://lists.freedesktop.o=
rg/mailman/listinfo/dri-devel&k=3DoIvRg1%2BdGAgOoM1BIlLLqw%3D%3D%0A&r=3Dl5A=
go9ekmVFZ3c4M6eauqrJWGwjf6fTb%2BP3CxbBFkVM%3D%0A&m=3DUz7JXDXYXp4RlLs7G6qxMQ=
lhOOT0trW3l78xpKg6Ass%3D%0A&s=3D50d6b7b3bfd093c93a228437a3d4414e49b4de81765=
7c49c35154a115a5c2188
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
