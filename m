Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE849C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 00:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32FAD2171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 00:39:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dU+cus5J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32FAD2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A35028E0003; Tue, 12 Mar 2019 20:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3648E0002; Tue, 12 Mar 2019 20:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D3468E0003; Tue, 12 Mar 2019 20:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1DE8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 20:39:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u19so130570pfn.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+hX026rpYJ/LrRtNbb8F5ij7BYrG6XmL8SylXJLPkuw=;
        b=q0dvzvzpXmI/H02fLulBOo73yZJE9dbL8RbF1AlB+pGJofI7hdRDD7Xh/Gb7CxqIQr
         K/vXlKH+gEEmRKBch8BJ8kqeggkUuzUsT78hsAjWcYt3N0sOmGOa375tqpWd4s/BFY7S
         RDnpDa3WamJYe0bns4eh5e9bSGseevYUhmt44UxxI5x73j6xaIkMdeVMkxM2NQQvK78d
         W1+hVfD5Jb8x8GK0pTRRuyavybKoqXzbeK5WrNVEsGBWGPtIx8x8tSFmtPDQ5QE2yWDF
         N0ZKKyD9YnODe68WkvG378m7jPoOgOx6klLvopkn86U4H6RtAyQyXu5zdtZ8YWtCxhaf
         8dRQ==
X-Gm-Message-State: APjAAAVyDWKuvR4NrpIXNGCnz7B9+lNkvaYbM6MEmw0cXIBoNAgrhqJX
	LzL6Glih/Rt7B1LEwiHbc877Cq4Kv2j3Wj32u73Rj4sPd83iimgCTLiTJ3GwPU7zNfDTT5gqUrv
	4a3qo6Jyt1xT31/gPa+D2zd/b4P9aUapBJrDUAr6Xt8f6M8y4omU2sz3Tc39q0f/LXw==
X-Received: by 2002:a17:902:968b:: with SMTP id n11mr42603294plp.316.1552437561823;
        Tue, 12 Mar 2019 17:39:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHsu7iqo+2CTQiu2OIkQM0UaUTwF5pDMjfLzKf48TVVmoIc9k/PRvXTvATcEr/mxj0LWyB
X-Received: by 2002:a17:902:968b:: with SMTP id n11mr42603219plp.316.1552437560492;
        Tue, 12 Mar 2019 17:39:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552437560; cv=none;
        d=google.com; s=arc-20160816;
        b=AJUMHQTmTZH0WWg7CVeXdkIbHeMqfzfbr/d8ApElGLDNbRwgS4UsZVcntNl14yO+x7
         YB5M+4Y3Xb0AuvurdwxMzYE0w9t8ByfR9MInvnK9uH5rVuv1OpAup5sizcVBBFkiZKVt
         4UpK/+lpshr009egiAeCoD9o08M7FVjEgy4N4uM7RH36PlgsP7QJ6X4s0KWofysdM+qH
         SYiDegV74KJziXgpVJjrFlrCy7dCYc6qeEHFm5SLq1FBHO7xZhe83+Ob3mHnaUZaXil2
         4RWZGUiRQw26MK7oUBKZZiDVhZBRi9uaPPrrgBRQavscdbMlIO3doG+BGxg/XBCyaY0b
         M8gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+hX026rpYJ/LrRtNbb8F5ij7BYrG6XmL8SylXJLPkuw=;
        b=j7X7STabxWC3TviPnzyqHgoCbPX8meHLpomYtbqZutQ1sMpXLTrtrvAnKzp8BKEoTK
         WBcYGREU8pv50prZWAbIah/I75+m801cNaGLK8LpousyJX/+4tG8AZFuA63vCmgy9T7C
         81fvdtGbrE3xKyiBUhKPgkDOBtK6T+CTKLvqshH2m60PiA8mkwmFA602ZBeWRDOimaX3
         Kdho9uzLB9dJcD1c9jxDQW7D9E61RlKNjDCfvxo6obMrCoGguHu0sREFYIDBzbExpcZo
         YYVIooiqz6gitY2mlAJ4g2UC21DKgk0ph7L4O9TgRAD6qnSwXFYusOX8OZlthxFl5lEW
         VtWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dU+cus5J;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e6si9101556pfc.201.2019.03.12.17.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 17:39:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dU+cus5J;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c8851390000>; Tue, 12 Mar 2019 17:39:21 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 12 Mar 2019 17:39:19 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 12 Mar 2019 17:39:19 -0700
Received: from [10.2.175.16] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 13 Mar
 2019 00:39:18 +0000
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <20190312153033.GG1119@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c9c80511-0805-a877-af6f-b769c6dcb111@nvidia.com>
Date: Tue, 12 Mar 2019 17:38:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190312153033.GG1119@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552437561; bh=+hX026rpYJ/LrRtNbb8F5ij7BYrG6XmL8SylXJLPkuw=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=dU+cus5JdTgOMNpreNlFZkqZG4Mx1Zi1iZA0fSrVGprBOYkQQyh9q2SG0gSInk2+5
	 idxsPpJIsYB1A8jRSiVS1VL5XQwAvJeODh3TK3Twqi5i8Ocs3dFhgAx5VRZsMp9Nns
	 zcZanWOjt6fOq6VB0pBU8/PHrBqRzYG/kCqmg2DTeQRBRkh8PsgMukGg0pIhdLyO55
	 nm4hQtV5MWqMv0p67E1MlXk18NSuVcdblXQFMeqDZffAfwwVM89yzFHGuzFrl+glGK
	 zsnWvN9yQJOY7EnzdX/v+4dW1kWIeoI1aSMCV81RFwax7jeeEdrlfEeDOtJG+YkF4U
	 IZSkBKy5cNZjQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/12/19 8:30 AM, Ira Weiny wrote:
> On Wed, Mar 06, 2019 at 03:54:55PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Introduces put_user_page(), which simply calls put_page().
>> This provides a way to update all get_user_pages*() callers,
>> so that they call put_user_page(), instead of put_page().
> 
> So I've been running with these patches for a while but today while ramping up
> my testing I hit the following:
> 
> [ 1355.557819] ------------[ cut here ]------------
> [ 1355.563436] get_user_pages pin count overflowed

Hi Ira,

Thanks for reporting this. That overflow, at face value, means that we've
used more than the 22 bits worth of gup pin counts, so about 4 million pins
of the same page...

> [ 1355.563446] WARNING: CPU: 1 PID: 1740 at mm/gup.c:73 get_gup_pin_page+0xa5/0xb0
> [ 1355.577391] Modules linked in: ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transpo
> rt_srp ext4 mbcache jbd2 mlx4_ib opa_vnic rpcrdma sunrpc rdma_ucm ib_iser rdma_cm ib_umad iw_cm libiscs
> i ib_ipoib scsi_transport_iscsi ib_cm sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm irqbyp
> ass snd_hda_codec_realtek ib_uverbs snd_hda_codec_generic crct10dif_pclmul ledtrig_audio snd_hda_intel
> crc32_pclmul snd_hda_codec snd_hda_core ghash_clmulni_intel snd_hwdep snd_pcm aesni_intel crypto_simd s
> nd_timer ib_core cryptd snd glue_helper dax_pmem soundcore nd_pmem ipmi_si device_dax nd_btt ioatdma nd
> _e820 ipmi_devintf ipmi_msghandler iTCO_wdt i2c_i801 iTCO_vendor_support libnvdimm pcspkr lpc_ich mei_m
> e mei mfd_core wmi pcc_cpufreq acpi_cpufreq sch_fq_codel xfs libcrc32c mlx4_en sr_mod cdrom sd_mod mgag
> 200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops mlx4_core ttm crc32c_intel igb isci ah
> ci dca libsas firewire_ohci drm i2c_algo_bit libahci scsi_transport_sas
> [ 1355.577429]  firewire_core crc_itu_t i2c_core libata dm_mod [last unloaded: rdmavt]
> [ 1355.686703] CPU: 1 PID: 1740 Comm: reg-mr Not tainted 5.0.0+ #10
> [ 1355.693851] Hardware name: Intel Corporation W2600CR/W2600CR, BIOS SE5C600.86B.02.04.0003.1023201411
> 38 10/23/2014
> [ 1355.705750] RIP: 0010:get_gup_pin_page+0xa5/0xb0
> [ 1355.711348] Code: e8 40 02 ff ff 80 3d ba a2 fb 00 00 b8 b5 ff ff ff 75 bb 48 c7 c7 48 0a e9 81 89 4
> 4 24 04 c6 05 a1 a2 fb 00 01 e8 35 63 e8 ff <0f> 0b 8b 44 24 04 eb 9c 0f 1f 00 66 66 66 66 90 41 57 49
> bf 00 00
> [ 1355.733244] RSP: 0018:ffffc90005a23b30 EFLAGS: 00010286
> [ 1355.739536] RAX: 0000000000000000 RBX: ffffea0014220000 RCX: 0000000000000000
> [ 1355.748005] RDX: 0000000000000003 RSI: ffffffff827d94a3 RDI: 0000000000000246
> [ 1355.756453] RBP: ffffea0014220000 R08: 0000000000000002 R09: 0000000000022400
> [ 1355.764907] R10: 0009ccf0ad0c4203 R11: 0000000000000001 R12: 0000000000010207
> [ 1355.773369] R13: ffff8884130b7040 R14: fff0000000000fff R15: 000fffffffe00000
> [ 1355.781836] FS:  00007f2680d0d740(0000) GS:ffff88842e840000(0000) knlGS:0000000000000000
> [ 1355.791384] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1355.798319] CR2: 0000000000589000 CR3: 000000040b05e004 CR4: 00000000000606e0
> [ 1355.806809] Call Trace:
> [ 1355.810078]  follow_page_pte+0x4f3/0x5c0
> [ 1355.814987]  __get_user_pages+0x1eb/0x730
> [ 1355.820020]  get_user_pages+0x3e/0x50
> [ 1355.824657]  ib_umem_get+0x283/0x500 [ib_uverbs]
> [ 1355.830340]  ? _cond_resched+0x15/0x30
> [ 1355.835065]  mlx4_ib_reg_user_mr+0x75/0x1e0 [mlx4_ib]
> [ 1355.841235]  ib_uverbs_reg_mr+0x10c/0x220 [ib_uverbs]
> [ 1355.847400]  ib_uverbs_write+0x2f9/0x4d0 [ib_uverbs]
> [ 1355.853473]  __vfs_write+0x36/0x1b0
> [ 1355.857904]  ? selinux_file_permission+0xf0/0x130
> [ 1355.863702]  ? security_file_permission+0x2e/0xe0
> [ 1355.869503]  vfs_write+0xa5/0x1a0
> [ 1355.873751]  ksys_write+0x4f/0xb0
> [ 1355.878009]  do_syscall_64+0x5b/0x180
> [ 1355.882656]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [ 1355.888862] RIP: 0033:0x7f2680ec3ed8
> [ 1355.893420] Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 8d 05 45 78 0
> d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49
> 89 d4 55
> [ 1355.915573] RSP: 002b:00007ffe65d50bc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> [ 1355.924621] RAX: ffffffffffffffda RBX: 00007ffe65d50c74 RCX: 00007f2680ec3ed8
> [ 1355.933195] RDX: 0000000000000030 RSI: 00007ffe65d50c80 RDI: 0000000000000003
> [ 1355.941760] RBP: 0000000000000030 R08: 0000000000000007 R09: 0000000000581260
> [ 1355.950326] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000581930
> [ 1355.958885] R13: 000000000000000c R14: 0000000000581260 R15: 0000000000000000
> [ 1355.967430] ---[ end trace bc771ac6189977a2 ]---
> 
> 
> I'm not sure what I did to do this and I'm going to work on a reproducer.  At
> the time of the Warning I only had 1 GUP user?!?!?!?!

If there is a get_user_pages() call that lacks a corresponding put_user_pages()
call, then the count could start working its way up, and up. Either that, or a
bug in my patches here, could cause this. The basic counting works correctly
in fio runs on an NVMe driver with Direct IO, when I dump out
`cat /proc/vmstat | grep gup`: the counts match up, but that is a simple test.

One way to force a faster repro is to increase the GUP_PIN_COUNTING_BIAS, so
that the gup pin count runs into the max much sooner.

I'd really love to create a test setup that would generate this failure, so
anything you discover on how to repro (including what hardware is required--I'm
sure I can scrounge up some IB gear in a pinch) is of great interest.

Also, I'm just now starting on the DEBUG_USER_PAGE_REFERENCES idea that Jerome,
Jan, and Dan floated some months ago. It's clearly a prerequisite to converting
the call sites properly--just our relatively small IB driver is showing that.
This feature will provide a different mapping of the struct pages, if get
them via get_user_pages(). That will allow easily asserting that put_user_page()
and put_page() are not swapped, in either direction.


> 
> I'm not using ODP, so I don't think the changes we have discussed there are a
> problem.
> 
> Ira
> 


thanks,
-- 
John Hubbard
NVIDIA

