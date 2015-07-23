Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D4FA76B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:02:25 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so209987160wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:02:25 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id bl7si6925896wjc.28.2015.07.23.07.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 07:02:24 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so220664788wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:02:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150723134714.GA29224@quack.suse.cz>
References: <1437650286-117629-1-git-send-email-valentinrothberg@gmail.com> <20150723134714.GA29224@quack.suse.cz>
From: Valentin Rothberg <valentinrothberg@gmail.com>
Date: Thu, 23 Jul 2015 16:01:53 +0200
Message-ID: <CAD3Xx4KNpbiSau5E2qSOuvww4FNeVBk8vbutA-fFX_0f8XLm8g@mail.gmail.com>
Subject: Re: [PATCH] mm/Kconfig: NEED_BOUNCE_POOL: clean-up condition
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>, hengelein Stefan <stefan.hengelein@fau.de>

Hi Jan,

On Thu, Jul 23, 2015 at 3:47 PM, Jan Kara <jack@suse.cz> wrote:
> On Thu 23-07-15 13:18:06, Valentin Rothberg wrote:
>> commit 106542e7987c ("fs: Remove ext3 filesystem driver") removed ext3
>> and JBD, hence remove the superfluous condition.
>>
>> Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
>> ---
>> I detected the issue with undertaker-checkpatch
>> (https://undertaker.cs.fau.de)
>
> Thanks. I have added your patch into my tree. BTW, is the checker automated
> enough that it could be made part of the 0-day tests Fengguang runs?

The checker is automated, but it also produces false positives for
certain kinds of bugs/defects, so we decided to run the bot on our
servers at the University of Erlangen-Nuremberg.  It runs daily on
linux-next; we check the reports and fix the issue as above or we
report it to the authors and maintainers.  So we catch things as soon
as they are in linux-next.

If you want to check for symbolic issues (i.e., references on
undefined Kconfig opionts/symbols) you can use
scripts/checkkconfigsymbols.py which detects most of the cases.
However, this script did not catch the upper case (I will check why).

Kind regards,
 Valentin

>                                                                 Honza
>
>>  mm/Kconfig | 8 +-------
>>  1 file changed, 1 insertion(+), 7 deletions(-)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index e79de2bd12cd..d4e6495a720f 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -299,15 +299,9 @@ config BOUNCE
>>  # On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
>>  # have more than 4GB of memory, but we don't currently use the IOTLB to present
>>  # a 32-bit address to OHCI.  So we need to use a bounce pool instead.
>> -#
>> -# We also use the bounce pool to provide stable page writes for jbd.  jbd
>> -# initiates buffer writeback without locking the page or setting PG_writeback,
>> -# and fixing that behavior (a second time; jbd2 doesn't have this problem) is
>> -# a major rework effort.  Instead, use the bounce buffer to snapshot pages
>> -# (until jbd goes away).  The only jbd user is ext3.
>>  config NEED_BOUNCE_POOL
>>       bool
>> -     default y if (TILE && USB_OHCI_HCD) || (BLK_DEV_INTEGRITY && JBD)
>> +     default y if TILE && USB_OHCI_HCD
>>
>>  config NR_QUICK
>>       int
>> --
>> 1.9.1
>>
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
