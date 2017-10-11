Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14B556B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 03:00:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g70so517660lfl.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 00:00:11 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id a11si1658258lfg.406.2017.10.11.00.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 00:00:08 -0700 (PDT)
Subject: Re: [PATCH] proc: do not show VmExe bigger than total executable
 virtual memory
References: <150728955451.743749.11276392315459539583.stgit@buzz>
 <20171010152504.c0b84899a95e0bcd79b73290@linux-foundation.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <bfa040ba-7935-02b6-3736-4b71aac31619@yandex-team.ru>
Date: Wed, 11 Oct 2017 10:00:06 +0300
MIME-Version: 1.0
In-Reply-To: <20171010152504.c0b84899a95e0bcd79b73290@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11.10.2017 01:25, Andrew Morton wrote:
> On Fri, 06 Oct 2017 14:32:34 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> 
>> If start_code / end_code pointers are screwed then "VmExe" could be bigger
>> than total executable virtual memory and "VmLib" becomes negative:
>>
>> VmExe:	  294320 kB
>> VmLib:	18446744073709327564 kB
>>
>> VmExe and VmLib documented as text segment and shared library code size.
>>
>> Now their sum will be always equal to mm->exec_vm which sums size of
>> executable and not writable and not stack areas.
> 
> When does this happen?  What causes start_code/end_code to get "screwed"?

I don't know exactly what happened.
I've seen this for huge (>2Gb) statically linked binary which has whole world inside.

For it start_code .. end_code range also covers one of rodata sections.
Probably this is bug in customized linker, elf loader or both.

Anyway CONFIG_CHECKPOINT_RESTORE allows to change these pointers,
thus we cannot trust them without validation.

> 
> When these pointers are screwed, the result of end_code-start_code can
> still be wrong while not necessarily being negative, yes?  In which
> case we'll still display incorrect output?
> 

Here we split exec_vm into main code segment and libraries.

Range start_code .. end_code declared as main code segment.
In my case it's bigger than exec_vm, so libraries have to be negative.

After my patch libraries will be 0 and whole exec_vm show as VmExe.
At least sum VmExe + VmLib stays correct and both of them sane.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
