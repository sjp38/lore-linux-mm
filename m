Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 881306B0007
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 15:46:02 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v188-v6so2101538oie.3
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 12:46:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v67si1510137ota.118.2018.10.02.12.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 12:46:00 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92JhfqU144979
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 15:45:59 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mvdhfbu9f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 15:45:59 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <tyreld@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 13:45:59 -0600
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
 <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
 <20181002145922.GZ18290@dhcp22.suse.cz>
 <d338b385-626b-0e79-9944-708178fe245d@linux.vnet.ibm.com>
 <20181002160446.GA18290@dhcp22.suse.cz>
 <e7dd66c1-d196-3a14-0115-acdaf538ebfd@linux.vnet.ibm.com>
From: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>
Date: Tue, 2 Oct 2018 12:45:50 -0700
MIME-Version: 1.0
In-Reply-To: <e7dd66c1-d196-3a14-0115-acdaf538ebfd@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <bbc5f219-614f-b024-0888-8ad216c5eaf8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, linux-kernel@vger.kernel.org, Nicholas Piggin <npiggin@gmail.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On 10/02/2018 11:13 AM, Michael Bringmann wrote:
> 
> 
> On 10/02/2018 11:04 AM, Michal Hocko wrote:
>> On Tue 02-10-18 10:14:49, Michael Bringmann wrote:
>>> On 10/02/2018 09:59 AM, Michal Hocko wrote:
>>>> On Tue 02-10-18 09:51:40, Michael Bringmann wrote:
>>>> [...]
>>>>> When the device-tree affinity attributes have changed for memory,
>>>>> the 'nid' affinity calculated points to a different node for the
>>>>> memory block than the one used to install it, previously on the
>>>>> source system.  The newly calculated 'nid' affinity may not yet
>>>>> be initialized on the target system.  The current memory tracking
>>>>> mechanisms do not record the node to which a memory block was
>>>>> associated when it was added.  Nathan is looking at adding this
>>>>> feature to the new implementation of LMBs, but it is not there
>>>>> yet, and won't be present in earlier kernels without backporting a
>>>>> significant number of changes.
>>>>
>>>> Then the patch you have proposed here just papers over a real issue, no?
>>>> IIUC then you simply do not remove the memory if you lose the race.
>>>
>>> The problem occurs when removing memory after an affinity change
>>> references a node that was previously unreferenced.  Other code
>>> in 'kernel/mm/memory_hotplug.c' deals with initializing an empty
>>> node when adding memory to a system.  The 'removing memory' case is
>>> specific to systems that perform LPM and allow device-tree changes.
>>> The powerpc kernel does not have the option of accepting some PRRN
>>> requests and accepting others.  It must perform them all.
>>
>> I am sorry, but you are still too cryptic for me. Either there is a
>> correctness issue and the the patch doesn't really fix anything or the
>> final race doesn't make any difference and then the ppc code should be
>> explicit about that. Checking the node inside the hotplug core code just
>> looks as a wrong layer to mitigate an arch specific problem. I am not
>> saying the patch is a no-go but if anything we want a big fat comment
>> explaining how this is possible because right now it just points to an
>> incorrect API usage.
>>
>> That being said, this sounds pretty much ppc specific problem and I
>> would _prefer_ it to be handled there (along with a big fat comment of
>> course).
> 
> Let me try again.  Regardless of the path to which we get to this condition,
> we currently crash the kernel.  This patch changes that to a WARN_ON notice
> and continues executing the kernel without shutting down the system.  I saw
> the problem during powerpc testing, because that is the focus of my work.
> There are other paths to this function besides powerpc.  I feel that the
> kernel should keep running instead of halting.

This is still basically a hack to get around a known race. In itself this patch is still worth while in that we shouldn't crash the kernel on a null pointer dereference. However, I think the actual problem still needs to be addressed. We shouldn't run any PRRN events for the source system on the target after a migration. The device tree update should have taken care of telling us about new affinities and what not. Can we just throw out any queued PRRN events when we wake up on the target?

-Tyrel
> 
> Regards,
> 
