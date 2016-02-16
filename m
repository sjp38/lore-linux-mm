Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA7F6B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:46:39 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e127so107249450pfe.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:46:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e3si51852293pas.149.2016.02.16.07.46.38
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 07:46:39 -0800 (PST)
Subject: Re: [PATCHv2 17/28] thp: skip file huge pmd on copy_huge_pmd()
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-18-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2781.7060808@intel.com> <20160216101450.GE46557@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56C3445D.3040305@intel.com>
Date: Tue, 16 Feb 2016 07:46:37 -0800
MIME-Version: 1.0
In-Reply-To: <20160216101450.GE46557@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/16/2016 02:14 AM, Kirill A. Shutemov wrote:
> On Fri, Feb 12, 2016 at 10:42:09AM -0800, Dave Hansen wrote:
>> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
>>> File pmds can be safely skip on copy_huge_pmd(), we can re-fault them
>>> later. COW for file mappings handled on pte level.
>>
>> Is this different from 4k pages?  I figured we might skip copying
>> file-backed ptes on fork, but I couldn't find the code.
> 
> Currently, we only filter out on per-VMA basis. See first comment in
> copy_page_range().
> 
> Here we handle PMD mapped file pages in COW mapping. File THP can be
> mapped into COW mapping as result of read page fault.

OK...  So, copy_page_range() has a check for "Don't copy ptes where a
page fault will fill them correctly."  Seems sane enough, but the check
is implemented using a check for the VMA having !vma->anon_vma, which is
a head-scratcher for a moment.  Why does that apply to huge tmpfs?

Ahh, MAP_PRIVATE.  MAP_PRIVATE vmas have ->anon_vma because they have
essentially-anonymous pages for when they do a COW, so they don't hit
that check and they go through the copy_*() functions, including
copy_huge_pmd().

We don't handle 2M COW operations yet so we simply decline to copy these
pages.  Might cost us page faults down the road, but it makes things
easier to implement for now.

Did I get that right?

Any chance we could get a bit of that into the patch descriptions so
that the next hapless reviewer can spend their time looking at your code
instead of relearning the fork() handling for MAP_PRIVATE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
