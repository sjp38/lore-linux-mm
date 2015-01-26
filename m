Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id E98B56B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:04:29 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id a3so7187923oib.8
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:04:29 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id x8si4953292obw.51.2015.01.26.06.04.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 06:04:29 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YFkHA-002Ail-Sq
	for linux-mm@kvack.org; Mon, 26 Jan 2015 14:04:26 +0000
Message-ID: <54C6494D.80802@roeck-us.net>
Date: Mon, 26 Jan 2015 06:03:57 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050445.GA22751@roeck-us.net> <20150123111304.GA5975@node.dhcp.inet.fi> <54C263CC.1060904@roeck-us.net> <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org> <20150124055207.GA8926@roeck-us.net> <20150126122944.GE25833@node.dhcp.inet.fi>
In-Reply-To: <20150126122944.GE25833@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 01/26/2015 04:29 AM, Kirill A. Shutemov wrote:
> On Fri, Jan 23, 2015 at 09:52:07PM -0800, Guenter Roeck wrote:
>> On Fri, Jan 23, 2015 at 01:55:19PM -0800, Andrew Morton wrote:
>>> On Fri, 23 Jan 2015 07:07:56 -0800 Guenter Roeck <linux@roeck-us.net> wrote:
>>>
>>>>>>
>>>>>> qemu:microblaze generates warnings to the console.
>>>>>>
>>>>>> WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
>>>>>>
>>>>>> with various call stacks. See
>>>>>> http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
>>>>>> for details.
>>>>>
>>>>> Could you try patch below? Completely untested.
>>>>>
>>>>> >From b584bb8d493794f67484c0b57c161d61c02599bc Mon Sep 17 00:00:00 2001
>>>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>>> Date: Fri, 23 Jan 2015 13:08:26 +0200
>>>>> Subject: [PATCH] microblaze: define __PAGETABLE_PMD_FOLDED
>>>>>
>>>>> Microblaze uses custom implementation of PMD folding, but doesn't define
>>>>> __PAGETABLE_PMD_FOLDED, which generic code expects to see. Let's fix it.
>>>>>
>>>>> Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
>>>>> It also fixes problems with recently-introduced pmd accounting.
>>>>>
>>>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>>> Reported-by: Guenter Roeck <linux@roeck-us.net>
>>>>
>>>> Tested working.
>>>>
>>>> Tested-by: Guenter Roeck <linux@roeck-us.net>
>>>>
>>>> Any idea how to fix the sh problem ?
>>>
>>> Can you tell us more about it?  All I'm seeing is "qemu:sh fails to
>>> shut down", which isn't very clear.
>>
>> Turns out that the include file defining __PAGETABLE_PMD_FOLDED
>> was not always included where used, resulting in a messed up mm_struct.
>
> What means "messed up" here? It should only affect size of mm_struct.
>
Plus the offset of all variables after the #ifndef.

>> The patch below fixes the problem for the sh architecture.
>> No idea if the patch is correct/acceptable for other architectures.
>
> That's pain. Some archs includes <linux/mm_types.h> from <asm/pgtable.h>.
> I don't see obvious way to fix this. Urghh.
>
Does it matter ? Circular includes are normally ok and happen all over the place.
I could run a full build / qemu test cycle for all architectures if that helps.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
