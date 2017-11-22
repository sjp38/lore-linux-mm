Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74E0D6B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 22:45:03 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d86so1849644pfk.19
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:45:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l7si12730585pli.651.2017.11.21.19.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 19:45:02 -0800 (PST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E53D521994
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:45:01 +0000 (UTC)
Received: by mail-it0-f44.google.com with SMTP id 187so2847215iti.5
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:45:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7e458284-b334-bb70-a374-c65cc4ef9f02@linux.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193113.E35BC3BF@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202057581.2348@nanos> <7e458284-b334-bb70-a374-c65cc4ef9f02@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 21 Nov 2017 19:44:39 -0800
Message-ID: <CALCETrXv3VxEdr1UOjWW9GTFTd_BoUCpThxOxz7a4-YC+d_i=Q@mail.gmail.com>
Subject: Re: [PATCH 09/30] x86, kaiser: only populate shadow page tables for userspace
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Tue, Nov 21, 2017 at 2:09 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/20/2017 12:12 PM, Thomas Gleixner wrote:
>>> +                     */
>>> +                    native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
>>> +                    /*
>>> +                     * For the copy of the pgd that the kernel
>>> +                     * uses, make it unusable to userspace.  This
>>> +                     * ensures if we get out to userspace with the
>>> +                     * wrong CR3 value, userspace will crash
>>> +                     * instead of running.
>>> +                     */
>>> +                    pgd.pgd |= _PAGE_NX;
>>> +            }
>>> +    } else if (!pgd.pgd) {
>>> +            /*
>>> +             * We are clearing the PGD and can not check  _PAGE_USER
>>> +             * in the zero'd PGD.
>>
>> Just the argument cannot be checked because it's clearing the entry. The
>> pgd entry itself is not yet modified, so it could be checked.
>
> So, I guess we could enforce that only PGDs with _PAGE_USER set can ever
> be cleared.  That has a nice symmetry to it because we set the shadow
> when we see _PAGE_USER and we would then clear the shadow when we see
> _PAGE_USER.

Is this code path ever hit in any case other than tearing down an LDT?

I'm tempted to suggest that KAISER just disable the MODIFY_LDT config
option for now...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
