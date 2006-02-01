Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k113M1o1027476
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 22:22:01 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k113OLsw191586
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 20:24:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k113M0Hu015912
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 20:22:00 -0700
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
	controller
From: chandra seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060119080408.24736.13148.sendpatchset@debian>
	 <20060131023000.7915.71955.sendpatchset@debian>
Content-Type: text/plain
Date: Tue, 31 Jan 2006 19:07:35 -0800
Message-Id: <1138763255.3938.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi KUROSAWA,

I tried to use the controller but having some problems.

- Created class a,
- set guarantee to 50(with parent having 100, i expected class a to get 
  50% of memory in the system). 
- moved my shell to class a. 
- Issued a make in the kernel tree.
It consistently fails with 
-----------
make: getcwd: : Cannot allocate memory
Makefile:313: /scripts/Kbuild.include: No such file or directory
Makefile:532: /arch/i386/Makefile: No such file or directory
Can't open perl script "/scripts/setlocalversion": No such file or
directory
make: *** No rule to make target `/arch/i386/Makefile'.  Stop.
-----------
Note that the compilation succeeds if I move my shell to the default
class.

I got a oops too:
------------------------------
kernel BUG at mm/page_alloc.c:1074!
invalid operand: 0000 [#1]
SMP
Modules linked in:
CPU:    1
EIP:    0060:[<c013768d>]    Not tainted VLI
EFLAGS: 00010256   (2.6.15n)
EIP is at __free_pages+0x17/0x42
eax: 00000000   ebx: 00000000   ecx: c17f8b80   edx: c17f8b80
esi: f7c85578   edi: c1931e20   ebp: c1931a20   esp: d9799f98
ds: 007b   es: 007b   ss: 0068
Process make (pid: 12576, threadinfo=d9798000 task=f6324530)
Stack: c1931e20 c01637d1 ffc5c000 0000001b bfe6c930 bfe6c930 00001000
d9798000
       c01026fb bfe6c930 00001000 40143f0c bfe6c930 00001000 bfe6c098
000000b7
       0000007b c010007b 000000b7 ffffe410 00000073 00000286 bfe6c06c
0000007b
Call Trace:
 [<c01637d1>] sys_getcwd+0x17f/0x18a
 [<c01026fb>] sysenter_past_esp+0x54/0x79
Code: 4b 78 0e 8b 56 04 8b 44 9e 08 e8 da f8 ff ff eb ef 5b 5e c3 53 89
c1 89 d3 89 c2 8b 00 f6 c4 40 74 03 8b 51 0c 8b 42 04 40 75 08 <0f> 0b
32 04 45 72 30 c0 f0 83 41 04 ff 0f 98 c0 84 c0 74 15 85
-------------------------------------
Note: "if (put_page_testzero(page)) {" is line 1074 in my source tree

Also, I do not see a mem= line in the stats file for the default class.

chandra

On Tue, 2006-01-31 at 11:30 +0900, KUROSAWA Takahiro wrote:
> I've split the patches into smaller pieces in order to increase
> readability.  The core part of the patchset is the fifth one with
> the subject "Add the pzone_create() function."
> 
> Changes since the last post:
> * Fixed a bug that pages allocated with __GFP_COLD are incorrectly handled.
> * Moved the PZONE bit in page flags next to the zone number bits in 
>   order to make changes by pzones smaller.
> * Moved the nr_zones locking functions outside of the CONFIG_PSEUDO_ZONE
>   because they are not directly related to pzones.
> 
> Thanks,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
