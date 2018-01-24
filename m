Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21EB4800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:09:53 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id b26so4443043qtb.18
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:09:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b201si10813179qka.64.2018.01.23.21.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 21:09:52 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0O59ZgH044526
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:09:51 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fpbk2fkem-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:09:51 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 24 Jan 2018 05:09:48 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <87mv1phptq.fsf@concordia.ellerman.id.au>
 <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
 <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
 <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 24 Jan 2018 10:39:41 +0530
MIME-Version: 1.0
In-Reply-To: <20180123160653.GU1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/23/2018 09:36 PM, Michal Hocko wrote:
> On Tue 23-01-18 21:28:28, Anshuman Khandual wrote:
>> On 01/23/2018 06:15 PM, Michal Hocko wrote:
>>> On Tue 23-01-18 16:55:18, Anshuman Khandual wrote:
>>>> On 01/17/2018 01:37 PM, Michal Hocko wrote:
>>>>> On Thu 11-01-18 15:38:37, Anshuman Khandual wrote:
>>>>>> On 01/09/2018 09:43 PM, Michal Hocko wrote:
>>>>> [...]
>>>>>>> Did you manage to catch _who_ is requesting that anonymous mapping? Do
>>>>>>> you need a help with the debugging patch?
>>>>>>
>>>>>> Not yet, will get back on this.
>>>>>
>>>>> ping?
>>>>
>>>> Hey Michal,
>>>>
>>>> Missed this thread, my apologies. This problem is happening only with
>>>> certain binaries like 'sed', 'tmux', 'hostname', 'pkg-config' etc. As
>>>> you had mentioned before the map request collision is happening on
>>>> [10030000, 10040000] and [10030000, 10040000] ranges only which is
>>>> just a single PAGE_SIZE. You asked previously that who might have
>>>> requested the anon mapping which is already present in there ? Would
>>>> not that be the same process itself ? I am bit confused.
>>>
>>> We are early in the ELF loading. If we are mapping over an existing
>>> mapping then we are effectivelly corrupting it. In other words exactly
>>> what this patch tries to prevent. I fail to see what would be a relevant
>>> anon mapping this early and why it would be colliding with elf
>>> segements.
>>>
>>>> Would it be
>>>> helpful to trap all the mmap() requests from any of the binaries
>>>> and see where we might have created that anon mapping ?
>>>
>>> Yeah, that is exactly what I was suggesting. Sorry for not being clear
>>> about that.
>>>
>>
>> Tried to instrument just for the 'sed' binary and dont see any where
>> it actually requests the anon VMA which got hit when loading the ELF
>> section which is strange. All these requested flags here already has
>> MAP_FIXED_NOREPLACE (0x100000). Wondering from where the anon VMA
>> actually came from.
> 
> Could you try to dump backtrace?

This is when it fails inside elf_map() function due to collision with
existing anon VMA mapping.

[c000201c9ad07880] [c000000000b0b4c0] dump_stack+0xb0/0xf0 (unreliable)
[c000201c9ad078c0] [c0000000003c4550] elf_map+0x2d0/0x310
[c000201c9ad07b60] [c0000000003c6258] load_elf_binary+0x6f8/0x158c
[c000201c9ad07c80] [c000000000352900] search_binary_handler+0xd0/0x270
[c000201c9ad07d10] [c000000000354838] do_execveat_common.isra.31+0x658/0x890
[c000201c9ad07df0] [c000000000354e80] SyS_execve+0x40/0x50
[c000201c9ad07e30] [c00000000000b220] system_call+0x58/0x6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
