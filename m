Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 523DB6B0121
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:48:47 -0400 (EDT)
Received: by iebgx4 with SMTP id gx4so93666739ieb.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:48:47 -0700 (PDT)
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com. [209.85.223.181])
        by mx.google.com with ESMTPS id yp6si10542027icb.65.2015.05.26.07.48.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 07:48:46 -0700 (PDT)
Received: by iesa3 with SMTP id a3so93807375ies.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:48:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150526143547.GA22363@cbox>
References: <20150524193404.GD16910@cbox>
	<20150525141525.GB26958@redhat.com>
	<20150526080848.GA27075@cbox>
	<CAPvkgC3kTgP720CawpfvLbm90FCs9UGNP3WOAamOD=UEgKoQCw@mail.gmail.com>
	<20150526143547.GA22363@cbox>
Date: Tue, 26 May 2015 15:48:46 +0100
Message-ID: <CAPvkgC0h+pYFfcuNh7f-b44mktR+CX6UYa2OXouDB8ZmZtroPQ@mail.gmail.com>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, ebru.akagunduz@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 26 May 2015 at 15:35, Christoffer Dall <christoffer.dall@linaro.org> wrote:
> Hi Steve,
>
> On Tue, May 26, 2015 at 03:24:20PM +0100, Steve Capper wrote:
>> >> On Sun, May 24, 2015 at 09:34:04PM +0200, Christoffer Dall wrote:
>> >> > Hi all,
>> >> >
>> >> > I noticed a regression on my arm64 APM X-Gene system a couple
>> >> > of weeks back.  I would occassionally see the system lock up and see RCU
>> >> > stalls during the caching phase of kernbench.  I then wrote a small
>> >> > script that does nothing but cache the files
>> >> > (http://paste.ubuntu.com/11324767/) and ran that in a loop.  On a known
>> >> > bad commit (v4.1-rc2), out of 25 boots, I never saw it get past 21
>> >> > iterations of the loop.  I have since tried to run a bisect from v3.19 to
>> >> > v4.0 using 100 iterations as my criteria for a good commit.
>> >> >
>> >> > This resulted in the following first bad commit:
>> >> >
>> >> > 10359213d05acf804558bda7cc9b8422a828d1cd
>> >> > (mm: incorporate read-only pages into transparent huge pages, 2015-02-11)
>> >> >
>> >> > Indeed, running the workload on v4.1-rc4 still produced the behavior,
>> >> > but reverting the above commit gets me through 100 iterations of the
>> >> > loop.
>> >> >
>> >> > I have not tried to reproduce on an x86 system.  Turning on a bunch
>> >> > of kernel debugging features *seems* to hide the problem.  My config for
>> >> > the XGene system is defconfig + CONFIG_BRIDGE and
>> >> > CONFIG_POWER_RESET_XGENE.
>> >> >
>> >> > Please let me know if I can help test patches or other things I can
>> >> > do to help.  I'm afraid that by simply reading the patch I didn't see
>> >> > anything obviously wrong with it which would cause this behavior.
>> >>
>> >> As further confirmation, could you try:
>> >>
>> >> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
>> >
>> > this returns -EINVAL.
>> >
>> > But I'm trying now with:
>> >
>> > echo never > /sys/kernel/mm/transparent_hugepage/enabled
>> >
>> >>
>> >> and verify the problem goes away without having to revert the patch?
>> >
>> > will let you know, so far so good...
>> >
>> >>
>> >> Accordingly you should reproduce much eaiser this way (setting
>> >> $largevalue to 8192 or something, it doesn't matter).
>> >>
>> >> echo $largevalue > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
>> >> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
>> >> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
>> >>
>> >> Then push the system into swap with some memhog -r1000 xG.
>> >
>> > what is memhog?  I couldn't find the utility in Google...
>> >
>> > I did try with the above settings and just push a bunch of data into
>> > ramfs and tmpfs and indeed the sytem died very quickly (on v4.0-rc4).
>> >
>> >>
>> >> The patch just allows readonly anon pages to be collapsed along with
>> >> read-write ones, the vma permissions allows it, so they have to be
>> >> swapcache pages, this is why swap shall be required.
>> >>
>> >> Perhaps there's some arch detail that needs fixing but it'll be easier
>> >> to track it down once you have a way to reproduce fast.
>> >>
>> > Yes, would be great to be able to reproduce quickly.
>> >
>
>> I'm trying to reproduce this on hardware here; but have been unable to
>> thus far with 4.1-rc2 on a Xgene and Seattle systems.
>
> Really?  That's concerning.  I think Andre mentioned he could
> reproduce...
>
> How many iterations have you run the caching loop for?
>
> Are you using defconfig?  I noticed that turning on debugging features
> was hiding the problem.
>
>> Also, I tried the memhog + pages_to_scan suggestion from Andrea.
>
> Any chance you could send me the memhog tool?
>
>>
>> Maybe a silly question, where is your root filesystem located? Is
>> there anything network mounted?
>>
> It's a regular ext4 on the local SATA disk.  Ubuntu Trusty.
>
> Thanks,
> -Christoffer

Sending an email to lakml appears to have been enough to make it hang
on the Xgene :-).
The system is completely frozen, not even the serial port works.

On Seattle, I've hit 100 iterations multiple times without any problems.

Investigating...

Cheers,
--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
