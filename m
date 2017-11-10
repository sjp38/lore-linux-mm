Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDAD6B02D7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 19:53:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 4so5737983pge.8
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 16:53:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b9si7330988pgs.562.2017.11.09.16.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 16:53:37 -0800 (PST)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AC33A21983
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 00:53:36 +0000 (UTC)
Received: by mail-io0-f172.google.com with SMTP id p186so11835810ioe.12
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 16:53:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com> <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 9 Nov 2017 16:53:15 -0800
Message-ID: <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 9, 2017 at 11:26 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/09/2017 11:04 AM, Andy Lutomirski wrote:
>> On Wed, Nov 8, 2017 at 11:47 AM, Dave Hansen
>> <dave.hansen@linux.intel.com> wrote:
>>>
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>>
>>> The VSYSCALL page is mapped by kernel page tables at a kernel address.
>>> It is troublesome to support with KAISER in place, so disable the
>>> native case.
>>>
>>> Also add some help text about how KAISER might affect the emulation
>>> case as well.
>>
>> Can you re-explain why this is helpful?
>
> How about this?
>
> The KAISER code attempts to "poison" the user portion of the kernel page
> tables.  It detects the entries pages that it wants that it wants to
> poison in two ways:
>  * Looking for addresses >= PAGE_OFFSET
>  * Looking for entries without _PAGE_USER set

What do you mean "poison"?

Anyway, the stuff here:

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_stack

is an attempt to create the infrastructure needed to move (almost?)
everything needed in the user tables into the fixmap.  If that ends up
working well, then perhaps the fixmap should just be completely
special-cased, in which case I think this issue goes away.  What I
have in mind is something like:

set_user_fixmap(index, pa, prot);

that sets an entry in the *user* fixmap.  All user mms would get the
same PGD entry for the user fixmap.

(And yes, it quite correctly fails kbuild bot right now.  That's why I
haven't emailed out the patches yet.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
