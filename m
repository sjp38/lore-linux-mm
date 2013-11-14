Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 23D176B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 03:55:34 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fb1so168539pad.31
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 00:55:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.150])
        by mx.google.com with SMTP id vs7si26833491pbc.265.2013.11.14.00.55.30
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 00:55:32 -0800 (PST)
Message-ID: <52849084.1010606@asianux.com>
Date: Thu, 14 Nov 2013 16:57:40 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] arch: um: kernel: skas: mmu: remove pmd_free() and pud_free()
 for failure processing in init_stub_pte()
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils> <528308E8.8040203@asianux.com> <alpine.LNX.2.00.1311132041200.1785@eggly.anvils> <52847237.5030405@asianux.com> <52847CD5.1030105@asianux.com> <528481E2.9030707@nod.at>
In-Reply-To: <528481E2.9030707@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Hugh Dickins <hughd@google.com>, Jeff Dike <jdike@addtoit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, uml-user <user-mode-linux-user@lists.sourceforge.net>

On 11/14/2013 03:55 PM, Richard Weinberger wrote:
> Am 14.11.2013 08:33, schrieb Chen Gang:
>> > On 11/14/2013 02:48 PM, Chen Gang wrote:
>>>> >>> >From the look of it, if an error did occur in init_stub_pte(),
>>>>> >>>> then the special mapping of STUB_CODE and STUB_DATA would not
>>>>> >>>> be installed, so this area would be invisible to munmap and exit,
>>>>> >>>> and with your patch then the pages allocated likely to be leaked.
>>>>> >>>>
>>> >> It sounds reasonable to me: "although 'pgd' related with 'mm', but they
>>> >> are not installed". But just like you said originally: "better get ACK
>>> >> from some mm guys".
>>> >>
>>> >>
>>> >> Hmm... is it another issue: "after STUB_CODE succeeds, but STUB_DATA
>>> >> fails, the STUB_CODE will be leaked".
>>> >>
>>> >>
>>>>> >>>> Which is not to say that the existing code is actually correct:
>>>>> >>>> you're probably right that it's technically wrong.  But it would
>>>>> >>>> be very hard to get init_stub_pte() to fail, and has anyone
>>>>> >>>> reported a problem with it?  My guess is not, and my own
>>>>> >>>> inclination to dabble here is zero.
>>>>> >>>>
>>> >> Yeah.
>>> >>
>> > 
>> > If we can not get ACK from any mm guys, and we have no enough time
>> > resource to read related source code, for me, I still recommend to
>> > remove p?d_free() in failure processing.
> It's rather easy, does your commit fix a real problem you are facing?
> If the answer is "yes" we can talk.
> 

We have met many code which *should* be correct, but in really world it
is incorrect (most of reasons come from related interface definition).
I want to let these code less and less.

Now I want to make clear all p?d_free() related things, and except our
um, also 3 areas use it.

  arch/arm/mm/pgd.c:100:  pud_free(mm, new_pud);
  arch/arm/mm/pgd.c:137:  pud_free(mm, pud);
  arch/arm/mm/pgd.c:155:          pud_free(mm, pud);
  drivers/iommu/arm-smmu.c:947:   pud_free(NULL, pud_base);
  mm/memory.c:3835:               pud_free(mm, new);

I am checking all of them (include um), and now for me, the related
code under um can be improved, so I communicate with you (send the
related patch).


> Chen, If you really want to help us, please investigate into existing/real problems.
> Toralf does a very good job in finding strange issues using trinity.
> You could help him resolving the issue described in that thread:
> "[uml-devel] fuzz tested 32 bit user mode linux image hangs in radix_tree_next_chunk()"

Excuse me, at least now, I have no related plan to analyze issues which
not find by myself. The reasons are:

 - I am not quite familiar with kernel, I need preparing (what I am doing is just familiar kernel step by step).

 - my current/original plan about public kernel is delayed.

 - originally I plan (not declare to outside) to solve the issues from Bugzilla of public kernel in next year (2014).
   it will (of cause) also be delayed (I even can not dare to declare it, now).


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
