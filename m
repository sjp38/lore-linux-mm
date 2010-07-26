Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5726C600227
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:24:41 -0400 (EDT)
Message-ID: <4C4D620E.9010008@amd.com>
Date: Mon, 26 Jul 2010 12:23:10 +0200
From: Andre Przywara <andre.przywara@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix off-by-one bug in mbind() syscall implementation
References: <1280136498-28219-1-git-send-email-andre.przywara@amd.com> <20100726094931.GA17756@basil.fritz.box>
In-Reply-To: <20100726094931.GA17756@basil.fritz.box>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Jul 26, 2010 at 11:28:18AM +0200, Andre Przywara wrote:
>> When the mbind() syscall implementation processes the node mask
>> provided by the user, the last node is accidentally masked out.
>> This is present since the dawn of time (aka Before Git), I guess
>> nobody realized that because libnuma as the most prominent user of
>> mbind() uses large masks (sizeof(long)) and nobody cared if the
>> 64th node is not handled properly. But if the user application
>> defers the masking to the kernel and provides the number of valid bits
>> in maxnodes, there is always the last node missing.
>> However this also affect the special case with maxnodes=0, the manpage
>> reads that mbind(ptr, len, MPOL_DEFAULT, &some_long, 0, 0); should
>> reset the policy to the default one, but in fact it returns EINVAL.
>> This patch just removes the decrease-by-one statement, I hope that
>> there is no workaround code in the wild that relies on the bogus
>> behavior.
> 
> Actually libnuma and likely most existing users rely on it.
If grep didn't fool me, then the only users in libnuma aware of that bug 
are the test implementations in numactl-2.0.3/test, namely /test/tshm.c 
(NUMA_MAX_NODES+1) and test/mbind_mig_pages.c (old_nodes->size + 1).

Has this bug been known before?
> 
> The only way to change it would be to add new system calls.
That would probably be overkill, but if this behavior is now fixed, it 
should be documented (in the manpage and in the kernel code).
Also the actual libnuma code should be adjusted, then.

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
