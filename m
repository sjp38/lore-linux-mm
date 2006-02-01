Date: Wed, 1 Feb 2006 14:54:59 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
 controller
In-Reply-To: <1138763255.3938.27.camel@localhost.localdomain>
References: <20060119080408.24736.13148.sendpatchset@debian>
	<20060131023000.7915.71955.sendpatchset@debian>
	<1138763255.3938.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20060201055459.B079574033@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jan 2006 19:07:35 -0800
chandra seetharaman <sekharan@us.ibm.com> wrote:

> I tried to use the controller but having some problems.
> 
> - Created class a,
> - set guarantee to 50(with parent having 100, i expected class a to get 
>   50% of memory in the system). 
> - moved my shell to class a. 
> - Issued a make in the kernel tree.
> It consistently fails with 
> -----------
> make: getcwd: : Cannot allocate memory
> Makefile:313: /scripts/Kbuild.include: No such file or directory
> Makefile:532: /arch/i386/Makefile: No such file or directory
> Can't open perl script "/scripts/setlocalversion": No such file or
> directory
> make: *** No rule to make target `/arch/i386/Makefile'.  Stop.
> -----------
> Note that the compilation succeeds if I move my shell to the default
> class.

Hmm... That should be a bug in the pzones because the default class
has the same number of pages as the class a.

Could you show me the output of "cat /proc/zoneinfo" after setting up 
the class a?  The information would help me debugging.

> I got a oops too:
> ------------------------------
> kernel BUG at mm/page_alloc.c:1074!
> invalid operand: 0000 [#1]
> SMP
> Modules linked in:
> CPU:    1
> EIP:    0060:[<c013768d>]    Not tainted VLI
> EFLAGS: 00010256   (2.6.15n)
> EIP is at __free_pages+0x17/0x42
> eax: 00000000   ebx: 00000000   ecx: c17f8b80   edx: c17f8b80
> esi: f7c85578   edi: c1931e20   ebp: c1931a20   esp: d9799f98
> ds: 007b   es: 007b   ss: 0068
> Process make (pid: 12576, threadinfo=d9798000 task=f6324530)
> Stack: c1931e20 c01637d1 ffc5c000 0000001b bfe6c930 bfe6c930 00001000
> d9798000
>        c01026fb bfe6c930 00001000 40143f0c bfe6c930 00001000 bfe6c098
> 000000b7
>        0000007b c010007b 000000b7 ffffe410 00000073 00000286 bfe6c06c
> 0000007b
> Call Trace:
>  [<c01637d1>] sys_getcwd+0x17f/0x18a
>  [<c01026fb>] sysenter_past_esp+0x54/0x79
> Code: 4b 78 0e 8b 56 04 8b 44 9e 08 e8 da f8 ff ff eb ef 5b 5e c3 53 89
> c1 89 d3 89 c2 8b 00 f6 c4 40 74 03 8b 51 0c 8b 42 04 40 75 08 <0f> 0b
> 32 04 45 72 30 c0 f0 83 41 04 ff 0f 98 c0 84 c0 74 15 85
> -------------------------------------
> Note: "if (put_page_testzero(page)) {" is line 1074 in my source tree
> 
> Also, I do not see a mem= line in the stats file for the default class.

My source tree has the same line.  I'll investigate the oops.


Thanks for the report,

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
