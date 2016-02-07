Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB766B0261
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 15:54:12 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so90080167wmr.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 12:54:12 -0800 (PST)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id l187si12580251wmf.83.2016.02.07.12.54.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 07 Feb 2016 12:54:11 -0800 (PST)
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
 <20160207165524.GF5862@pd.tnic>
From: Richard Weinberger <richard@nod.at>
Message-ID: <56B7AEEE.5070504@nod.at>
Date: Sun, 7 Feb 2016 21:54:06 +0100
MIME-Version: 1.0
In-Reply-To: <20160207165524.GF5862@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Am 07.02.2016 um 17:55 schrieb Borislav Petkov:
> due to those
> 
>> +     _ASM_EXTABLE_FAULT(0b,30b)
>> +     _ASM_EXTABLE_FAULT(1b,31b)
>> +     _ASM_EXTABLE_FAULT(2b,32b)
>> +     _ASM_EXTABLE_FAULT(3b,33b)
>> +     _ASM_EXTABLE_FAULT(4b,34b)
> 
> things below and that's because ex_handler_fault() is defined in
> arch/x86/mm/extable.c and UML doesn't include that file in the build. It
> takes kernel/extable.c and lib/extable.c only.
> 
> Richi, what's the usual way to address that in UML? I.e., make an
> x86-only symbol visible to the UML build too? Define a dummy one, just
> so that it builds?

As discussed on IRC with Boris, UML offers only minimal extable support.
To get rid of the said #ifndef, UML would have to provide its own
extable.c (mostly copy&paste from arch/x86) and an advanced
struct exception_table_entry which includes the trap number.
This implies also that UML can no longer use uaccess.h from asm-generic
or has to add a new ifdef into uaccess.h to whiteout the minimal
struct exception_table_entry from there.

So, I'd vote to keep the #ifndef CONFIG_UML in memcpy_64.S.
As soon you need another #ifndef please ping me and I'll happily
bite the bullet and implement the advanced extable stuff for UML.
Deal?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
