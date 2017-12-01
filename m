Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 310556B0261
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:26:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 73so7780328pfz.11
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:26:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si5413299pfh.310.2017.12.01.09.26.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 09:26:53 -0800 (PST)
Subject: Re: [PATCH] proc: do not show VmExe bigger than total executable
 virtual memory
References: <150728955451.743749.11276392315459539583.stgit@buzz>
 <20171010152504.c0b84899a95e0bcd79b73290@linux-foundation.org>
 <bfa040ba-7935-02b6-3736-4b71aac31619@yandex-team.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8e7872bf-5af2-91db-f35e-921990849dda@suse.cz>
Date: Fri, 1 Dec 2017 18:25:25 +0100
MIME-Version: 1.0
In-Reply-To: <bfa040ba-7935-02b6-3736-4b71aac31619@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/11/2017 09:00 AM, Konstantin Khlebnikov wrote:
> On 11.10.2017 01:25, Andrew Morton wrote:
>> On Fri, 06 Oct 2017 14:32:34 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>>
>>> If start_code / end_code pointers are screwed then "VmExe" could be bigger
>>> than total executable virtual memory and "VmLib" becomes negative:
>>>
>>> VmExe:	  294320 kB
>>> VmLib:	18446744073709327564 kB
>>>
>>> VmExe and VmLib documented as text segment and shared library code size.
>>>
>>> Now their sum will be always equal to mm->exec_vm which sums size of
>>> executable and not writable and not stack areas.
>>
>> When does this happen?  What causes start_code/end_code to get "screwed"?
> 
> I don't know exactly what happened.
> I've seen this for huge (>2Gb) statically linked binary which has whole world inside.
> 
> For it start_code .. end_code range also covers one of rodata sections.
> Probably this is bug in customized linker, elf loader or both.
> 
> Anyway CONFIG_CHECKPOINT_RESTORE allows to change these pointers,
> thus we cannot trust them without validation.

Please add this to changelog. I agree that it's better/safer after your
patch. These counters are fundamentally heuristics so we can't guarantee
"proper" values for weird binaries. exec_vm OTOH is an objective value
so it makes sense to use it as a safe boundary.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>>
>> When these pointers are screwed, the result of end_code-start_code can
>> still be wrong while not necessarily being negative, yes?  In which
>> case we'll still display incorrect output?
>>
> 
> Here we split exec_vm into main code segment and libraries.
> 
> Range start_code .. end_code declared as main code segment.
> In my case it's bigger than exec_vm, so libraries have to be negative.
> 
> After my patch libraries will be 0 and whole exec_vm show as VmExe.
> At least sum VmExe + VmLib stays correct and both of them sane.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
