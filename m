Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 438C16B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 05:00:42 -0400 (EDT)
Message-ID: <4C5140DD.802@amd.com>
Date: Thu, 29 Jul 2010 10:50:37 +0200
From: Andre Przywara <andre.przywara@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix off-by-one bug in mbind() syscall implementation
References: <1280136498-28219-1-git-send-email-andre.przywara@amd.com> <20100726094931.GA17756@basil.fritz.box> <4C4D620E.9010008@amd.com> <20100726104020.GB17756@basil.fritz.box>
In-Reply-To: <20100726104020.GB17756@basil.fritz.box>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Jul 26, 2010 at 12:23:10PM +0200, Andre Przywara wrote:
>> Andi Kleen wrote:
>>> On Mon, Jul 26, 2010 at 11:28:18AM +0200, Andre Przywara wrote:
>>>> When the mbind() syscall implementation processes the node mask
>>>> provided by the user, the last node is accidentally masked out.
>>>> This is present since the dawn of time (aka Before Git), I guess
>>>> nobody realized that because libnuma as the most prominent user of
>>>> mbind() uses large masks (sizeof(long)) and nobody cared if the
>>>> 64th node is not handled properly. But if the user application
>>>> defers the masking to the kernel and provides the number of valid bits
>>>> in maxnodes, there is always the last node missing.
>>>> However this also affect the special case with maxnodes=0, the manpage
>>>> reads that mbind(ptr, len, MPOL_DEFAULT, &some_long, 0, 0); should
>>>> reset the policy to the default one, but in fact it returns EINVAL.
>>>> This patch just removes the decrease-by-one statement, I hope that
>>>> there is no workaround code in the wild that relies on the bogus
>>>> behavior.
>>> Actually libnuma and likely most existing users rely on it.
>> If grep didn't fool me, then the only users in libnuma aware of that
>> bug are the test implementations in numactl-2.0.3/test, namely
>> /test/tshm.c (NUMA_MAX_NODES+1) and test/mbind_mig_pages.c
>> (old_nodes->size + 1).
> 
> At least libnuma 1 (which is the libnuma most distributions use today)
> explicitely knows about it and will break if you change it.
Please define most distributions. I just did some research:
Old libnuma with the workaround active:
* OpenSuse 11.0 (recently EOL)
* Fedora 9 (EOL for about a year)
* SLES10 (still supported, but unlikey to get a vanilla kernel update)
* CentOS 5.5 (same as SLES10)
First version with a safe libnuma:
* OpenSuse 11.1
* Fedora 10
* SLES11
Didn't check others, but I guess that looks similar. If they get an 
official kernel update, they likely get the corresponding library fixes 
along with it.
Also I found that numactl-1.0.3 already had the bug fix.

So how big is the chance the anyone with these old distros will use a 
2.6.36+ kernel with it? If someone does so, then I'd guess he'd be on 
his own and will probably also update other parts of the system (or 
better upgrade the whole setup).
I see that this is a general question and should not be answered with 
probability arguments, but I would like to hear other statements on this 
policy. After all this is a clear kernel bug and should be fixed. Recent 
library implementation will trigger this bug.
Also I would like to know whether we support any older library with 
newer kernels. I guess there is no such promise (thinking of modutils, 
udev, ...)
Is the stable syscall interface defined by documentation or by (possibly 
buggy) de facto implementation?

> 
>> Has this bug been known before?
> 
> Yes (and you can argue whether it's a problem or not)
OK, I will:
1. It's not documented, neither in the kernel nor in libnuma.
2. The default interface for large bitmaps (consisting of a number of 
longs) is to pass the number of valid bits. A variant would be passing 
the highest valid bit number. The number of bits plus one is not in the 
list.
3. There is a special case in the syscall interface for resetting the 
policy. It says you need to pass either a NULL pointer or 0 for the 
number of bits (along with MPOL_DEFAULT). This simply does not work. 
Instead you have to pass a NULL pointer or _1_. Also that means that 
passing 1 intentionally triggers the special case.
3. libnuma changed the behavior from work-arounding to ignoring some 18 
month or so before. This bug will lead to the 64th node (or the 128th 
node, the 192th node, ...) to be ignored. And please don't argument that 
nobody will ever have 64 nodes...
4. If one use mbind() directly and lets the kernel do the masking by 
passing the number of valid bits (and not the size of the buffer) then 
the last node will always be masked off.

So I strongly opt for fixing this by removing the line and maybe add 
some documentation about the old behavior.

Regards,
Andre.

-- 
Andre Przywara
AMD-Operating System Research Center (OSRC), Dresden, Germany
Tel: +49 351 448-3567-12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
