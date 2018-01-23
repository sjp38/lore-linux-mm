Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52891800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:59:22 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id a17so1205141qta.10
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:59:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h1si927224qkj.417.2018.01.23.07.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 07:59:20 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0NFvKH2120580
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:59:20 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fp7nuhngw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:59:11 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 15:58:37 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
 <20180107090229.GB24862@dhcp22.suse.cz>
 <87mv1phptq.fsf@concordia.ellerman.id.au>
 <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
 <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
 <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 23 Jan 2018 21:28:28 +0530
MIME-Version: 1.0
In-Reply-To: <20180123124545.GL1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/23/2018 06:15 PM, Michal Hocko wrote:
> On Tue 23-01-18 16:55:18, Anshuman Khandual wrote:
>> On 01/17/2018 01:37 PM, Michal Hocko wrote:
>>> On Thu 11-01-18 15:38:37, Anshuman Khandual wrote:
>>>> On 01/09/2018 09:43 PM, Michal Hocko wrote:
>>> [...]
>>>>> Did you manage to catch _who_ is requesting that anonymous mapping? Do
>>>>> you need a help with the debugging patch?
>>>>
>>>> Not yet, will get back on this.
>>>
>>> ping?
>>
>> Hey Michal,
>>
>> Missed this thread, my apologies. This problem is happening only with
>> certain binaries like 'sed', 'tmux', 'hostname', 'pkg-config' etc. As
>> you had mentioned before the map request collision is happening on
>> [10030000, 10040000] and [10030000, 10040000] ranges only which is
>> just a single PAGE_SIZE. You asked previously that who might have
>> requested the anon mapping which is already present in there ? Would
>> not that be the same process itself ? I am bit confused.
> 
> We are early in the ELF loading. If we are mapping over an existing
> mapping then we are effectivelly corrupting it. In other words exactly
> what this patch tries to prevent. I fail to see what would be a relevant
> anon mapping this early and why it would be colliding with elf
> segements.
> 
>> Would it be
>> helpful to trap all the mmap() requests from any of the binaries
>> and see where we might have created that anon mapping ?
> 
> Yeah, that is exactly what I was suggesting. Sorry for not being clear
> about that.
> 

Tried to instrument just for the 'sed' binary and dont see any where
it actually requests the anon VMA which got hit when loading the ELF
section which is strange. All these requested flags here already has
MAP_FIXED_NOREPLACE (0x100000). Wondering from where the anon VMA
actually came from.

cat /sys/kernel/debug/tracing/trace | grep '10030000 10040000'

             sed-7579  [008] ....    10.358521: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-7583  [060] ....    10.358640: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8520  [059] ....    14.955216: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8802  [040] ....    23.063756: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8804  [051] ....    23.064434: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8828  [051] ....    23.334103: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8836  [066] .n..    23.369308: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8859  [013] ....    23.436563: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8868  [020] ....    23.484949: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8916  [066] ....    23.692761: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8936  [065] ....    23.860220: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8941  [066] ....    23.864280: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8946  [006] ....    23.868742: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8952  [056] ....    23.906065: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8969  [044] ....    24.199167: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8975  [005] ....    24.212314: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8980  [046] ....    24.215694: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-8987  [028] ....    24.223261: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9001  [016] ....    24.247962: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9004  [048] ....    24.250521: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9007  [017] ....    24.253165: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9010  [005] ....    24.255651: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9013  [030] ....    24.258122: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9016  [004] ....    24.260814: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9020  [029] ....    24.266019: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9026  [003] .n..    24.269327: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9029  [053] ....    24.272223: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9032  [030] ....    24.274914: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9035  [068] ....    24.277492: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9038  [007] ....    24.280134: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9043  [065] ....    24.286741: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9046  [060] ....    24.289189: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9049  [018] ....    24.291915: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9052  [068] ....    24.294782: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9056  [044] ....    24.299412: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9059  [068] ....    24.302153: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9062  [055] ....    24.304719: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9065  [046] ....    24.307286: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9069  [029] ....    24.311957: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9072  [010] ....    24.315013: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9075  [002] ....    24.317803: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9078  [030] ....    24.320709: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9081  [011] ....    24.323806: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9085  [042] ....    24.329019: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9091  [049] ....    24.337911: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9100  [023] ....    24.392637: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9103  [058] ....    24.395753: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9106  [066] ....    24.398322: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9109  [023] ....    24.401226: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9112  [057] ....    24.404415: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9115  [045] ....    24.406961: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9125  [007] ....    24.460685: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9128  [021] ....    24.463883: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802
             sed-9284  [046] ....   340.883633: do_mmap: comm sed range [10030000 10040000] prot 3 flags 101802


Errors while loading ELF sections.

$dmesg | grep 'sed requested'

[   10.358608] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   10.358646] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   14.955315] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.063862] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.064445] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.334212] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.369408] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.436664] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.485034] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.692866] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.860316] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.864333] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.868912] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   23.906131] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.199315] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.212413] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.215787] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.223368] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.248050] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.250594] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.253236] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.255709] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.258191] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.260887] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.266149] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.269456] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.272336] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.275035] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.277572] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.280204] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.286818] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.289273] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.291999] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.294861] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.299508] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.302229] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.304801] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.307371] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.312062] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.315121] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.317913] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.320821] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.323901] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.329124] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.338009] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.392780] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.395842] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.398442] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.401325] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.404494] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.407072] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.460794] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[   24.463986] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
[  340.883717] sed requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
