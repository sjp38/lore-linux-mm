Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B27056B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 11:29:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d86so11206510pfk.19
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 08:29:35 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l12si21762380plc.265.2017.11.26.08.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 08:29:34 -0800 (PST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38CB8219AE
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 16:29:34 +0000 (UTC)
Received: by mail-it0-f44.google.com with SMTP id x28so18165703ita.0
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 08:29:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2e4773b2-2cb3-284e-f0a7-3eaebc2676e5@linux.intel.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com>
 <CALCETrUx-3bXEsZSuaSBkEf7r+MmGoOb9fM8A3eGQpwq0qc2HA@mail.gmail.com>
 <CALCETrXqcB_2oBktvLTc2k1z_O65mTs2rDF5ZMYnFvhs2Kh3Ng@mail.gmail.com> <2e4773b2-2cb3-284e-f0a7-3eaebc2676e5@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 26 Nov 2017 08:29:12 -0800
Message-ID: <CALCETrUp=Cq0A8reEhXqmjeb_=C8yHS3-RTAH9TERGTxUG9AiQ@mail.gmail.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Sun, Nov 26, 2017 at 8:24 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/26/2017 08:10 AM, Andy Lutomirski wrote:
>>> As a side benefit, this shouldn't have magical interactions with the
>>> vsyscall page any more.
>>>
>>> Are there cases that this would get wrong?
>>>
>> Quick ping: did this get lost?
>
> It does drop a warning that the other version of the code has, but
> that's pretty minor.
>
> Basically, we need two checks:
>
>         pgd_userspace_access() (aka _PAGE_USER) and
>         pgdp_maps_userspace()
>
> The original code does pgd_userspace_access() in a top-level if and then
> the pgdp_maps_userspace() checks at the second level.  I think you are
> basically suggesting that we flip that.
>
> Logically, I'm sure we can make it work.  It's just a matter of needing
> to look at other things first.
>
> BTW, this comment is, I think incorrect:
>
>>   if (pgdp_maps_userspace(pgdp)) {
> ...
>>   } else {
>>     /*
>>      * We can get here due to vmalloc, a vmalloc fault, memory
>> hot-add, or initial setup
>>      * of kernelmode page tables.  Regardless of which particular code
>> path we're in,
>>      * these mappings should not be automatically propagated to the
>> usermode tables.
>>      */
>
> Since we pre-populated the entire kernel area's PGDs, I don't think
> we'll ever have a valid reason to be doing a set_pgd() again on the
> kernel area.

Right, forgot about that.  So it's just initial setup, then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
