Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE6B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:55:39 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b186so722865wmc.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:55:38 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::5])
        by mx.google.com with ESMTPS id g19si56144554wrh.190.2019.01.15.02.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 02:55:36 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
 <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
 <20181213112511.GA4574@lst.de>
 <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de>
 <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
 <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
 <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
 <20190103073622.GA24323@lst.de>
 <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de>
 <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de>
 <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de>
 <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de>
 <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de>
 <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
 <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
Message-ID: <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
Date: Tue, 15 Jan 2019 11:55:25 +0100
MIME-Version: 1.0
In-Reply-To: <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Next step: 21074ef03c0816ae158721a78cabe9035938dddd (powerpc/dma: use 
the generic direct mapping bypass)

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout 21074ef03c0816ae158721a78cabe9035938dddd

I was able to compile the kernel for the AmigaOne X1000 (Nemo board with 
PA Semi PA6T-1682M SoC). It boots but the PA Semi onboard ethernet 
doesn't work.

dmesg:

[   12.698063] pasemi_mac 0000:00:14.3 enp0s20f3: renamed from eth0
[   16.516966] IPv6: ADDRCONF(NETDEV_UP): enp0s20f3: link is not ready
[   16.521025] pci 0000:00:1a.0: overflow 0x000000026a587802+1646 of DMA 
mask ffffffff bus mask 0
[   16.521047] WARNING: CPU: 0 PID: 2318 at kernel/dma/direct.c:43 
.dma_direct_map_page+0x11c/0x200
[   16.521049] Modules linked in:
[   16.521056] CPU: 0 PID: 2318 Comm: NetworkManager Not tainted 
5.0.0-rc2-2_A-EON_AmigaOne_X1000_Nemo-54576-g21074ef-dirty #1
[   16.521059] NIP:  c00000000010395c LR: c000000000103a30 CTR: 
0000000000000000
[   16.521062] REGS: c00000026a1a29a0 TRAP: 0700   Not tainted 
(5.0.0-rc2-2_A-EON_AmigaOne_X1000_Nemo-54576-g21074ef-dirty)
[   16.521064] MSR:  900000000202b032 <SF,HV,VEC,EE,FP,ME,IR,DR,RI>  CR: 
22002442  XER: 20000000
[   16.521074] IRQMASK: 0
                GPR00: c000000000103a30 c00000026a1a2c30 
c000000001923f00 0000000000000052
                GPR04: c00000026f206778 c00000026f20d458 
c000000001ab1178 7063693a30303030
                GPR08: 0000000000000007 0000000000000000 
0000000000000000 0000000000000010
                GPR12: 3a30303a31612e30 c000000001b10000 
0000000000a79020 0000000000ace140
                GPR16: 00000000fffdd958 0000000000000000 
0000000000000000 c00000026be92220
                GPR20: 0000000000000000 c00000026a470000 
0000000000000000 0000000000000000
                GPR24: 0000000000000800 c00000026a1c0000 
c00000026bc69280 c00000026a1c0000
                GPR28: c000000277b1f588 000000000000066e 
c00000026d3c68b0 0000000000000802
[   16.521111] NIP [c00000000010395c] .dma_direct_map_page+0x11c/0x200
[   16.521114] LR [c000000000103a30] .dma_direct_map_page+0x1f0/0x200
[   16.521116] Call Trace:
[   16.521120] [c00000026a1a2c30] [c000000000103a30] 
.dma_direct_map_page+0x1f0/0x200 (unreliable)
[   16.521126] [c00000026a1a2cd0] [c00000000099b84c] 
.pasemi_mac_replenish_rx_ring+0x12c/0x2a0
[   16.521131] [c00000026a1a2da0] [c00000000099dcc4] 
.pasemi_mac_open+0x384/0x7c0
[   16.521137] [c00000026a1a2e40] [c000000000c6f4e4] .__dev_open+0x134/0x1e0
[   16.521142] [c00000026a1a2ee0] [c000000000c6fa4c] 
.__dev_change_flags+0x1bc/0x210
[   16.521147] [c00000026a1a2f90] [c000000000c6fae8] 
.dev_change_flags+0x48/0xa0
[   16.521153] [c00000026a1a3030] [c000000000c8c8ec] .do_setlink+0x3dc/0xf60
[   16.521158] [c00000026a1a31b0] [c000000000c8dde4] 
.__rtnl_newlink+0x5e4/0x900
[   16.521163] [c00000026a1a35f0] [c000000000c8e16c] .rtnl_newlink+0x6c/0xb0
[   16.521167] [c00000026a1a3680] [c000000000c89898] 
.rtnetlink_rcv_msg+0x2e8/0x3d0
[   16.521172] [c00000026a1a3760] [c000000000cc0ff0] 
.netlink_rcv_skb+0x120/0x170
[   16.521177] [c00000026a1a3820] [c000000000c87378] 
.rtnetlink_rcv+0x28/0x40
[   16.521181] [c00000026a1a38a0] [c000000000cc0458] 
.netlink_unicast+0x208/0x2f0
[   16.521186] [c00000026a1a3950] [c000000000cc0a08] 
.netlink_sendmsg+0x348/0x460
[   16.521190] [c00000026a1a3a30] [c000000000c387d4] .sock_sendmsg+0x44/0x70
[   16.521195] [c00000026a1a3ab0] [c000000000c3a7fc] 
.___sys_sendmsg+0x30c/0x320
[   16.521199] [c00000026a1a3ca0] [c000000000c3c414] 
.__sys_sendmsg+0x74/0xf0
[   16.521204] [c00000026a1a3d90] [c000000000cb4e00] 
.__se_compat_sys_sendmsg+0x40/0x60
[   16.521210] [c00000026a1a3e20] [c00000000000a21c] system_call+0x5c/0x70
[   16.521212] Instruction dump:
[   16.521215] 60000000 f8610070 3d20ffff 6129fffe 79290020 e8e70000 
7fa74840 409d00b8
[   16.521222] 3d420001 892acb59 2f890000 419e00b8 <0fe00000> 382100a0 
3860ffff e8010010
[   16.521231] ---[ end trace 2129e4121bbdd0e9 ]---

I wasn't able to compile it for the AmigaOne X5000 (Cyrus+ board with 
Qoriq P5020 SoC). Error message:

CALL    scripts/checksyscalls.sh
   CHK     include/generated/compile.h
   CC      arch/powerpc/sysdev/fsl_pci.o
arch/powerpc/sysdev/fsl_pci.c: In function 'fsl_pci_dma_set_mask':
arch/powerpc/sysdev/fsl_pci.c:142:21: error: 'dma_nommu_ops' undeclared 
(first use in this function)
    set_dma_ops(dev, &dma_nommu_ops);
                      ^
arch/powerpc/sysdev/fsl_pci.c:142:21: note: each undeclared identifier 
is reported only once for each function it appears in
scripts/Makefile.build:276: recipe for target 
'arch/powerpc/sysdev/fsl_pci.o' failed
make[2]: *** [arch/powerpc/sysdev/fsl_pci.o] Error 1
scripts/Makefile.build:492: recipe for target 'arch/powerpc/sysdev' failed
make[1]: *** [arch/powerpc/sysdev] Error 2
Makefile:1049: recipe for target 'arch/powerpc' failed
make: *** [arch/powerpc] Error 2

-- Christian


On 15 January 2019 at 09:49AM, Christian Zigotzky wrote:
> Next step: 63a6e350e037a21e9a88c8b710129bea7049a80f (powerpc/dma: use 
> the dma_direct mapping routines)
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> git checkout 63a6e350e037a21e9a88c8b710129bea7049a80f
>
> Error message:
>
> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x0): undefined reference to 
> `__dma_nommu_alloc_coherent'
> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x8): undefined reference to 
> `__dma_nommu_free_coherent'
> Makefile:1027: recipe for target 'vmlinux' failed
> make: *** [vmlinux] Error 1
>
> -- Christian
>
>
> On 15 January 2019 at 09:07AM, Christian Zigotzky wrote:
>> Next step: 240d7ecd7f6fa62e074e8a835e620047954f0b28 (powerpc/dma: use 
>> the dma-direct allocator for coherent platforms)
>>
>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>
>> git checkout 240d7ecd7f6fa62e074e8a835e620047954f0b28
>>
>> Link to the Git: 
>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>
>> env LANG=C make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc zImage
>>
>> Error message:
>>
>> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x0): undefined reference to 
>> `__dma_nommu_alloc_coherent'
>> arch/powerpc/kernel/dma.o:(.data.rel.ro+0x8): undefined reference to 
>> `__dma_nommu_free_coherent'
>> Makefile:1027: recipe for target 'vmlinux' failed
>> make: *** [vmlinux] Error 1
>>
>> -- Christian
>>
>>
>> On 12 January 2019 at 7:14PM, Christian Zigotzky wrote:
>>> Next step: 4558b6e1ddf3dcf5a86d6a5d16c2ac1600c7df39 (swiotlb: remove 
>>> swiotlb_dma_supported)
>>>
>>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>>
>>> git checkout 4558b6e1ddf3dcf5a86d6a5d16c2ac1600c7df39
>>>
>>> Output:
>>>
>>> You are in 'detached HEAD' state. You can look around, make 
>>> experimental
>>> changes and commit them, and you can discard any commits you make in 
>>> this
>>> state without impacting any branches by performing another checkout.
>>>
>>> If you want to create a new branch to retain commits you create, you 
>>> may
>>> do so (now or later) by using -b with the checkout command again. 
>>> Example:
>>>
>>>   git checkout -b <new-branch-name>
>>>
>>> HEAD is now at 4558b6e... swiotlb: remove swiotlb_dma_supported
>>>
>>> ----
>>>
>>> Link to the Git: 
>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>
>>> Results: PASEMI onboard ethernet (X1000) works and the X5000 (P5020 
>>> board) boots. I also successfully tested sound, hardware 3D 
>>> acceleration, Bluetooth, network, booting with a label etc. The 
>>> uImages work also in a virtual e5500 quad-core QEMU machine.
>>>
>>> -- Christian
>>>
>>>
>>> On 11 January 2019 at 03:10AM, Christian Zigotzky wrote:
>>>> Next step: 891dcc1072f1fa27a83da920d88daff6ca08fc02 (powerpc/dma: 
>>>> remove dma_nommu_dma_supported)
>>>>
>>>> git clone git://git.infradead.org/users/hch/misc.git -b 
>>>> powerpc-dma.6 a
>>>>
>>>> git checkout 891dcc1072f1fa27a83da920d88daff6ca08fc02
>>>>
>>>> Output:
>>>>
>>>> Note: checking out '891dcc1072f1fa27a83da920d88daff6ca08fc02'.
>>>>
>>>> You are in 'detached HEAD' state. You can look around, make 
>>>> experimental
>>>> changes and commit them, and you can discard any commits you make 
>>>> in this
>>>> state without impacting any branches by performing another checkout.
>>>>
>>>> If you want to create a new branch to retain commits you create, 
>>>> you may
>>>> do so (now or later) by using -b with the checkout command again. 
>>>> Example:
>>>>
>>>> git checkout -b <new-branch-name>
>>>>
>>>> HEAD is now at 891dcc1... powerpc/dma: remove dma_nommu_dma_supported
>>>>
>>>> ---
>>>>
>>>> Link to the Git: 
>>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>>
>>>> Results: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>>> boots. I also successfully tested sound, hardware 3D acceleration, 
>>>> Bluetooth, network, booting with a label etc. The uImages work also 
>>>> in a virtual e5500 quad-core QEMU machine.
>>>>
>>>> -- Christian
>>>>
>>>>
>>>> On 09 January 2019 at 10:31AM, Christian Zigotzky wrote:
>>>>> Next step: a64e18ba191ba9102fb174f27d707485ffd9389c (powerpc/dma: 
>>>>> remove dma_nommu_get_required_mask)
>>>>>
>>>>> git clone git://git.infradead.org/users/hch/misc.git -b 
>>>>> powerpc-dma.6 a
>>>>>
>>>>> git checkout a64e18ba191ba9102fb174f27d707485ffd9389c
>>>>>
>>>>> Link to the Git: 
>>>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>>>
>>>>> Results: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>>>> boots. I also successfully tested sound, hardware 3D acceleration, 
>>>>> Bluetooth, network, booting with a label etc. The uImages work 
>>>>> also in a virtual e5500 quad-core QEMU machine.
>>>>>
>>>>> -- Christian
>>>>>
>>>>>
>>>>> On 05 January 2019 at 5:03PM, Christian Zigotzky wrote:
>>>>>> Next step: c446404b041130fbd9d1772d184f24715cf2362f (powerpc/dma: 
>>>>>> remove dma_nommu_mmap_coherent)
>>>>>>
>>>>>> git clone git://git.infradead.org/users/hch/misc.git -b 
>>>>>> powerpc-dma.6 a
>>>>>>
>>>>>> git checkout c446404b041130fbd9d1772d184f24715cf2362f
>>>>>>
>>>>>> Output:
>>>>>>
>>>>>> Note: checking out 'c446404b041130fbd9d1772d184f24715cf2362f'.
>>>>>>
>>>>>> You are in 'detached HEAD' state. You can look around, make 
>>>>>> experimental
>>>>>> changes and commit them, and you can discard any commits you make 
>>>>>> in this
>>>>>> state without impacting any branches by performing another checkout.
>>>>>>
>>>>>> If you want to create a new branch to retain commits you create, 
>>>>>> you may
>>>>>> do so (now or later) by using -b with the checkout command again. 
>>>>>> Example:
>>>>>>
>>>>>>   git checkout -b <new-branch-name>
>>>>>>
>>>>>> HEAD is now at c446404... powerpc/dma: remove 
>>>>>> dma_nommu_mmap_coherent
>>>>>>
>>>>>> -----
>>>>>>
>>>>>> Link to the Git: 
>>>>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>>>>
>>>>>> Result: PASEMI onboard ethernet works and the X5000 (P5020 board) 
>>>>>> boots.
>>>>>>
>>>>>> -- Christian
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
>
