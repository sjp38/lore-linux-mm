Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8C86B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:32:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k5so157339313qkd.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:32:05 -0700 (PDT)
Received: from 6.mo6.mail-out.ovh.net (6.mo6.mail-out.ovh.net. [87.98.177.69])
        by mx.google.com with ESMTPS id b73si934734wmb.1.2016.05.12.08.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 08:32:04 -0700 (PDT)
Received: from player795.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo6.mail-out.ovh.net (Postfix) with ESMTP id CBF5B1005062
	for <linux-mm@kvack.org>; Thu, 12 May 2016 17:32:02 +0200 (CEST)
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
 <60fc4f9f-fc8e-84a4-da84-a3c823b9b5bb@morey-chaisemartin.com>
 <20160511145141.GA5288@gmail.com>
 <432180fd-2faf-af37-7d99-4e24ab263d50@morey-chaisemartin.com>
 <20160512093632.GA15092@gmail.com>
 <e009b1e5-2fb2-0cc6-b065-932d7fa1c658@morey-chaisemartin.com>
 <20160512135253.GA17039@gmail.com>
From: Nicolas Morey-Chaisemartin <devel@morey-chaisemartin.com>
Message-ID: <db706ffa-2b61-de50-0118-9b0b6834ef68@morey-chaisemartin.com>
Date: Thu, 12 May 2016 17:31:52 +0200
MIME-Version: 1.0
In-Reply-To: <20160512135253.GA17039@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



Le 05/12/2016 a 03:52 PM, Jerome Glisse a ecrit :
> On Thu, May 12, 2016 at 03:30:24PM +0200, Nicolas Morey-Chaisemartin wrote:
>> Le 05/12/2016 a 11:36 AM, Jerome Glisse a ecrit :
>>> On Thu, May 12, 2016 at 08:07:59AM +0200, Nicolas Morey-Chaisemartin wrote:
[...]
>>>> With transparent_hugepage=never I can't see the bug anymore.
>>>>
>>> Can you test https://patchwork.kernel.org/patch/9061351/ with 4.5
>>> (does not apply to 3.10) and without transparent_hugepage=never
>>>
>>> Jerome
>> Fails with 4.5 + this patch and with 4.5 + this patch + yours
>>
> There must be some bug in your code, we have upstream user that works
> fine with the above combination (see drivers/vfio/vfio_iommu_type1.c)
> i suspect you might be releasing the page pin too early (put_page()).
In my previous tests, I checked the page before calling put_page and it has already changed.
And I also checked that there is not multiple transfers in a single page at once.
So I doubt it's that.
>
> If you really believe it is bug upstream we would need a dumb kernel
> module that does gup like you do and that shows the issue. Right now
> looking at code (assuming above patches applied) i can't see anything
> that can go wrong with THP.

The issue is that I doubt I'll be able to do that. We have had code running in production for at least a year without the issue showing up and now a single test shows this.
And some tweak to the test (meaning memory footprint in the user space) can make the problem disappear.

Is there a way to track what is happening to the THP? From the looks of it, the refcount are changed behind my back? Would kgdb with watch point work on this?
Is there a less painful way?

Thanks

Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
