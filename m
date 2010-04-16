Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 098F86B01F0
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 09:42:04 -0400 (EDT)
Message-ID: <4BC86920.3080101@humyo.com>
Date: Fri, 16 Apr 2010 14:41:52 +0100
From: John Berthels <john@humyo.com>
MIME-Version: 1.0
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks, heavy
 write load, 8k stack, x86-64
References: <4BBC6719.7080304@humyo.com> <20100407140523.GJ11036@dastard> <4BBCAB57.3000106@humyo.com> <20100407234341.GK11036@dastard> <20100408030347.GM11036@dastard> <4BBDC92D.8060503@humyo.com> <4BBDEC9A.9070903@humyo.com> <20100408233837.GP11036@dastard> <20100409113850.GE13327@think>
In-Reply-To: <20100409113850.GE13327@think>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, John Berthels <john@humyo.com>, linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> shrink_zone on my box isn't 500 bytes, but lets try the easy stuff
> first.  This is against .34, if you have any trouble applying to .32,
> just add the word noinline after the word static on the function
> definitions.
> 
> This makes shrink_zone disappear from my check_stack.pl output.
> Basically I think the compiler is inlining the shrink_active_zone and
> shrink_inactive_zone code into shrink_zone.

Hi Chris,

I hadn't seen the followup discussion on lkml until today, but this message:

http://marc.info/?l=linux-mm&m=127122143303771&w=2

allowed me to look at stack usage in our build environment. If I've 
understood correctly, it seems that a build with gcc-4.4 and gcc-4.3 
have very different stack usages for shrink_zone(): 0x88 versus 0x1d8. 
(details below).

The reason appears to be the -fconserve-stack compilation option 
specified when using 4.4, since running the cmdline from mm/.vmscan.cmd 
with gcc-4.4 but *without* -fconserve-stack gives the same result as 
with 4.3.

According to the discussion when the flag was added, 
http://www.gossamer-threads.com/lists/linux/kernel/1131612
this flag seems to primarily affects inlining, so I double-checked the 
noinline patch you sent to the list and discovered that it had been 
incorrectly applied to the build tree. Correctly applying that patch to 
mm/vmscan.c (and using gcc-4.3) gives a

sub    $0x78,%rsp

line. I'm very sorry that this test or ours wasn't correct and I'm sorry 
for sending bad info to the list.

We're currently building a kernel with gcc-4.4 and will let you know if 
it blows the 8k limit or not.

Thanks for your help.

regards,

jb

$ gcc-4.3 --version
gcc-4.3 (Ubuntu 4.3.4-5ubuntu1) 4.3.4
$ gcc-4.4 --version
gcc-4.4 (Ubuntu 4.4.1-4ubuntu9) 4.4.1


$ make CC=gcc-4.4 mm/vmscan.o
$ objdump -d mm/vmscan.o  | less +/shrink_zone
0000000000002830 <shrink_zone>:
     2830:       55                      push   %rbp
     2831:       48 89 e5                mov    %rsp,%rbp
     2834:       41 57                   push   %r15
     2836:       41 56                   push   %r14
     2838:       41 55                   push   %r13
     283a:       41 54                   push   %r12
     283c:       53                      push   %rbx
     283d:       48 81 ec 88 00 00 00    sub    $0x88,%rsp
     2844:       e8 00 00 00 00          callq  2849 <shrink_zone+0x19>
$ make clean
$ make CC=gcc-4.3 mm/vmscan.o
$ objdump -d mm/vmscan.o  | less +/shrink_zone
0000000000001ca0 <shrink_zone>:
     1ca0:       55                      push   %rbp
     1ca1:       48 89 e5                mov    %rsp,%rbp
     1ca4:       41 57                   push   %r15
     1ca6:       41 56                   push   %r14
     1ca8:       41 55                   push   %r13
     1caa:       41 54                   push   %r12
     1cac:       53                      push   %rbx
     1cad:       48 81 ec d8 01 00 00    sub    $0x1d8,%rsp
     1cb4:       e8 00 00 00 00          callq  1cb9 <shrink_zone+0x19>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
