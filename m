Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A502A6B6EC1
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 13:56:09 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y137-v6so3296574ywy.0
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 10:56:09 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 11-v6si5508743ybq.307.2018.09.04.10.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 10:56:08 -0700 (PDT)
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180829181424.GB3784@redhat.com>
 <20180829183906.GF10223@dhcp22.suse.cz> <20180829211106.GC3784@redhat.com>
 <20180830105616.GD2656@dhcp22.suse.cz> <20180830140825.GA3529@redhat.com>
 <20180830161800.GJ2656@dhcp22.suse.cz> <20180830165751.GD3529@redhat.com>
 <e0c0c966-6706-4ca2-4077-e79322756a9b@oracle.com>
 <20180830183944.GE3529@redhat.com> <20180903055654.GA14951@dhcp22.suse.cz>
 <20180904140035.GA3526@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4b275965-3e6e-2a68-4b39-d09902bbc573@oracle.com>
Date: Tue, 4 Sep 2018 10:55:54 -0700
MIME-Version: 1.0
In-Reply-To: <20180904140035.GA3526@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On 09/04/2018 07:00 AM, Jerome Glisse wrote:
> On Mon, Sep 03, 2018 at 07:56:54AM +0200, Michal Hocko wrote:
>> On Thu 30-08-18 14:39:44, Jerome Glisse wrote:
>>> For all intents and purposes this is not a backport of the original
>>> patch so maybe we should just drop the commit reference and just
>>> explains that it is there to fix mmu notifier in respect to huge page
>>> migration.
>>>
>>> The original patches fix more than this case because newer featurers
>>> like THP migration, THP swapping, ... added more cases where things
>>> would have been wrong. But in 4.4 frame there is only huge tlb fs
>>> migration.
>>
>> And THP migration is still a problem with 4.4 AFAICS. All other cases
>> simply split the huge page but THP migration keeps it in one piece and
>> as such it is theoretically broken as you have explained. So I would
>> stick with what I posted with some more clarifications in the changelog
>> if you think it is appropriate (suggestions welcome).
> 
> Reading code there is no THP migration in 4.4 only huge tlb migration.
> Look at handle_mm_fault which do not know how to handle swap pmd, only
> the huge tlb fs fault handler knows how to handle those. Hence why i
> was checking for huge tlb exactly as page_check_address() to only range
> invalidate for huge tlb fs migration.

I agree with JA(C)rA'me that THP migration was added after 4.4.  But, I could
be missing something.

> But i am fine with doing the range invalidation with all.

Since the shared pmd patch which will ultimately go on top of this needs
the PageHuge checks, my preference would be JA(C)rA'me's patch.

However, IMO I am not certain we really need/want a separate patch.  We
could just add the notifiers to the shared pmd patch.  Back porting the
shared pmd patch will also require some fixup.

Either would work.  I'll admit I do not know what stable maintainers would
prefer.
-- 
Mike Kravetz
