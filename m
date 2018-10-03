Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB9286B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 19:05:23 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l75-v6so6541372qke.23
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 16:05:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n37-v6sor1656196qta.136.2018.10.03.16.05.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 16:05:22 -0700 (PDT)
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
 <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
 <20181002145922.GZ18290@dhcp22.suse.cz>
 <d338b385-626b-0e79-9944-708178fe245d@linux.vnet.ibm.com>
 <20181002160446.GA18290@dhcp22.suse.cz>
 <e7dd66c1-d196-3a14-0115-acdaf538ebfd@linux.vnet.ibm.com>
 <bbc5f219-614f-b024-0888-8ad216c5eaf8@linux.vnet.ibm.com>
 <17781f9e-abfb-8c1e-eb18-39571d1b5cd6@linux.vnet.ibm.com>
From: Tyrel Datwyler <turtle.in.the.kernel@gmail.com>
Message-ID: <e7c0f7cc-02a4-47ff-9d7c-0b63f106932e@gmail.com>
Date: Wed, 3 Oct 2018 16:05:18 -0700
MIME-Version: 1.0
In-Reply-To: <17781f9e-abfb-8c1e-eb18-39571d1b5cd6@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>, Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On 10/03/2018 06:27 AM, Michael Bringmann wrote:
> On 10/02/2018 02:45 PM, Tyrel Datwyler wrote:
>> On 10/02/2018 11:13 AM, Michael Bringmann wrote:
>>>
>>>
>>> On 10/02/2018 11:04 AM, Michal Hocko wrote:
>>>> On Tue 02-10-18 10:14:49, Michael Bringmann wrote:
>>>>> On 10/02/2018 09:59 AM, Michal Hocko wrote:
>>>>>> On Tue 02-10-18 09:51:40, Michael Bringmann wrote:
>>>>>> [...]
>>>>>>> When the device-tree affinity attributes have changed for memory,
>>>>>>> the 'nid' affinity calculated points to a different node for the
>>>>>>> memory block than the one used to install it, previously on the
>>>>>>> source system.  The newly calculated 'nid' affinity may not yet
>>>>>>> be initialized on the target system.  The current memory tracking
>>>>>>> mechanisms do not record the node to which a memory block was
>>>>>>> associated when it was added.  Nathan is looking at adding this
>>>>>>> feature to the new implementation of LMBs, but it is not there
>>>>>>> yet, and won't be present in earlier kernels without backporting a
>>>>>>> significant number of changes.
>>>>>>
>>>>>> Then the patch you have proposed here just papers over a real issue, no?
>>>>>> IIUC then you simply do not remove the memory if you lose the race.
>>>>>
>>>>> The problem occurs when removing memory after an affinity change
>>>>> references a node that was previously unreferenced.  Other code
>>>>> in 'kernel/mm/memory_hotplug.c' deals with initializing an empty
>>>>> node when adding memory to a system.  The 'removing memory' case is
>>>>> specific to systems that perform LPM and allow device-tree changes.
>>>>> The powerpc kernel does not have the option of accepting some PRRN
>>>>> requests and accepting others.  It must perform them all.
>>>>
>>>> I am sorry, but you are still too cryptic for me. Either there is a
>>>> correctness issue and the the patch doesn't really fix anything or the
>>>> final race doesn't make any difference and then the ppc code should be
>>>> explicit about that. Checking the node inside the hotplug core code just
>>>> looks as a wrong layer to mitigate an arch specific problem. I am not
>>>> saying the patch is a no-go but if anything we want a big fat comment
>>>> explaining how this is possible because right now it just points to an
>>>> incorrect API usage.
>>>>
>>>> That being said, this sounds pretty much ppc specific problem and I
>>>> would _prefer_ it to be handled there (along with a big fat comment of
>>>> course).
>>>
>>> Let me try again.  Regardless of the path to which we get to this condition,
>>> we currently crash the kernel.  This patch changes that to a WARN_ON notice
>>> and continues executing the kernel without shutting down the system.  I saw
>>> the problem during powerpc testing, because that is the focus of my work.
>>> There are other paths to this function besides powerpc.  I feel that the
>>> kernel should keep running instead of halting.
>>
>> This is still basically a hack to get around a known race. In itself this patch is still worth while in that we shouldn't crash the kernel on a null pointer dereference. However, I think the actual problem still needs to be addressed. We shouldn't run any PRRN events for the source system on the target after a migration. The device tree update should have taken care of telling us about new affinities and what not. Can we just throw out any queued PRRN events when we wake up on the target?
> 
> We are not talking about queued events provided on the source system, but about
> new PRRN events sent by phyp to the kernel on the target system to update the
> kernel state after migration.  No way to predict the content.

Okay, but either way shouldn't your other proposed patches to update memory affinity by re-adding memory and changing the time topology updates are stopped to include the post-mobility updates put things in the right nodes? Or, am I missing something? I would assume a PRRN on the target would assume the target was up-to-date with respect to where things are supposed to be located.

-Tyrel

> 
>>
>> -Tyrel
>>>
>>> Regards,
>>>
> 
> Michael
> 
