Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3469C6B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:45:59 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id x12so484051wgg.2
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:45:58 -0700 (PDT)
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
        by mx.google.com with ESMTPS id o4si4239326wix.94.2014.09.16.14.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 14:45:58 -0700 (PDT)
Received: by mail-wg0-f49.google.com with SMTP id m15so481237wgh.20
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:45:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410886335.28990.393.camel@misato.fc.hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	<1410367910-6026-7-git-send-email-toshi.kani@hp.com>
	<CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
	<1410379933.28990.287.camel@misato.fc.hp.com>
	<CALCETrUh20-2PX_KN2KWO085n=5XJpOnPysmCGbk7bufaD3Mhw@mail.gmail.com>
	<1410384895.28990.312.camel@misato.fc.hp.com>
	<1410815951.28990.384.camel@misato.fc.hp.com>
	<CALCETrXMiSpMMi-4P8FTMeH_0J+6eNj0RAVJDhZYQOZub1jUOA@mail.gmail.com>
	<1410886335.28990.393.camel@misato.fc.hp.com>
Date: Wed, 17 Sep 2014 00:45:57 +0300
Message-ID: <CACTTzNbP23WAxDFMyJ+hbOGt-8S1_ZCUs2KxKObz1XVHOfJGaw@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
From: Yigal Korman <yigal@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Perhaps your patch is still valid in the context of this patch:
https://lkml.org/lkml/2014/9/9/612
Part of the reason for creating it was the fact that ioremap is using
a fake virtual address mapping.
So I think we can still use set_memory_wt for memory created with
add_persistent_memory.
What do you think?

Also, a thought: maybe the driver that will be managing the memory
added by add_persistent_memory should be responsible for resolving
aliasing issues.

Thanks,
Yigal

On Tue, Sep 16, 2014 at 7:52 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Mon, 2014-09-15 at 18:22 -0700, Andy Lutomirski wrote:
>> On Mon, Sep 15, 2014 at 2:19 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>> > On Wed, 2014-09-10 at 15:34 -0600, Toshi Kani wrote:
>> >> On Wed, 2014-09-10 at 13:29 -0700, Andy Lutomirski wrote:
>> >> > On Wed, Sep 10, 2014 at 1:12 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>> >> > > On Wed, 2014-09-10 at 11:30 -0700, Andy Lutomirski wrote:
>> >> > >> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
>> >> > >> > +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
>> >> > >> > +a specific range to wt with set_memory_wt.
>> >> > >>
>> >> > >> That's mighty specific :)
>> >> > >
>> >> > > How about below?
>> >> > >
>> >> > > Drivers may use set_memory_wt to set WT type for cached reserve ranges.
>> >> >
>> >> > Do they have to be cached?
>> >>
>> >> Yes, set_memory_xyz only supports WB->type->WB transition.
>> >>
>> >> > How about:
>> >> >
>> >> > Drivers may call set_memory_wt on ioremapped ranges.  In this case,
>> >> > there is no need to change the memory type back before calling
>> >> > iounmap.
>> >> >
>> >> > (Or only on cached ioremapped ranges if that is, in fact, the case.)
>> >>
>> >> Sounds good.  Yes, I will use cashed ioremapped ranges.
>> >
>> > Well, testing "no need to change the memory type back before calling
>> > iounmap" turns out to be a good test case.  I realized that
>> > set_memory_xyz only works properly for RAM.  There are two problems for
>> > using this interface for ioremapped ranges.
>> >
>> > 1) set_memory_xyz calls reserve_memtype() with __pa(addr).  However,
>> > __pa() translates the addr into a fake physical address when it is an
>> > ioremapped address.
>> >
>> > 2) reserve_memtype() does not work for set_memory_xyz.  For RAM, the WB
>> > state is managed untracked.  Hence, WB->new->WB is not considered as a
>> > conflict.  For ioremapped ranges, WB is tracked in the same way as other
>> > cache types.  Hence, WB->new is considered as a conflict.
>> >
>> > In my previous testing, 2) was undetected since 1) led using a fake
>> > physical address which was not tracked for WB.  This made ioremapped
>> > ranges worked just like RAM. :-(
>> >
>> > Anyway, 1) can be fixed by using slow_virt_to_phys() instead of __pa().
>> > set_memory_xyz is already slow, but this makes it even slower, though.
>> >
>> > For 2), WB has to be continuously tracked in order to detect aliasing,
>> > ex. ioremap_cache and ioremap to a same address.  So, I think
>> > reserve_memtype() needs the following changes:
>> >  - Add a new arg to see if an operation is to create a new mapping or to
>> > change cache attribute.
>> >  - Track overlapping maps so that cache type change to an overlapping
>> > range can be detected and failed.
>> >
>> > This level of changes requires a separate set of patches if we pursue to
>> > support ioremapped ranges.  So, I am considering to take one of the two
>> > options below.
>> >
>> > A) Drop the patch for set_memory_wt.
>> >
>> > B) Keep the patch for set_memory_wt, but document that it fails with
>> > -EINVAL and its use is for RAM only.
>> >
>>
>> I vote A.  I see no great reason to add code that can't be used.  Once
>> someone needs this ability, they can add it :)
>
> Agreed.  I will drop the patch for now.  Since _PGMT_WB does not seem to
> be used for tracking WB, we might be able to use this bit for WT.  But I
> need to look at the code more carefully for sure.
>
>> It's too bad that ioremap is called ioremap and not iomap.  Otherwise
>> the natural solution would be to add a different function call
>> ioremap_wt that's like set_memory_wt but for ioremap ranges.  Calling
>> it ioreremap_wt sounds kind of disgusting :)
>
> :)
>
> Thanks,
> -Toshi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
