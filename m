Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D70C66B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 07:01:02 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 36so11293394plb.18
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 04:01:02 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a29si4856776pgd.225.2018.02.05.04.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 04:01:00 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug 198617] New: zswap causing random applications to crash)
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
	<20180203013455.GA739@jagdpanzerIV>
	<CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
	<20180205013758.GA648@jagdpanzerIV>
Date: Mon, 05 Feb 2018 20:00:57 +0800
In-Reply-To: <20180205013758.GA648@jagdpanzerIV> (Sergey Senozhatsky's message
	of "Mon, 5 Feb 2018 10:37:58 +0900")
Message-ID: <87d11j4pdy.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> writes:

> Hi,
>
> On (02/04/18 22:21), huang ying wrote:
> [..]
>> >> After disabling zswap no crashes at all.
>> >>
>> >> /etc/systemd/swap.conf
>> >> zswap_enabled=1
>> >> zswap_compressor=lz4      # lzo lz4
>> >> zswap_max_pool_percent=25 # 1-99
>> >> zswap_zpool=zbud          # zbud z3fold
>> >
> [..]
>> Can you give me some detailed steps to reproduce this?  Like the
>> kernel configuration file, swap configuration, etc.  Any kernel
>> WARNING during testing?  Can you reproduce this with a real swap
>> device instead of zswap?
>
> No warnings (at least no warnings with my .config). Tested it only with
> zram based swap (I'm running swap-less x86 systems, so zram is the easiest
> way). It seems it's THP + frontswap that makes things unstable, rather
> than THP + swap.
>
> Kernel zswap boot params:
> zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=10 zswap.zpool=zbud
>
> Then I add a 4G zram swap and run a silly memory hogger. I don't think
> you'll have any problems reproducing it, but just in case I attached my
> .config

I have successfully reproduced the issue and find the problem.  The
following patch fix the issue for me, can you try it?

Best Regards,
Huang, Ying

---------------------------------8<-------------------------------
