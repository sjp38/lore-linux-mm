Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A38882F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 19:20:30 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so104884740obd.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 16:20:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d185si1209094oia.29.2015.11.06.16.20.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 16:20:29 -0800 (PST)
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
 <20151105094615.GP8644@n2100.arm.linux.org.uk> <563B81DA.2080409@redhat.com>
 <20151105162719.GQ8644@n2100.arm.linux.org.uk> <563BFCC4.8050705@redhat.com>
 <CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
 <563CF510.9080506@redhat.com> <20151106204641.GT8644@n2100.arm.linux.org.uk>
 <563D3AC5.4020203@redhat.com>
 <CAGXu5jLf+BAhPvQihZ02jUpSE4woP-aMhfUQ6vobZBShrZXT4g@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <563D43CA.9030405@redhat.com>
Date: Fri, 6 Nov 2015 16:20:26 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLf+BAhPvQihZ02jUpSE4woP-aMhfUQ6vobZBShrZXT4g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 11/06/2015 03:49 PM, Kees Cook wrote:
> On Fri, Nov 6, 2015 at 3:41 PM, Laura Abbott <labbott@redhat.com> wrote:
>> On 11/06/2015 12:46 PM, Russell King - ARM Linux wrote:
>>>
>>> On Fri, Nov 06, 2015 at 10:44:32AM -0800, Laura Abbott wrote:
>>>>
>>>> with my test patch. I think setting both current->active_mm and &init_mm
>>>> is sufficient. Maybe explicitly setting swapper_pg_dir would be cleaner?
>>>
>>>
>>> Please, stop thinking like this.  If you're trying to change the kernel
>>> section mappings after threads have been spawned, you need to change
>>> them for _all_ threads, which means you need to change them for every
>>> page table that's in existence at that time - you can't do just one
>>> table and hope everyone updates, it doesn't work like that.
>>>
>>
>> That's a bad assumption assumption on my part based on what I was
>> observing. At the time of mark_rodata_ro, the only threads present
>> are kernel threads which aren't going to have task->mm. Only the
>> running thread is going to have active_mm. None of those are init_mm.
>> To be complete we need:
>>
>> - Update every task->mm for every thread in every process
>> - Update current->active_mm
>> - Update &init_mm explicitly
>>
>> All this would need to be done under stop_machine as well. Does that cover
>> everything or am I still off?
>
> I still think we need to find an earlier place to do this. :(
>
> -Kees
>

The problem is still the initmem. That needs to be writable and executable
during inittime and then have the page tables adjusted afterwards if it is
going to be freed back. I'll give this some more thought to see if I can
come up with something or if anyone else has another idea.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
