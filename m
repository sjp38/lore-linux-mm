Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 783926B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 19:51:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b124so248405wmf.6
        for <linux-mm@kvack.org>; Mon, 01 May 2017 16:51:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m66si531618wmg.22.2017.05.01.16.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 16:51:33 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41NcWLD096718
	for <linux-mm@kvack.org>; Mon, 1 May 2017 19:51:31 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a6cpe4w52-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 19:51:31 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 1 May 2017 17:51:30 -0600
Date: Mon, 1 May 2017 18:51:23 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
 <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
 <ce589129-d86c-ba43-7e04-55acf08f7f29@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ce589129-d86c-ba43-7e04-55acf08f7f29@nvidia.com>
Message-Id: <20170501235123.2k372i75vxlw5n75@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On Mon, May 01, 2017 at 02:56:34PM -0700, John Hubbard wrote:
>On 05/01/2017 02:04 PM, Reza Arbab wrote:
>>On Mon, May 01, 2017 at 01:41:55PM -0700, John Hubbard wrote:
>>>1. A way to move pages between NUMA nodes, both virtual address 
>>>and physical address-based, from kernel mode.
>>
>>Jerome's migrate_vma() and migrate_dma() should have this covered, 
>>including DMA-accelerated copy.
>
>Yes, that's good. I wasn't sure from this discussion here if either or 
>both of those would be used, but now I see.
>
>Are those APIs ready for moving pages between NUMA nodes? As there is 
>no NUMA node id in the API, are we relying on the pages' membership 
>(using each page and updating which node it is on)?

Yes. Those APIs work by callback. The alloc_and_copy() function you 
provide will be called at the appropriate point in the migration. Yours 
would allocate from a specific destination node, and copy using DMA.

>>>5. Something to handle the story of bringing NUMA nodes online and 
>>>putting them back offline, given that they require a device driver 
>>>that may not yet have been loaded. There are a few minor missing bits 
>>>there.
>>
>>This has been prototyped with the driver doing memory 
>>hotplug/hotremove. Could you elaborate a little on what you feel is 
>>missing?
>>
>
>We just worked through how to deal with this in our driver, and I 
>remember feeling worried about the way NUMA nodes can only be put 
>online via a user space action (through sysfs). It seemed like you'd 
>want to do that from kernel as well, when a device driver gets loaded.

That's true. I don't think we have a way to online/offline from a 
driver. To online, the alternatives are memhp_auto_online (incapable of 
doing online_movable), or udev rules (not ideal in this driver 
controlled memory use case). To offline, nothing that I know of.

>I was also uneasy about user space trying to bring a node online before 
>the associated device driver was loaded, and I think it would be nice 
>to be sure that that whole story is looked at.
>
>The theme here is that driver load/unload is, today, independent from 
>the NUMA node online/offline, and that's a problem. Not a huge one, 
>though, just worth enumerating here.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
