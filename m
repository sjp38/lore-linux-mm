Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9FFEC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:24:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B3F20818
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:24:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B3F20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD718E0003; Fri,  1 Mar 2019 06:24:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D323A8E0001; Fri,  1 Mar 2019 06:24:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFB958E0003; Fri,  1 Mar 2019 06:24:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 640938E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:24:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o9so9914479edh.10
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:24:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i+T0VygfrHFnsfE1t+YCQ9jD/2p7CcsZS7Yl6ahZBTs=;
        b=W6KGqHNu+SisDoAW8FPeT3bCAUN3Ejc8fZTwQPxQZyS4rXQ2dgmqMqQYh1aCKF9KVm
         chKaFIOuWnUEGUMSa6hoDAunf1xWMU8NekzsSknbOIxbWw5crG2k1/+ElR3EnmIdqJir
         6ZubPMKQStroIrgML6t1UIxI1dXEnp8hR1DOFlOouKpeXLxbMvWt7sh3cR5inGZiLCmF
         MWvc+2/pFmAUtARJGlSIZIF8JtVU50Rypur+039dZ/l+M7LzeHHXLaTn6Mibb+0wF58V
         5+0fjFS9BgemoXrN0YfEyqBB4WDAUGlJE8Ns9HNxD1pnirPAHE3a2iAlRsE/TQiUj1k7
         oXnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWEvxQChrrKxx7Yr6nAXNH5m8cvvTGTVNpODmSCwkYArEFdKLvW
	+Fs9SA0A6/cAMAk/QEMZIEwJPwN0tTTxN6NwEZVFf8OzRnynISZ/s0bjC3pkOVxNYmFpwvrBiH1
	ZgAxzNuUrgyPhEaRo1rifwODrBeu/KriSk+9rr4Eo/d9umPZboN+IxiDnIdZr0MrMUA==
X-Received: by 2002:a05:6402:1490:: with SMTP id e16mr3719430edv.201.1551439472940;
        Fri, 01 Mar 2019 03:24:32 -0800 (PST)
X-Google-Smtp-Source: APXvYqy9S7U9wYNhP3nlshuxQ7oxR08vSbU940JbskJDg8fwc6cUjgaAw3p6EcuKxuw2li24AcwB
X-Received: by 2002:a05:6402:1490:: with SMTP id e16mr3719351edv.201.1551439471535;
        Fri, 01 Mar 2019 03:24:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551439471; cv=none;
        d=google.com; s=arc-20160816;
        b=CSRvShO78jCvwPEzffOj05ZeiHqAX84tCHqoFmYeT1YtfNcc7R1yjyduxiUAjildVf
         FxRC6wqvbY7mfsdm7Iqgqc6nslWU9FGKPKcNjSc5F5ud8ZLQRYkPH89mRlbk+7cRoCCh
         Y+0gs8qT7YT+brzUZOGrpUvju/TC2jm3gkoVddPdKP5afn/CvxARA+308+ZN3o1mRsyf
         iNaUP6d73tHkIDBuI9YyDEA8mhp6G1gaoQ18yD0gUBeVrFUUlm5NzHdfGnWjgRnBO3ow
         uTQc0imklHH/LFnypQPMV+XFBX6hz8TLq69dk2AB57D0TQlkB8lRF2ej9w0yOFOsy+yV
         +xzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=i+T0VygfrHFnsfE1t+YCQ9jD/2p7CcsZS7Yl6ahZBTs=;
        b=GP3wQ2Vw2TMLNMnsonrHORiOJyadfJxUJi0dGrBbRNYHR9IWsBL+fwt6JRFKOagAJF
         Wi7z4yCg7woD/8krticcucBUnDhofBUMdiNC9ABMd3HvYcNnH4r/iIklFJp4UQeLl7Ss
         vaSK8MbgG4/Q1qYstUhkepM1o68EkB/ghujSREAzRtd10XsDbsJMFQuET/p6DLsQupmW
         D8AEnx0lvjvdFntSsmJpRTOj88GUsh7TZU5Mrpg4hb0lFWmyDITaBBULjPEfSQsUWTd5
         ydSFtftKKSXdJHWST7qZDioJRXd8bMW22baTf0Qa1QeOMD9KvFkTb6CFM0di/AWdPKVi
         TmZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v20si286750edm.292.2019.03.01.03.24.31
        for <linux-mm@kvack.org>;
        Fri, 01 Mar 2019 03:24:31 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2E290EBD;
	Fri,  1 Mar 2019 03:24:30 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 06C343F5C1;
	Fri,  1 Mar 2019 03:24:26 -0800 (PST)
Subject: Re: [PATCH v3 27/34] mm: pagewalk: Add 'depth' parameter to pte_hole
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-28-steven.price@arm.com>
 <aece3046-6040-e2ec-fcd7-204113d40eb7@intel.com>
 <02b9ec67-75c5-4a36-9110-cc4ba6ee4f94@arm.com>
 <5f354bf5-4ac8-d0e2-048c-0857c91a21e6@intel.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <26df02dd-c54e-ea91-bdd1-0a4aad3a30ac@arm.com>
Date: Fri, 1 Mar 2019 11:24:25 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <5f354bf5-4ac8-d0e2-048c-0857c91a21e6@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/02/2019 19:00, Dave Hansen wrote:
> On 2/28/19 3:28 AM, Steven Price wrote:
>> static int get_level(unsigned long addr, unsigned long end)
>> {
>> 	/* Add 1 to account for ~0ULL */
>> 	unsigned long size = (end - addr) + 1;
>> 	if (size < PMD_SIZE)
>> 		return 4;
>> 	else if (size < PUD_SIZE)
>> 		return 3;
>> 	else if (size < P4D_SIZE)
>> 		return 2;
>> 	else if (size < PGD_SIZE)
>> 		return 1;
>> 	return 0;
>> }
>>
>> There are two immediate problems with that:
>>
>>  * The "+1" to deal with ~0ULL is fragile
>>
>>  * PGD_SIZE isn't what you might expect, it's not defined for most
>> architectures and arm64/x86 use it as the size of the PGD table.
>> Although that's easy enough to fix up.
>>
>> Do you think a function like above would be preferable?
> 
> The question still stands of why we *need* the depth/level in the first
> place.  As I said, we obviously need it for printing out the "name" of
> the level.  Is that it?

That is the only use I'm currently aware of.

>> The other option would of course be to just drop the information from
>> the debugfs file about at which level the holes are. But it can be
>> useful information to see whether there are empty levels in the page
>> table structure. Although this is an area where x86 and arm64 differ
>> currently (x86 explicitly shows the gaps, arm64 doesn't), so if x86
>> doesn't mind losing that functionality that would certainly simplify things!
> 
> I think I'd actually be OK with the holes just not showing up.  I
> actually find it kinda hard to read sometimes with the holes in there.
> I'd be curious what others think though.

If no-one has any objections to dropping the holes in the output, then I
can rebase on something like below and drop this 'depth' patch.

Steve

----8<----
From a9eabadfc212389068ec5cc60265c7a55585bb76 Mon Sep 17 00:00:00 2001
From: Steven Price <steven.price@arm.com>
Date: Fri, 1 Mar 2019 10:06:33 +0000
Subject: [PATCH] x86: mm: Hide page table holes in debugfs

For the /sys/kernel/debug/page_tables/ files, rather than outputing a
mostly empty line when a block of memory isn't present just skip the
line. This keeps the output shorter and will help with a future change
switching to using the generic page walk code as we no longer care about
the 'level' that the page table holes are at.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index e3cdc85ce5b6..a0f4139631dd 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -304,8 +304,8 @@ static void note_page(struct seq_file *m, struct
pg_state *st,
 		/*
 		 * Now print the actual finished series
 		 */
-		if (!st->marker->max_lines ||
-		    st->lines < st->marker->max_lines) {
+		if ((cur & _PAGE_PRESENT) && (!st->marker->max_lines ||
+		    st->lines < st->marker->max_lines)) {
 			pt_dump_seq_printf(m, st->to_dmesg,
 					   "0x%0*lx-0x%0*lx   ",
 					   width, st->start_address,
@@ -321,7 +321,9 @@ static void note_page(struct seq_file *m, struct
pg_state *st,
 			printk_prot(m, st->current_prot, st->level,
 				    st->to_dmesg);
 		}
-		st->lines++;
+		if (cur & _PAGE_PRESENT) {
+			st->lines++;
+		}

 		/*
 		 * We print markers for special areas of address space,
-- 
2.20.1

