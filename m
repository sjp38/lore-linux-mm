Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 67A9D6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 04:48:04 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so31336417pac.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 01:48:04 -0700 (PDT)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id tz6si16830520pab.216.2015.06.15.01.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 01:48:03 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id C08AFAC0088
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 17:47:59 +0900 (JST)
Message-ID: <557E911F.5040602@jp.fujitsu.com>
Date: Mon, 15 Jun 2015 17:47:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com> <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com> <5577A9A9.7010108@jp.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F32A8F209@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A8F209@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/11 5:40, Luck, Tony wrote:
>> I guess, mirrored memory should be allocated if !__GFP_HIGHMEM or !__GFP_MOVABLE
>
> HIGHMEM shouldn't matter - partial memory mirror only makes any sense on X86_64 systems ... 32-bit kernels
> don't even boot on systems with 64GB, and the minimum rational configuration for a machine that supports
> mirror is 128GB (4 cpu sockets * 2 memory controller per socket * 4 channels per controller * 4GB DIMM ...
> leaving any channels empty likely leaves you short of memory bandwidth for these high core count processors).
>
> MOVABLE is mostly the opposite of MIRROR - we never want to fill a kernel allocation from a MOVABLE page. I
> want all kernel allocations to be from MIRROR.
>

So, there are 3 ideas.

  (1) kernel only from MIRROR / user only from MOVABLE (Tony)
  (2) kernel only from MIRROR / user from MOVABLE + MIRROR(ASAP)  (AKPM suggested)
      This makes use of the fact MOVABLE memory is reclaimable but Tony pointed out
      the memory reclaim can be critical for GFP_ATOMIC.
  (3) kernel only from MIRROR / user from MOVABLE, special user from MIRROR (Xishi)

2 Implementation ideas.
   - creating ZONE
   - creating new alloation attribute

I don't convince whether we need some new structure in mm. Isn't it good to use
ZONE_MOVABLE for not-mirrored memory ?
Then, disable fallback from ZONE_MOVABLE -> ZONE_NORMAL for (1) and (3)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
