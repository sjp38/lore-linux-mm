Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09BED8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:38:57 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v64so6919846qka.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:38:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r29si5599302qtr.290.2019.01.16.15.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 15:38:55 -0800 (PST)
Date: Wed, 16 Jan 2019 18:38:50 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
Message-ID: <20190116233849.GE3617@redhat.com>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
 <2b52778d-f120-eec7-3e7a-3a9c182170f0@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2b52778d-f120-eec7-3e7a-3a9c182170f0@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On Wed, Jan 16, 2019 at 03:01:39PM -0800, Dave Hansen wrote:
> On 1/16/19 11:16 AM, Jerome Glisse wrote:
> >> We also rework the old error message a bit since we do not get
> >> the conflicting entry back: only an indication that we *had* a
> >> conflict.
> > We should keep the device private check (moving it in __request_region)
> > as device private can try to register un-use physical address (un-use
> > at time of device private registration) that latter can block valid
> > physical address the error message you are removing report such event.
> 
> If a resource can't support having a child, shouldn't it just be marked
> IORESOURCE_BUSY, rather than trying to somehow special-case
> IORES_DESC_DEVICE_PRIVATE_MEMORY behavior?

So the thing about IORES_DESC_DEVICE_PRIVATE_MEMORY is that they
are not necessarily link to any real resource ie they can just be
random range of physical address that at the time of registration
had no resource.

Now you can latter hotplug some memory that would conflict with
this IORES_DESC_DEVICE_PRIVATE_MEMORY and if that happens we want
to tell that to the user ie:
    "Sorry we registered some fake memory at fake physical address
     and now you have hotplug something that conflict with that."


Why no existing resource ? Well it depends on the platform. In some
case memory for HMM is just not accessible by the CPU _at_ all so
there is obviously no physical address from CPU point of view for
this kind of memory. The other case is PCIE and BAR size. If we
have PCIE bar resizing working everywhere we could potentialy
use the resized PCIE bar (thought i think some device have bug on
that front so i need to check device side too). So when HMM was
design without the PCIE resize and with totaly un-accessible memory
the only option was to pick some unuse physical address range as
anyway memory we are hotpluging is not CPU accessible.

It has been on my TODO to try to find a better way to reserve a
physical range but this is highly platform specific. I need to
investigate if i can report to ACPI on x86 that i want to make
sure the system never assign some physical address range.

Checking PCIE bar resize is also on my TODO (on device side as
i think some device are just buggy there and won't accept BAR
bigger than 256MB and freakout if you try).

So right now i would rather that we keep properly reporting this
hazard so that at least we know it failed because of that. This
also include making sure that we can not register private memory
as a child of an un-busy resource that does exist but might not
have yet been claim by its rightful owner.

Existing code make sure of that, with your change this is a case
that i would not be able to stop. Well i would have to hot unplug
and try a different physical address i guess.

Cheers,
Jérôme
