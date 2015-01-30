Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7072D6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:44:28 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so54813971pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:44:28 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id bo8si14582562pdb.47.2015.01.30.09.44.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 09:44:27 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000LHN44QU9B0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 17:48:27 +0000 (GMT)
Message-id: <54CBC2EE.6050709@samsung.com>
Date: Fri, 30 Jan 2015 20:44:14 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 16/17] module: fix types of device tables aliases
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-17-git-send-email-a.ryabinin@samsung.com>
 <20150129151314.8b3951ff70d67cde9223f927@linux-foundation.org>
In-reply-to: <20150129151314.8b3951ff70d67cde9223f927@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>

On 01/30/2015 02:13 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:12:00 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
>> Normally alias should have the same type as aliased symbol.
>>
>> Device tables are arrays, so they have 'struct type##_device_id[x]'
>> types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
>> 	'struct type##_device_id'.
>>
>> This inconsistency confuses compiler, it could make a wrong
>> assumption about variable's size which leads KASan to
>> produce a false positive report about out of bounds access.
> 
> The changelog describes the problem but doesn't describe how the patch
> addresses the problem.  Some more details would be useful.
> 

For every global variable compiler calls __asan_register_globals()
passing information about global variable (address, size, size with redzone, name ...)
__asan_register_globals() poison symbols redzone so we could detect out of bounds access.

If we have alias to symbol __asan_register_globals() will be called as for symbol so for alias.
Compiler determines size of variable by its type.
Alias and symbol have the same address, but if alias have the wrong size we will
poison part of memory that actually belongs to the symbol, not the redzone.


>> --- a/include/linux/module.h
>> +++ b/include/linux/module.h
>> @@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
>>  #ifdef MODULE
>>  /* Creates an alias so file2alias.c can find device table. */
>>  #define MODULE_DEVICE_TABLE(type, name)					\
>> -  extern const struct type##_device_id __mod_##type##__##name##_device_table \
>> +extern typeof(name) __mod_##type##__##name##_device_table \
>>    __attribute__ ((unused, alias(__stringify(name))))
> 
> We lost the const?  If that's deliberate then why?  What are the
> implications?  Do the device tables now go into rw memory?
> 

Lack of const is unintentional, but this should be harmless because
this is just an alias to device table.

I'll add const back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
