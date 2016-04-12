Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEEB6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:03:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id td3so14203863pab.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:03:50 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 8si10470861pad.28.2016.04.12.07.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 07:03:48 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id r187so1554854pfr.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:03:48 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <570B10B2.2000000@hisilicon.com>
Date: Tue, 12 Apr 2016 23:03:41 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <BB685A51-165C-424C-8359-58F7F3E379B7@gmail.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com> <20160407142148.GI5657@arm.com> <570B10B2.2000000@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Will Deacon <will.deacon@arm.com>, mhocko@suse.com, Laura Abbott <labbott@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, ard.biesheuvel@linaro.org, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, rientjes@google.com, linux-mm@kvack.org, puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

On Apr 11, 2016, at 11:49 AM, Chen Feng wrote:

Dear Chen,

> Hi will,
> Thanks for review.
>=20
> On 2016/4/7 22:21, Will Deacon wrote:
>> On Tue, Apr 05, 2016 at 04:22:51PM +0800, Chen Feng wrote:
>>> We can reduce the memory allocated at mem-map
>>> by flatmem.
>>>=20
>>> currently, the default memory-model in arm64 is
>>> sparse memory. The mem-map array is not freed in
>>> this scene. If the physical address is too long,
>>> it will reserved too much memory for the mem-map
>>> array.
>>=20
>> Can you elaborate a bit more on this, please? We use the vmemmap, so =
any
>> spaces between memory banks only burns up virtual space. What exactly =
is
>> the problem you're seeing that makes you want to use flatmem (which =
is
>> probably unsuitable for the majority of arm64 machines).
>>=20
> The root cause we want to use flat-mem is the mam_map alloced in =
sparse-mem
> is not freed.
>=20
> take a look at here:
> arm64/mm/init.c
> void __init mem_init(void)
> {
> #ifndef CONFIG_SPARSEMEM_VMEMMAP
> 	free_unused_memmap();
> #endif
> }
>=20
> Memory layout (3GB)
>=20
> 0             1.5G    2G             3.5G            4G
> |              |      |               |              |
> +--------------+------+---------------+--------------+
> |    MEM       | hole |     MEM       |   IO (regs)  |
> +--------------+------+---------------+--------------+
>=20
>=20
> Memory layout (4GB)
>=20
> 0                                    3.5G            4G    4.5G
> |                                     |              |       |
> +-------------------------------------+--------------+-------+
> |                   MEM               |   IO (regs)  |  MEM  |
> +-------------------------------------+--------------+-------+
>=20
> Currently, the sparse memory section is 1GB.
>=20
> 3GB ddr: the 1.5 ~2G and 3.5 ~ 4G are holes.
> 3GB ddr: the 3.5 ~ 4G and 4.5 ~ 5G are holes.
>=20
> This will alloc 1G/4K * (struct page) memory for mem_map array.
>=20
> We want to use flat-mem to reduce the alloced mem_map.
>=20
> I don't know why you tell us the flatmem is unsuitable for the
> majority of arm64 machines. Can tell us the reason of it?
>=20
> And we are not going to limit the memdel in arm64, we just want to
> make the flat-mem is an optional item in arm64.

I've experienced the same problem and considered the ideas mentioned
in this thread: flatmem and small SECTION_SIZE_BITS. However, I was
reluctant to post any patch since the issue is highly related to memory
map design document, [1], saying 1GB aligned RAM. The majority of arm64
platforms might follow the information although it is not spec. IOW,
a machine I've played was at least unusual *at that time*, so I didn't
consider upstream work.

[1] =
http://infocenter.arm.com/help/topic/com.arm.doc.den0001c/DEN0001C_princip=
les_of_arm_memory_maps.pdf =20

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
