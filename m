Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 529A46B0032
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 13:58:00 -0400 (EDT)
Received: by ierf6 with SMTP id f6so53796651ier.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 10:58:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id x2si7206039ich.58.2015.04.07.10.57.59
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 10:57:59 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 9371920437
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:57:58 +0000 (UTC)
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4E58B20416
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:57:55 +0000 (UTC)
Received: by wgbdm7 with SMTP id dm7so64330519wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 10:57:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7hwq1v4iq4.fsf@deeprootsystems.com>
References: <20150324004537.GA24816@verge.net.au>
	<CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com>
	<20150324161358.GA694@kahuna>
	<20150326003939.GA25368@verge.net.au>
	<20150326133631.GB2805@arm.com>
	<CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au>
	<20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
	<20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
	<7hwq1v4iq4.fsf@deeprootsystems.com>
Date: Tue, 7 Apr 2015 10:57:52 -0700
Message-ID: <CAMAWPa_YEJDQc=_60_sPqzwLYN8Yefzcko_rydxrt8oOCq20gw@mail.gmail.com>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid ICE
 in gcc 4.7.3
From: Kevin Hilman <khilman@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marc Zyngier <marc.zyngier@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Andrew,

On Wed, Apr 1, 2015 at 2:54 PM, Kevin Hilman <khilman@kernel.org> wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Wed, 01 Apr 2015 10:47:49 +0100 Marc Zyngier <marc.zyngier@arm.com> wrote:
>>
>>> > -static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>>> > -                  unsigned long private, struct page *page, int force,
>>> > -                  enum migrate_mode mode)
>>> > +static noinline int unmap_and_move(new_page_t get_new_page,
>>> > +                             free_page_t put_new_page,
>>> > +                             unsigned long private, struct page *page,
>>> > +                             int force, enum migrate_mode mode)
>>> >  {
>>> >    int rc = 0;
>>> >    int *result = NULL;
>>> >
>>>
>>> Ouch. That's really ugly. And on 32bit ARM, we end-up spilling half of
>>> the parameters on the stack, which is not going to help performance
>>> either (not that this would be useful on 32bit ARM anyway...).
>>>
>>> Any chance you could make this dependent on some compiler detection
>>> mechanism?
>>
>> With my arm compiler (gcc-4.4.4) the patch makes no difference -
>> unmap_and_move() isn't being inlined anyway.
>>
>> How does this look?
>>
>> Kevin, could you please retest?  I might have fat-fingered something...
>
> Your patch on top of Geert's still compiles fine for me with gcc-4.7.3.
> However, I'm not sure how specific we can be on the versions.
>
> /me goes to test a few more compilers...   OK...
>
> ICE: 4.7.1, 4.7.3, 4.8.3
> OK: 4.6.3, 4.9.2, 4.9.3
>
> The diff below[2] on top of yours compiles fine here and at least covers
> the compilers I *know* to trigger the ICE.

I see my fix in your mmots since last Thurs (4/2), but it's not in
mmotm (last updated today) so today's linux-next still has the ICE for
anything other than gcc-4.7.3.   Just checking to see when you plan to
update mmotm.

Thanks,

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
