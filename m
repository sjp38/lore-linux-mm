Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE8646B039D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 06:11:12 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so15223482wmi.6
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 03:11:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4si16044836wmp.14.2017.02.21.03.11.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 03:11:11 -0800 (PST)
Date: Tue, 21 Feb 2017 12:11:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170221111107.GJ15595@dhcp22.suse.cz>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
[...]
> * User space using mbind() to get CDM memory is an additional benefit
>   we get by making the CDM plug in as a node and be part of the buddy
>   allocator. But the over all idea from the user space point of view
>   is that the application can allocate any generic buffer and try to
>   use the buffer either from the CPU side or from the device without
>   knowing about where the buffer is really mapped physically. That
>   gives a seamless and transparent view to the user space where CPU
>   compute and possible device based compute can work together. This
>   is not possible through a driver allocated buffer.

But how are you going to define any policy around that. Who is allowed
to allocate and how much of this "special memory". Is it possible that
we will eventually need some access control mechanism? If yes then mbind
is really not suitable interface to (ab)use. Also what should happen if
the mbind mentions only CDM memory and that is depleted?

Could you also explain why the transparent view is really better than
using a device specific mmap (aka CDM awareness)?
 
> * The placement of the memory on the buffer can happen on system memory
>   when the CPU faults while accessing it. But a driver can manage the
>   migration between system RAM and CDM memory once the buffer is being
>   used from CPU and the device interchangeably. As you have mentioned
>   driver will have more information about where which part of the buffer
>   should be placed at any point of time and it can make it happen with
>   migration. So both allocation and placement are decided by the driver
>   during runtime. CDM provides the framework for this can kind device
>   assisted compute and driver managed memory placements.
> 
> * If any application is not using CDM memory for along time placed on
>   its buffer and another application is forced to fallback on system
>   RAM when it really wanted is CDM, the driver can detect these kind
>   of situations through memory access patterns on the device HW and
>   take necessary migration decisions.

Is this implemented or at least designed?

Btw. I believe that sending new versions of the patchset with minor
changes is not really helping the review process. I believe the
highlevel concerns about the API are not resolved yet and that is the
number 1 thing to deal with currently.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
