Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547206B04BA
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 23:46:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so341230pga.23
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 20:46:15 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r39si1746419pld.235.2018.01.03.20.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 20:46:14 -0800 (PST)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com [209.85.214.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 05BD921A19
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 04:46:14 +0000 (UTC)
Received: by mail-it0-f42.google.com with SMTP id c16so931569itc.5
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 20:46:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems> <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
 <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 3 Jan 2018 20:45:52 -0800
Message-ID: <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509 certs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable <stable@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 3, 2018 at 8:35 PM, Benjamin Gilbert
<benjamin.gilbert@coreos.com> wrote:
> On Wed, Jan 03, 2018 at 04:37:53PM -0800, Andy Lutomirski wrote:
>> Maybe try rebuilding a bad kernel with free_ldt_pgtables() modified
>> to do nothing, and the read /sys/kernel/debug/page_tables/current (or
>> current_kernel, or whatever it's called).  The problem may be obvious.
>
> current_kernel attached.  I have not seen any crashes with
> free_ldt_pgtables() stubbed out.

I haven't reproduced it, but I think I see what's wrong.  KASLR sets
vaddr_end to a totally bogus value.  It should be no larger than
LDT_BASE_ADDR.  I suspect that your vmemmap is getting randomized into
the LDT range.  If it weren't for that, it could just as easily land
in the cpu_entry_area range.  This will need fixing in all versions
that aren't still called KAISER.

Our memory map code is utter shite.  This kind of bug should not be
possible without a giant warning at boot that something is screwed up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
