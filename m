Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEEF6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:20:27 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so69262328pab.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:20:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xi9si18717804pbc.158.2015.06.15.10.20.25
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 10:20:26 -0700 (PDT)
Date: Mon, 15 Jun 2015 10:20:25 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
Message-ID: <20150615172023.GA12088@agluck-desk.sc.intel.com>
References: <55704A7E.5030507@huawei.com>
 <55704CC4.8040707@huawei.com>
 <557691E0.5020203@jp.fujitsu.com>
 <5576BA2B.6060907@huawei.com>
 <5577A9A9.7010108@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32A8F209@ORSMSX114.amr.corp.intel.com>
 <557E911F.5040602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <557E911F.5040602@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 15, 2015 at 05:47:27PM +0900, Kamezawa Hiroyuki wrote:
> So, there are 3 ideas.
> 
>  (1) kernel only from MIRROR / user only from MOVABLE (Tony)
>  (2) kernel only from MIRROR / user from MOVABLE + MIRROR(ASAP)  (AKPM suggested)
>      This makes use of the fact MOVABLE memory is reclaimable but Tony pointed out
>      the memory reclaim can be critical for GFP_ATOMIC.
>  (3) kernel only from MIRROR / user from MOVABLE, special user from MIRROR (Xishi)
> 
> 2 Implementation ideas.
>   - creating ZONE
>   - creating new alloation attribute
> 
> I don't convince whether we need some new structure in mm. Isn't it good to use
> ZONE_MOVABLE for not-mirrored memory ?
> Then, disable fallback from ZONE_MOVABLE -> ZONE_NORMAL for (1) and (3)

We might need to rename it ... right now the memory hotplug
people use ZONE_MOVABLE to indicate regions of physical memory
that can be removed from the system.  I'm wondering whether
people will want systems that have both removable and mirrored
areas?  Then we have four attribute combinations:

mirror=no  removable=no  - prefer to use for user, could use for kernel if we run out of mirror
mirror=no  removable=yes - can only be used for user (kernel allocation makes it not-removable)
mirror=yes removable=no  - use for kernel, possibly for special users if we define some interface
mirror=yes removable=yes - must not use for kernel ... would have to give to user ... seems like a bad idea to configure a system this way

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
