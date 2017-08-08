Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 922896B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 11:20:02 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id p32so12909478uag.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:20:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 205si790849vkc.106.2017.08.08.08.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 08:20:01 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
 <1502198148.6577.18.camel@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
Date: Tue, 8 Aug 2017 08:19:48 -0700
MIME-Version: 1.0
In-Reply-To: <1502198148.6577.18.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On 08/08/2017 06:15 AM, Rik van Riel wrote:
> On Tue, 2017-08-08 at 11:58 +0200, Florian Weimer wrote:
>> On 08/07/2017 08:23 PM, Mike Kravetz wrote:
>>> If my thoughts above are correct, what about returning EINVAL if
>>> one
>>> attempts to set MADV_DONTFORK on mappings set up for sharing?
>>
>> That's my preference as well.  If there is a use case for shared or
>> non-anonymous mappings, then we can implement MADV_DONTFORK with the
>> semantics for this use case.  If we pick some arbitrary semantics
>> now,
>> without any use case, we might end up with something that's not
>> actually
>> useful.
> 
> MADV_DONTFORK is existing semantics, and it is enforced
> on shared, non-anonymous mappings. It is frequently used
> for things like device mappings, which should not be
> inherited by a child process, because the device can only
> be used by one process at a time.
> 
> When someone requests MADV_DONTFORK on a shared VMA, they
> will get it. The later madvise request overrides the mmap
> flags that were used earlier.
> 
> The question is, should MADV_WIPEONFORK (introduced by
> this series) have not just different semantics, but also
> totally different behavior from MADV_DONTFORK?

Sorry for the confusion.  I accidentally used MADV_DONTFORK instead
of MADV_WIPEONFORK in my reply (which Florian commented on).

> Does the principle of least surprise dictate that the
> last request determines the policy on an area, or should
> later requests not be able to override policy that was
> set at mmap time?

That is the question.

The other question I was trying to bring up is "What does MADV_WIPEONFORK
mean for various types of mappings?"  For example, if we allow
MADV_WIPEONFORK on a file backed mapping what does that mapping look
like in the child after fork?  Does it have any connection at all to the
file?  Or, do we drop all references to the file and essentially transform
it to a private (or shared?) anonymous mapping after fork.  What about
System V shared memory?  What about hugetlb?

If the use case is fairly specific, then perhaps it makes sense to
make MADV_WIPEONFORK not applicable (EINVAL) for mappings where the
result is 'questionable'.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
