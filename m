Subject: I've got the BAD_RANGE BUG in rmqueue!!! (Pre9-4)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 23 May 2000 20:38:54 +0200
Message-ID: <yttsnv9p0w1.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        After I change the way that pages are returned to the LRU list
        in shrink_mmap (I change that to return pages un freeables to
        the beginning of the list, instead of the end), I get the
        following Oops:
the line 191 in page_alloc.c is the first test:
			if (BAD_RANGE(zone,page))
				BUG();
in the function rmqueue.

I am not changing nothing else in the shrink_mmap function, only the
order in which pages are ordered, I suppose that this should not cause
that BUG.

Comments are welcome.

Later, Juan.

ksymoops 2.3.4 on i686 2.3.99-pre9.  Options used
     -V (default)
     -K (specified)
     -L (specified)
     -O (specified)
     -m /boot/System.map-2.3.99-pre9 (specified)
     -x
kernel BUG at page_alloc.c:191!     
invalid operand: 0000                                                           
CPU:    0                                                                       
EIP:    0010:[<c012fa1e>]                                                       
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010086                                                                
eax: 00000020   ebx: c10696b0   ecx: 00000000   edx: c0241a8c                   
esi: c0242a7c   edi: 00000000   ebp: 00000000   esp: c7357e2c                   
ds: 0018   es: 0018   ss: 0018                                                  
Process mmap002 (pid: 278, stackpage=c7357000)                                  
Stack: c01f842f c01f86fe 000000bf c0242a60 c0242cd0 0000532c 00000000 c100aeb0  
       00000286 00000000 c0242a60 c012fc25 00000000 c736e5dc 0000532c c12fc0fc  
       c0242cc8 c0127651 00000000 c749bea0 c13fae00 00005320 00000003 c0128de8  
Call Trace: [<c01f842f>] [<c01f86fe>] [<c012fc25>] [<c0127651>] [<c0128de8>] [< 
       [<c01253e8>] [<c0113a8c>] [<ec400000>] [<c01aaf9b>] [<c011f87c>] [<c010c 
Code: 0f 0b 83 c4 0c 8b 53 04 8b 03 89 d9 2b 0d 60 27 24 c0 69 e9               

>>EIP; c012fa1e <rmqueue+54/560>   <=====
Trace; c01f842f <tvecs+13631/121104>
Trace; c01f86fe <tvecs+14350/121104>
Trace; c012fc25 <__alloc_pages+13/404>
Trace; c0127651 <read_cluster_nonblocking+145/348>
Trace; c0128de8 <filemap_nopage+356/924>
Trace; c01253e8 <handle_mm_fault+272/428>
Trace; c0113a8c <do_page_fault+412/1344>
Trace; ec400000 <END_OF_CODE+739535576/????>
Trace; c01aaf9b <net_rx_action+303/604>
Trace; c011f87c <do_softirq+92/140>
Code;  c012fa1e <rmqueue+54/560>
00000000 <_EIP>:
Code;  c012fa1e <rmqueue+54/560>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c012fa20 <rmqueue+56/560>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c012fa23 <rmqueue+59/560>
   5:   8b 53 04                  mov    0x4(%ebx),%edx
Code;  c012fa26 <rmqueue+62/560>
   8:   8b 03                     mov    (%ebx),%eax
Code;  c012fa28 <rmqueue+64/560>
   a:   89 d9                     mov    %ebx,%ecx
Code;  c012fa2a <rmqueue+66/560>
   c:   2b 0d 60 27 24 c0         sub    0xc0242760,%ecx
Code;  c012fa30 <rmqueue+72/560>
  12:   69 e9 00 00 00 00         imul   $0x0,%ecx,%ebp




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
