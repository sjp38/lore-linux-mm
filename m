Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA15630
	for <Linux-MM@kvack.org>; Fri, 23 Apr 1999 00:13:18 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199904221603.JAA15772@google.engr.sgi.com>
Subject: RFC: patch for suspected shm swap problem
Date: Thu, 22 Apr 1999 09:03:14 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,
 
While running some heavy stress on shm code, I took a panic in
shm_swap coming out of do_try_to_free_pages in the context of
non-kswapd processes. From the register display, I suspect the
problem to be fixed by this patch:
 
--- /usr/tmp/p_rdiff_a000PE/shm.c       Tue Apr 20 16:07:02 1999
+++ kern/ipc/shm.c	Tue Apr 20 16:05:54 1999
@@ -716,10 +716,10 @@
                next_id:
                swap_idx = 0;
                if (++swap_id > max_shmid) {
+                       swap_id = 0;
                        if (loop)
                                goto failed;
                        loop = 1;
-                       swap_id = 0;
                }
                goto check_id;
        }

I suspect the problem is that shm_swap bumps up swap_id to more
than max_shmid under some circumstances, leading the next call
to shm_swap to trip. Note that valid values of max_shmid are 0 ..
SHMMNI - 1, but shm_swap can leave swap_id set to SHMMNI.

MMU code maintainers, could you please review the patch and let 
me know whether it is good and if it will be accepted into the 
source. 

Thanks much!

Kanoj

PS - In case you are interested in the detailed analysis, here it is:

atlantis.vancouver.sgi.com login: root
Unable to handle kernel NULL pointer dereference at virtual address 0000000d
current->tss.cr3 = 01fd9000, %cr3 = 01fd9000
*pde = 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<c0138cda>]
EFLAGS: 00010213
eax: 00000080   ebx: 00000020   ecx: 00000000   edx: 00000000
esi: 00000001   edi: 00000015   ebp: bfffd040   esp: c1fdbf10
ds: 0018   es: 0018   ss: 0018
Process multitask (pid: 7102, process nr: 268, stackpage=c1fdb000)
Stack: 00000015 bfffd040 c1fda000 00000000 c064f248 00000001 00000000 c001b11c 
       00000020 00091a00 00000000 00000020 00000006 c01214fb 00000006 00000015 
       00000001 00000015 bfffd244 c012164f 00000015 c1fda000 fffffff4 c0121e3e 
Call Trace: [<c01214fb>] [<c012164f>] [<c0121e3e>] [<c010e4a7>] [<c012bca4>] [<c012cbcd>] [<c0107aec>] 
Code: f6 41 0d 04 74 38 c7 05 dc b7 21 c0 00 00 00 00 ff 05 d8 b7 
Unable to handle kernel NULL pointer dereference at virtual address 0000000d
current->tss.cr3 = 03c04000, %cr3 = 03c04000
*pde = 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<c0138cda>]
EFLAGS: 00010213
eax: 00000080   ebx: 00000020   ecx: 00000000   edx: 00000000
esi: 00000001   edi: 00000013   ebp: 00037000   esp: c39fbdcc
ds: 0018   es: 0018   ss: 0018
Process klogd (pid: 213, process nr: 10, stackpage=c39fb000)
Stack: 00000013 00037000 00000000 c01b64af 00000000 00000001 00000000 00000000 
       00000020 00091b00 00000000 00000020 00000006 c01214fb 00000006 00000013 
       00000001 00000013 00000010 c012164f 00000013 c39fa000 00000000 c0121e3e 
Call Trace: [<c01b64af>] [<c01214fb>] [<c012164f>] [<c0121e3e>] [<c0122732>] [<c01220e6>] [<c0122124>] 
       [<c011abe3>] [<c011af4f>] [<c0174960>] [<c010e4a7>] [<c0107bf1>] [<c01133b0>] [<c0144901>] [<c0124fde>] 
       [<c0107aec>] 
Code: f6 41 0d 04 74 38 c7 05 dc b7 21 c0 00 00 00 00 ff 05 d8 b7 
Unable to handle kernel NULL pointer dereference at virtual address 0000000d
current->tss.cr3 = 00234000, %cr3 = 00234000
*pde = 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<c0138cda>]
EFLAGS: 00010213
eax: 00000080   ebx: 00000020   ecx: 00000000   edx: 00000000
esi: 00000001   edi: 00000013   ebp: 0001af00   esp: c0005d4c
ds: 0018   es: 0018   ss: 0018
Process init (pid: 1, process nr: 2, stackpage=c0005000)
Stack: 00000013 0001af00 00000801 c0260a90 00000000 00000001 00000000 00016013 
       00000020 00098300 00000000 00000020 00000006 c01214fb 00000006 00000013 
       00000001 00000013 c0004000 c012164f 00000013 c0004000 00000000 c0121e3e 
Call Trace: [<c01214fb>] [<c012164f>] [<c0121e3e>] [<c0122732>] [<c012212c>] [<c011abe3>] [<c011af4f>] 
       [<c010e4a7>] [<c0107bf1>] [<c0100018>] [<c01072a3>] [<c01076b9>] [<c0107a16>] [<c012e976>] [<c0107b34>] 
Code: f6 41 0d 04 74 38 c7 05 dc b7 21 c0 00 00 00 00 ff 05 d8 b7 
 
Dump of assembler code for function shm_swap:
0xc0138c88 <shm_swap>:  subl   $0x2c,%esp
0xc0138c8b <shm_swap+3>:        pushl  %ebp
0xc0138c8c <shm_swap+4>:        pushl  %edi
0xc0138c8d <shm_swap+5>:        pushl  %esi
0xc0138c8e <shm_swap+6>:        pushl  %ebx
0xc0138c8f <shm_swap+7>:        movl   $0x0,0x20(%esp,1)
0xc0138c97 <shm_swap+15>:       movl   0xc021b78c,%esi
0xc0138c9d <shm_swap+21>:       movl   0x40(%esp,1),%ecx
0xc0138ca1 <shm_swap+25>:       sarl   %cl,%esi
0xc0138ca3 <shm_swap+27>:       movl   %esi,0x1c(%esp,1)
0xc0138ca7 <shm_swap+31>:       testl  %esi,%esi
0xc0138ca9 <shm_swap+33>:       je     0xc0138d79 <shm_swap+241>
0xc0138caf <shm_swap+39>:       call   0xc01227a0 <get_swap_page>
0xc0138cb4 <shm_swap+44>:       movl   %eax,0x2c(%esp,1)
0xc0138cb8 <shm_swap+48>:       testl  %eax,%eax
0xc0138cba <shm_swap+50>:       je     0xc0138d79 <shm_swap+241>
0xc0138cc0 <shm_swap+56>:       movl   0xc021b7d8,%eax
0xc0138cc5 <shm_swap+61>:       movl   0xc0249790(,%eax,4),%ecx
0xc0138ccc <shm_swap+68>:       movl   %ecx,0x30(%esp,1)
0xc0138cd0 <shm_swap+72>:       cmpl   $0xffffffff,%ecx
0xc0138cd3 <shm_swap+75>:       je     0xc0138ce0 <shm_swap+88>
0xc0138cd5 <shm_swap+77>:       cmpl   $0xfffffffe,%ecx
0xc0138cd8 <shm_swap+80>:       je     0xc0138ce0 <shm_swap+88>
0xc0138cda <shm_swap+82>:       testb  $0x4,0xd(%ecx)
0xc0138cde <shm_swap+86>:       je     0xc0138d18 <shm_swap+144>
0xc0138ce0 <shm_swap+88>:       movl   $0x0,0xc021b7dc
0xc0138cea <shm_swap+98>:       incl   0xc021b7d8
0xc0138cf0 <shm_swap+104>:      movl   0xc021b794,%eax
0xc0138cf5 <shm_swap+109>:      cmpl   %eax,0xc021b7d8
0xc0138cfb <shm_swap+115>:      jbe    0xc0138cc0 <shm_swap+56>
0xc0138cfd <shm_swap+117>:      cmpl   $0x0,0x20(%esp,1)
 
System.map has:
c0249790 b shm_segs
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
