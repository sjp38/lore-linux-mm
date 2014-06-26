Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 20C836B0083
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 18:59:02 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so3608734pdb.30
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 15:59:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ew3si11714882pbb.184.2014.06.26.15.59.00
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 15:59:01 -0700 (PDT)
Message-ID: <53ACA5B3.3010702@intel.com>
Date: Thu, 26 Jun 2014 15:58:59 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com> <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com> <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com> <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com> <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com> <53AB42E1.4090102@intel.com> <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com>
In-Reply-To: <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 06/26/2014 03:19 PM, Andy Lutomirski wrote:
> On Wed, Jun 25, 2014 at 2:45 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>> On 06/25/2014 02:05 PM, Andy Lutomirski wrote:
>>> Hmm.  the memfd_create thing may be able to do this for you.  If you
>>> created a per-mm memfd and mapped it, it all just might work.
>>
>> memfd_create() seems to bring a fair amount of baggage along (the fd
>> part :) if all we want is a marker.  Really, all we need is _a_ bit, and
>> some way to plumb to userspace the RSS values of VMAs with that bit set.
>>
>> Creating and mmap()'ing a fd seems a rather roundabout way to get there.
> 
> Hmm.  So does VM_MPX, though.  If this stuff were done entirely in
> userspace, then memfd_create would be exactly the right solution, I
> think.
> 
> Would it work to just scan the bound directory to figure out how many
> bound tables exist?

Theoretically, perhaps.

Practically, the bounds directory is 2GB, and it is likely to be very
sparse.  You would have to walk the page tables finding where pages were
mapped, then search the mapped pages for bounds table entries.

Assuming that it was aligned and minimally populated, that's a *MINIMUM*
search looking for a PGD entry, then you have to look at 512 PUD
entries.  A full search would have to look at half a million ptes.
That's just finding out how sparse the first level of the tables are
before you've looked at a byte of actual data, and if they were empty.

We could keep another, parallel, data structure that handles this better
other than the hardware tables.  Like, say, an rbtree that stores ranges
of virtual addresses.  We could call them vm_area_somethings ... wait a
sec... we have a structure like that. ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
