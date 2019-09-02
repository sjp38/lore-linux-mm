Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28636C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 15:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDCF0217D7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 15:18:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDCF0217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D3A16B0003; Mon,  2 Sep 2019 11:18:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15D4A6B0006; Mon,  2 Sep 2019 11:18:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3FE16B0007; Mon,  2 Sep 2019 11:18:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id CD3236B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:18:38 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6050D68A9
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 15:18:38 +0000 (UTC)
X-FDA: 75890337516.17.twist40_4b5ba5933b51f
X-HE-Tag: twist40_4b5ba5933b51f
X-Filterd-Recvd-Size: 10248
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 15:18:37 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x82FCEBt035971
	for <linux-mm@kvack.org>; Mon, 2 Sep 2019 11:18:37 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2us4jaa2qe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 02 Sep 2019 11:18:36 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 2 Sep 2019 16:18:34 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 2 Sep 2019 16:18:26 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x82FI1cc20119894
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 2 Sep 2019 15:18:01 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3E679AE055;
	Mon,  2 Sep 2019 15:18:24 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0E5B0AE051;
	Mon,  2 Sep 2019 15:18:22 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.160])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon,  2 Sep 2019 15:18:21 +0000 (GMT)
Date: Mon, 2 Sep 2019 18:18:20 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Simek <monstr@monstr.eu>
Cc: Michal Hocko <mhocko@kernel.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
        Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>,
        "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Will Deacon <will@kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "x86@kernel.org" <x86@kernel.org>,
        "willy@infradead.org" <willy@infradead.org>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>,
        Hoan Tran OS <hoan@os.amperecomputing.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Open Source Submission <patches@amperecomputing.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>,
        Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>,
        Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>,
        "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "David S . Miller" <davem@davemloft.net>,
        Randy Dunlap <rdunlap@infradead.org>
Subject: Re: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2
 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
References: <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
 <20190731122631.GB14538@rapoport-lnx>
 <20190731130037.GN9330@dhcp22.suse.cz>
 <20190731142129.GA24998@rapoport-lnx>
 <20190731144114.GY9330@dhcp22.suse.cz>
 <20190731171510.GB24998@rapoport-lnx>
 <f57f15b5-dee7-c2be-5a34-192a9ecf0763@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f57f15b5-dee7-c2be-5a34-192a9ecf0763@monstr.eu>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19090215-0008-0000-0000-000003101CE3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090215-0009-0000-0000-00004A2E6B76
Message-Id: <20190902151819.GA13793@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-02_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=540 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909020172
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 03:51:25PM +0200, Michal Simek wrote:
> On 31. 07. 19 19:15, Mike Rapoport wrote:
> > On Wed, Jul 31, 2019 at 04:41:14PM +0200, Michal Hocko wrote:
> >> On Wed 31-07-19 17:21:29, Mike Rapoport wrote:
> >>> On Wed, Jul 31, 2019 at 03:00:37PM +0200, Michal Hocko wrote:
> >>>>
> >>>> I am sorry, but I still do not follow. Who is consuming that node id
> >>>> information when NUMA=n. In other words why cannot we simply do
> >>>  
> >>> We can, I think nobody cared to change it.
> >>
> >> It would be great if somebody with the actual HW could try it out.
> >> I can throw a patch but I do not even have a cross compiler in my
> >> toolbox.
> > 
> > Well, it compiles :)
> >  
> >>>> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> >>>> index a015a951c8b7..3a47e8db8d1c 100644
> >>>> --- a/arch/microblaze/mm/init.c
> >>>> +++ b/arch/microblaze/mm/init.c
> >>>> @@ -175,14 +175,9 @@ void __init setup_memory(void)
> >>>>  
> >>>>  		start_pfn = memblock_region_memory_base_pfn(reg);
> >>>>  		end_pfn = memblock_region_memory_end_pfn(reg);
> >>>> -		memblock_set_node(start_pfn << PAGE_SHIFT,
> >>>> -				  (end_pfn - start_pfn) << PAGE_SHIFT,
> >>>> -				  &memblock.memory, 0);
> >>>> +		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
> >>>
> >>> memory_present() expects pfns, the shift is not needed.
> >>
> >> Right.
> 
> Sorry for slow response on this. In general regarding this topic.
> Microblaze is soft core CPU (now there are hardcore versions too but not
> running Linux). I believe there could be Numa system with
> microblaze/microblazes (SMP is not supported in mainline).
> 
> This code was added in 2011 which is pretty hard to remember why it was
> done in this way.
> 
> It compiles but not working on HW. Please take a look at log below.
> 
> Thanks,
> Michal
> 
> 
> [    0.000000] Linux version 5.3.0-rc6-00007-g54b01939182f-dirty
> (monstr@monstr-desktop3) (gcc version 8.2.0 (crosstool-NG 1.20.0)) #101
> Mon Sep 2 15:44:05 CEST 2019
> [    0.000000] setup_memory: max_mapnr: 0x40000
> [    0.000000] setup_memory: min_low_pfn: 0x80000
> [    0.000000] setup_memory: max_low_pfn: 0xb0000
> [    0.000000] setup_memory: max_pfn: 0xc0000
> [    0.000000] start pfn 0x80000
> [    0.000000] end pfn 0xc0000
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000080000000-0x00000000afffffff]
> [    0.000000]   Normal   empty
> [    0.000000]   HighMem  [mem 0x00000000b0000000-0x00000000bfffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   1: [mem 0x0000000080000000-0x00000000bfffffff]
> [    0.000000] Could not find start_pfn for node 0
> [    0.000000] Initmem setup node 0 [mem
> 0x0000000000000000-0x0000000000000000]

This does not look good :)

I think the problem is that without an explicit call to memblock_set_node()
the ->nid in memblock is MAX_NUMNODES but free_area_init_nodes() presumes
actual node ids are properly set.

> [    0.000000] earlycon: ns16550a0 at MMIO 0x44a01000 (options '115200n8')
> [    0.000000] printk: bootconsole [ns16550a0] enabled
> [    0.000000] setup_cpuinfo: initialising
> [    0.000000] setup_cpuinfo: Using full CPU PVR support
> [    0.000000] wt_msr_noirq
> [    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
> [    0.000000] pcpu-alloc: [0] 0
> [    0.000000] Built 1 zonelists, mobility grouping off.  Total pages: 0
> [    0.000000] Kernel command line: earlycon
> [    0.000000] Dentry cache hash table entries: -2147483648 (order: -13,
> 0 bytes, linear)
> [    0.000000] Inode-cache hash table entries: -2147483648 (order: -13,
> 0 bytes, linear)
> [    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
> [    0.000000] Oops: kernel access of bad area, sig: 11
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted
> 5.3.0-rc6-00007-g54b01939182f-dirty #101
> [    0.000000]  Registers dump: mode=805B9EA8
> [    0.000000]  r1=000065A0, r2=C05B7AE6, r3=00000000, r4=00000000
> [    0.000000]  r5=00080000, r6=00080B50, r7=00000000, r8=00000004
> [    0.000000]  r9=00000000, r10=0000001F, r11=00000000, r12=00006666
> [    0.000000]  r13=4119DCC0, r14=00000000, r15=C05EFF8C, r16=00000000
> [    0.000000]  r17=C0604408, r18=FFFC0000, r19=C05B9F6C, r20=BFFEC168
> [    0.000000]  r21=BFFEC168, r22=EFFF9AC0, r23=00000001, r24=C0606874
> [    0.000000]  r25=BFE6B74C, r26=80000000, r27=00000000, r28=90000040
> [    0.000000]  r29=01000000, r30=00000380, r31=C05C02F0, rPC=C0604408
> [    0.000000]  msr=000046A0, ear=00000004, esr=00000D12, fsr=FFFFFFFF
> [    0.000000] Oops: kernel access of bad area, sig: 11
> 
> 
> -- 
> Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel - Xilinx Microblaze
> Maintainer of Linux kernel - Xilinx Zynq ARM and ZynqMP ARM64 SoCs
> U-Boot custodian - Xilinx Microblaze/Zynq/ZynqMP/Versal SoCs
> 
> 




-- 
Sincerely yours,
Mike.


