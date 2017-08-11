Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89A756B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:50:03 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b20so48316971itd.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:50:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c82si1184718iof.148.2017.08.11.08.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 08:50:01 -0700 (PDT)
Subject: Re: [v6 04/15] mm: discard memblock data later
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6366171f-1a30-2faa-d776-01983fcb5a00@oracle.com>
Date: Fri, 11 Aug 2017 11:49:15 -0400
MIME-Version: 1.0
In-Reply-To: <20170811093249.GE30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

> I guess this goes all the way down to
> Fixes: 7e18adb4f80b ("mm: meminit: initialise remaining struct pages in parallel with kswapd")

I will add this to the patch.

>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> 
> Considering that some HW might behave strangely and this would be rather
> hard to debug I would be tempted to mark this for stable. It should also
> be merged separately from the rest of the series.
> 
> I have just one nit below
> Acked-by: Michal Hocko <mhocko@suse.com>

I will address your comment, and send out a new patch. Should I send it 
out separately from the series or should I keep it inside?

Also, before I send out a new patch, I will need to root cause and 
resolve problem found by kernel test robot <fengguang.wu@intel.com>, and 
bisected down to this patch.

[  156.659400] BUG: Bad page state in process swapper  pfn:03147
[  156.660051] page:ffff88001ed8a1c0 count:0 mapcount:-127 mapping: 
     (null) index:0x1
[  156.660917] flags: 0x0()
[  156.661198] raw: 0000000000000000 0000000000000000 0000000000000001 
00000000ffffff80
[  156.662006] raw: ffff88001f4a8120 ffff88001ed85ce0 0000000000000000 
0000000000000000
[  156.662811] page dumped because: nonzero mapcount
[  156.663307] CPU: 0 PID: 1 Comm: swapper Not tainted 
4.13.0-rc3-00220-g1aad694 #1
[  156.664077] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[  156.665129] Call Trace:
[  156.665422]  dump_stack+0x1e/0x20
[  156.665802]  bad_page+0x122/0x148

I was not able to reproduce this problem, even-though I used their qemu 
script and config. But I am getting the following panic both base and fix:

[  115.763259] VFS: Cannot open root device "ram0" or 
unknown-block(0,0): error -6
[  115.764511] Please append a correct "root=" boot option; here are the 
available partitions:
[  115.765816] Kernel panic - not syncing: VFS: Unable to mount root fs 
on unknown-block(0,0)
[  115.767124] CPU: 0 PID: 1 Comm: swapper Not tainted 
4.13.0-rc4_pt_memset6-00033-g7e65200b1473 #7
[  115.768506] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
[  115.770368] Call Trace:
[  115.770771]  dump_stack+0x1e/0x20
[  115.771310]  panic+0xf8/0x2bc
[  115.771792]  mount_block_root+0x3bb/0x441
[  115.772437]  ? do_early_param+0xc5/0xc5
[  115.773051]  ? do_early_param+0xc5/0xc5
[  115.773683]  mount_root+0x7c/0x7f
[  115.774243]  prepare_namespace+0x194/0x1d1
[  115.774898]  kernel_init_freeable+0x1c8/0x1df
[  115.775575]  ? rest_init+0x13f/0x13f
[  115.776153]  kernel_init+0x14/0x142
[  115.776711]  ? rest_init+0x13f/0x13f
[  115.777285]  ret_from_fork+0x2a/0x40
[  115.777864] Kernel Offset: disabled

Their config has CONFIG_BLK_DEV_RAM disabled, but qemu script has:
root=/dev/ram0, so I enabled dev_ram, but still getting a panic when 
root is mounted both in base and fix.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
