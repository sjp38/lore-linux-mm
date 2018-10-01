Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 290996B0006
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 19:23:34 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v4-v6so82549oix.2
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 16:23:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b42-v6si7151262otb.226.2018.10.01.16.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 16:23:33 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w91NIYjq128271
	for <linux-mm@kvack.org>; Mon, 1 Oct 2018 19:23:32 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2muv2m1ysy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 Oct 2018 19:23:32 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <tyreld@linux.vnet.ibm.com>;
	Mon, 1 Oct 2018 17:23:31 -0600
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
From: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>
Date: Mon, 1 Oct 2018 16:23:22 -0700
MIME-Version: 1.0
In-Reply-To: <20181001202724.GL18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <75acdad4-f0f4-f9c6-8a5c-3df44d4882cf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Bringmann <mwb@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, linux-kernel@vger.kernel.org, Nicholas Piggin <npiggin@gmail.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On 10/01/2018 01:27 PM, Michal Hocko wrote:
> On Mon 01-10-18 13:56:25, Michael Bringmann wrote:
>> In some LPAR migration scenarios, device-tree modifications are
>> made to the affinity of the memory in the system.  For instance,
>> it may occur that memory is installed to nodes 0,3 on a source
>> system, and to nodes 0,2 on a target system.  Node 2 may not
>> have been initialized/allocated on the target system.
>>
>> After migration, if a RTAS PRRN memory remove is made to a
>> memory block that was in node 3 on the source system, then
>> try_offline_node tries to remove it from node 2 on the target.
>> The NODE_DATA(2) block would not be initialized on the target,
>> and there is no validation check in the current code to prevent
>> the use of a NULL pointer.
> 
> I am not familiar with ppc and the above doesn't really help me
> much. Sorry about that. But from the above it is not clear to me whether
> it is the caller which does something unexpected or the hotplug code
> being not robust enough. From your changelog I would suggest the later
> but why don't we see the same problem for other archs? Is this a problem
> of unrolling a partial failure?
> 
> dlpar_remove_lmb does the following
> 
> 	nid = memory_add_physaddr_to_nid(lmb->base_addr);
> 
> 	remove_memory(nid, lmb->base_addr, block_sz);
> 
> 	/* Update memory regions for memory remove */
> 	memblock_remove(lmb->base_addr, block_sz);
> 
> 	dlpar_remove_device_tree_lmb(lmb);
> 
> Is the whole operation correct when remove_memory simply backs off
> silently. Why don't we have to care about memblock resp
> dlpar_remove_device_tree_lmb parts? In other words how come the physical
> memory range is valid while the node association is not?
> 

I guess with respect to my previous reply that patch in conjunction with this patch set as well?

https://lore.kernel.org/linuxppc-dev/20181001125846.2676.89826.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com/T/#t

-Tyrel
