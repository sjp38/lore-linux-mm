Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC9628024E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:04:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so111060564pfy.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:04:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z4si41261109pau.35.2016.09.21.09.04.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 09:04:36 -0700 (PDT)
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
 <57E17531.6050008@linux.intel.com> <20160921120507.GG10300@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E2AF8F.6030202@linux.intel.com>
Date: Wed, 21 Sep 2016 09:04:31 -0700
MIME-Version: 1.0
In-Reply-To: <20160921120507.GG10300@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/21/2016 05:05 AM, Michal Hocko wrote:
> On Tue 20-09-16 10:43:13, Dave Hansen wrote:
>> On 09/20/2016 08:52 AM, Rui Teng wrote:
>>> On 9/20/16 10:53 PM, Dave Hansen wrote:
>> ...
>>>> That's good, but aren't we still left with a situation where we've
>>>> offlined and dissolved the _middle_ of a gigantic huge page while the
>>>> head page is still in place and online?
>>>>
>>>> That seems bad.
>>>>
>>> What about refusing to change the status for such memory block, if it
>>> contains a huge page which larger than itself? (function
>>> memory_block_action())
>>
>> How will this be visible to users, though?  That sounds like you simply
>> won't be able to offline memory with gigantic huge pages.
> 
> I might be missing something but Is this any different from a regular
> failure when the memory cannot be freed? I mean
> /sys/devices/system/memory/memory API doesn't give you any hint whether
> the memory in the particular block is used and
> unmigrateable.

It's OK to have free hugetlbfs pages in an area that's being offline'd.
 If we did that, it would not be OK to have a free gigantic hugetlbfs
page that's larger than the area being offlined.

It would be a wee bit goofy to have the requirement that userspace go
find all the gigantic pages and make them non-gigantic before trying to
offline something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
