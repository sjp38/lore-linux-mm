Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8A176B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:41:52 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so78286074qta.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:41:52 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id a88si4124582qka.133.2017.01.11.08.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:41:52 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id a29so22798978qtb.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:41:51 -0800 (PST)
Subject: Re: [PATCH v2] memory_hotplug: zone_can_shift() returns boolean value
References: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
 <20170109152703.4dd336106200d55d8f4deafb@linux-foundation.org>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <53c25651-026f-898a-7204-c164528ab4e6@gmail.com>
Date: Wed, 11 Jan 2017 11:41:43 -0500
MIME-Version: 1.0
In-Reply-To: <20170109152703.4dd336106200d55d8f4deafb@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, Reza Arbab <arbab@linux.vnet.ibm.com>

Hi Andrew

On 01/09/2017 06:27 PM, Andrew Morton wrote:
> On Tue, 13 Dec 2016 15:29:49 -0500 Yasuaki Ishimatsu <yasu.isimatu@gmail.com> wrote:
>
>> online_{kernel|movable} is used to change the memory zone to
>> ZONE_{NORMAL|MOVABLE} and online the memory.
>>
>> To check that memory zone can be changed, zone_can_shift() is used.
>> Currently the function returns minus integer value, plus integer
>> value and 0. When the function returns minus or plus integer value,
>> it means that the memory zone can be changed to ZONE_{NORNAL|MOVABLE}.
>>
>> But when the function returns 0, there is 2 meanings.
>>
>> One of the meanings is that the memory zone does not need to be changed.
>> For example, when memory is in ZONE_NORMAL and onlined by online_kernel
>> the memory zone does not need to be changed.
>>
>> Another meaning is that the memory zone cannot be changed. When memory
>> is in ZONE_NORMAL and onlined by online_movable, the memory zone may
>> not be changed to ZONE_MOVALBE due to memory online limitation(see
>> Documentation/memory-hotplug.txt). In this case, memory must not be
>> onlined.
>>
>> The patch changes the return type of zone_can_shift() so that memory
>> is not onlined when memory zone cannot be changed.
>
> What are the user-visible runtime effects of this fix?

The user-visible runtime effects of the fix are here:

Before applying patch:
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320
   # echo online_movable > memory4097/state
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  8388608
           managed  8388608

   online_movable operation succeeded. But memory is onlined as
   ZONE_NORMAL, not ZONE_MOVABLE.

After applying patch:
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320
   # echo online_movable > memory4097/state
   bash: echo: write error: Invalid argument
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320

   online_movable operation failed because of failure of changing
   the memory zone from ZONE_NORMAL to ZONE_MOVABLE

> Please always include this info when fixing bugs - it is required so
> that others can decide which kernel version(s) need the fix.

I'll add the above information and resend the patch as v3.

Thanks,
Yasuaki Ishimatsu

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
