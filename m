Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65B156B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:43:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a82so39079544pfc.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:43:53 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0085.outbound.protection.outlook.com. [104.47.40.85])
        by mx.google.com with ESMTPS id 72si2147002plc.388.2017.06.16.07.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 07:43:52 -0700 (PDT)
Subject: Re: [PATCH tip/sched/core] mm/early_ioremap: Adjust early_ioremap
 system_state check
From: Tom Lendacky <thomas.lendacky@amd.com>
References: <20170614191152.28089.65392.stgit@tlendack-t1.amdoffice.net>
 <alpine.DEB.2.20.1706161257250.2254@nanos>
 <dae047fa-6b09-d15b-0362-ca814822318a@amd.com>
Message-ID: <9408c89a-8c72-32a8-9b28-87cbfcf7bcaa@amd.com>
Date: Fri, 16 Jun 2017 09:43:40 -0500
MIME-Version: 1.0
In-Reply-To: <dae047fa-6b09-d15b-0362-ca814822318a@amd.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>, Ingo Molnar <mingo@kernel.org>

On 6/16/2017 8:03 AM, Tom Lendacky wrote:
> On 6/16/2017 5:58 AM, Thomas Gleixner wrote:
>> On Wed, 14 Jun 2017, Tom Lendacky wrote:
>>> A recent change added a new system_state value, SYSTEM_SCHEDULING, which
>>> exposed a warning issued by early_ioreamp() when the system_state was 
>>> not
>>> SYSTEM_BOOTING. Since early_ioremap() can be called when the 
>>> system_state
>>> is SYSTEM_SCHEDULING, the check to issue the warning is changed from
>>> system_state != SYSTEM_BOOTING to system_state >= SYSTEM_RUNNING.
>>
>> Errm, why is that early_ioremap() stuff called after we enabled the
>> scheduler? At that point the regular ioremap stuff is long working.
> 
> As part of the SME support I'm decrypting the trampoline area during
> set_real_mode_permissions().  Since it was still valid to use the
> early_memremap()/early_ioremap() functions I chose to use those instead
> of creating new ioremap functions to support encrypted or decrypted
> mappings with and without write-protection.

Looking at this again, in setup_real_mode() I can update the trampoline
area with the proper encryption attributes using set_memory_decrypted()
before the trampoline area is copied and thus avoid having to decrypt
the area in-place.  With that I won't need to use the early_memremap()
functions.

So you can ignore this patch.

Thanks,
Tom

> 
> I could look into adding new ioremap APIs, but their usage would be
> limited to this one case.  Since the early_memremap() works I thought
> that would be the best path and just adjust the WARNing condition.
> 
> Thanks,
> Tom
> 
>>
>> Thanks,
>>
>>     tglx
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
