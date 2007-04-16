Received: from 65.44.231.216.in-addr (HELO [10.0.0.20]) (zachcarter@[216.231.44.65])
          (envelope-sender <linux@zachcarter.com>)
          by mail7.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 16 Apr 2007 03:30:28 -0000
Message-ID: <4622EDD3.9080103@zachcarter.com>
Date: Sun, 15 Apr 2007 20:30:27 -0700
From: Zach Carter <linux@zachcarter.com>
MIME-Version: 1.0
Subject: BUG:  Bad page state errors during kernel make
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hiya folks,

If there is anything I can do to help track down and fix this bug, please let me know.

thanks!

-Zach


PROBLEM:  Bad page state errors during kernel make

DESCRIPTION:  Frequently, when trying to build the kernel from source,
my PC will lock up with console messages such as these.  I do not
recall a version of the kernel when this has not been a problem,
however, it did become less frequent when I upgraded from 2.6.20.4 to 2.6.21-rc5.

Steps To Reproduce:

# note, I have never gotten past try #3
for i in 1 2 3 4 5
do
   echo $i > /tmp/num_tries
   cd /src/linux-2.6 && make clean && make -j4
done

Console Messages:
Bad page state in process 'cc1'
page:c1ca88e8 flags:0x52000000 mapping:c1000000 mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
  [<c015625d>] bad_page+0x5e/0x89
  [<c0156ab1>] get_page_from_freelist+0x1de/0x298
  [<c0156bd3>] __alloc_pages+0x68/0x2aa
  [<c016322a>] anon_vma_prepare+0x20/0xb8
  [<c0129647>] tasklet_action+0x4b/0xa4
  [<c015e336>] __handle_mm_fault+0x3b2/0x88f
  [<c0116dce>] smp_apic_timer_interrupt+0x6e/0x7a
  [<c01380d7>] hrtimer_run_queues+0x138/0x152
  [<c0315e4a>] do_page_fault+0x23f/0x53c
  [<c0315c0b>] do_page_fault+0x0/0x53c
  [<c031488c>] error_code+0x7c/0x84
  =======================
list_del corruption. prev->next should be c21a4628, but was e21a4628
------------[ cut here ]------------
kernel BUG at lib/list_debug.c:67!
invalid opcode: 0000 [#1]
SMP
Modules linked in: xt_tcpudp iptable_filter ip_tables x_tables w83627ehf i2c_isa eeprom hidp l2cap 
bluetooth sunrpc ipv6 cpufreq_ondemand dm_mirror dm_multipath dm_mod raid10 raid0 video sbs i2c_ec 
dock button battery asus_acpi ac lp parport_serial snd_hda_intel snd_hda_codec snd_seq_dummy 
snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss parport_pc ohci1394 
snd_pcm usblp parport ieee1394 snd_timer sg ide_cd cdrom snd soundcore snd_page_alloc shpchp 
forcedeth k8temp hwmon serio_raw i2c_nforce2 floppy i2c_core pcspkr sata_sil sata_via sata_nv libata 
sd_mod scsi_mod raid456 xor raid1 ext3 jbd ehci_hcd ohci_hcd uhci_hcd
CPU:    0
EIP:    0060:[<c01e5cd1>]    Tainted: G    B  VLI
EFLAGS: 00010092   (2.6.21-rc6 #17)
EIP is at list_del+0x21/0x5d
eax: 00000048   ebx: c21a4608   ecx: c03f2fd0   edx: 00000082
esi: c03f8c10   edi: 00000011   ebp: 00000011   esp: f7f03e6c
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Process kswapd0 (pid: 245, ti=f7f02000 task=c258c7f0 task.ti=f7f02000)
Stack: c03b0c1a c21a4628 e21a4628 c21a4608 c0159617 f7f03f04 00000020 c03f8c00
        00000c1d c03f7b00 f7f03f74 c0159762 f7f03f0c 00000000 00000020 00000007
        00000000 00000000 00000000 00000001 c21aebf8 c21adcd0 c21830c0 c21903d8
Call Trace:
  [<c0159617>] isolate_lru_pages+0x31/0x7d
  [<c0159762>] shrink_active_list+0xff/0x38a
  [<c01978b8>] mb_cache_shrink_fn+0x47/0xbb
  [<c015a418>] shrink_slab+0x132/0x13e
  [<c015a2aa>] shrink_zone+0xb3/0xef
  [<c015a767>] kswapd+0x2c7/0x3fe
  [<c0135ae5>] autoremove_wake_function+0x0/0x35
  [<c015a4a0>] kswapd+0x0/0x3fe
  [<c0135a20>] kthread+0xb2/0xda
  [<c013596e>] kthread+0x0/0xda
  [<c01049e3>] kernel_thread_helper+0x7/0x10
  =======================
Code: 00 00 00 89 c3 eb e8 90 90 90 53 83 ec 0c 8b 48 04 8b 11 39 c2 74 18 89 54 24 08 89 44 24 04 
c7 04 24 1a 0c 3b c0 e8 c9 fa f3 ff <0f> 0b eb fe 8b 10 8b 5a 04 39 c3 74 18 89 5c 24 08 89 44 24 04
EIP: [<c01e5cd1>] list_del+0x21/0x5d SS:ESP 0068:f7f03e6c
BUG: spinlock lockup on CPU#1, ld/9860, c03f8c00
  [<c01e5a99>] _raw_spin_lock+0xbb/0xdc
  [<c0158a96>] __pagevec_lru_add+0x42/0x8f
  [<c01916af>] mpage_readpages+0xeb/0x110
  [<f8898751>] ext3_get_block+0x0/0xd0 [ext3]
  [<c0156bd3>] __alloc_pages+0x68/0x2aa
  [<f889e913>] __ext3_journal_stop+0x19/0x34 [ext3]
  [<f8897c4d>] ext3_readpages+0x0/0x15 [ext3]
  [<c0158366>] __do_page_cache_readahead+0x125/0x1cc
  [<f8898751>] ext3_get_block+0x0/0xd0 [ext3]
  [<c0158459>] blockable_page_cache_readahead+0x4c/0x9f
  [<c015860f>] page_cache_readahead+0xbf/0x196
  [<c0153166>] do_generic_mapping_read+0x137/0x463
  [<c01550ec>] generic_file_aio_read+0x173/0x1a3
  [<c0152913>] file_read_actor+0x0/0xe0
  [<c01e3f6c>] mmx_clear_page+0x24/0x60
  [<c016ef08>] do_sync_read+0xc7/0x10a
  [<c0135ae5>] autoremove_wake_function+0x0/0x35
  [<c0313a71>] mutex_lock+0x1a/0x29
  [<c016ee41>] do_sync_read+0x0/0x10a
  [<c016f795>] vfs_read+0xa6/0x152
  [<c016fbee>] sys_read+0x41/0x67
  [<c0103dc4>] sysenter_past_esp+0x5d/0x81
  =======================
BUG: spinlock lockup on CPU#0, irqbalance/2974, c03f8c00
  [<c01e5a99>] _raw_spin_lock+0xbb/0xdc
  [<c0158a02>] __pagevec_lru_add_active+0x42/0x94
  [<c015fbcf>] unmap_region+0x2b/0xfb
  [<c0160679>] do_munmap+0x164/0x1b6
  [<c01606fb>] sys_munmap+0x30/0x3e
  [<c0103dc4>] sysenter_past_esp+0x5d/0x81
  =======================

-------------------------------------------------------------------------
Linux hoth 2.6.21-rc6 #17 SMP Fri Apr 13 09:51:51 PDT 2007 i686 athlon i386 GNU/Linux

Gnu C                  4.1.1
Gnu make               3.81
binutils               2.17.50.0.6-2.fc6
util-linux             2.13-pre7
mount                  2.13-pre7
module-init-tools      3.3-pre1
e2fsprogs              1.39
pcmciautils            014
quota-tools            3.13.
PPP                    2.4.4
isdn4k-utils           3.9
Linux C Library        > libc.2.5
Dynamic linker (ldd)   2.5
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.12
oprofile               0.9.2
Sh-utils               5.97
udev                   095
wireless-tools         28
Modules Loaded         xt_tcpudp iptable_filter ip_tables x_tables w83627ehf i2c_isa eeprom hidp 
l2cap bluetooth sunrpc ipv6 cpufreq_ondemand dm_mirror dm_multipath dm_mod raid10 raid0 video sbs 
i2c_ec dock button battery asus_acpi ac lp snd_hda_intel snd_hda_codec parport_serial snd_seq_dummy 
snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer 
snd floppy soundcore sg ohci1394 pcspkr i2c_nforce2 snd_page_alloc parport_pc ieee1394 k8temp 
parport hwmon shpchp i2c_core forcedeth ide_cd serio_raw usblp cdrom sata_sil sata_via sata_nv 
libata sd_mod scsi_mod raid456 xor raid1 ext3 jbd ehci_hcd ohci_hcd uhci_hcd
-------------------------------------------------------------------------

-------------------------------------------------------------------------
cat /proc/version
-------------------------------------------------------------------------
Linux version 2.6.21-rc6 (carter@hoth) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #17 SMP Fri 
Apr 13 09:51:51 PDT 2007
-------------------------------------------------------------------------
cat /proc/cpuinfo
-------------------------------------------------------------------------
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 15
model		: 75
model name	: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+
stepping	: 2
cpu MHz		: 1000.000
cache size	: 512 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 2
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr 
sse sse2 ht syscall nx mmxext fxsr_opt rdtscp lm 3dnowext 3dnow pni cx16 lahf_lm cmp_legacy svm 
extapic cr8legacy ts fid vid ttp tm stc
bogomips	: 2010.20
clflush size	: 64

processor	: 1
vendor_id	: AuthenticAMD
cpu family	: 15
model		: 75
model name	: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+
stepping	: 2
cpu MHz		: 1000.000
cache size	: 512 KB
physical id	: 0
siblings	: 2
core id		: 1
cpu cores	: 2
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr 
sse sse2 ht syscall nx mmxext fxsr_opt rdtscp lm 3dnowext 3dnow pni cx16 lahf_lm cmp_legacy svm 
extapic cr8legacy ts fid vid ttp tm stc
bogomips	: 2010.20
clflush size	: 64

-------------------------------------------------------------------------
cat /proc/modules
-------------------------------------------------------------------------
xt_tcpudp 7168 0 - Live 0xf8d51000
iptable_filter 6976 1 - Live 0xf8af6000
ip_tables 16580 1 iptable_filter, Live 0xf8d4b000
x_tables 18820 2 xt_tcpudp,ip_tables, Live 0xf8d45000
w83627ehf 21584 0 - Live 0xf8d3e000
i2c_isa 9408 1 w83627ehf, Live 0xf8d56000
eeprom 11344 0 - Live 0xf8b40000
hidp 26688 2 - Live 0xf8d36000
l2cap 30912 5 hidp, Live 0xf8d78000
bluetooth 58084 2 hidp,l2cap, Live 0xf8e32000
sunrpc 160796 1 - Live 0xf8f3c000
ipv6 269824 36 - Live 0xf8afd000
cpufreq_ondemand 11980 1 - Live 0xf8af2000
dm_mirror 25364 0 - Live 0xf8b46000
dm_multipath 21768 0 - Live 0xf8aeb000
dm_mod 58508 2 dm_mirror,dm_multipath, Live 0xf8adb000
raid10 27072 1 - Live 0xf8ad3000
raid0 12160 1 - Live 0xf8af9000
video 21000 0 - Live 0xf8a91000
sbs 19200 0 - Live 0xf8a8b000
i2c_ec 9216 1 sbs, Live 0xf8aab000
dock 14008 0 - Live 0xf8aaf000
button 12048 0 - Live 0xf8a6d000
battery 14084 0 - Live 0xf8a32000
asus_acpi 20508 0 - Live 0xf8ab8000
ac 9348 0 - Live 0xf893a000
lp 16264 0 - Live 0xf8a2d000
snd_hda_intel 24728 0 - Live 0xf8a1e000
snd_hda_codec 202752 1 snd_hda_intel, Live 0xf8a3a000
parport_serial 11264 0 - Live 0xf8a1a000
snd_seq_dummy 7812 0 - Live 0xf8a37000
snd_seq_oss 33600 0 - Live 0xf8a10000
snd_seq_midi_event 11264 1 snd_seq_oss, Live 0xf89e3000
snd_seq 51440 5 snd_seq_dummy,snd_seq_oss,snd_seq_midi_event, Live 0xf8a00000
snd_seq_device 11788 3 snd_seq_dummy,snd_seq_oss,snd_seq, Live 0xf89df000
snd_pcm_oss 43840 0 - Live 0xf89d3000
snd_mixer_oss 19520 1 snd_pcm_oss, Live 0xf89cd000
snd_pcm 75652 3 snd_hda_intel,snd_hda_codec,snd_pcm_oss, Live 0xf89b9000
snd_timer 25156 2 snd_seq,snd_pcm, Live 0xf898f000
snd 54084 9 
snd_hda_intel,snd_hda_codec,snd_seq_oss,snd_seq,snd_seq_device,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_timer, 
Live 0xf89aa000
floppy 59172 0 - Live 0xf89f0000
soundcore 11680 1 snd, Live 0xf8980000
sg 37532 0 - Live 0xf8975000
ohci1394 37552 0 - Live 0xf8968000
pcspkr 7104 0 - Live 0xf8986000
i2c_nforce2 9792 0 - Live 0xf8989000
snd_page_alloc 13768 2 snd_hda_intel,snd_pcm, Live 0xf8999000
parport_pc 30052 1 parport_serial, Live 0xf89a1000
ieee1394 96472 1 ohci1394, Live 0xf8a72000
k8temp 9600 0 - Live 0xf8936000
parport 38664 2 lp,parport_pc, Live 0xf892b000
hwmon 7428 2 w83627ehf,k8temp, Live 0xf8942000
shpchp 35476 0 - Live 0xf8921000
i2c_core 24896 5 w83627ehf,i2c_isa,eeprom,i2c_ec,i2c_nforce2, Live 0xf8947000
forcedeth 49288 0 - Live 0xf8913000
ide_cd 40800 0 - Live 0xf8953000
serio_raw 10820 0 - Live 0xf88f0000
usblp 17408 0 - Live 0xf8838000
cdrom 37280 1 ide_cd, Live 0xf88e5000
sata_sil 15368 0 - Live 0xf88e0000
sata_via 15364 0 - Live 0xf88db000
sata_nv 23300 29 - Live 0xf88d4000
libata 114004 3 sata_sil,sata_via,sata_nv, Live 0xf88f6000
sd_mod 24128 29 - Live 0xf8857000
scsi_mod 138988 3 sg,libata,sd_mod, Live 0xf886e000
raid456 123920 0 - Live 0xf88b4000
xor 17928 1 raid456, Live 0xf8851000
raid1 26368 5 - Live 0xf8849000
ext3 126664 14 - Live 0xf8894000
jbd 60840 1 ext3, Live 0xf885e000
ehci_hcd 35340 0 - Live 0xf883f000
ohci_hcd 23940 0 - Live 0xf882d000
uhci_hcd 26896 0 - Live 0xf8825000
-------------------------------------------------------------------------
cat /proc/ioports
-------------------------------------------------------------------------
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:04.0
01f0-01f7 : 0000:00:04.0
   01f0-01f7 : ide0
0295-0296 : w83627ehf
0376-0376 : 0000:00:04.0
03c0-03df : vga+
03f2-03f5 : floppy
03f6-03f6 : 0000:00:04.0
   03f6-03f6 : ide0
03f7-03f7 : floppy DIR
0960-0967 : 0000:00:05.1
   0960-0967 : sata_nv
0970-0977 : 0000:00:05.0
   0970-0977 : sata_nv
09e0-09e7 : 0000:00:05.1
   09e0-09e7 : sata_nv
09f0-09f7 : 0000:00:05.0
   09f0-09f7 : sata_nv
0b60-0b63 : 0000:00:05.1
   0b60-0b63 : sata_nv
0b70-0b73 : 0000:00:05.0
   0b70-0b73 : sata_nv
0be0-0be3 : 0000:00:05.1
   0be0-0be3 : sata_nv
0bf0-0bf3 : 0000:00:05.0
   0bf0-0bf3 : sata_nv
0cf8-0cff : PCI conf1
1000-107f : pnp 00:01
   1000-1003 : ACPI PM1a_EVT_BLK
   1004-1005 : ACPI PM1a_CNT_BLK
   1008-100b : ACPI PM_TMR
   101c-101c : ACPI PM2_CNT_BLK
   1020-1027 : ACPI GPE0_BLK
1080-10ff : pnp 00:01
1400-147f : pnp 00:01
1480-14ff : pnp 00:01
   14a0-14af : ACPI GPE1_BLK
1800-187f : pnp 00:01
1880-18ff : pnp 00:01
1c00-1c3f : 0000:00:01.1
   1c00-1c3f : nForce2_smbus
1c40-1c7f : 0000:00:01.1
   1c40-1c7f : nForce2_smbus
4000-4fff : PCI Bus #06
   4c00-4cff : 0000:06:00.0
5000-5fff : PCI Bus #05
6000-6fff : PCI Bus #04
7000-7fff : PCI Bus #03
8000-8fff : PCI Bus #02
9000-afff : PCI Bus #01
   9800-980f : 0000:01:09.0
   9c00-9c07 : 0000:01:09.0
   a000-a007 : 0000:01:09.0
   a400-a407 : 0000:01:09.0
   a800-a807 : 0000:01:09.0
   ac00-ac07 : 0000:01:09.0
     ac00-ac07 : serial
b000-b007 : 0000:00:09.0
   b000-b007 : forcedeth
b400-b407 : 0000:00:08.0
   b400-b407 : forcedeth
b800-b80f : 0000:00:05.2
   b800-b80f : sata_nv
bc00-bc03 : 0000:00:05.2
   bc00-bc03 : sata_nv
c000-c007 : 0000:00:05.2
   c000-c007 : sata_nv
c400-c403 : 0000:00:05.2
   c400-c403 : sata_nv
c800-c807 : 0000:00:05.2
   c800-c807 : sata_nv
cc00-cc0f : 0000:00:05.1
   cc00-cc0f : sata_nv
e000-e00f : 0000:00:05.0
   e000-e00f : sata_nv
f400-f40f : 0000:00:04.0
   f400-f407 : ide0
-------------------------------------------------------------------------
cat /proc/iomem
-------------------------------------------------------------------------
00000000-0009efff : System RAM
   00000000-00000000 : Crash kernel
0009f000-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000ccfff : Video ROM
000d0000-000d3fff : pnp 00:0b
000f0000-000fffff : System ROM
00100000-7ffeffff : System RAM
   00100000-003179d7 : Kernel code
   003179d8-00431713 : Kernel data
7fff0000-7fff2fff : ACPI Non-volatile Storage
7fff3000-7fffffff : ACPI Tables
e0000000-efffffff : PCI Bus #06
   e0000000-efffffff : 0000:06:00.0
f0000000-f3ffffff : reserved
fd400000-fd4fffff : PCI Bus #06
   fd400000-fd41ffff : 0000:06:00.0
   fd4e0000-fd4effff : 0000:06:00.1
   fd4f0000-fd4fffff : 0000:06:00.0
fd500000-fd5fffff : PCI Bus #05
fd600000-fd6fffff : PCI Bus #05
fd700000-fd7fffff : PCI Bus #04
fd800000-fd8fffff : PCI Bus #04
fd900000-fd9fffff : PCI Bus #03
fda00000-fdafffff : PCI Bus #03
fdb00000-fdbfffff : PCI Bus #02
fdc00000-fdcfffff : PCI Bus #02
fdd00000-fddfffff : PCI Bus #01
   fddf8000-fddfbfff : 0000:01:08.0
   fddff000-fddff7ff : 0000:01:08.0
     fddff000-fddff7ff : ohci1394
fde00000-fdefffff : PCI Bus #01
fe020000-fe023fff : 0000:00:06.1
   fe020000-fe023fff : ICH HD audio
fe025000-fe02500f : 0000:00:09.0
   fe025000-fe02500f : forcedeth
fe026000-fe0260ff : 0000:00:09.0
   fe026000-fe0260ff : forcedeth
fe027000-fe027fff : 0000:00:09.0
   fe027000-fe027fff : forcedeth
fe028000-fe02800f : 0000:00:08.0
   fe028000-fe02800f : forcedeth
fe029000-fe0290ff : 0000:00:08.0
   fe029000-fe0290ff : forcedeth
fe02a000-fe02afff : 0000:00:08.0
   fe02a000-fe02afff : forcedeth
fe02b000-fe02bfff : 0000:00:05.2
   fe02b000-fe02bfff : sata_nv
fe02c000-fe02cfff : 0000:00:05.1
   fe02c000-fe02cfff : sata_nv
fe02d000-fe02dfff : 0000:00:05.0
   fe02d000-fe02dfff : sata_nv
fe02e000-fe02e0ff : 0000:00:02.1
   fe02e000-fe02e0ff : ehci_hcd
fe02f000-fe02ffff : 0000:00:02.0
   fe02f000-fe02ffff : ohci_hcd
fec00000-ffffffff : reserved
-------------------------------------------------------------------------
cat /proc/scsi/scsi
-------------------------------------------------------------------------
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST3160827AS      Rev: 3.42
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST3160827AS      Rev: 3.42
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi2 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST3160827AS      Rev: 3.42
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi3 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST3160827AS      Rev: 3.42
   Type:   Direct-Access                    ANSI  SCSI revision: 05
-------------------------------------------------------------------------
lspci -vvv
-------------------------------------------------------------------------
00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a1)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Capabilities: [44] HyperTransport: Slave or Primary Interface
		Command: BaseUnitID=0 UnitCnt=15 MastHost- DefDir- DUL-
		Link Control 0: CFlE+ CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn- LSEn+ ExtCTL- 64b-
		Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
		Link Config 1: MLWI=8bit DwFcIn- MLWO=8bit DwFcOut- LWI=8bit DwFcInEn- LWO=8bit DwFcOutEn-
		Revision ID: 1.03
		Link Frequency 0: 1.0GHz
		Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 0: 200MHz+ 300MHz+ 400MHz+ 500MHz+ 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz- 
1.4GHz- 1.6GHz- Vend-
		Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD-
		Link Frequency 1: 200MHz
		Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 
1.4GHz- 1.6GHz- Vend-
		Error Handling: PFlE+ OFlE+ PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- 
CRCNFE- SERRNFE-
		Prefetchable memory behind bridge Upper: 00-00
		Bus Number: 00
	Capabilities: [e0] #00 [fee0]

00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 4: I/O ports at 1c00 [size=64]
	Region 5: I/O ports at 1c40 [size=64]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:01.2 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1) (prog-if 10 [OHCI])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at fe02f000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2) (prog-if 20 [EHCI])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin B routed to IRQ 18
	Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [44] Debug port
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1) (prog-if 8a [Master SecP PriP])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [disabled] [size=1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [disabled] [size=1]
	Region 4: I/O ports at f400 [size=16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:05.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) (prog-if 85 [Master SecO PriO])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin A routed to IRQ 19
	Region 0: I/O ports at 09f0 [size=8]
	Region 1: I/O ports at 0bf0 [size=4]
	Region 2: I/O ports at 0970 [size=8]
	Region 3: I/O ports at 0b70 [size=4]
	Region 4: I/O ports at e000 [size=16]
	Region 5: Memory at fe02d000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [b0] Message Signalled Interrupts: 64bit+ Queue=0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping

00:05.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) (prog-if 85 [Master SecO PriO])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin B routed to IRQ 20
	Region 0: I/O ports at 09e0 [size=8]
	Region 1: I/O ports at 0be0 [size=4]
	Region 2: I/O ports at 0960 [size=8]
	Region 3: I/O ports at 0b60 [size=4]
	Region 4: I/O ports at cc00 [size=16]
	Region 5: Memory at fe02c000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [b0] Message Signalled Interrupts: 64bit+ Queue=0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping

00:05.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) (prog-if 85 [Master SecO PriO])
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin C routed to IRQ 17
	Region 0: I/O ports at c800 [size=8]
	Region 1: I/O ports at c400 [size=4]
	Region 2: I/O ports at c000 [size=8]
	Region 3: I/O ports at bc00 [size=4]
	Region 4: I/O ports at b800 [size=16]
	Region 5: Memory at fe02b000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [b0] Message Signalled Interrupts: 64bit+ Queue=0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping

00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	I/O behind bridge: 00009000-0000afff
	Memory behind bridge: fdd00000-fddfffff
	Prefetchable memory behind bridge: fde00000-fdefffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [b8] #0d [0000]
	Capabilities: [8c] HyperTransport: MSI Mapping

00:06.1 Audio device: nVidia Corporation MCP55 High Definition Audio (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c20
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (500ns min, 1250ns max)
	Interrupt: pin B routed to IRQ 20
	Region 0: Memory at fe020000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [6c] HyperTransport: MSI Mapping

00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 218
	Region 0: Memory at fe02a000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at b400 [size=8]
	Region 2: Memory at fe029000 (32-bit, non-prefetchable) [size=256]
	Region 3: Memory at fe028000 (32-bit, non-prefetchable) [size=16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
	Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
		Vector table: BAR=2 offset=00000000
		PBA: BAR=3 offset=00000000
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable+
		Address: 00000000fee0100c  Data: 414a
	Capabilities: [6c] HyperTransport: MSI Mapping

00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
	Subsystem: ABIT Computer Corp. Unknown device 1c24
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 217
	Region 0: Memory at fe027000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at b000 [size=8]
	Region 2: Memory at fe026000 (32-bit, non-prefetchable) [size=256]
	Region 3: Memory at fe025000 (32-bit, non-prefetchable) [size=16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
	Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
		Vector table: BAR=2 offset=00000000
		PBA: BAR=3 offset=00000000
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable+
		Address: 00000000fee0200c  Data: 4152
	Capabilities: [6c] HyperTransport: MSI Mapping

00:0b.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00008000-00008fff
	Memory behind bridge: fdc00000-fdcfffff
	Prefetchable memory behind bridge: 00000000fdb00000-00000000fdb00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] #0d [0000]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 41b1
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <512ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x4
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd On, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [100] Virtual Channel

00:0c.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 00007000-00007fff
	Memory behind bridge: fda00000-fdafffff
	Prefetchable memory behind bridge: 00000000fd900000-00000000fd900000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] #0d [0000]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 41b9
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
		Link: Latency L0s <512ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x4
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd On, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [100] Virtual Channel

00:0d.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 00006000-00006fff
	Memory behind bridge: fd800000-fd8fffff
	Prefetchable memory behind bridge: 00000000fd700000-00000000fd700000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] #0d [0000]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 41c1
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
		Link: Latency L0s <512ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x4
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd On, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [100] Virtual Channel

00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: fd600000-fd6fffff
	Prefetchable memory behind bridge: 00000000fd500000-00000000fd500000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] #0d [0000]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 41c9
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 1
		Link: Latency L0s <512ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x8
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd On, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [100] Virtual Channel

00:0f.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: fd400000-fd4fffff
	Prefetchable memory behind bridge: 00000000e0000000-00000000eff00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [40] #0d [0000]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 41d1
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [80] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
		Link: Latency L0s <512ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd On, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [100] Virtual Channel

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology 
Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [f0] #0f [0010]

01:08.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22/A IEEE-1394a-2000 Controller (PHY/Link) 
(prog-if 10 [OHCI])
	Subsystem: ABIT Computer Corp. Unknown device 1c20
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (500ns min, 1000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at fddff000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at fddf8000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+

01:09.0 Serial controller: NetMos Technology PCI 9835 Multi-I/O Controller (rev 01) (prog-if 02 [16550])
	Subsystem: LSI Logic / Symbios Logic Unknown device 0001
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at ac00 [size=8]
	Region 1: I/O ports at a800 [size=8]
	Region 2: I/O ports at a400 [size=8]
	Region 3: I/O ports at a000 [size=8]
	Region 4: I/O ports at 9c00 [size=8]
	Region 5: I/O ports at 9800 [size=16]

06:00.0 VGA compatible controller: ATI Technologies Inc RV370 [Sapphire X550 Silent] (prog-if 00 [VGA])
	Subsystem: PC Partner Limited Unknown device 1490
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=256M]
	Region 1: I/O ports at 4c00 [size=256]
	Region 2: Memory at fd4f0000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at fd400000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <128ns, L1 <2us
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
		Link: Latency L0s <128ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
	Capabilities: [80] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [100] Advanced Error Reporting

06:00.1 Display controller: ATI Technologies Inc RV370 secondary [Sapphire X550 Silent]
	Subsystem: PC Partner Limited Unknown device 1491
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Region 0: Memory at fd4e0000 (32-bit, non-prefetchable) [disabled] [size=64K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <128ns, L1 <2us
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
		Link: Latency L0s <128ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
