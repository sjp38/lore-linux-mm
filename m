Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id BF7166B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:56:26 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so1401704wes.28
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 10:56:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si224056wia.53.2014.04.24.10.56.24
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 10:56:25 -0700 (PDT)
Message-ID: <53594FB3.9050505@redhat.com>
Date: Thu, 24 Apr 2014 13:53:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182426.D6DD1E8F@viggo.jf.intel.com> <20140424103727.GT23991@suse.de> <53594920.8030203@sr71.net>
In-Reply-To: <53594920.8030203@sr71.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com, "H. Peter Anvin" <hpa@zytor.com>

On 04/24/2014 01:25 PM, Dave Hansen wrote:
> On 04/24/2014 03:37 AM, Mel Gorman wrote:
>> On Mon, Apr 21, 2014 at 11:24:26AM -0700, Dave Hansen wrote:
>>> +This will cause us to do the global flush for more cases.
>>> +Lowering it to 0 will disable the use of the individual flushes.
>>> +Setting it to 1 is a very conservative setting and it should
>>> +never need to be 0 under normal circumstances.
>>> +
>>> +Despite the fact that a single individual flush on x86 is
>>> +guaranteed to flush a full 2MB, hugetlbfs always uses the full
>>> +flushes.  THP is treated exactly the same as normal memory.
>>> +
>>
>> You are the second person that told me this and I felt the manual was
>> unclear on this subject. I was told that it might be a documentation bug
>> but because this discussion was in a bar I completely failed to follow up
>> on it. Specifically this part in 4.10.2.3 caused me problems when I last
>> looked at the area.
> <snip>
>
> My understanding comes from "4.10.4.2 Recommended Invalidation":
>
> 	a?c If software modifies a paging-structure entry that identifies
> 	the final page frame for a page number (either a PTE or a
> 	paging-structure entry in which the PS flag is 1), it should
> 	execute INVLPG for any linear address with a page number whose
> 	translation uses that PTE. 2
>
> and especially the footnote:
>
> 	2. One execution of INVLPG is sufficient even for a page with
> 	size greater than 4 KBytes.
>
> I do agree that it's ambiguous at best.  I'll go see if anybody cares to
> update that bit.

I suspect that IF the TLB actually uses a 2MB entry for the
translation, a single INVLPG will work.

However, the CPU is free to cache the translations for a 2MB
region with a bunch of 4kB entries, if it wanted to, so in
the end we have no guarantee that an INVLPG will actually do
the right thing...

The same is definitely true for 1GB vs 2MB entries, with
some CPUs being capable of parsing page tables with 1GB
entries, but having no TLB entries for 1GB translations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
