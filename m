Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0297E6B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 21:43:50 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5040176pad.30
        for <linux-mm@kvack.org>; Sun, 18 May 2014 18:43:50 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id rm10si17482444pab.197.2014.05.18.18.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 May 2014 18:43:50 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data for powerpc
In-Reply-To: <alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
Date: Mon, 19 May 2014 09:42:46 +0930
Message-ID: <87wqdik4n5.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

Hugh Dickins <hughd@google.com> writes:
> On Thu, 15 May 2014, Madhavan Srinivasan wrote:
>> 
>> Hi Ingo,
>> 
>> 	Do you have any comments for the latest version of the patchset. If
>> not, kindly can you pick it up as is.
>> 
>> 
>> With regards
>> Maddy
>> 
>> > Kirill A. Shutemov with 8c6e50b029 commit introduced
>> > vm_ops->map_pages() for mapping easy accessible pages around
>> > fault address in hope to reduce number of minor page faults.
>> > 
>> > This patch creates infrastructure to modify the FAULT_AROUND_ORDER
>> > value using mm/Kconfig. This will enable architecture maintainers
>> > to decide on suitable FAULT_AROUND_ORDER value based on
>> > performance data for that architecture. First patch also defaults
>> > FAULT_AROUND_ORDER Kconfig element to 4. Second patch list
>> > out the performance numbers for powerpc (platform pseries) and
>> > initialize the fault around order variable for pseries platform of
>> > powerpc.
>
> Sorry for not commenting earlier - just reminded by this ping to Ingo.
>
> I didn't study your numbers, but nowhere did I see what PAGE_SIZE you use.
>
> arch/powerpc/Kconfig suggests that Power supports base page size of
> 4k, 16k, 64k or 256k.
>
> I would expect your optimal fault_around_order to depend very much on
> the base page size.

It was 64k, which is what PPC64 uses on all the major distributions.
You really only get a choice of 4k and 64k with 64 bit power.

> Perhaps fault_around_size would provide a more useful default?

That seems to fit.  With 4k pages and order 4, you're asking for 64k.
Maddy's result shows 64k is also reasonable for 64k pages.

Perhaps we try to generalize from two data points (a slight improvement
over doing it from 1!), eg:

/* 4 seems good for 4k-page x86, 0 seems good for 64k page ppc64, so: */
unsigned int fault_around_order __read_mostly =
        (16 - PAGE_SHIFT < 0 ? 0 : 16 - PAGE_SHIFT);

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
