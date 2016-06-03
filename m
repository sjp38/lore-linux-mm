Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB1D6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 13:28:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so115838853pfb.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 10:28:26 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id c186si3800800pfa.69.2016.06.03.10.28.24
        for <linux-mm@kvack.org>;
        Fri, 03 Jun 2016 10:28:24 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152822.FE8D405E@viggo.jf.intel.com>
 <20160601123705.72a606e7@lwn.net> <574F386A.8070106@sr71.net>
 <CAKgNAkiyD_2tAxrBxirxViViMUsfLRRqQp5HowM58dG21LAa7Q@mail.gmail.com>
 <574F7B16.4080906@sr71.net> <5499ff55-ae0f-e54c-05fd-b1e76dc05a89@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5751BE37.1060704@sr71.net>
Date: Fri, 3 Jun 2016 10:28:23 -0700
MIME-Version: 1.0
In-Reply-To: <5499ff55-ae0f-e54c-05fd-b1e76dc05a89@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>, lkml <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 06/02/2016 05:26 PM, Michael Kerrisk (man-pages) wrote:
> On 06/01/2016 07:17 PM, Dave Hansen wrote:
>> On 06/01/2016 05:11 PM, Michael Kerrisk (man-pages) wrote:
>>>>>>>
>>>>>>> If I read this right, it doesn't actually remove any pkey restrictions
>>>>>>> that may have been applied while the key was allocated.  So there could be
>>>>>>> pages with that key assigned that might do surprising things if the key is
>>>>>>> reallocated for another use later, right?  Is that how the API is intended
>>>>>>> to work?
>>>>>
>>>>> Yeah, that's how it works.
>>>>>
>>>>> It's not ideal.  It would be _best_ if we during mm_pkey_free(), we
>>>>> ensured that no VMAs under that mm have that vma_pkey() set.  But, that
>>>>> search would be potentially expensive (a walk over all VMAs), or would
>>>>> force us to keep a data structure with a count of all the VMAs with a
>>>>> given key.
>>>>>
>>>>> I should probably discuss this behavior in the manpages and address it
>>> s/probably//
>>>
>>> And, did I miss it. Was there an updated man-pages patch in the latest
>>> series? I did not notice it.
>>
>> There have been to changes to the patches that warranted updating the
>> manpages until now.  I'll send the update immediately.
> 
> Do those updated pages include discussion of the point noted above?
> I could not see it mentioned there.

I added the following text to pkey_alloc.2.  I somehow neglected to send
it out in the v3 update of the manpages RFC:

An application should not call
.BR pkey_free ()
on any protection key which has been assigned to an address
range by
.BR pkey_mprotect ()
and which is still in use.  The behavior in this case is
undefined and may result in an error.

I'll add that in the version (v4) I send out shortly.

> Just by the way, the above behavior seems to offer possibilities
> for users to shoot themselves in the foot, in a way that has security
> implications. (Or do I misunderstand?)

Protection keys has the potential to add a layer of security and
reliability to applications.  But, it has not been primarily designed as
a security feature.  For instance, WRPKRU is a completely unprivileged
instruction, so pkeys are useless in any case that an attacker controls
the PKRU register or can execute arbitrary instructions.

That said, this mechanism does, indeed, allow a user to shoot themselves
in the foot and in a way that could have security implications.

For instance, say the following happened:
1. A sensitive bit of data in memory was marked with a pkey
2. That pkey was set as PKEY_DISABLE_ACCESS
3. The application called pkey_free() on the pkey, without freeing
   the sensitive data
4. Application calls pkey_alloc() and then clears PKEY_DISABLE_ACCESS
5. Applocation can now read the sensitive data

The application has to have basically "leaked" a reference to the pkey.
 It forgot that it had sensitive data marked with that key.

The kernel _could_ enforce that no in-use pkey may have pkey_free()
called on it.  But, doing that has tradeoffs which could make
pkey_free() extremely slow:

> It's not ideal.  It would be _best_ if we during mm_pkey_free(), we
> ensured that no VMAs under that mm have that vma_pkey() set.  But, that
> search would be potentially expensive (a walk over all VMAs), or would
> force us to keep a data structure with a count of all the VMAs with a
> given key.

In addition, that checking _could_ be implemented in an application by
inspecting /proc/$pid/smaps for "ProtectionKey: $foo" before calling
pkey_free($foo).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
