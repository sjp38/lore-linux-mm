Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06BBF8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 11:45:30 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p17-v6so1049935ywp.15
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:45:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 84-v6sor2189098ywq.478.2018.09.18.08.45.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 08:45:20 -0700 (PDT)
Date: Tue, 18 Sep 2018 11:45:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: PROBLEM: Memory leaking when running kubernetes cronjobs
Message-ID: <20180918154517.GA6243@cmpxchg.org>
References: <OF4F83D2EA.AEC0204B-ON8025830C.003BD85C-8025830C.003CAFFE@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF4F83D2EA.AEC0204B-ON8025830C.003BD85C-8025830C.003CAFFE@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel McGinnes <MCGINNES@uk.ibm.com>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Nathaniel Rockwell <nrockwell@us.ibm.com>, Roman Gushchin <guro@fb.com>

Hi Daniel,

On Tue, Sep 18, 2018 at 11:02:52AM +0000, Daniel McGinnes wrote:
> we are hitting the following kernel issue, which we think might be caused 
> by memory cgroups.:
> 
> [1.] One line summary of the problem: Memory leaking when running 
> kubernetes cronjobs
> 
> [2.] Full description of the problem/report: 
> We are using Kubernetes V1.8.15 with docker 18.03.1-ce.
> We schedule 50 Kubernetes cronjobs to run every 5 minutes. Each cronjob 
> will create a simple busybox container, echo hello world, then terminate.
> In the first set of data I have I let this run for 1 hour, and in this 
> time the Available memory had reduced from 31256704 kB to 30461224 kB - so 
> a loss of 776 MB. 
> There doesn't appear to be any processes left behind, or any growth in any 
> other processes to explain where the memory has gone.
> echo 3 > /proc/sys/vm/drop_caches causes some of the memory to be 
> returned, but the majority remains leaked, and the only way to free it 
> appears to be to reboot the system.

There are patches lined up in the -mm tree for this exact issue:

mm: don't miss the last page because of round-off error
mm: drain memcg stocks on css offlining
mm: rework memcg kernel stack accounting
mm: slowly shrink slabs with a relatively small number of objects

CCing Roman who wrote them. Full quote below.

Johannes

> We are currently running Ubuntu 4.15.0-32.35-generic 4.15.18 and have 
> previously observed similar issues on Ubuntu 16.04 with Kernel 
> 4.4.0-89-generic #112-Ubuntu SMP Mon Jul 31 19:38:41 UTC 2017 and Debian 
> 9.4 running 4.9.0-6-amd64 #1 SMP Debian 4.9.82-1+deb9u3 (2018-03-02), and 
> I have just recreated on Linux version 4.19.0-041900rc3-generic 
> 
> The leak was more severe on the Debian system, and investigations there 
> showed leaks in pcpu_get_vm_areas and were related to memory cgroups. 
> Running with Kernel 4.17 on debian showed a leak at a similar rate to what 
> we now observe on 4.15 & 4.19 Kernels with Ubuntu. This leak causes us 
> issues as we need to run cronjobs regularly for backups and want the 
> systems to remain up for months.
> 
> Kubernetes will create a new cgroup each time the cronjob runs, but these 
> are removed when the job completes (which takes a few seconds). If I use 
> systemd-cgtop I don't see any increase in cgroups over time - but if I 
> monitor /proc/cgroups over time I can see num_cgroups for memory increases 
> for about the first 18 hours, and then stabilises at around 4300.
> 
> For the duration of the test I collected slabinfo, meminfo, vmallocinfo & 
> cgroups - which I can provide. 
> 
> I stopped the cronjobs after 1 hour, and I then left the system idle for 
> 10 minutes. I then ran echo 3 > /proc/sys/vm/drop_caches . This seemed to 
> free ~240MB - but this still leaves ~500MB lost. I then left the system 
> idle for a further 20 minutes, and MemoryAvailable didn't seem to be 
> increasing significantly.
> 
> I have performed another run for a longer period, and after 89 hours, the 
> MemoryAvailable has reduced by ~5.5GB - the rate of decrease seems less 
> severe after the first 4-5 hours - but clearly continues to decrease at a 
> rate of ~1 GB per day for the duration of the test.
> 
> After ~110 hours I ran `stress --vm 16 --vm-bytes 2147483648` to generate 
> some memory pressure to see how much would be reclaimed.
> Before running the stress utility  MemAvailable was 24585576 
> After running the stress utility MemAvailable was 27266788
> 
> I ran ps aux | awk '{sum+=$6} END {print sum / 1024}'
> which showed: 1220.44
> 
> Since the start of the test it looks like we have leaked 3.8GB which is 
> not reclaimable under memory pressure.
> 
> This was originally raised as this Ubuntu bug: 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1792349 , which 
> requested a kernel bug be opened.
> 
> [3.] Keywords (i.e., modules, networking, kernel):
> [4.] Kernel version (from /proc/version):Kernel version: Linux version 
> 4.19.0-041900rc3-generic (kernel@gloin) (gcc version 8.2.0 (Ubuntu 
> 8.2.0-6ubuntu1)) #201809120832 SMP Wed Sep 12 12:35:08 UTC 2018
> [5.] Output of Oops.. message (if applicable) with symbolic information 
> resolved (see Documentation/oops-tracing.txt): n/a
> [6.] A small shell script or example program which triggers the problem 
> (if possible): Tricky to provide as Kubernetes is fairly complex to 
> setup/configure
> [7.] Environment
>         Description:    Ubuntu 18.04.1 LTS
>         Release:        18.04
> [7.1.] Software (add the output of the ver_linux script here):
> Linux stage-dal09-carrier1-worker-37.alchemy.ibm.com 
> 4.19.0-041900rc3-generic #201809120832 SMP Wed Sep 12 12:35:08 UTC 2018 
> x86_64 x86_64 x86_64 GNU/Linux
> 
> GNU Make                4.1
> Binutils                2.30
> Util-linux              2.31.1
> Mount                   2.31.1
> Module-init-tools       24
> E2fsprogs               1.44.1
> Xfsprogs                4.9.0
> Nfs-utils               1.3.3
> Linux C Library         2.27
> Dynamic linker (ldd)    2.27
> Linux C++ Library       6.0.25
> Procps                  3.3.12
> Net-tools               2.10
> Kbd                     2.0.4
> Console-tools           2.0.4
> Sh-utils                8.28
> Udev                    237
> Modules Loaded          async_memcpy async_pq async_raid6_recov async_tx 
> async_xor autofs4 binfmt_misc bpfilter bridge btrfs cirrus crc32_pclmul 
> crct10dif_pclmul cryptd drm drm_kms_helper fb_sys_fops floppy 
> ghash_clmulni_intel hid hid_generic i2c_piix4 ib_cm ib_core ib_iser 
> ide_core ide_pci_generic input_leds intel_rapl intel_rapl_perf ip6_tables 
> ip6t_REJECT ip6t_rt ip6table_filter ip_set ip_set_hash_ip ip_set_hash_net 
> ip_tables ip_tunnel ip_vs ipip ipt_MASQUERADE ipt_REJECT iptable_filter 
> iptable_mangle iptable_nat iptable_raw iscsi_tcp iw_cm joydev libcrc32c 
> libiscsi libiscsi_tcp linear llc mac_hid multipath nf_conntrack 
> nf_conntrack_broadcast nf_conntrack_ftp nf_conntrack_netbios_ns 
> nf_conntrack_netlink nf_defrag_ipv4 nf_defrag_ipv6 nf_log_common 
> nf_log_ipv4 nf_log_ipv6 nf_nat nf_nat_ftp nf_nat_ipv4 nf_reject_ipv4 
> nf_reject_ipv6 nfnetlink overlay parport parport_pc pata_acpi piix ppdev 
> psmouse raid0 raid1 raid10 raid456 raid6_pq rdma_cm sb_edac sch_fq_codel 
> scsi_transport_iscsi serio_raw stp sunrpc syscopyarea sysfillrect 
> sysimgblt ttm tunnel4 usbhid veth x_tables xen_privcmd xenfs xfrm_algo 
> xfrm_user xor xt_LOG xt_addrtype xt_comment xt_conntrack xt_hl xt_limit 
> xt_mark xt_multiport xt_nat xt_recent xt_set xt_statistic xt_tcpudp 
> zstd_compress
> 
> [7.2.] Processor information (from /proc/cpuinfo):
> 
> (There are 16 processors - just including first one for brevity)
> 
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 63
> model name      : Intel(R) Xeon(R) CPU E5-2683 v3 @ 2.00GHz
> stepping        : 2
> microcode       : 0x3d
> cpu MHz         : 2000.018
> cache size      : 35840 KB
> physical id     : 0
> siblings        : 16
> core id         : 0
> cpu cores       : 16
> apicid          : 0
> initial apicid  : 0
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
> cmov pat pse36 clflush acpi mmx fxsr sse sse2 ht syscall pdpe1gb rdtscp lm 
> constant_tsc rep_good nopl cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 
> sse4_2 x2apic movbe popcnt tsc_deadline_timer xsave avx f16c rdrand 
> hypervisor lahf_lm abm cpuid_fault invpcid_single pti intel_ppin ssbd ibrs 
> ibpb stibp fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt 
> flush_l1d
> bugs            : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass 
> l1tf
> bogomips        : 4000.08
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 46 bits physical, 48 bits virtual
> power management:
> 
> [7.3.] Module information (from /proc/modules):
> binfmt_misc 20480 1 - Live 0xffffffffc0a7c000
> veth 24576 0 - Live 0xffffffffc0a75000
> xt_set 20480 4 - Live 0xffffffffc0a6f000
> xt_multiport 16384 11 - Live 0xffffffffc0a65000
> iptable_raw 16384 1 - Live 0xffffffffc0a60000
> iptable_mangle 16384 1 - Live 0xffffffffc0a45000
> ip_set_hash_ip 32768 1 - Live 0xffffffffc0a57000
> ip_set_hash_net 32768 2 - Live 0xffffffffc0a4a000
> ip_set 40960 3 xt_set,ip_set_hash_ip,ip_set_hash_net, Live 
> 0xffffffffc0a3a000
> ipip 16384 0 - Live 0xffffffffc0a35000
> tunnel4 16384 1 ipip, Live 0xffffffffc0a30000
> ip_tunnel 24576 1 ipip, Live 0xffffffffc0a29000
> xt_statistic 16384 5172 - Live 0xffffffffc0a24000
> xt_nat 16384 8652 - Live 0xffffffffc0a1f000
> xt_recent 20480 2 - Live 0xffffffffc0a15000
> ipt_MASQUERADE 16384 3 - Live 0xffffffffc0a10000
> xt_mark 16384 568 - Live 0xffffffffc096c000
> bridge 159744 0 - Live 0xffffffffc09e8000
> stp 16384 1 bridge, Live 0xffffffffc09e1000
> llc 16384 2 bridge,stp, Live 0xffffffffc09d9000
> xfrm_user 36864 1 - Live 0xffffffffc09cb000
> xfrm_algo 16384 1 xfrm_user, Live 0xffffffffc09c6000
> nf_conntrack_netlink 40960 0 - Live 0xffffffffc09bb000
> nfnetlink 16384 3 ip_set,nf_conntrack_netlink, Live 0xffffffffc0967000
> xt_comment 16384 39264 - Live 0xffffffffc095c000
> overlay 106496 8 - Live 0xffffffffc09a0000
> iptable_nat 16384 1 - Live 0xffffffffc094e000
> nf_nat_ipv4 16384 2 ipt_MASQUERADE,iptable_nat, Live 0xffffffffc0957000
> ip_vs 147456 0 - Live 0xffffffffc097b000
> ppdev 20480 0 - Live 0xffffffffc0896000
> intel_rapl 20480 0 - Live 0xffffffffc0975000
> sb_edac 24576 0 - Live 0xffffffffc0947000
> joydev 20480 0 - Live 0xffffffffc0961000
> intel_rapl_perf 16384 0 - Live 0xffffffffc0891000
> input_leds 16384 0 - Live 0xffffffffc088c000
> serio_raw 16384 0 - Live 0xffffffffc0887000
> parport_pc 36864 0 - Live 0xffffffffc08d4000
> parport 49152 2 ppdev,parport_pc, Live 0xffffffffc08c2000
> mac_hid 16384 0 - Live 0xffffffffc0882000
> ip6t_REJECT 16384 1 - Live 0xffffffffc087a000
> nf_reject_ipv6 16384 1 ip6t_REJECT, Live 0xffffffffc0875000
> nf_log_ipv6 16384 3 - Live 0xffffffffc0870000
> xt_hl 16384 22 - Live 0xffffffffc086b000
> ip6t_rt 16384 3 - Live 0xffffffffc0863000
> ipt_REJECT 16384 23 - Live 0xffffffffc085b000
> nf_reject_ipv4 16384 1 ipt_REJECT, Live 0xffffffffc0856000
> nf_log_ipv4 16384 3 - Live 0xffffffffc084e000
> nf_log_common 16384 2 nf_log_ipv6,nf_log_ipv4, Live 0xffffffffc0846000
> xt_LOG 16384 6 - Live 0xffffffffc083e000
> xt_limit 16384 9 - Live 0xffffffffc082f000
> xt_tcpudp 16384 20850 - Live 0xffffffffc082a000
> xt_addrtype 16384 18 - Live 0xffffffffc0795000
> sch_fq_codel 20480 17 - Live 0xffffffffc078f000
> xt_conntrack 16384 155 - Live 0xffffffffc0822000
> ip6table_filter 16384 1 - Live 0xffffffffc07c4000
> ip6_tables 28672 53 ip6table_filter, Live 0xffffffffc0816000
> nf_conntrack_netbios_ns 16384 0 - Live 0xffffffffc080e000
> nf_conntrack_broadcast 16384 1 nf_conntrack_netbios_ns, Live 
> 0xffffffffc073d000
> nf_nat_ftp 16384 0 - Live 0xffffffffc06cc000
> nf_nat 32768 3 xt_nat,nf_nat_ipv4,nf_nat_ftp, Live 0xffffffffc079f000
> nf_conntrack_ftp 20480 1 nf_nat_ftp, Live 0xffffffffc0804000
> nf_conntrack 143360 11 
> xt_nat,ipt_MASQUERADE,nf_conntrack_netlink,nf_nat_ipv4,ip_vs,xt_conntrack,nf_conntrack_netbios_ns,nf_conntrack_broadcast,nf_nat_ftp,nf_nat,nf_conntrack_ftp, 
> Live 0xffffffffc07d4000
> nf_defrag_ipv6 20480 1 nf_conntrack, Live 0xffffffffc07ca000
> ib_iser 53248 0 - Live 0xffffffffc07b6000
> nf_defrag_ipv4 16384 1 nf_conntrack, Live 0xffffffffc0743000
> rdma_cm 57344 1 ib_iser, Live 0xffffffffc072e000
> iptable_filter 16384 1 - Live 0xffffffffc0729000
> iw_cm 45056 1 rdma_cm, Live 0xffffffffc06b1000
> ib_cm 53248 1 rdma_cm, Live 0xffffffffc07a8000
> bpfilter 16384 0 - Live 0xffffffffc053a000
> ib_core 237568 4 ib_iser,rdma_cm,iw_cm,ib_cm, Live 0xffffffffc0754000
> iscsi_tcp 20480 0 - Live 0xffffffffc074e000
> libiscsi_tcp 20480 1 iscsi_tcp, Live 0xffffffffc0748000
> sunrpc 356352 1 - Live 0xffffffffc06d1000
> libiscsi 57344 3 ib_iser,iscsi_tcp,libiscsi_tcp, Live 0xffffffffc06bd000
> xenfs 16384 1 - Live 0xffffffffc0523000
> xen_privcmd 20480 1 xenfs, Live 0xffffffffc0330000
> scsi_transport_iscsi 98304 4 ib_iser,iscsi_tcp,libiscsi, Live 
> 0xffffffffc0698000
> ip_tables 24576 14 iptable_raw,iptable_mangle,iptable_nat,iptable_filter, 
> Live 0xffffffffc045f000
> x_tables 36864 23 
> xt_set,xt_multiport,iptable_raw,iptable_mangle,xt_statistic,xt_nat,xt_recent,ipt_MASQUERADE,xt_mark,xt_comment,ip6t_REJECT,xt_hl,ip6t_rt,ipt_REJECT,xt_LOG,xt_limit,xt_tcpudp,xt_addrtype,xt_conntrack,ip6table_filter,ip6_tables,iptable_filter,ip_tables, 
> Live 0xffffffffc068e000
> autofs4 40960 2 - Live 0xffffffffc0683000
> btrfs 1159168 0 - Live 0xffffffffc0567000
> zstd_compress 159744 1 btrfs, Live 0xffffffffc053f000
> raid10 53248 0 - Live 0xffffffffc052c000
> raid456 151552 0 - Live 0xffffffffc04fd000
> async_raid6_recov 20480 1 raid456, Live 0xffffffffc04f7000
> async_memcpy 16384 2 raid456,async_raid6_recov, Live 0xffffffffc04f2000
> async_pq 16384 2 raid456,async_raid6_recov, Live 0xffffffffc04ed000
> async_xor 16384 3 raid456,async_raid6_recov,async_pq, Live 
> 0xffffffffc04b5000
> async_tx 16384 5 
> raid456,async_raid6_recov,async_memcpy,async_pq,async_xor, Live 
> 0xffffffffc04b0000
> xor 24576 2 btrfs,async_xor, Live 0xffffffffc0483000
> raid6_pq 114688 4 btrfs,raid456,async_raid6_recov,async_pq, Live 
> 0xffffffffc0493000
> libcrc32c 16384 5 ip_vs,nf_nat,nf_conntrack,btrfs,raid456, Live 
> 0xffffffffc047e000
> raid1 40960 0 - Live 0xffffffffc046b000
> raid0 20480 0 - Live 0xffffffffc0422000
> multipath 16384 0 - Live 0xffffffffc02fe000
> linear 16384 0 - Live 0xffffffffc0312000
> hid_generic 16384 0 - Live 0xffffffffc0304000
> usbhid 49152 0 - Live 0xffffffffc02f1000
> hid 126976 2 hid_generic,usbhid, Live 0xffffffffc042e000
> cirrus 24576 1 - Live 0xffffffffc02e4000
> ttm 106496 1 cirrus, Live 0xffffffffc03eb000
> drm_kms_helper 167936 1 cirrus, Live 0xffffffffc04c3000
> syscopyarea 16384 1 drm_kms_helper, Live 0xffffffffc02ec000
> crct10dif_pclmul 16384 0 - Live 0xffffffffc04bb000
> sysfillrect 16384 1 drm_kms_helper, Live 0xffffffffc048e000
> crc32_pclmul 16384 0 - Live 0xffffffffc0429000
> ide_pci_generic 16384 0 - Live 0xffffffffc045a000
> sysimgblt 16384 1 drm_kms_helper, Live 0xffffffffc0317000
> ghash_clmulni_intel 16384 0 - Live 0xffffffffc0479000
> fb_sys_fops 16384 1 drm_kms_helper, Live 0xffffffffc0466000
> piix 16384 0 - Live 0xffffffffc0452000
> cryptd 24576 1 ghash_clmulni_intel, Live 0xffffffffc0347000
> ide_core 106496 2 ide_pci_generic,piix, Live 0xffffffffc0407000
> drm 466944 4 cirrus,ttm,drm_kms_helper, Live 0xffffffffc0352000
> psmouse 151552 0 - Live 0xffffffffc03c5000
> i2c_piix4 24576 0 - Live 0xffffffffc033c000
> pata_acpi 16384 0 - Live 0xffffffffc0337000
> floppy 77824 0 - Live 0xffffffffc031c000
> 
> 
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> cat /proc/ioports
> 0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0061-0061 : PNP0800:00
>   0064-0064 : keyboard
>   0070-0071 : rtc0
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>   0170-0177 : 0000:00:01.1
>     0170-0177 : ata_piix
>   01f0-01f7 : 0000:00:01.1
>     01f0-01f7 : ata_piix
>   0376-0376 : 0000:00:01.1
>     0376-0376 : ata_piix
>   0378-037a : parport0
>   03c0-03df : vga+
>   03f2-03f2 : floppy
>   03f4-03f5 : floppy
>   03f6-03f6 : 0000:00:01.1
>     03f6-03f6 : ata_piix
>   03f7-03f7 : floppy
>   03f8-03ff : serial
>   04d0-04d1 : pnp 00:01
>   08a0-08a3 : pnp 00:01
>   0cc0-0ccf : pnp 00:01
> 0cf8-0cff : PCI conf1
> 0d00-ffff : PCI Bus 0000:00
>   10c0-1141 : pnp 00:08
>   afe0-afe3 : ACPI GPE0_BLK
>   b000-b03f : 0000:00:01.3
>     b000-b003 : ACPI PM1a_EVT_BLK
>     b004-b005 : ACPI PM1a_CNT_BLK
>     b008-b00b : ACPI PM_TMR
>   b044-b047 : pnp 00:08
>   c000-c0ff : 0000:00:03.0
>     c000-c0ff : xen-platform-pci
>   c300-c31f : 0000:00:01.2
>     c300-c31f : uhci_hcd
>   c320-c32f : 0000:00:01.1
>     c320-c32f : ata_piix
> 
> cat /proc/iomem
> 00000000-00000fff : Reserved
> 00001000-0009dfff : System RAM
> 0009e000-0009ffff : Reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000c8bff : Video ROM
> 000c9000-000c99ff : Adapter ROM
> 000e0000-000fffff : Reserved
>   000f0000-000fffff : System ROM
> 00100000-efffffff : System RAM
> f0000000-fbffffff : PCI Bus 0000:00
>   f0000000-f1ffffff : 0000:00:02.0
>     f0000000-f1ffffff : cirrusdrmfb_vram
>   f2000000-f2ffffff : 0000:00:03.0
>     f2000000-f2ffffff : xen-platform-pci
>   f3000000-f33fffff : 0000:00:06.0
>   f3400000-f3400fff : 0000:00:02.0
>     f3400000-f3400fff : cirrusdrmfb_mmio
> fc000000-ffffffff : Reserved
>   fec00000-fec003ff : IOAPIC 0
>   fed00000-fed003ff : HPET 0
>     fed00000-fed003ff : PNP0103:00
>   fee00000-fee00fff : Local APIC
> 100000000-80fbfffff : System RAM
>   30b400000-30c2031d0 : Kernel code
>   30c2031d1-30cc9fa3f : Kernel data
>   30cf22000-30d16dfff : Kernel bss
> 80fc00000-80fffffff : RAM buffer
> 
> [7.5.] PCI information ('lspci -vvv' as root)
> 
> sudo lspci -vvv
> 00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 
> 02)
>         Subsystem: Red Hat, Inc Qemu virtual machine
>         Physical Slot: 0
>         Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
>         Subsystem: Red Hat, Inc Qemu virtual machine
>         Physical Slot: 1
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE [Natoma/Triton 
> II] (prog-if 80 [Master])
>         Subsystem: XenSource, Inc. 82371SB PIIX3 IDE [Natoma/Triton II]
>         Physical Slot: 1
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64
>         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) 
> [size=8]
>         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
>         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) 
> [size=8]
>         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
>         Region 4: I/O ports at c320 [size=16]
>         Kernel driver in use: ata_piix
>         Kernel modules: pata_acpi, piix, ide_pci_generic
> 
> 00:01.2 USB controller: Intel Corporation 82371SB PIIX3 USB [Natoma/Triton 
> II] (rev 01) (prog-if 00 [UHCI])
>         Subsystem: XenSource, Inc. 82371SB PIIX3 USB [Natoma/Triton II]
>         Physical Slot: 1
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64
>         Interrupt: pin D routed to IRQ 23
>         Region 4: I/O ports at c300 [size=32]
>         Kernel driver in use: uhci_hcd
> 
> 00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 01)
>         Subsystem: Red Hat, Inc Qemu virtual machine
>         Physical Slot: 1
>         Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 9
>         Kernel modules: i2c_piix4
> 
> 00:02.0 VGA compatible controller: Cirrus Logic GD 5446 (prog-if 00 [VGA 
> controller])
>         Subsystem: XenSource, Inc. GD 5446
>         Physical Slot: 2
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 24
>         Region 0: Memory at f0000000 (32-bit, prefetchable) [size=32M]
>         Region 1: Memory at f3400000 (32-bit, non-prefetchable) [size=4K]
>         [virtual] Expansion ROM at 000c0000 [disabled] [size=128K]
>         Kernel driver in use: cirrus
>         Kernel modules: cirrusfb, cirrus
> 
> 00:03.0 SCSI storage controller: XenSource, Inc. Xen Platform Device (rev 
> 01)
>         Subsystem: XenSource, Inc. Xen Platform Device
>         Physical Slot: 3
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 30
>         Region 0: I/O ports at c000 [size=256]
>         Region 1: Memory at f2000000 (32-bit, prefetchable) [size=16M]
>         Kernel driver in use: xen-platform-pci
> 
> 00:06.0 System peripheral: XenSource, Inc. Citrix XenServer PCI Device for 
> Windows Update (rev 01)
>         Subsystem: XenSource, Inc. Citrix XenServer PCI Device for Windows 
> Update
>         Physical Slot: 6
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 5
>         Region 1: Memory at f3000000 (32-bit, prefetchable) [size=4M]
> 
> [7.6.] SCSI information (from /proc/scsi/scsi)
> Attached devices:
> 
> [7.7.] Other information that might be relevant to the problem
>        (please look in /proc and include all information that you
>        think to be relevant):
> 
> cat slabinfo
> 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> 
> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata 
> <active_slabs> <num_slabs> <sharedavail>
> ovl_inode           9408   9408    680   48    8 : tunables    0    0    0 
> : slabdata    196    196      0
> ext4_groupinfo_1k     60     60    136   60    2 : tunables    0    0    0 
> : slabdata      1      1      0
> nf_conntrack_expect      0      0    216   37    2 : tunables    0    0 0 
> : slabdata      0      0      0
> nf_conntrack        6783   6783    320   51    4 : tunables    0    0    0 
> : slabdata    133    133      0
> rpc_inode_cache      102    102    640   51    8 : tunables    0    0    0 
> : slabdata      2      2      0
> ext4_groupinfo_4k   3248   3248    144   56    2 : tunables    0    0    0 
> : slabdata     58     58      0
> btrfs_delayed_ref_head      0      0    152   53    2 : tunables    0    0 
>    0 : slabdata      0      0      0
> btrfs_delayed_node      0      0    296   55    4 : tunables    0    0 0 : 
> slabdata      0      0      0
> btrfs_ordered_extent      0      0    416   39    4 : tunables    0    0  
> 0 : slabdata      0      0      0
> btrfs_extent_map       0      0    144   56    2 : tunables    0    0    0 
> : slabdata      0      0      0
> btrfs_extent_buffer      0      0    280   58    4 : tunables    0    0 0 
> : slabdata      0      0      0
> btrfs_path             0      0    112   36    1 : tunables    0    0    0 
> : slabdata      0      0      0
> btrfs_inode            0      0   1136   28    8 : tunables    0    0    0 
> : slabdata      0      0      0
> PINGv6                 0      0   1152   28    8 : tunables    0    0    0 
> : slabdata      0      0      0
> RAWv6               2184   2408   1152   28    8 : tunables    0    0    0 
> : slabdata     86     86      0
> UDPv6               4037   4175   1280   25    8 : tunables    0    0    0 
> : slabdata    167    167      0
> tw_sock_TCPv6       2176   2176    240   68    4 : tunables    0    0    0 
> : slabdata     32     32      0
> request_sock_TCPv6      0      0    304   53    4 : tunables    0    0 0 : 
> slabdata      0      0      0
> TCPv6               2716   2716   2304   14    8 : tunables    0    0    0 
> : slabdata    194    194      0
> kcopyd_job             0      0   3312    9    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dm_uevent              0      0   2632   12    8 : tunables    0    0    0 
> : slabdata      0      0      0
> scsi_sense_cache       0      0    128   64    2 : tunables    0    0    0 
> : slabdata      0      0      0
> cfq_io_cq              0      0    120   68    2 : tunables    0    0    0 
> : slabdata      0      0      0
> mqueue_inode_cache    544    544    960   34    8 : tunables    0    0 0 : 
> slabdata     16     16      0
> fuse_request         640    640    400   40    4 : tunables    0    0    0 
> : slabdata     16     16      0
> fuse_inode          7566   7566    832   39    8 : tunables    0    0    0 
> : slabdata    194    194      0
> ecryptfs_key_record_cache      0      0    576   56    8 : tunables    0  
> 0    0 : slabdata      0      0      0
> ecryptfs_headers       8      8   4096    8    8 : tunables    0    0    0 
> : slabdata      1      1      0
> ecryptfs_inode_cache      0      0    960   34    8 : tunables    0    0  
> 0 : slabdata      0      0      0
> ecryptfs_dentry_info_cache    128    128     32  128    1 : tunables    0  
>  0    0 : slabdata      1      1      0
> ecryptfs_file_cache      0      0     16  256    1 : tunables    0    0 0 
> : slabdata      0      0      0
> ecryptfs_auth_tok_list_item      0      0    832   39    8 : tunables    0 
>    0    0 : slabdata      0      0      0
> fat_inode_cache        0      0    736   44    8 : tunables    0    0    0 
> : slabdata      0      0      0
> fat_cache              0      0     40  102    1 : tunables    0    0    0 
> : slabdata      0      0      0
> squashfs_inode_cache     92     92    704   46    8 : tunables    0    0  
> 0 : slabdata      2      2      0
> jbd2_journal_head  12376  12376    120   68    2 : tunables    0    0    0 
> : slabdata    182    182      0
> jbd2_revoke_table_s    768    768     16  256    1 : tunables    0    0 0 
> : slabdata      3      3      0
> ext4_inode_cache   73909  82020   1080   30    8 : tunables    0    0    0 
> : slabdata   2734   2734      0
> ext4_allocation_context   1024   1024    128   64    2 : tunables    0 0  
> 0 : slabdata     16     16      0
> ext4_io_end         1984   1984     64   64    1 : tunables    0    0    0 
> : slabdata     31     31      0
> ext4_extent_status  82192  83130     40  102    1 : tunables    0    0 0 : 
> slabdata    815    815      0
> mbcache             5548   5548     56   73    1 : tunables    0    0    0 
> : slabdata     76     76      0
> fscrypt_info        7680   7680     32  128    1 : tunables    0    0    0 
> : slabdata     60     60      0
> fscrypt_ctx         1360   1360     48   85    1 : tunables    0    0    0 
> : slabdata     16     16      0
> userfaultfd_ctx_cache      0      0    192   42    2 : tunables    0    0  
>  0 : slabdata      0      0      0
> dnotify_struct         0      0     32  128    1 : tunables    0    0    0 
> : slabdata      0      0      0
> posix_timers_cache    544    544    240   68    4 : tunables    0    0 0 : 
> slabdata      8      8      0
> UNIX                8544   8544   1024   32    8 : tunables    0    0    0 
> : slabdata    267    267      0
> ip4-frags            624    624    208   39    2 : tunables    0    0    0 
> : slabdata     16     16      0
> secpath_cache       1024   1024    128   64    2 : tunables    0    0    0 
> : slabdata     16     16      0
> xfrm_dst_cache         0      0    320   51    4 : tunables    0    0    0 
> : slabdata      0      0      0
> xfrm_state             0      0    768   42    8 : tunables    0    0    0 
> : slabdata      0      0      0
> PING                   0      0    960   34    8 : tunables    0    0    0 
> : slabdata      0      0      0
> RAW                 6086   6392    960   34    8 : tunables    0    0    0 
> : slabdata    188    188      0
> tw_sock_TCP         2176   2176    240   68    4 : tunables    0    0    0 
> : slabdata     32     32      0
> request_sock_TCP     901    901    304   53    4 : tunables    0    0    0 
> : slabdata     17     17      0
> TCP                 1605   1605   2176   15    8 : tunables    0    0    0 
> : slabdata    107    107      0
> hugetlbfs_inode_cache    104    104    624   52    8 : tunables    0    0  
>  0 : slabdata      2      2      0
> dquot               1024   1024    256   64    4 : tunables    0    0    0 
> : slabdata     16     16      0
> eventpoll_pwq      25984  25984     72   56    1 : tunables    0    0    0 
> : slabdata    464    464      0
> inotify_inode_mark   3978   3978     80   51    1 : tunables    0    0 0 : 
> slabdata     78     78      0
> dax_cache             42     42    768   42    8 : tunables    0    0    0 
> : slabdata      1      1      0
> request_queue         39     39   2480   13    8 : tunables    0    0    0 
> : slabdata      3      3      0
> blkdev_requests       52     52    312   52    4 : tunables    0    0    0 
> : slabdata      1      1      0
> biovec-max           300    304   8192    4    8 : tunables    0    0    0 
> : slabdata     76     76      0
> biovec-128            32     32   2048   16    8 : tunables    0    0    0 
> : slabdata      2      2      0
> biovec-64            512    512   1024   32    8 : tunables    0    0    0 
> : slabdata     16     16      0
> dmaengine-unmap-256     15     15   2112   15    8 : tunables    0    0 0 
> : slabdata      1      1      0
> dmaengine-unmap-128     30     30   1088   30    8 : tunables    0    0 0 
> : slabdata      1      1      0
> dmaengine-unmap-16  13860  13860    192   42    2 : tunables    0    0 0 : 
> slabdata    330    330      0
> dmaengine-unmap-2   3072   3072     64   64    1 : tunables    0    0    0 
> : slabdata     48     48      0
> sock_inode_cache   26914  27232    704   46    8 : tunables    0    0    0 
> : slabdata    592    592      0
> skbuff_fclone_cache   1216   1216    512   64    8 : tunables    0    0 0 
> : slabdata     19     19      0
> skbuff_head_cache  33488  34368    256   64    4 : tunables    0    0    0 
> : slabdata    537    537      0
> file_lock_cache      640    640    200   40    2 : tunables    0    0    0 
> : slabdata     16     16      0
> fsnotify_mark_connector   2720   2720     24  170    1 : tunables    0 0  
> 0 : slabdata     16     16      0
> net_namespace        180    185   6336    5    8 : tunables    0    0    0 
> : slabdata     37     37      0
> shmem_inode_cache  17822  18400    704   46    8 : tunables    0    0    0 
> : slabdata    400    400      0
> taskstats            784    784    328   49    4 : tunables    0    0    0 
> : slabdata     16     16      0
> proc_dir_entry      8603   8694    192   42    2 : tunables    0    0    0 
> : slabdata    207    207      0
> pde_opener         22848  22848     40  102    1 : tunables    0    0    0 
> : slabdata    224    224      0
> proc_inode_cache   49963  51888    672   48    8 : tunables    0    0    0 
> : slabdata   1081   1081      0
> sigqueue             816    816    160   51    2 : tunables    0    0    0 
> : slabdata     16     16      0
> bdev_cache           312    312    832   39    8 : tunables    0    0    0 
> : slabdata      8      8      0
> kernfs_node_cache 7775161 7775400    136   60    2 : tunables    0    0 0 
> : slabdata 129590 129590      0
> mnt_cache           5215   5250    384   42    4 : tunables    0    0    0 
> : slabdata    125    125      0
> filp              167618 171136    256   64    4 : tunables    0    0    0 
> : slabdata   2674   2674      0
> inode_cache       5517103 5523174    600   54    8 : tunables    0    0 0 
> : slabdata 102281 102281      0
> dentry            14733403 14827218    192   42    2 : tunables    0    0  
>  0 : slabdata 353029 353029      0
> names_cache          296    296   4096    8    8 : tunables    0    0    0 
> : slabdata     37     37      0
> iint_cache             0      0    120   68    2 : tunables    0    0    0 
> : slabdata      0      0      0
> buffer_head       2184093 2604927    104   39    1 : tunables    0    0 0 
> : slabdata  66793  66793      0
> uts_namespace        592    592    440   37    4 : tunables    0    0    0 
> : slabdata     16     16      0
> nsproxy             1752   1752     56   73    1 : tunables    0    0    0 
> : slabdata     24     24      0
> vm_area_struct    108257 109080    200   40    2 : tunables    0    0    0 
> : slabdata   2727   2727      0
> mm_struct           9330   9330   1088   30    8 : tunables    0    0    0 
> : slabdata    311    311      0
> files_cache        11040  11040    704   46    8 : tunables    0    0    0 
> : slabdata    240    240      0
> signal_cache       12270  12270   1088   30    8 : tunables    0    0    0 
> : slabdata    409    409      0
> sighand_cache       4780   4800   2112   15    8 : tunables    0    0    0 
> : slabdata    320    320      0
> task_struct         3625   3815   5888    5    8 : tunables    0    0    0 
> : slabdata    763    763      0
> cred_jar           56532  56532    192   42    2 : tunables    0    0    0 
> : slabdata   1346   1346      0
> anon_vma_chain    130241 132096     64   64    1 : tunables    0    0    0 
> : slabdata   2064   2064      0
> anon_vma           83964  84364     88   46    1 : tunables    0    0    0 
> : slabdata   1834   1834      0
> pid                41603  41728    128   64    2 : tunables    0    0    0 
> : slabdata    652    652      0
> Acpi-Operand        4256   4256     72   56    1 : tunables    0    0    0 
> : slabdata     76     76      0
> Acpi-ParseExt        624    624    104   39    1 : tunables    0    0    0 
> : slabdata     16     16      0
> Acpi-State           459    459     80   51    1 : tunables    0    0    0 
> : slabdata      9      9      0
> Acpi-Namespace      4284   4284     40  102    1 : tunables    0    0    0 
> : slabdata     42     42      0
> numa_policy          186    186    264   62    4 : tunables    0    0    0 
> : slabdata      3      3      0
> trace_event_file    2116   2116     88   46    1 : tunables    0    0    0 
> : slabdata     46     46      0
> ftrace_event_field  24294  25670     48   85    1 : tunables    0    0 0 : 
> slabdata    302    302      0
> pool_workqueue      4736   4736    256   64    4 : tunables    0    0    0 
> : slabdata     74     74      0
> radix_tree_node   2679706 2689960    584   56    8 : tunables    0    0 0 
> : slabdata  48035  48035      0
> task_group           816    816    640   51    8 : tunables    0    0    0 
> : slabdata     16     16      0
> dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-1024       0      0   1024   32    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-512        0      0    512   64    8 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-256        0      0    256   64    4 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-128        0      0    128   64    2 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-192        0      0    192   42    2 : tunables    0    0    0 
> : slabdata      0      0      0
> dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 
> : slabdata      0      0      0
> kmalloc-8192         827    844   8192    4    8 : tunables    0    0    0 
> : slabdata    211    211      0
> kmalloc-4096        7301   8208   4096    8    8 : tunables    0    0    0 
> : slabdata   1026   1026      0
> kmalloc-2048        9739  13440   2048   16    8 : tunables    0    0    0 
> : slabdata    840    840      0
> kmalloc-1024       20177  22272   1024   32    8 : tunables    0    0    0 
> : slabdata    696    696      0
> kmalloc-512        62892  94464    512   64    8 : tunables    0    0    0 
> : slabdata   1476   1476      0
> kmalloc-256        22049  25024    256   64    4 : tunables    0    0    0 
> : slabdata    391    391      0
> kmalloc-192       1296144 1296918    192   42    2 : tunables    0    0 0 
> : slabdata  30879  30879      0
> kmalloc-128       7230544 7231680    128   64    2 : tunables    0    0 0 
> : slabdata 112995 112995      0
> kmalloc-96        8202597 8204952     96   42    1 : tunables    0    0 0 
> : slabdata 195356 195356      0
> kmalloc-64        2169882 2190016     64   64    1 : tunables    0    0 0 
> : slabdata  34219  34219      0
> kmalloc-32        147668 303872     32  128    1 : tunables    0    0    0 
> : slabdata   2374   2374      0
> kmalloc-16        156395 170496     16  256    1 : tunables    0    0    0 
> : slabdata    666    666      0
> kmalloc-8         131584 131584      8  512    1 : tunables    0    0    0 
> : slabdata    257    257      0
> kmem_cache_node    74067  74880     64   64    1 : tunables    0    0    0 
> : slabdata   1170   1170      0
> kmem_cache         73491  74004    384   42    4 : tunables    0    0    0 
> : slabdata   1762   1762      0
> 
> cat meminfo
> MemTotal:       32910232 kB
> MemFree:         6742744 kB
> MemAvailable:   25470032 kB
> Buffers:          947924 kB
> Cached:          8611528 kB
> SwapCached:            0 kB
> Active:          5668624 kB
> Inactive:        5374688 kB
> Active(anon):    1488612 kB
> Inactive(anon):      620 kB
> Active(file):    4180012 kB
> Inactive(file):  5374068 kB
> Unevictable:        5408 kB
> Mlocked:            5408 kB
> SwapTotal:             0 kB
> SwapFree:              0 kB
> Dirty:               520 kB
> Writeback:             0 kB
> AnonPages:       1478048 kB
> Mapped:           305152 kB
> Shmem:              1164 kB
> Slab:           11596304 kB
> SReclaimable:    8061752 kB
> SUnreclaim:      3534552 kB
> KernelStack:       14800 kB
> PageTables:        13676 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    16455116 kB
> Committed_AS:    3378396 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> Percpu:          3316224 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:     10240 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> CmaTotal:              0 kB
> CmaFree:               0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> Hugetlb:               0 kB
> DirectMap4k:      387072 kB
> DirectMap2M:    27920384 kB
> DirectMap1G:     6291456 kB
> 
> 
> 
> 
> Dan McGinnes
> 
> IBM Cloud - Containers performance
> 
> Int Tel: 247359        Ext Tel: 01962 817359
> 
> Notes: Daniel McGinnes/UK/IBM
> Email: MCGINNES@uk.ibm.com
> 
> IBM (UK) Ltd, Hursley Park,Winchester,Hampshire, SO21 2JN
> Unless stated otherwise above:
> IBM United Kingdom Limited - Registered in England and Wales with number 
> 741598. 
> Registered office: PO Box 41, North Harbour, Portsmouth, Hampshire PO6 3AU
