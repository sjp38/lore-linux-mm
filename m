Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28BDB6B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 08:56:32 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y205so33909763qkb.4
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:56:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v200si22501116qkb.187.2016.11.24.05.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 05:56:31 -0800 (PST)
Date: Thu, 24 Nov 2016 08:56:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
Message-ID: <20161124135623.GA12887@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
 <5832D33C.6030403@linux.vnet.ibm.com>
 <20161121124218.GF2392@redhat.com>
 <5833CE1B.6030104@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5833CE1B.6030104@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Nov 22, 2016 at 10:18:27AM +0530, Anshuman Khandual wrote:
> On 11/21/2016 06:12 PM, Jerome Glisse wrote:
> > On Mon, Nov 21, 2016 at 04:28:04PM +0530, Anshuman Khandual wrote:
> >> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> >>> To allow use of device un-addressable memory inside a process add a
> >>> special swap type. Also add a new callback to handle page fault on
> >>> such entry.
> >>
> >> IIUC this swap type is required only for the mirror cases and its
> >> not a requirement for migration. If it's required for mirroring
> >> purpose where we intercept each page fault, the commit message
> >> here should clearly elaborate on that more.
> > 
> > It is only require for un-addressable memory. The mirroring has nothing to do
> > with it. I will clarify commit message.
> 
> One thing though. I dont recall how persistent memory ZONE_DEVICE
> pages are handled inside the page tables, point here is it should
> be part of the same code block. We should catch that its a device
> memory page and then figure out addressable or not and act
> accordingly. Because persistent memory are CPU addressable, there
> might not been special code block but dealing with device pages 
> should be handled in a more holistic manner.

Before i repost updated patchset i should stress that dealing with un-addressable
device page and addressable one in same block is not do-able without re-doing once
again the whole mm page fault code path. Because i use special swap entry the 
logical place for me to handle it is with where swap entry are handled.

Regular device page are handle bit simpler that other page because they can't be
evicted/swaped so they are always present once faulted. I think right now they
are always populated through fs page fault callback (well dax one).

So not much reasons to consolidate all device page handling in one place. We are
looking at different use case in the end.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
