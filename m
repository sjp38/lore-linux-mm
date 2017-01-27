Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CAE26B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 02:48:43 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z67so342534515pgb.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 23:48:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t63si3687452pfk.141.2017.01.26.23.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 23:48:42 -0800 (PST)
Date: Fri, 27 Jan 2017 08:48:54 +0100
From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] base/memory, hotplug: fix a kernel oops in
 show_valid_zones()
Message-ID: <20170127074854.GA31443@kroah.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
 <20170126214415.4509-3-toshi.kani@hpe.com>
 <20170126135254.cbd0bdbe3cdc5910c288ad32@linux-foundation.org>
 <1485472910.2029.28.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1485472910.2029.28.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "abanman@sgi.com" <abanman@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "rientjes@google.com" <rientjes@google.com>

On Thu, Jan 26, 2017 at 10:26:23PM +0000, Kani, Toshimitsu wrote:
> On Thu, 2017-01-26 at 13:52 -0800, Andrew Morton wrote:
> > On Thu, 26 Jan 2017 14:44:15 -0700 Toshi Kani <toshi.kani@hpe.com>
> > wrote:
> > 
> > > Reading a sysfs memoryN/valid_zones file leads to the following
> > > oops when the first page of a range is not backed by struct page.
> > > show_valid_zones() assumes that 'start_pfn' is always valid for
> > > page_zone().
> > > 
> > >  BUG: unable to handle kernel paging request at ffffea017a000000
> > >  IP: show_valid_zones+0x6f/0x160
> > > 
> > > Since test_pages_in_a_zone() already checks holes, extend this
> > > function to return 'valid_start' and 'valid_end' for a given range.
> > > show_valid_zones() then proceeds with the valid range.
> > 
> > This doesn't apply to current mainline due to changes in
> > zone_can_shift().  Please redo and resend.
> 
> Sorry, I will rebase to the -mm tree and resend the patches.
> 
> > Please also update the changelog to provide sufficient information
> > for others to decide which kernel(s) need the fix.  In particular:
> > under what circumstances will it occur?  On real machines which real
> > people own?
> 
> Yes, this issue happens on real x86 machines with 64GiB or more memory.
>  On such systems, the memory block size is bumped up to 2GiB. [1]
> 
> Here is an example system.  0x3240000000 is only aligned by 1GiB and
> its memory block starts from 0x3200000000, which is not backed by
> struct page.
> 
>  BIOS-e820: [mem 0x0000003240000000-0x000000603fffffff] usable
> 
> I will add the descriptions to the patch.

Should it also be backported to the stable kernels to resolve the issue
there?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
