Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0CD6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 17:52:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w78so297238722oie.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 14:52:12 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id i204si11883840oib.150.2016.09.06.14.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 14:52:04 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id y2so97115897oie.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 14:52:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160906131756.6b6c6315b7dfba3a9d5f233a@linux-foundation.org>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160906131756.6b6c6315b7dfba3a9d5f233a@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Sep 2016 14:52:03 -0700
Message-ID: <CAPcyv4hjdPWxdY+UTKVstiLZ7r4oOCa+h+Hd+kzS+wJZidzCjA@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

On Tue, Sep 6, 2016 at 1:17 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 06 Sep 2016 09:49:41 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> track_pfn_insert() is marking dax mappings as uncacheable.
>>
>> It is used to keep mappings attributes consistent across a remapped range.
>> However, since dax regions are never registered via track_pfn_remap(), the
>> caching mode lookup for dax pfns always returns _PAGE_CACHE_MODE_UC.  We do not
>> use track_pfn_insert() in the dax-pte path, and we always want to use the
>> pgprot of the vma itself, so drop this call.
>>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
>> Reported-by: Kai Zhang <kai.ka.zhang@oracle.com>
>> Reported-by: Toshi Kani <toshi.kani@hpe.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Changelog fails to explain the user-visible effects of the patch.  The
> stable maintainer(s) will look at this and wonder "ytf was I sent
> this".

True, I'll change it to this:

track_pfn_insert() is marking dax mappings as uncacheable rendering
them impractical for application usage.  DAX-pte mappings are cached
and the goal of establishing DAX-pmd mappings is to attain more
performance, not dramatically less (3 orders of magnitude).

Deleting the call to track_pfn_insert() in vmf_insert_pfn_pmd() lets
the default pgprot (write-back cache enabled) from the vma be used for
the mapping which yields the expected performance improvement over
DAX-pte mappings.

track_pfn_insert() is meant to keep the cache mode for a given range
synchronized across different users of remap_pfn_range() and
vm_insert_pfn_prot().  DAX uses neither of those mapping methods, and
the pmem driver is already marking its memory ranges as write-back
cache enabled.  So, removing the call to track_pfn_insert() leaves the
kernel no worse off than the current situation where a user could map
the range via /dev/mem with an incompatible cache mode compared to the
driver.

> After fixing that,
>
> Acked-by: Andrew Morton <akpm@linux-foundation.org>

Thanks Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
