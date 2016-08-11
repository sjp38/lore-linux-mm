Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6E246B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:53:23 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m130so147883522ioa.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:53:23 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id r106si382818ota.272.2016.08.10.21.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 21:53:23 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id b22so1071397oii.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <006e01d1f30a$bfc7f430$3f57dc90$@samsung.com>
References: <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
 <01a001d1eed5$c50726c0$4f157440$@samsung.com> <20160805082015.GA28235@bbox>
 <01c101d1ef28$50706ad0$f1514070$@samsung.com> <20160805205018.GE7999@amd> <006e01d1f30a$bfc7f430$3f57dc90$@samsung.com>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 11 Aug 2016 10:23:22 +0530
Message-ID: <CAOaiJ-=ZBFnFOJE1ZZySY2JPO9MVTeKA25PzGsqJ=z+darwY8w@mail.gmail.com>
Subject: Re: [linux-mm] Drastic increase in application memory usage with
 Kernel version upgrade
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: Pavel Machek <pavel@ucw.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com, chulspro.kim@samsung.com

On Wed, Aug 10, 2016 at 6:56 PM, PINTU KUMAR <pintu.k@samsung.com> wrote:
> Hi,
>
>> -----Original Message-----
>> From: Pavel Machek [mailto:pavel@ucw.cz]
>> Sent: Saturday, August 06, 2016 2:20 AM
>> To: PINTU KUMAR
>> Cc: 'Minchan Kim'; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
>> jaejoon.seo@samsung.com; jy0.jeon@samsung.com; vishnu.ps@samsung.com
>> Subject: Re: [linux-mm] Drastic increase in application memory usage with
> Kernel
>> version upgrade
>>
>> On Fri 2016-08-05 20:17:36, PINTU KUMAR wrote:
>> > Hi,
>>
>> > > On Fri, Aug 05, 2016 at 10:26:37AM +0530, PINTU KUMAR wrote:
>> > > > Hi All,
>> > > >
>> > > > For one of our ARM embedded product, we recently updated the
>> > > > Kernel version from 3.4 to 3.18 and we noticed that the same
>> > > > application memory usage  (PSS value) gone up by ~10% and for
>> > > > some cases it even crossed ~50%. There is no change in platform
>> > > > part. All platform component was  built with ARM 32-bit toolchain.
>> > > > However, the Kernel is changed from 32-bit to 64-bit.
>> > > >
>> > > > Is upgrading Kernel version and moving from 32-bit to 64-bit is
>> > > > such a risk?
>> > > > After the upgrade, what can we do further to reduce the
>> > > > application memory usage ?
>> > > > Is there any other factor that will help us to improve without
>> > > > major modifications in platform ?
>> > > >
>> > > > As a proof, we did a small experiment on our Ubuntu-32 bit machine.
>> > > > We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we
>> > > > observed the following:
>> > > > ------------------------------------------------------------------
>> > > > |UBUNTU-32 bit  |Kernel 3.13    |Kernel 4.03    |DIFF   |
>> > > > |CALCULATOR PSS |6057 KB        |6466 KB        |409 KB |
>> > > > ------------------------------------------------------------------
>> > > > So, just by upgrading the Kernel version: PSS value for calculator
>> > > > is increased by 409KB.
>> > > >
>> > > > If anybody knows any in-sight about it please point out more
>> > > > details about the root cause.
>> > >
>> > > One of culprit is [8c6e50b0290c, mm: introduce vm_ops->map_pages()].
>> > Ok. Thank you for your reply.
>> > So, if I revert this patch, will the memory usage be decreased for the
>> > processes with Kernel 3.18 ?
>>
>> I guess you should try it...
>>
> Thanks for the reply and confirmation.
> Our exact kernel version is: 3.18.14
> And, we already have this patch:
> /*
> mm: do not call do_fault_around for non-linear fault
> Ingo Korb reported that "repeated mapping of the same file on tmpfs
> using remap_file_pages sometimes triggers a BUG at mm/filemap.c:202 when
> the process exits".
> He bisected the bug to d7c1755179b8 ("mm: implement ->map_pages for
> shmem/tmpfs"), although the bug was actually added by commit
> 8c6e50b0290c ("mm: introduce vm_ops->map_pages()").
> */
>
> So, I guess, reverting this patch (8c6e50b0290c), is not required ?
> But, still we have memory usage issue.
>
I had observed the PSS increase with 3.18, and that was because of the
faultaround patch which MInchan mentioned.
Without reverting the patch you can just try reducing
fault_around_bytes (mm/memory.c) to PAGE_SIZE. That should
bring down the PSS.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
