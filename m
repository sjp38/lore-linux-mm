Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6257282F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 18:49:17 -0500 (EST)
Received: by igpw7 with SMTP id w7so48832105igp.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 15:49:17 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id c5si1272145igl.47.2015.11.06.15.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 15:49:16 -0800 (PST)
Received: by ioll68 with SMTP id l68so139426219iol.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 15:49:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <563D3AC5.4020203@redhat.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<20151106204641.GT8644@n2100.arm.linux.org.uk>
	<563D3AC5.4020203@redhat.com>
Date: Fri, 6 Nov 2015 15:49:16 -0800
Message-ID: <CAGXu5jLf+BAhPvQihZ02jUpSE4woP-aMhfUQ6vobZBShrZXT4g@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Nov 6, 2015 at 3:41 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 11/06/2015 12:46 PM, Russell King - ARM Linux wrote:
>>
>> On Fri, Nov 06, 2015 at 10:44:32AM -0800, Laura Abbott wrote:
>>>
>>> with my test patch. I think setting both current->active_mm and &init_mm
>>> is sufficient. Maybe explicitly setting swapper_pg_dir would be cleaner?
>>
>>
>> Please, stop thinking like this.  If you're trying to change the kernel
>> section mappings after threads have been spawned, you need to change
>> them for _all_ threads, which means you need to change them for every
>> page table that's in existence at that time - you can't do just one
>> table and hope everyone updates, it doesn't work like that.
>>
>
> That's a bad assumption assumption on my part based on what I was
> observing. At the time of mark_rodata_ro, the only threads present
> are kernel threads which aren't going to have task->mm. Only the
> running thread is going to have active_mm. None of those are init_mm.
> To be complete we need:
>
> - Update every task->mm for every thread in every process
> - Update current->active_mm
> - Update &init_mm explicitly
>
> All this would need to be done under stop_machine as well. Does that cover
> everything or am I still off?

I still think we need to find an earlier place to do this. :(

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
