From: Andi Kleen <ak@suse.de>
Subject: Re: [discuss] Memory performance problems on Tyan VX50
Date: Wed, 1 Feb 2006 15:39:39 +0100
References: <43DF7654.6060807@t-platforms.ru> <200601311223.11492.raybry@mpdtxmail.amd.com> <43E0B8FE.8040803@t-platforms.ru>
In-Reply-To: <43E0B8FE.8040803@t-platforms.ru>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602011539.40368.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: discuss@x86-64.org
Cc: Andrey Slepuhin <pooh@t-platforms.ru>, Ray Bryant <raybry@mpdtxmail.amd.com>, linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wednesday 01 February 2006 14:34, Andrey Slepuhin wrote:
> Ray Bryant wrote:
> > I don't think this will show anything is wrong, but try running the attached 
> > program on your box; it will diagnose situations where the numa setup is 
> > incorrect.
> 
> Hi Ray,
> 
> I was not able to run wheremem om my system - it prints
> 
> [pooh@trans-rh4 ~]$ ./wheremem -vvv
> ./wheremem: checking 16 processors and 8 nodes; allocating 1024 pages.
> ./wheremem: starts....
> Killed
> 
> The program is killed by OOM killer and then kernel gets oops and kernel 
> panic.
> 
> On another system with 2 CPUs/4 cores it works just fine.
> 
> I attached a console log with oops.


Looks like a bug. There were changes both in the page allocator and in
mempolicy in 2.6.16rc, so it might be related to that.
What does this wheremem program do exactly?
And what does numastat --hardware say on the machine?

Either it's generally broken in page alloc or mempolicy somehow managed to pass in
a NULL zonelist. 

-Andi

Out of Memory: Killed process 4945 (wheremem).
Unable to handle kernel NULL pointer dereference at 0000000000000008 RIP: 
<ffffffff8015476c>{__rmqueue+60}
PGD 6ff91d067 PUD 6ffd7d067 PMD 0 
Oops: 0000 [1] SMP 
CPU 2 
Modules linked in: netconsole i2c_nforce2 tg3 floppy
Pid: 4945, comm: wheremem Not tainted 2.6.16-rc1 #7
RIP: 0010:[<ffffffff8015476c>] <ffffffff8015476c>{__rmqueue+60}
RSP: 0000:ffff810403bbfce0  EFLAGS: 00010017
RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff810000029700
RBP: 0000000000000001 R08: ffff810000029700 R09: ffff810000029848
R10: 0000000000000000 R11: 0000000000000000 R12: ffff810000029700
R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000001
FS:  00002afd5e9fbde0(0000) GS:ffff8101038921c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 00000006ffc42000 CR4: 00000000000006e0
Process wheremem (pid: 4945, threadinfo ffff810403bbe000, task ffff8104ffa2b0e0)
Stack: ffff8101038920c0 ffff8101038920d0 ffffffff80154cd0 0000000000000001 
       0000000200000001 ffff8101038de140 0000000180154099 ffff8101038de140 
       000280d200000000 0000000000000286 
Call Trace: <ffffffff80154cd0>{get_page_from_freelist+272}
       <ffffffff801550a7>{__alloc_pages+311} <ffffffff8015f2d5>{__handle_mm_fault+517}
       <ffffffff801610e7>{vma_adjust+503} <ffffffff80354078>{do_page_fault+936}
       <ffffffff8016c6b6>{do_mbind+678} <ffffffff8010ba75>{error_exit+0}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
