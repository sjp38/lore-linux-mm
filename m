Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B8D0E82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 18:06:59 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so54563277pac.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:06:59 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id uz5si5409835pac.230.2015.10.29.15.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 15:06:59 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so46441626pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:06:58 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
 <871tcewoso.fsf@x220.int.ebiederm.org>
 <CABXk95DOSKv70p+=DQvHck5LCvRDc0WDORpoobSStWhrcrCiyg@mail.gmail.com>
 <CAEP4de2GsEwn0eeO126GEtFb-FSJoU3fgOWTAr1yPFAmyXTi0Q@mail.gmail.com>
 <87oafiuys0.fsf@x220.int.ebiederm.org>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <56329880.4080103@android.com>
Date: Thu, 29 Oct 2015 15:06:56 -0700
MIME-Version: 1.0
In-Reply-To: <87oafiuys0.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, Jonathan Corbet <corbet@lwn.net>, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, Mark Salyzyn <salyzyn@android.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On 10/28/2015 08:41 PM, Eric W. Biederman wrote:
> Dan Cashman <dcashman@android.com> writes:
> 
>>>> This all would be much cleaner if the arm architecture code were just to
>>>> register the sysctl itself.
>>>>
>>>> As it sits this looks like a patchset that does not meaninfully bisect,
>>>> and would result in code that is hard to trace and understand.
>>>
>>> I believe the intent is to follow up with more architecture specific
>>> patches to allow each architecture to define the number of bits to use
>>
>> Yes.  I included these patches together because they provide mutual
>> context, but each has a different outcome and they could be taken
>> separately.
> 
> They can not.  The first patch is incomplete by itself.

Could you be more specific in what makes the first patch incomplete?  Is
it because it is essentially a no-op without additional architecture
changes (e.g. the second patch) or is it specifically because it
introduces and uses the three "mmap_rnd_bits*" variables without
defining them?  If the former, I'd like to avoid combining the general
procfs change with any architecture-specific one(s).  If the latter, I
hope the proposal below addresses that.

>> The arm architecture-specific portion allows the changing
>> of the number of bits used for mmap ASLR, useful even without the
>> sysctl.  The sysctl patch (patch 1) provides another way of setting
>> this value, and the hope is that this will be adopted across multiple
>> architectures, with the arm changes (patch 2) providing an example.  I
>> hope to follow this with changes to arm64 and x86, for example.
> 
> If you want to make the code generic.  Please maximize the sharing.
> That is please define the variables in a generic location, as well
> as the Kconfig variables (if possible).
> 
> As it is you have an architecture specific piece of code that can not be
> reused without duplicating code, and that is just begging for problems.

I think it would make sense to move the variable definitions into
mm/mmap.c, included conditionally based on the presence of
CONFIG_ARCH_MMAP_RND_BITS.

As for the Kconfigs, I am open to suggestions.  I considered declaring
and documenting ARCH_MMAP_RND_BITS in arch/Kconfig, but I would like it
to be bounded in range by the _MIN and _MAX values, which necessarily
must be defined in the arch-specific Kconfigs.  Thus, we'd have
ARCH_MMAP_RND_BITS declared in arch/Kconfig as it currently is in
arch/arm/Kconfig defaulting to _MIN, and would declare both the _MIN and
_MAX in arch/Kconfig, while specifying default values in
arch/${ARCH}/Kconfig.

Would these changes be more acceptable?

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
