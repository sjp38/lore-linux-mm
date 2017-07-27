Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAAA6B0292
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:58:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so37500638pfd.14
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:58:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d127si10894358pfg.316.2017.07.27.05.58.28
        for <linux-mm@kvack.org>;
        Thu, 27 Jul 2017 05:58:28 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and document behaviour
References: <20170725154114.24131-1-punit.agrawal@arm.com>
	<20170725154114.24131-2-punit.agrawal@arm.com>
	<20170726085038.GB2981@dhcp22.suse.cz>
	<20170726085325.GC2981@dhcp22.suse.cz>
	<87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
	<20170726123357.GP2981@dhcp22.suse.cz>
	<20170726124704.GQ2981@dhcp22.suse.cz>
	<8760efjp98.fsf@e105922-lin.cambridge.arm.com>
	<9b3b3585-f984-e592-122c-ed23c8558069@oracle.com>
Date: Thu, 27 Jul 2017 13:58:25 +0100
In-Reply-To: <9b3b3585-f984-e592-122c-ed23c8558069@oracle.com> (Mike Kravetz's
	message of "Wed, 26 Jul 2017 20:16:31 -0700")
Message-ID: <87o9s6hw9a.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 07/26/2017 06:34 AM, Punit Agrawal wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>>> On Wed 26-07-17 14:33:57, Michal Hocko wrote:
>>>> On Wed 26-07-17 13:11:46, Punit Agrawal wrote:
>>> [...]
>>>>> I've been running tests from mce-test suite and libhugetlbfs for similar
>>>>> changes we did on arm64. There could be assumptions that were not
>>>>> exercised but I'm not sure how to check for all the possible usages.
>>>>>
>>>>> Do you have any other suggestions that can help improve confidence in
>>>>> the patch?
>>>>
>>>> Unfortunatelly I don't. I just know there were many subtle assumptions
>>>> all over the place so I am rather careful to not touch the code unless
>>>> really necessary.
>>>>
>>>> That being said, I am not opposing your patch.
>>>
>>> Let me be more specific. I am not opposing your patch but we should
>>> definitely need more reviewers to have a look. I am not seeing any
>>> immediate problems with it but I do not see a large improvements either
>>> (slightly less nightmare doesn't make me sleep all that well ;)). So I
>>> will leave the decisions to others.
>> 
>> I hear you - I'd definitely appreciate more eyes on the code change and
>> description.
>
> I like the change in semantics for the routine.  Like you, I examined all
> callers of huge_pte_offset() and it appears that they will not be impacted
> by your change.
>
> My only concern is that arch specific versions of huge_pte_offset, may
> not (yet) follow the new semantic.  Someone could potentially introduce
> a new huge_pte_offset call and depend on the new 'documented' semantics.
> Yet, an unmodified arch specific version of huge_pte_offset might have
> different semantics.  I have not reviewed all the arch specific instances
> of the routine to know if this is even possible.  Just curious if you
> examined these, or perhaps you think this is not an issue?

>From checking through the implementations of huge_pte_offset()
architectures, the change shouldn't break anything. (I also cc'd the
posting to linux-arch for architecture maintainers to take more notice).

This is because existing users actively deal with the different returned
values (NULL, huge pte_t*, swap pte_t*) and are not checking explicitly
for pmd or pud.

Guarding against future users is more tricky - it would definitely help
to align all the implementations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
