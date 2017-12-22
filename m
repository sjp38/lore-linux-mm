Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 866176B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:31:58 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x1so14321897plb.2
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 14:31:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f129si3309239pgc.402.2017.12.22.14.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 14:31:57 -0800 (PST)
Date: Fri, 22 Dec 2017 15:31:54 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171222223154.GC25711@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Fri, Dec 22, 2017 at 08:39:41AM +0530, Anshuman Khandual wrote:
> On 12/14/2017 07:40 AM, Ross Zwisler wrote:
<>
> > We solve this issue by providing userspace with performance information on
> > individual memory ranges.  This performance information is exposed via
> > sysfs:
> > 
> >   # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
> >   mem_tgt2/firmware_id:1
> >   mem_tgt2/is_cached:0
> >   mem_tgt2/local_init/read_bw_MBps:40960
> >   mem_tgt2/local_init/read_lat_nsec:50
> >   mem_tgt2/local_init/write_bw_MBps:40960
> >   mem_tgt2/local_init/write_lat_nsec:50
<>
> We will enlist properties for all possible "source --> target" on the system?

Nope, just 'local' initiator/target pairs.  I talk about the reasoning for
this in the cover letter for patch 3:

https://lists.01.org/pipermail/linux-nvdimm/2017-December/013574.html

> Right now it shows only bandwidth and latency properties, can it accommodate
> other properties as well in future ?

We also have an 'is_cached' attribute for the memory targets if they are
involved in a caching hierarchy, but right now those are all the things we
expose.  We can potentially expose whatever we want that is present in the
HMAT, but those seemed like a good start.

I noticed that in your presentation you had some other examples of attributes
you cared about:

 * reliability
 * power consumption
 * density

The HMAT doesn't provide this sort of information at present, but we
could/would add them to sysfs if the HMAT ever grew support for them.

> > This allows applications to easily find the memory that they want to use.
> > We expect that the existing NUMA APIs will be enhanced to use this new
> > information so that applications can continue to use them to select their
> > desired memory.
> 
> I had presented a proposal for NUMA redesign in the Plumbers Conference this
> year where various memory devices with different kind of memory attributes
> can be represented in the kernel and be used explicitly from the user space.
> Here is the link to the proposal if you feel interested. The proposal is
> very intrusive and also I dont have a RFC for it yet for discussion here.
> 
> https://linuxplumbersconf.org/2017/ocw//system/presentations/4656/original/Hierarchical_NUMA_Design_Plumbers_2017.pdf
> 
> Problem is, designing the sysfs interface for memory attribute detection
> from user space without first thinking about redesigning the NUMA for
> heterogeneous memory may not be a good idea. Will look into this further.

I took another look at your presentation, and overall I think that if/when a
NUMA redesign like this takes place ACPI systems with HMAT tables will be able
to participate.  But I think we are probably a ways away from that, and like I
said in my previous mail ACPI systems with memory-only NUMA nodes are going to
exist and need to be supported with the current NUMA scheme.  Hence I don't
think that this patch series conflicts with your proposal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
