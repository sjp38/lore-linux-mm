Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5C95F6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:02:31 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so3994675qcq.4
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 03:02:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ge8si184833qab.146.2014.01.14.03.02.29
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 03:02:30 -0800 (PST)
Message-ID: <52D51938.1090408@redhat.com>
Date: Tue, 14 Jan 2014 06:02:16 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user [v2]
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>	 <1389380698-19361-4-git-send-email-prarit@redhat.com>	 <alpine.DEB.2.02.1401111624170.20677@be1.lrz> <52D32962.5050908@redhat.com>	 <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>	 <52D4793E.8070102@redhat.com> <1389659632.1792.247.camel@misato.fc.hp.com>
In-Reply-To: <1389659632.1792.247.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bodo Eggert <7eggert@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, dyoung@redhat.com, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 01/13/2014 07:33 PM, Toshi Kani wrote:
> On Mon, 2014-01-13 at 18:39 -0500, Prarit Bhargava wrote:
>>
>> On 01/13/2014 03:31 PM, KOSAKI Motohiro wrote:
>>> On Sun, Jan 12, 2014 at 6:46 PM, Prarit Bhargava <prarit@redhat.com> wrote:
>>>>
>>>>
>>>> On 01/11/2014 11:35 AM, 7eggert@gmx.de wrote:
>>>>>
>>>>>
>>>>> On Fri, 10 Jan 2014, Prarit Bhargava wrote:
>>>>>
>>>>>> kdump uses memmap=exactmap and mem=X values to configure the memory
>>>>>> mapping for the kdump kernel.  If memory is hotadded during the boot of
>>>>>> the kdump kernel it is possible that the page tables for the new memory
>>>>>> cause the kdump kernel to run out of memory.
>>>>>>
>>>>>> Since the user has specified a specific mapping ACPI Memory Hotplug should be
>>>>>> disabled in this case.
>>>>>
>>>>> I'll ask just in case: Is it possible to want memory hotplug in spite of
>>>>> using memmap=exactmap or mem=X?
>>>>
>>>> Good question -- I can't think of a case.  When a user specifies "memmap" or
>>>> "mem" IMO they are asking for a very specific memory configuration.  Having
>>>> extra memory added above what the user has specified seems to defeat the purpose
>>>> of "memmap" and "mem".
>>>
>>> May be yes, may be no.
>>>
>>> They are often used for a wrokaround to avoid broken firmware issue.
>>> If we have no way
>>> to explicitly enable hotplug. We will lose a workaround.
>>>
>>> Perhaps, there is no matter. Today, memory hotplug is only used on
>>> high-end machine
>>> and their firmware is carefully developped and don't have a serious
>>> issue almostly. Though.
>>
>> Oof -- sorry Kosaki :(  I didn't see this until just now (and your subsequent
>> ACK on the updated patch).
>>
>> I just remembered that we did have a processor vendor's whitebox that would not
>> boot unless we specified a specific memmap and we did specify memmap=exactmap to
>> boot the system correctly and the system had hotplug memory.
>>
>> So it means that I should not key off of "memmap=exactmap".
> 
> I do not think it makes sense.  You needed memmap=exactmap as a
> workaround because the kernel did not boot with the firmware's memory
> info.  So, it's broken, and you requested the kernel to ignore the
> firmware info.
> 
> Why do you think memory hotplug needs to be supported under such
> condition, which has to use the broken firmware info?

There was a memory address region that was not in the e820 map that had to be
reserved for a specific device's use.  It was not so we used memmap=exactmap and
other memmap entries to "rewrite" the e820 map to see if the system would boot;
then I filed a bug against the hardware vendor ;)

So, yes, in that case I did want memory hotplug & memmap=exactmap.  Admittedly
this was a rare corner case, and I certainly could have recompiled the kernel.

P.

> 
> Thanks,
> -Toshi 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
