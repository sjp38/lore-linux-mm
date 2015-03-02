Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 180D96B0075
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 21:11:49 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id w8so20881459qac.1
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 18:11:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y66si709327qky.24.2015.03.01.18.11.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Mar 2015 18:11:48 -0800 (PST)
Message-ID: <54F3C6AD.50300@redhat.com>
Date: Sun, 01 Mar 2015 21:10:53 -0500
From: Jon Masters <jcm@redhat.com>
MIME-Version: 1.0
Subject: PMD update corruption (sync question)
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org> <54F06636.6080905@redhat.com>
In-Reply-To: <54F06636.6080905@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jon Masters <jcm@redhat.com>, Steve Capper <steve.capper@linaro.org>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

Hi Folks,

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
