Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 09BAE6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:32:01 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so105005989pab.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:32:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qp8si51788519pac.229.2016.02.16.07.32.00
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 07:32:00 -0800 (PST)
Subject: Re: [PATCHv2 13/28] thp: support file pages in zap_huge_pmd()
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-14-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE2581.6070901@intel.com> <20160216100023.GC46557@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56C340EE.1060506@intel.com>
Date: Tue, 16 Feb 2016 07:31:58 -0800
MIME-Version: 1.0
In-Reply-To: <20160216100023.GC46557@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/16/2016 02:00 AM, Kirill A. Shutemov wrote:
> On Fri, Feb 12, 2016 at 10:33:37AM -0800, Dave Hansen wrote:
>> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
>>> For file pages we don't deposit page table on mapping: no need to
>>> withdraw it.
>>
>> I thought the deposit thing was to guarantee we could always do a PMD
>> split.  It still seems like if you wanted to split a huge-tmpfs page,
>> you'd need to first split the PMD which might need the deposited one.
>>
>> Why not?
> 
> For file thp, split_huge_pmd() is implemented by clearing out the pmd: we
> can setup and fill pte table later. Therefore no need to deposit page
> table -- we would not use it. DAX does the same.

Ahh...  Do we just never split in any fault contexts, or do we just
retry the fault?

In any case, that seems like fine enough (although subtle) behavior.
Can you call it out a bit more explicitly in the patch text?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
