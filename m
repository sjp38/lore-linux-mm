Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id B213782F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 15:17:58 -0400 (EDT)
Received: by lacdq2 with SMTP id dq2so19771486lac.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:17:57 -0700 (PDT)
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com. [209.85.215.43])
        by mx.google.com with ESMTPS id y191si6333587lfd.174.2015.09.24.12.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 12:17:57 -0700 (PDT)
Received: by lahh2 with SMTP id h2so73868117lah.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:17:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56044A88.7030203@sr71.net>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 24 Sep 2015 12:17:37 -0700
Message-ID: <CALCETrVd+wgGvRcKhz6wHYqYi+9=MSddqxOkWucW=DT9kQ=8Jg@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>

On Thu, Sep 24, 2015 at 12:10 PM, Dave Hansen <dave@sr71.net> wrote:
> On 09/24/2015 02:49 AM, Ingo Molnar wrote:
>> * Dave Hansen <dave@sr71.net> wrote:
>>>> Another question, related to enumeration as well: I'm wondering whether
>>>> there's any way for the kernel to allocate a bit or two for its own purposes -
>>>> such as protecting crypto keys? Or is the facility fundamentally intended for
>>>> user-space use only?
>>>
>>> No, that's not possible with the current setup.
>>
>> Ok, then another question, have you considered the following usecase:
>>
>> AFAICS pkeys only affect data loads and stores. Instruction fetches are notably
>> absent from the documentation. Can you clarify that instructions can be fetched
>> and executed from PTE_READ but pkeys-all-access-disabled pags?
>
> That is my understanding.  I don't have a test for it, but I'll go make one.
>
>> If yes then this could be a significant security feature / usecase for pkeys:
>> executable sections of shared libraries and binaries could be mapped with pkey
>> access disabled. If I read the Intel documentation correctly then that should be
>> possible.
>
> Agreed.  I've even heard from some researchers who are interested in this:
>
> https://www.infsec.cs.uni-saarland.de/wp-content/uploads/sites/2/2014/10/nuernberger2014ccs_disclosure.pdf
>
>> I.e. AFAICS pkeys could be used to create true '--x' permissions for executable
>> (user-space) pages.
>
> Just remember that all of the protections are dependent on the contents
> of PKRU.  If an attacker controls the Access-Disable bit in PKRU for the
> executable-only region, you're sunk.
>
> But, that either requires being able to construct and execute arbitrary
> code *or* call existing code that sets PKRU to the desired values.
> Which, I guess, gets harder to do if all of the the wrpkru's are *in*
> the execute-only area.
>

This may mean that we want to have a way for binaries to indicate that
they want their --x segments to be loaded with a particular protection
key.  The right way to do that might be using an ELF note, and I also
want to use ELF notes to allow turning off vsyscalls, so maybe it's
time to write an ELF note parser in the kernel.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
