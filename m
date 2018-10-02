Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFAF6B0274
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:51:54 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id e136-v6so1393932oib.11
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:51:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d83-v6si7434678oia.227.2018.10.02.07.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 07:51:53 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92EnQmi093632
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 10:51:52 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mv9amv64m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 10:51:51 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <mwb@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 10:51:48 -0400
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
From: Michael Bringmann <mwb@linux.vnet.ibm.com>
Date: Tue, 2 Oct 2018 09:51:40 -0500
MIME-Version: 1.0
In-Reply-To: <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

See below.

On 10/01/2018 06:20 PM, Tyrel Datwyler wrote:
> On 10/01/2018 01:27 PM, Michal Hocko wrote:
>> On Mon 01-10-18 13:56:25, Michael Bringmann wrote:
>>> In some LPAR migration scenarios, device-tree modifications are
>>> made to the affinity of the memory in the system.  For instance,
>>> it may occur that memory is installed to nodes 0,3 on a source
>>> system, and to nodes 0,2 on a target system.  Node 2 may not
>>> have been initialized/allocated on the target system.
>>>
>>> After migration, if a RTAS PRRN memory remove is made to a
>>> memory block that was in node 3 on the source system, then
>>> try_offline_node tries to remove it from node 2 on the target.
>>> The NODE_DATA(2) block would not be initialized on the target,
>>> and there is no validation check in the current code to prevent
>>> the use of a NULL pointer.
>>
>> I am not familiar with ppc and the above doesn't really help me
>> much. Sorry about that. But from the above it is not clear to me whether
>> it is the caller which does something unexpected or the hotplug code
>> being not robust enough. From your changelog I would suggest the later
>> but why don't we see the same problem for other archs? Is this a problem
>> of unrolling a partial failure?
>>
>> dlpar_remove_lmb does the following
>>
>> 	nid = memory_add_physaddr_to_nid(lmb->base_addr);
>>
>> 	remove_memory(nid, lmb->base_addr, block_sz);
>>
>> 	/* Update memory regions for memory remove */
>> 	memblock_remove(lmb->base_addr, block_sz);
>>
>> 	dlpar_remove_device_tree_lmb(lmb);
>>
>> Is the whole operation correct when remove_memory simply backs off
>> silently. Why don't we have to care about memblock resp
>> dlpar_remove_device_tree_lmb parts? In other words how come the physical
>> memory range is valid while the node association is not?
>>
> 
> I think the issue here is a race between the LPM code updating affinity and PRRN events being processed. Does your other patch[1] not fix the issue? Or is it that the LPM affinity updates don't do any of the initialization/allocation you mentioned?

This patch addresses the specific case where PRRN changes to CPU or memory are occurring on a system that also observes affinity changes during migration.  Yes,  there is a race condition -- if the PRRN events reliably occurred before the device-tree was updated, this error would not occur.  However, they overlap or occur after the changes during most LPMs observed.

When the device-tree affinity attributes have changed for memory, the 'nid' affinity calculated points to a different node for the memory block than the one used to install it, previously on the source system.  The newly calculated 'nid' affinity may not yet be initialized on the target system.  The current memory tracking mechanisms do not record the node to which a memory block was associated when it was added.  Nathan is looking at adding this feature to the new implementation of LMBs, but it is not there yet, and won't be present in earlier kernels without backporting a significant number of changes.

My other patch[1] is more intended to address locking and CPU update dependencies between PRRN changes and RTAS requests which did not necessarly involve memory updates.  The node to memory association problem after migration would be present even with this issue resolved.

> 
> -Tyrel
> 
> [1] https://lore.kernel.org/linuxppc-dev/20181001185603.11373.61650.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com/T/#u
> 

Michael

-- 
Michael W. Bringmann
Linux Technology Center
IBM Corporation
Tie-Line  363-5196
External: (512) 286-5196
Cell:       (512) 466-0650
mwb@linux.vnet.ibm.com
