Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 219866B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 18:26:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x98-v6so7353891ede.0
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:26:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n59-v6si379360edc.61.2018.11.13.15.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 15:26:28 -0800 (PST)
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <20181113094305.GM15120@dhcp22.suse.cz>
 <20181113151503.fd370e28cb9df5a0933e9b04@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d88fae5c-e12d-ca35-d200-587a2ff02ec9@suse.cz>
Date: Wed, 14 Nov 2018 00:23:28 +0100
MIME-Version: 1.0
In-Reply-To: <20181113151503.fd370e28cb9df5a0933e9b04@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 11/14/18 12:15 AM, Andrew Morton wrote:
> On Tue, 13 Nov 2018 10:43:05 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4364,6 +4353,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>>  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>>  	struct alloc_context ac = { };
>>  
>> +	/*
>> +	 * There are several places where we assume that the order value is sane
>> +	 * so bail out early if the request is out of bound.
>> +	 */
>> +	if (unlikely(order >= MAX_ORDER)) {
>> +		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>> +		return NULL;
>> +	}
>> +
> 
> I know "everybody enables CONFIG_DEBUG_VM", but given this is fastpath,
> we could help those who choose not to enable it by using
> 
> #ifdef CONFIG_DEBUG_VM
> 	if (WARN_ON_ONCE(order >= MAX_ORDER && !(gfp_mask & __GFP_NOWARN)))
> 		return NULL;
> #endif

Hmm, but that would mean there's still potential undefined behavior for
!CONFIG_DEBUG_VM, so I would prefer not to do it like that.

> 
> (Again curses 91241681c62 ("include/linux/mmdebug.h: make VM_WARN* non-rvals"))
> 
