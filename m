Date: Sun, 3 Sep 2000 18:04:30 +0300 (EET DST)
From: Aki M Laukkanen <amlaukka@cc.helsinki.fi>
Subject: Re: [PATCH *] VM patch w/ drop behind for 2.4.0-test8-pre1
In-Reply-To: <Pine.LNX.4.21.0008311801570.7217-100000@duckman.distro.conectiva>
Message-ID: <Pine.OSF.4.20.0009031753510.27587-100000@sirppi.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Aug 2000, Rik van Riel wrote:

Hi Rik, 

> today I released a new version of my VM patch for 2.4.0-test.

I seem to have severe troubles with the VM patch although I'm not
so sure it is the culprit. I'm running a t8-p1 kernel with vm2,
sard (for 2.4.0-t5 but applied without faults) + streamfs on SMP.

I get:
VM: reclaim_page_found -2147483647

and then
kernel BUG at page_alloc.c:91!

Oops is hand written so if it looks wrong it's probably a typo.

eax: 0000001f ebx: c1156ba0 ecx: c6ad0000
esi: 0000012f edi: c68a8420 edx: c0208e6c
Stack: c01dc600 c01dc86e 0000005b c1156ba0 0000012f c68a8420
Call backtrace: [<c01dc600>] [<c01dc86e>] [<c013085c>] [<c0130c4e>]
[<c01252ba>]
[<c01277e0>] [<c011b35a>] [<c011f2eb>] [<c011f4be>] [<c010aba7>]
Code: 0f 0b 83 c4 0c 89 f6 d8 2b 05 80 9c 20 c0 69 c0 f1 f0 f0
 
 >>EIP; c012fee1 <__free_pages_ok+41/34c>   <=====
 Trace; c01dc600 <tvecs+2a40/ca5c>
 Trace; c01dc86e <tvecs+2cae/ca5c>
 Trace; c013085c <__free_pages+14/18>
 Trace; c0130c4e <free_page_and_swap_cache+72/78>
 Trace; c01252ba <zap_page_range+186/210>
 Code;  c012fee1 <__free_pages_ok+41/34c>
 00000000 <_EIP>:
 Code;  c012fee1 <__free_pages_ok+41/34c>   <=====
    0:   0f 0b                     ud2a      <=====
 Code;  c012fee3 <__free_pages_ok+43/34c>
    2:   83 c4 0c                  add    $0xc,%esp
 Code;  c012fee6 <__free_pages_ok+46/34c>
    5:   89 f6                     mov    %esi,%esi
 Code;  c012fee8 <__free_pages_ok+48/34c>
    7:   d8 2b                     fsubrs (%ebx)
 Code;  c012feea <__free_pages_ok+4a/34c>
    9:   05 80 9c 20 c0            add    $0xc0209c80,%eax
 Code;  c012feef <__free_pages_ok+4f/34c>
    e:   69 c0 f1 f0 f0 00         imul   $0xf0f0f1,%eax,%eax 

The workload was hdrbench with 30 input and 10 output files
on the streamfs partition. On background I was running sard
and vmstat. Also I managed to crash it when in X
(doing nothing in particular). I would probably think it 
was streamfs if not for the X incident (module was not
even loaded) and sard patch looks pretty safe. Not to
mention that without the patch it has been running solid.

-- 
D.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
