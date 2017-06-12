Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9776B02C3
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 16:54:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e187so51023714pgc.7
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 13:54:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n15si7877964pll.207.2017.06.12.13.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 13:54:37 -0700 (PDT)
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <20170612181354-mutt-send-email-mst@kernel.org>
 <9d0900f3-9df5-ac63-4069-2d796f2a5bc7@intel.com>
 <20170612194438-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d0811862-6633-a43c-90a5-629fe9b6d150@intel.com>
Date: Mon, 12 Jun 2017 13:54:36 -0700
MIME-Version: 1.0
In-Reply-To: <20170612194438-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/12/2017 01:34 PM, Michael S. Tsirkin wrote:
> On Mon, Jun 12, 2017 at 09:42:36AM -0700, Dave Hansen wrote:
>> On 06/12/2017 09:28 AM, Michael S. Tsirkin wrote:
>>>
>>>> The hypervisor is going to throw away the contents of these pages,
>>>> right?
>>> It should be careful and only throw away contents that was there before
>>> report_unused_page_block was invoked.  Hypervisor is responsible for not
>>> corrupting guest memory.  But that's not something an mm patch should
>>> worry about.
>>
>> That makes sense.  I'm struggling to imagine how the hypervisor makes
>> use of this information, though.  Does it make the pages read-only
>> before this, and then it knows if there has not been a write *and* it
>> gets notified via this new mechanism that it can throw the page away?
> 
> Yes, and specifically, this is how it works for migration.  Normally you
> start by migrating all of memory, then send updates incrementally if
> pages have been modified.  This mechanism allows skipping some pages in
> the 1st stage, if they get changed they will be migrated in the 2nd
> stage.

OK, so the migration starts and marks everything read-only.  All the
pages now have read-only valuable data, or read-only worthless data in
the case that the page is in the free lists.  In order for a page to
become non-worthless, it has to have a write done to it, which the
hypervisor obviously knows about.

With this mechanism, the hypervisor knows it can discard pages which
have not had a write since they were known to have worthless contents.

Correct?

That also seems like pretty good information to include in the
changelog.  Otherwise, folks are going to be left wondering what good
the mechanism is.  It's pretty non-trivial to figure out. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
