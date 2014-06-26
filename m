Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 84A336B003D
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 19:15:34 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so2393990lab.18
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 16:15:33 -0700 (PDT)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
        by mx.google.com with ESMTPS id iz6si16846324lbc.46.2014.06.26.16.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 16:15:32 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so2360985lab.23
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 16:15:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53ACA5B3.3010702@intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
 <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com>
 <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com>
 <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com>
 <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com>
 <53AB42E1.4090102@intel.com> <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com>
 <53ACA5B3.3010702@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 26 Jun 2014 16:15:12 -0700
Message-ID: <CALCETrVceOhRunCg1b9Q3VL10Kcb+uA-HFUURnq5f2S63_jACg@mail.gmail.com>
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Jun 26, 2014 at 3:58 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/26/2014 03:19 PM, Andy Lutomirski wrote:
>> On Wed, Jun 25, 2014 at 2:45 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>>> On 06/25/2014 02:05 PM, Andy Lutomirski wrote:
>>>> Hmm.  the memfd_create thing may be able to do this for you.  If you
>>>> created a per-mm memfd and mapped it, it all just might work.
>>>
>>> memfd_create() seems to bring a fair amount of baggage along (the fd
>>> part :) if all we want is a marker.  Really, all we need is _a_ bit, and
>>> some way to plumb to userspace the RSS values of VMAs with that bit set.
>>>
>>> Creating and mmap()'ing a fd seems a rather roundabout way to get there.
>>
>> Hmm.  So does VM_MPX, though.  If this stuff were done entirely in
>> userspace, then memfd_create would be exactly the right solution, I
>> think.
>>
>> Would it work to just scan the bound directory to figure out how many
>> bound tables exist?
>
> Theoretically, perhaps.
>
> Practically, the bounds directory is 2GB, and it is likely to be very
> sparse.  You would have to walk the page tables finding where pages were
> mapped, then search the mapped pages for bounds table entries.
>
> Assuming that it was aligned and minimally populated, that's a *MINIMUM*
> search looking for a PGD entry, then you have to look at 512 PUD
> entries.  A full search would have to look at half a million ptes.
> That's just finding out how sparse the first level of the tables are
> before you've looked at a byte of actual data, and if they were empty.
>
> We could keep another, parallel, data structure that handles this better
> other than the hardware tables.  Like, say, an rbtree that stores ranges
> of virtual addresses.  We could call them vm_area_somethings ... wait a
> sec... we have a structure like that. ;)
>
>

So here's my mental image of how I might do this if I were doing it
entirely in userspace: I'd create a file or memfd for the bound tables
and another for the bound directory.  These files would be *huge*: the
bound directory file would be 2GB and the bounds table file would be
2^48 bytes or whatever it is.  (Maybe even bigger?)

Then I'd just map pieces of those files wherever they'd need to be,
and I'd make the mappings sparse.  I suspect that you don't actually
want a vma for each piece of bound table that gets mapped -- the space
of vmas could end up incredibly sparse.  So I'd at least map (in the
vma sense, not the pte sense) and entire bound table at a time.  And
I'd probably just map the bound directory in one big piece.

Then I'd populate it in the fault handler.

This is almost what the code is doing, I think, modulo the files.

This has one killer problem: these mappings need to be private (cowed
on fork).  So memfd is no good.  There's got to be an easyish way to
modify the mm code to allow anonymous maps with vm_ops.  Maybe a new
mmap_region parameter or something?  Maybe even a special anon_vma,
but I don't really understand how those work.


Also, egads: what happens when a bound table entry is associated with
a MAP_SHARED page?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
