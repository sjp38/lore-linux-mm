Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id F10EC6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 00:59:23 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id a108so15530259qge.8
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 21:59:23 -0800 (PST)
Received: from mx3-phx2.redhat.com (mx3-phx2.redhat.com. [209.132.183.24])
        by mx.google.com with ESMTPS id i204si10895089qhc.56.2015.03.01.21.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 21:59:23 -0800 (PST)
Date: Mon, 2 Mar 2015 00:58:36 -0500 (EST)
Subject: Re: PMD update corruption (sync question)
From: Jon Masters <jcm@redhat.com>
MIME-Version: 1.0
Message-ID: <938476184.27970130.1425275915893.JavaMail.zimbra@zmail15.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
In-Reply-To: <54F3C6AD.50300@redhat.com>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org> <54F06636.6080905@redhat.com> <54F3C6AD.50300@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-arch@vger.kernel.org, linux@arm.linux.org.uk, Steve Capper <steve.capper@linaro.org>, linux-mm@kvack.org, catalin.marinas@arm.com
Cc: gary.robertson@linaro.org, mark.rutland@arm.com, hughd@google.com, akpm@linux-foundation.org, christoffer.dall@linaro.org, peterz@infradead.org, mgorman@suse.de, will.deacon@arm.com, dann.frazier@canonical.com, anders.roxell@linaro.org

Test kernels running with an explicit DSB in all PTE update cases now running overnight. Just in case.

-- 
Computer Architect | Sent from my #ARM Powered Mobile Device

On Mar 1, 2015 9:10 PM, Jon Masters <jcm@redhat.com> wrote:
>
> Hi Folks, 
>
> I've pulled a couple of all nighters reproducing this hard to trHi Folks,

I've pulled a couple of all nighters reproducing this hard to trigger
issue and got some data. It looks like the high half of the (note always
userspace) PMD is all zeros or all ones, which makes me wonder if the
logic in update_mmu_cache might be missing something on AArch64.

When a kernel is built with 64K pages and 2 levels the PMD is
effectively updated using set_pte_at, which explicitly won't perform a
DSB if the address is userspace (it expects this to happen later, in
update_mmu_cache as an example.

Can anyone think of an obvious reason why we might not be properly
flushing the changes prior to them being consumed by a hardware walker?

Jon.

On 02/27/2015 07:42 AM, Jon Masters wrote:
> On 09/26/2014 10:03 AM, Steve Capper wrote:
> 
>> This series implements general forms of get_user_pages_fast and
>> __get_user_pages_fast in core code and activates them for arm and arm64.
>>
>> These are required for Transparent HugePages to function correctly, as
>> a futex on a THP tail will otherwise result in an infinite loop (due to
>> the core implementation of __get_user_pages_fast always returning 0).
>>
>> Unfortunately, a futex on THP tail can be quite common for certain
>> workloads; thus THP is unreliable without a __get_user_pages_fast
>> implementation.
>>
>> This series may also be beneficial for direct-IO heavy workloads and
>> certain KVM workloads.
>>
>> I appreciate that the merge window is coming very soon, and am posting
>> this revision on the off-chance that it gets the nod for 3.18. (The changes
>> thus far have been minimal and the feedback I've got has been mainly
>> positive).
> 
> Head's up: these patches are currently implicated in a rare-to-trigger
> hang that we are seeing on an internal kernel. An extensive effort is
> underway to confirm whether these are the cause. Will followup.
> 
> Jon.
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
