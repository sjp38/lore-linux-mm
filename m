Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6A88E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 15:26:26 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so12728131qkb.13
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:26:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j35si33895qtc.137.2019.01.18.12.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 12:26:25 -0800 (PST)
Date: Fri, 18 Jan 2019 15:26:18 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
Message-ID: <20190118202618.GB3060@redhat.com>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
 <c6df9b8d-571d-3b4f-c528-dc176f8577e2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c6df9b8d-571d-3b4f-c528-dc176f8577e2@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On Fri, Jan 18, 2019 at 11:58:54AM -0800, Dave Hansen wrote:
> On 1/16/19 11:16 AM, Jerome Glisse wrote:
> >> We *could* also simply truncate the existing top-level
> >> "Persistent Memory" resource and take over the released address
> >> space.  But, this means that if we ever decide to hot-unplug the
> >> "RAM" and give it back, we need to recreate the original setup,
> >> which may mean going back to the BIOS tables.
> >>
> >> This should have no real effect on the existing collision
> >> detection because the areas that truly conflict should be marked
> >> IORESOURCE_BUSY.
> > 
> > Still i am worrying that this might allow device private to register
> > itself as a child of some un-busy resource as this patch obviously
> > change the behavior of register_memory_resource()
> > 
> > What about instead explicitly providing parent resource to add_memory()
> > and then to register_memory_resource() so if it is provided as an
> > argument (!NULL) then you can __request_region(arg_res, ...) otherwise
> > you keep existing code intact ?
> 
> We don't have the locking to do this, do we?  For instance, all the
> locking is done below register_memory_resource(), so any previous
> resource lookup is invalid by the time we get to register_memory_resource().

Yeah you are right, maybe just a bool then ? bool as_child

Cheers,
Jérôme
