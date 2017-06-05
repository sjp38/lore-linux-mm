Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 491016B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 05:27:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a3so2105682wma.12
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 02:27:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d33si28840298wrd.85.2017.06.05.02.27.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 02:27:24 -0700 (PDT)
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170602125059.66209870607085b84c257593@linux-foundation.org>
 <8a810c81-6a72-2af0-a450-6f03c71d8cca@suse.cz>
 <20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org>
 <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
 <20170602141041.baace0cfa370b6bec6d411b4@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0457fa18-fdaa-6572-819d-f918c49c0c6f@suse.cz>
Date: Mon, 5 Jun 2017 11:27:20 +0200
MIME-Version: 1.0
In-Reply-To: <20170602141041.baace0cfa370b6bec6d411b4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/02/2017 11:10 PM, Andrew Morton wrote:
> On Fri, 2 Jun 2017 22:55:12 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> On 06/02/2017 10:40 PM, Andrew Morton wrote:
>>> On Fri, 2 Jun 2017 22:31:47 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>>>> Perhaps we should be adding new prctl modes to select this new
>>>>> behaviour and leave the existing PR_SET_THP_DISABLE behaviour as-is?
>>>>
>>>> I think we can reasonably assume that most users of the prctl do just
>>>> the fork() & exec() thing, so they will be unaffected.
>>>
>>> That sounds optimistic.  Perhaps people are using the current behaviour
>>> to set on particular mapping to MMF_DISABLE_THP, with
>>>
>>> 	prctl(PR_SET_THP_DISABLE)
>>> 	mmap()
>>> 	prctl(PR_CLR_THP_DISABLE)
>>>
>>> ?
>>>
>>> Seems a reasonable thing to do.
>>
>> Using madvise(MADV_NOHUGEPAGE) seems reasonabler to me, with the same
>> effect. And it's older (2.6.38).
>>
>>> But who knows - people do all sorts of
>>> inventive things.
>>
>> Yeah :( but we can hope they don't even know that the prctl currently
>> behaves they way it does - man page doesn't suggest it would, and most
>> of us in this thread found it surprising.
> 
> Well.  There might be such people and sometimes we do make people
> unhappy.  it partly depends on how traumatic it would be to leave the
> current behaviour as-is.  Have you evaluated such a patch?

You mean introducing a new prctl instead of changing the existing one? I
can evaluate that as being ugly :)
Well, maybe we could use arg3, because currently we have:
        case PR_SET_THP_DISABLE:
                if (arg3 || arg4 || arg5)
                        return -EINVAL;

We could make non-zero arg3 (or specific value of arg3) set the new
"immediate" behavior. This would also take care of the discovery of
kernels that support the fixed/altered behavior, without having to check
uname etc - just check if we got -EINVAL.

I'm just not sure how to implement PR_GET_THP_DISABLE properly in such
scenario. Or what happens when somebody calls SET with arg3==0 and then
arg3==1 (or vice versa). But we would have to think about it even when
we introduced a newly named option. Reminds me of the MLOCK_ONFAULT
discussions...

>>>> And as usual, if
>>>> somebody does complain in the end, we revert and try the other way?
>>>
>>> But by then it's too late - the new behaviour will be out in the field.
>>
>> Revert in stable then?
>> But I don't think this patch should go to stable. I understand right
>> that CRIU will switch to the UFFDIO_COPY approach and doesn't need the
>> prctl change/new madvise anymore?
> 
> What I mean is that the new behaviour will go out in 4.12 and it may
> be many months before we find out that we broke someone.  By then, we
> can't go back because others may be assuming the new behaviour.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
