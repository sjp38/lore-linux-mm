Subject: Oops in 2.3.99-pre6
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 17 Apr 2000 01:07:39 +0200
Message-ID: <yttd7npprus.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        If you need some more information, let me know. I


[1.] One line summary of the problem:    
     I get one Oops and a bug
[2.] Full description of the problem/report:
     I have applied the patch from Al Viro to fix the umount bug in
     shut_down.

[3.] Keywords (i.e., modules, networking, kernel):
     Memory and Page cache
[4.] Kernel version (from /proc/version):
    Linux version 2.3.99-pre6 (quintela@vexeta) (gcc version 2.95.2 20000313 (Debian GNU/Linux)) #55 Sat Apr 15 22:39:15 CEST 2000
[5.] Output of Oops.. message (if applicable) with symbolic information 
     resolved (see Documentation/oops-tracing.txt)
First Oops:

ksymoops 2.3.4 on i686 2.3.99-pre6.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6/ (default)
     -m /boot/System.map-2.3.99-pre6 (specified)

Unable to handle kernel NULL pointer dereference at virtual address 00000028
c012f8e0
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c012f8e0>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010213
eax: 0000fd40   ebx: 00000000   ecx: cfb25440   edx: 00000000
esi: 0000fd40   edi: c10ffd38   ebp: 0000fd40   esp: c9c6df00
ds: 0018   es: 0018   ss: 0018
Process dpkg (pid: 22720, stackpage=c9c6d000)
Stack: c10ffd00 c021aec0 00000000 00000000 c0121d83 c10ffd00 00000000 c17fe900 
       c021aec0 00000000 00000000 00000000 c013fca1 c17fe9bc 00000000 00000000 
       ca411200 c17fe900 cec01240 c013e90a c17fe900 c17fe900 c037c3c0 c0147eaf 
Call Trace: [<c0121d83>] [<c013fca1>] [<c013e90a>] [<c0147eaf>] [<c01390a9>] [<c0139189>] [<c013920f>] 
       [<c010af4c>] 
Code: 8b 5a 28 0f b7 42 08 8d 34 28 39 6c 24 18 77 09 52 e8 4a ff 

>>EIP; c012f8e0 <block_flushpage+40/90>   <=====
Trace; c0121d83 <truncate_inode_pages+63/1b0>
Trace; c013fca1 <iput+91/240>
Trace; c013e90a <d_delete+4a/70>
Trace; c0147eaf <ext2_unlink+df/100>
Trace; c01390a9 <vfs_unlink+119/170>
Trace; c0139189 <do_unlink+89/f0>
Trace; c013920f <sys_unlink+1f/60>
Trace; c010af4c <system_call+34/38>
Code;  c012f8e0 <block_flushpage+40/90>
00000000 <_EIP>:
Code;  c012f8e0 <block_flushpage+40/90>   <=====
   0:   8b 5a 28                  mov    0x28(%edx),%ebx   <=====
Code;  c012f8e3 <block_flushpage+43/90>
   3:   0f b7 42 08               movzwl 0x8(%edx),%eax
Code;  c012f8e7 <block_flushpage+47/90>
   7:   8d 34 28                  lea    (%eax,%ebp,1),%esi
Code;  c012f8ea <block_flushpage+4a/90>
   a:   39 6c 24 18               cmp    %ebp,0x18(%esp,1)
Code;  c012f8ee <block_flushpage+4e/90>
   e:   77 09                     ja     19 <_EIP+0x19> c012f8f9 <block_flushpage+59/90>
Code;  c012f8f0 <block_flushpage+50/90>
  10:   52                        push   %edx
Code;  c012f8f1 <block_flushpage+51/90>
  11:   e8 4a ff 00 00            call   ff60 <_EIP+0xff60> c013f840 <clean_inode+90/a0>

Then a second one in a BUG:
kernel BUG at page_alloc.c:104!
this bug is the one in __free_pages_ok:
     
if (page->mapping) 
    BUG(); 

ksymoops 2.3.4 on i686 2.3.99-pre6.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6/ (default)
     -m /boot/System.map-2.3.99-pre6 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0129b39>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000020   ebx: c10ffd10   ecx: ffffffff   edx: 00000000
esi: c10ffd10   edi: 00000000   ebp: 00000000   esp: c14a1f4c
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c14a1000)
Stack: c01db223 c01db4af 00000068 c10ffd2c c10ffd10 00000000 c14a1fac c10ffd38 
       c10ffd38 00000282 00000023 c14a1fac c01220c7 00000007 00000006 00000004 
       c0217fb4 c0217fd0 0000196a 00000000 c14a1f9c c14a1f9c c14a1fa4 c14a1fa4 
Call Trace: [<c01db223>] [<c01db4af>] [<c01220c7>] [<c012968c>] [<c0129765>] [<c0108df8>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 0c 7c 21 c0 69 c0 39 8e e3 

>>EIP; c0129b39 <__free_pages_ok+49/2a0>   <=====
Trace; c01db223 <tvecs+3223/1bc00>
Trace; c01db4af <tvecs+34af/1bc00>
Trace; c01220c7 <shrink_mmap+1f7/2d0>
Trace; c012968c <do_try_to_free_pages+2c/90>
Trace; c0129765 <kswapd+75/f0>
Trace; c0108df8 <kernel_thread+28/40>
Code;  c0129b39 <__free_pages_ok+49/2a0>
00000000 <_EIP>:
Code;  c0129b39 <__free_pages_ok+49/2a0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0129b3b <__free_pages_ok+4b/2a0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0129b3e <__free_pages_ok+4e/2a0>
   5:   89 f6                     mov    %esi,%esi
Code;  c0129b40 <__free_pages_ok+50/2a0>
   7:   89 d8                     mov    %ebx,%eax
Code;  c0129b42 <__free_pages_ok+52/2a0>
   9:   2b 05 0c 7c 21 c0         sub    0xc0217c0c,%eax
Code;  c0129b48 <__free_pages_ok+58/2a0>
   f:   69 c0 39 8e e3 00         imul   $0xe38e39,%eax,%eax



[6.] A small shell script or example program which triggers the
     problem (if possible)
     I was usig dpkg.....

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
Debian woody
Linux vexeta 2.3.99-pre6 #55 Sat Apr 15 22:39:15 CEST 2000 i686 unknown
Kernel modules         2.3.10
Gnu C                  2.95.2
Binutils               2.9.5.0.31
Linux C Library        2.1.3
Dynamic linker         ldd: version 1.9.11
Procps                 .
Mount                  2.10f
Net-tools              2.05
Console-tools          0.2.3
Sh-utils               2.0g
Modules Loaded         es1371 ac97_codec soundcore serial

[7.2.] Processor information (from /proc/cpuinfo):
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 6
model		: 1
model name	: AMD-K7(tm) Processor
stepping	: 2
cpu MHz		: 499.045450
cache size	: 512 KB
fdiv_bug	: no
hlt_bug		: no
sep_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca cmov 16 mmxext mmx 3dnowext 3dnow
bogomips	: 996.15
[7.3.] Module information (from /proc/modules):
es1371                 27588   1 (autoclean)
ac97_codec              6916   0 (autoclean) [es1371]
soundcore               3908   4 (autoclean) [es1371]
serial                 41284   0 (autoclean)

[X.] Other notes, patches, fixes, workarounds:


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
