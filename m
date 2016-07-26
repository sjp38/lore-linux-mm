Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36BD76B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 17:11:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so3087281qte.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 14:11:33 -0700 (PDT)
Received: from mail-yw0-x22b.google.com (mail-yw0-x22b.google.com. [2607:f8b0:4002:c05::22b])
        by mx.google.com with ESMTPS id l128si616834ybf.110.2016.07.26.14.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 14:11:32 -0700 (PDT)
Received: by mail-yw0-x22b.google.com with SMTP id u134so33845475ywg.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 14:11:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <476DC76E7D1DF2438D32BFADF679FC5601260044@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <CAFJ0LnENnrpVA_SdngGxeShsmxq9Mvc0h9EH1=8vEP=hFFnt1g@mail.gmail.com> <476DC76E7D1DF2438D32BFADF679FC5601260044@ORSMSX103.amr.corp.intel.com>
From: Nick Kralevich <nnk@google.com>
Date: Tue, 26 Jul 2016 14:11:23 -0700
Message-ID: <CAFJ0LnHkpjSRwikMCcLNmjJ2Xxta_ngk+qeSqjPgFmyjrUvDnw@mail.gmail.com>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Roberts, William C" <william.c.roberts@intel.com>
Cc: "jason@lakedaemon.net" <jason@lakedaemon.net>, lkml <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Greg KH <gregkh@linuxfoundation.org>, Jeffrey Vander Stoep <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, Daniel Cashman <dcashman@android.com>, linux-mm@kvack.org

On Tue, Jul 26, 2016 at 2:02 PM, Roberts, William C
<william.c.roberts@intel.com> wrote:
>
>
>> -----Original Message-----
>> From: Nick Kralevich [mailto:nnk@google.com]
>> Sent: Tuesday, July 26, 2016 1:41 PM
>> To: Roberts, William C <william.c.roberts@intel.com>
>> Cc: jason@lakedaemon.net; linux-mm@vger.kernel.org; lkml <linux-
>> kernel@vger.kernel.org>; kernel-hardening@lists.openwall.com; Andrew
>> Morton <akpm@linux-foundation.org>; Kees Cook <keescook@chromium.org>;
>> Greg KH <gregkh@linuxfoundation.org>; Jeffrey Vander Stoep
>> <jeffv@google.com>; salyzyn@android.com; Daniel Cashman
>> <dcashman@android.com>
>> Subject: Re: [PATCH] [RFC] Introduce mmap randomization
>>
>> My apologies in advance if I misunderstand the purposes of this patch.
>>
>> IIUC, this patch adds a random gap between various mmap() mappings, with the
>> goal of ensuring that both the mmap base address and gaps between pages are
>> randomized.
>>
>> If that's the goal, please note that this behavior has caused significant
>> performance problems to Android in the past. Specifically, random gaps between
>> mmap()ed regions causes memory space fragmentation. After a program runs for
>> a long time, the ability to find large contiguous blocks of memory becomes
>> impossible, and mmap()s fail due to lack of a large enough address space.
>
> Yes and fragmentation is definitely a problem here. Especially when the mmaps()
> are not a consistent length for program life.
>
>>
>> This isn't just a theoretical concern. Android actually hit this on kernels prior to
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=7dbaa46
>> 6780a754154531b44c2086f6618cee3a8
>> . Before that patch, the gaps between mmap()ed pages were randomized.
>> See the discussion at:
>>
>>   http://lists.infradead.org/pipermail/linux-arm-kernel/2011-
>> November/073082.html
>>   http://marc.info/?t=132070957400005&r=1&w=2
>>
>> We ended up having to work around this problem in the following commits:
>>
>>
>> https://android.googlesource.com/platform/dalvik/+/311886c6c6fcd3b531531f59
>> 2d56caab5e2a259c
>>   https://android.googlesource.com/platform/art/+/51e5386
>>   https://android.googlesource.com/platform/art/+/f94b781
>>
>> If this behavior was re-introduced, it's likely to cause hard-to-reproduce
>> problems, and I suspect Android based distributions would tend to disable this
>> feature either globally, or for applications which make a large number of mmap()
>> calls.
>
> Yeah and this is the issue I want to see if we can overcome. I see the biggest benefit
> being on libraries loaded by dl. Perhaps a random flag and modify to linkers. Im just
> spit balling here and collecting the feedback, like this. Thanks for the detail, that
> helps a lot.

Android N introduced library load order randomization, which partially
helps with this.

https://android-review.googlesource.com/178130

There's also https://android-review.googlesource.com/248499 which adds
additional gaps for shared libraries.


>
>>
>> -- Nick
>>
>>
>>
>> On Tue, Jul 26, 2016 at 11:22 AM,  <william.c.roberts@intel.com> wrote:
>> > From: William Roberts <william.c.roberts@intel.com>
>> >
>> > This patch introduces the ability randomize mmap locations where the
>> > address is not requested, for instance when ld is allocating pages for
>> > shared libraries. It chooses to randomize based on the current
>> > personality for ASLR.
>> >
>> > Currently, allocations are done sequentially within unmapped address
>> > space gaps. This may happen top down or bottom up depending on scheme.
>> >
>> > For instance these mmap calls produce contiguous mappings:
>> > int size = getpagesize();
>> > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
>> 0x40026000
>> > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
>> 0x40027000
>> >
>> > Note no gap between.
>> >
>> > After patches:
>> > int size = getpagesize();
>> > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
>> 0x400b4000
>> > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
>> 0x40055000
>> >
>> > Note gap between.
>> >
>> > Using the test program mentioned here, that allocates fixed sized
>> > blocks till exhaustion:
>> > https://www.linux-mips.org/archives/linux-mips/2011-05/msg00252.html,
>> > no difference was noticed in the number of allocations. Most varied
>> > from run to run, but were always within a few allocations of one
>> > another between patched and un-patched runs.
>> >
>> > Performance Measurements:
>> > Using strace with -T option and filtering for mmap on the program ls
>> > shows a slowdown of approximate 3.7%
>> >
>> > Signed-off-by: William Roberts <william.c.roberts@intel.com>
>> > ---
>> >  mm/mmap.c | 24 ++++++++++++++++++++++++
>> >  1 file changed, 24 insertions(+)
>> >
>> > diff --git a/mm/mmap.c b/mm/mmap.c
>> > index de2c176..7891272 100644
>> > --- a/mm/mmap.c
>> > +++ b/mm/mmap.c
>> > @@ -43,6 +43,7 @@
>> >  #include <linux/userfaultfd_k.h>
>> >  #include <linux/moduleparam.h>
>> >  #include <linux/pkeys.h>
>> > +#include <linux/random.h>
>> >
>> >  #include <asm/uaccess.h>
>> >  #include <asm/cacheflush.h>
>> > @@ -1582,6 +1583,24 @@ unacct_error:
>> >         return error;
>> >  }
>> >
>> > +/*
>> > + * Generate a random address within a range. This differs from
>> > +randomize_addr() by randomizing
>> > + * on len sized chunks. This helps prevent fragmentation of the virtual
>> memory map.
>> > + */
>> > +static unsigned long randomize_mmap(unsigned long start, unsigned
>> > +long end, unsigned long len) {
>> > +       unsigned long slots;
>> > +
>> > +       if ((current->personality & ADDR_NO_RANDOMIZE) ||
>> !randomize_va_space)
>> > +               return 0;
>> > +
>> > +       slots = (end - start)/len;
>> > +       if (!slots)
>> > +               return 0;
>> > +
>> > +       return PAGE_ALIGN(start + ((get_random_long() % slots) *
>> > +len)); }
>> > +
>> >  unsigned long unmapped_area(struct vm_unmapped_area_info *info)  {
>> >         /*
>> > @@ -1676,6 +1695,8 @@ found:
>> >         if (gap_start < info->low_limit)
>> >                 gap_start = info->low_limit;
>> >
>> > +       gap_start = randomize_mmap(gap_start, gap_end, length) ? :
>> > + gap_start;
>> > +
>> >         /* Adjust gap address to the desired alignment */
>> >         gap_start += (info->align_offset - gap_start) &
>> > info->align_mask;
>> >
>> > @@ -1775,6 +1796,9 @@ found:
>> >  found_highest:
>> >         /* Compute highest gap address at the desired alignment */
>> >         gap_end -= info->length;
>> > +
>> > +       gap_end = randomize_mmap(gap_start, gap_end, length) ? :
>> > + gap_end;
>> > +
>> >         gap_end -= (gap_end - info->align_offset) & info->align_mask;
>> >
>> >         VM_BUG_ON(gap_end < info->low_limit);
>> > --
>> > 1.9.1
>> >
>>
>>
>>
>> --
>> Nick Kralevich | Android Security | nnk@google.com | 650.214.4037



-- 
Nick Kralevich | Android Security | nnk@google.com | 650.214.4037

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
