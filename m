Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 277916B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:43:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so49014796pfj.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 10:43:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x67si5357780pfk.12.2016.09.20.10.43.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 10:43:14 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
 <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E17531.6050008@linux.intel.com>
Date: Tue, 20 Sep 2016 10:43:13 -0700
MIME-Version: 1.0
In-Reply-To: <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/20/2016 08:52 AM, Rui Teng wrote:
> On 9/20/16 10:53 PM, Dave Hansen wrote:
...
>> That's good, but aren't we still left with a situation where we've
>> offlined and dissolved the _middle_ of a gigantic huge page while the
>> head page is still in place and online?
>>
>> That seems bad.
>>
> What about refusing to change the status for such memory block, if it
> contains a huge page which larger than itself? (function
> memory_block_action())

How will this be visible to users, though?  That sounds like you simply
won't be able to offline memory with gigantic huge pages.

> I think it will not affect the hot-plug function too much. We can
> change the nr_hugepages to zero first, if we really want to hot-plug a
> memory.

Is that really feasible?  Suggest that folks stop using hugetlbfs before
offlining any memory?  Isn't the entire point of hotplug to keep the
system running while you change the memory present?  Doing this would
require that you stop your applications that are using huge pages.

With gigantic pages, you may also never get them back if you do this.

> And I also found that the __test_page_isolated_in_pageblock() function
> can not handle a gigantic page well. It will cause a device busy error
> later. I am still investigating on that.
> 
> Any suggestion?

It sounds like the _first_ offline operation needs to dissolve an
_entire_ page if that page has any portion in the section being
offlined.  I'm not quite sure where the page should live after that, but
I'm not sure of any other way to do this sanely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
