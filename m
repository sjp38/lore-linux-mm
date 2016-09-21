Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C15A96B026C
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:27:19 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so15809594lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:27:19 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id h7si1888895wji.18.2016.09.21.09.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 09:27:18 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 133so9534671wmq.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:27:18 -0700 (PDT)
Date: Wed, 21 Sep 2016 18:27:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
Message-ID: <20160921162715.GC24210@dhcp22.suse.cz>
References: <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
 <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
 <57E17531.6050008@linux.intel.com>
 <20160921120507.GG10300@dhcp22.suse.cz>
 <57E2AF8F.6030202@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E2AF8F.6030202@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On Wed 21-09-16 09:04:31, Dave Hansen wrote:
> On 09/21/2016 05:05 AM, Michal Hocko wrote:
> > On Tue 20-09-16 10:43:13, Dave Hansen wrote:
> >> On 09/20/2016 08:52 AM, Rui Teng wrote:
> >>> On 9/20/16 10:53 PM, Dave Hansen wrote:
> >> ...
> >>>> That's good, but aren't we still left with a situation where we've
> >>>> offlined and dissolved the _middle_ of a gigantic huge page while the
> >>>> head page is still in place and online?
> >>>>
> >>>> That seems bad.
> >>>>
> >>> What about refusing to change the status for such memory block, if it
> >>> contains a huge page which larger than itself? (function
> >>> memory_block_action())
> >>
> >> How will this be visible to users, though?  That sounds like you simply
> >> won't be able to offline memory with gigantic huge pages.
> > 
> > I might be missing something but Is this any different from a regular
> > failure when the memory cannot be freed? I mean
> > /sys/devices/system/memory/memory API doesn't give you any hint whether
> > the memory in the particular block is used and
> > unmigrateable.
> 
> It's OK to have free hugetlbfs pages in an area that's being offline'd.
>  If we did that, it would not be OK to have a free gigantic hugetlbfs
> page that's larger than the area being offlined.

That was not my point. I wasn't very clear probably. Offlining can fail
which shouldn't be really surprising. There might be a kernel allocation
in the particular block which cannot be migrated so failures are to be
expected. I just do not see how offlining in the middle of a gigantic
page is any different from having any other unmovable allocation in a
block. That being said, why don't we simply refuse to offline a block
which is in the middle of a gigantic page.
 
> It would be a wee bit goofy to have the requirement that userspace go
> find all the gigantic pages and make them non-gigantic before trying to
> offline something.

yes

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
