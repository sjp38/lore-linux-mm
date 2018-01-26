Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD6F66B0028
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 07:34:40 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l6so460508qtj.0
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 04:34:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c9si7683545qtk.410.2018.01.26.04.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 04:34:39 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0QCXnqW099571
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 07:34:39 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fr2ydub3q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 07:34:38 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 26 Jan 2018 12:34:36 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
 <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
 <20180124090539.GH1526@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 26 Jan 2018 18:04:27 +0530
MIME-Version: 1.0
In-Reply-To: <20180124090539.GH1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/24/2018 02:35 PM, Michal Hocko wrote:
> On Wed 24-01-18 10:39:41, Anshuman Khandual wrote:
>> On 01/23/2018 09:36 PM, Michal Hocko wrote:
>>> On Tue 23-01-18 21:28:28, Anshuman Khandual wrote:
>>>> On 01/23/2018 06:15 PM, Michal Hocko wrote:
>>>>> On Tue 23-01-18 16:55:18, Anshuman Khandual wrote:
>>>>>> On 01/17/2018 01:37 PM, Michal Hocko wrote:
>>>>>>> On Thu 11-01-18 15:38:37, Anshuman Khandual wrote:
>>>>>>>> On 01/09/2018 09:43 PM, Michal Hocko wrote:
>>>>>>> [...]
>>>>>>>>> Did you manage to catch _who_ is requesting that anonymous mapping? Do
>>>>>>>>> you need a help with the debugging patch?
>>>>>>>> Not yet, will get back on this.
>>>>>>> ping?
>>>>>> Hey Michal,
>>>>>>
>>>>>> Missed this thread, my apologies. This problem is happening only with
>>>>>> certain binaries like 'sed', 'tmux', 'hostname', 'pkg-config' etc. As
>>>>>> you had mentioned before the map request collision is happening on
>>>>>> [10030000, 10040000] and [10030000, 10040000] ranges only which is
>>>>>> just a single PAGE_SIZE. You asked previously that who might have
>>>>>> requested the anon mapping which is already present in there ? Would
>>>>>> not that be the same process itself ? I am bit confused.
>>>>> We are early in the ELF loading. If we are mapping over an existing
>>>>> mapping then we are effectivelly corrupting it. In other words exactly
>>>>> what this patch tries to prevent. I fail to see what would be a relevant
>>>>> anon mapping this early and why it would be colliding with elf
>>>>> segements.
>>>>>
>>>>>> Would it be
>>>>>> helpful to trap all the mmap() requests from any of the binaries
>>>>>> and see where we might have created that anon mapping ?
>>>>> Yeah, that is exactly what I was suggesting. Sorry for not being clear
>>>>> about that.
>>>>>
>>>> Tried to instrument just for the 'sed' binary and dont see any where
>>>> it actually requests the anon VMA which got hit when loading the ELF
>>>> section which is strange. All these requested flags here already has
>>>> MAP_FIXED_NOREPLACE (0x100000). Wondering from where the anon VMA
>>>> actually came from.
>>> Could you try to dump backtrace?
>> This is when it fails inside elf_map() function due to collision with
>> existing anon VMA mapping.
> This is not the interesting one. This is the ELF loader. And we know it
> fails. We are really interested in the one _who_ installs the original
> VMA. Because nothing should be really there.
> 

I tried to instrument mmap_region() for a single instance of 'sed'
binary and traced all it's VMA creation. But there is no trace when
that 'anon' VMA got created which suddenly shows up during subsequent
elf_map() call eventually failing it. Please note that the following
VMA was never created through call into map_region() in the process
which is strange.

=================================================================
[    9.076867] Details for VMA[3] c000001fce42b7c0
[    9.076925] vma c000001fce42b7c0 start 0000000010030000 end 0000000010040000
next c000001fce42b580 prev c000001fce42b880 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops           (null)
pgoff 1003 file           (null) private_data           (null)
flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
=================================================================

VMA creation for 'sed' binary
=============================
[    9.071902] XXX: mm c000001fce40fa00 registered

[    9.071971] Total VMAs 2 on MM c000001fce40fa00
----
[    9.072010] Details for VMA[1] c000001fce42bdc0
[    9.072064] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
next c000001fce42b580 prev           (null) mm c000001fce40fa00
prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
pgoff 0 file c000001fe2969a00 private_data           (null)
flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)
----
[    9.072402] Details for VMA[2] c000001fce42b580
[    9.072469] vma c000001fce42b580 start 00007fffcafe0000 end 00007fffcb010000
next           (null) prev c000001fce42bdc0 mm c000001fce40fa00
prot 8000000000000104 anon_vma c000001fce4456f0 vm_ops           (null)
pgoff 1fffffffd file           (null) private_data           (null)
flags: 0x100173(read|write|mayread|maywrite|mayexec|growsdown|account)

[    9.072839] CPU: 48 PID: 7544 Comm: sed Not tainted 4.14.0-dirty #154
[    9.072928] Call Trace:
[    9.072952] [c000001fbef37840] [c000000000b17a00] dump_stack+0xb0/0xf0 (unreliable)
[    9.073021] [c000001fbef37880] [c0000000002dbc48] mmap_region+0x718/0x720
[    9.073097] [c000001fbef37970] [c0000000002dc034] do_mmap+0x3e4/0x480
[    9.073179] [c000001fbef379f0] [c0000000002a96c8] vm_mmap_pgoff+0xe8/0x120
[    9.073268] [c000001fbef37ac0] [c0000000003cf378] elf_map+0x98/0x270
[    9.073326] [c000001fbef37b60] [c0000000003d1258] load_elf_binary+0x6f8/0x158c
[    9.073416] [c000001fbef37c80] [c00000000035d320] search_binary_handler+0xd0/0x270
[    9.073510] [c000001fbef37d10] [c00000000035f278] do_execveat_common.isra.31+0x658/0x890
[    9.073599] [c000001fbef37df0] [c00000000035f8c0] SyS_execve+0x40/0x50
[    9.073673] [c000001fbef37e30] [c00000000000b220] system_call+0x58/0x6c


[    9.073749] Total VMAs 3 on MM c000001fce40fa00
----
[    9.073795] Details for VMA[1] c000001fce42bdc0
[    9.073847] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
next c000001fce42b880 prev           (null) mm c000001fce40fa00
prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
pgoff 0 file c000001fe2969a00 private_data           (null)
flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)
----
[    9.074170] Details for VMA[2] c000001fce42b880
[    9.074236] vma c000001fce42b880 start 0000000010020000 end 0000000010030000
next c000001fce42b580 prev c000001fce42bdc0 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops c008000011ddca18
pgoff 1 file c000001fe2969a00 private_data           (null)
flags: 0x100873(read|write|mayread|maywrite|mayexec|denywrite|account)
----
[    9.074612] Details for VMA[3] c000001fce42b580
[    9.074661] vma c000001fce42b580 start 00007fffcafe0000 end 00007fffcb010000
next           (null) prev c000001fce42b880 mm c000001fce40fa00
prot 8000000000000104 anon_vma c000001fce4456f0 vm_ops           (null)
pgoff 1fffffffd file           (null) private_data           (null)
flags: 0x100173(read|write|mayread|maywrite|mayexec|growsdown|account)

[    9.075038] CPU: 48 PID: 7544 Comm: sed Not tainted 4.14.0-dirty #154
[    9.075104] Call Trace:
[    9.075124] [c000001fbef37840] [c000000000b17a00] dump_stack+0xb0/0xf0 (unreliable)
[    9.075212] [c000001fbef37880] [c0000000002db824] mmap_region+0x2f4/0x720
[    9.075288] [c000001fbef37970] [c0000000002dc034] do_mmap+0x3e4/0x480
[    9.075358] [c000001fbef379f0] [c0000000002a96c8] vm_mmap_pgoff+0xe8/0x120
[    9.075432] [c000001fbef37ac0] [c0000000003cf378] elf_map+0x98/0x270
[    9.075490] [c000001fbef37b60] [c0000000003d1258] load_elf_binary+0x6f8/0x158c
[    9.075591] [c000001fbef37c80] [c00000000035d320] search_binary_handler+0xd0/0x270
[    9.075675] [c000001fbef37d10] [c00000000035f278] do_execveat_common.isra.31+0x658/0x890
[    9.075765] [c000001fbef37df0] [c00000000035f8c0] SyS_execve+0x40/0x50
[    9.075834] [c000001fbef37e30] [c00000000000b220] system_call+0x58/0x6c

When it fails
===============
[    9.075910] 7544 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already

[    9.076010] Total VMAs 4 on MM c000001fce40fa00
----
[    9.076055] Details for VMA[1] c000001fce42bdc0
[    9.076103] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
next c000001fce42b880 prev           (null) mm c000001fce40fa00
prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
pgoff 0 file c000001fe2969a00 private_data           (null)
flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)
----
[    9.076461] Details for VMA[2] c000001fce42b880
[    9.076509] vma c000001fce42b880 start 0000000010020000 end 0000000010030000
next c000001fce42b7c0 prev c000001fce42bdc0 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops c008000011ddca18
pgoff 1 file c000001fe2969a00 private_data           (null)
flags: 0x100873(read|write|mayread|maywrite|mayexec|denywrite|account)
----
[    9.076867] Details for VMA[3] c000001fce42b7c0
[    9.076925] vma c000001fce42b7c0 start 0000000010030000 end 0000000010040000
next c000001fce42b580 prev c000001fce42b880 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops           (null)
pgoff 1003 file           (null) private_data           (null)
flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
-----
[    9.077285] Details for VMA[4] c000001fce42b580
[    9.077335] vma c000001fce42b580 start 00007fffcafe0000 end 00007fffcb010000
next           (null) prev c000001fce42b7c0 mm c000001fce40fa00
prot 8000000000000104 anon_vma c000001fce4456f0 vm_ops           (null)
pgoff 1fffffffd file           (null) private_data           (null)
flags: 0x100173(read|write|mayread|maywrite|mayexec|growsdown|account)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
