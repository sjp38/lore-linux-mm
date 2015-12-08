Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 868B56B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 03:08:08 -0500 (EST)
Received: by ioir85 with SMTP id r85so16930853ioi.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 00:08:08 -0800 (PST)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id k123si3804880ioe.26.2015.12.08.00.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 00:08:07 -0800 (PST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 2CE8FAC0185
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 17:08:01 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
Date: Tue, 8 Dec 2015 08:07:59 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54298EAE@G01JPEXMBYT01>
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <20151207163112.930a495d24ab259cad9020ac@linux-foundation.org>
In-Reply-To: <20151207163112.930a495d24ab259cad9020ac@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "tony.luck@intel.com" <tony.luck@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

Dear Tony,

  Thanks for testing!

Dear Andrew,


> > Xeon E7 v3 based systems supports Address Range Mirroring
> > and UEFI BIOS complied with UEFI spec 2.5 can notify which
> > ranges are reliable (mirrored) via EFI memory map.
> > Now Linux kernel utilize its information and allocates
> > boot time memory from reliable region.
> >
> > My requirement is:
> >   - allocate kernel memory from reliable region
> >   - allocate user memory from non-reliable region
> >
> > In order to meet my requirement, ZONE_MOVABLE is useful.
> > By arranging non-reliable range into ZONE_MOVABLE,
> > reliable memory is only used for kernel allocations.
> >
> > My idea is to extend existing "kernelcore" option and
> > introduces kernelcore=reliable option. By specifying
> > "reliable" instead of specifying the amount of memory,
> > non-reliable region will be arranged into ZONE_MOVABLE.
> 
> It is unfortunate that the kernel presently refers to this memory as
> "mirrored", but this patchset introduces the new term "reliable".  I
> think it would be better if we use "mirrored" throughout.
> Of course, mirroring isn't the only way to get reliable memory.

  YES. "mirroring" is not the only way.
  So, in my opinion, we should change "mirrored" into "reliable" in order
  to match terms of UEFI 2.5 spec.

> Perhaps if a part of the system memory has ECC correction then this
> also can be accessed using "reliable", in which case your proposed
> naming makes sense.  reliable == mirrored || ecc?

  "reliable" is better.

  But, I'm willing to change "reliable" into "mirrored".

  Otherwise, I keep "kernelcore=reliable" and add the following minimal fix as 
  a separate patch:

diff  a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -134,7 +134,7 @@ void __init efi_find_mirror(void)
                }
        }
        if (mirror_size)
-               pr_info("Memory: %lldM/%lldM mirrored memory\n",
+               pr_info("Memory: %lldM/%lldM reliable memory\n",
                        mirror_size>>20, total_size>>20);
 }

 
 Which do you think is beter ?
   - change into kernelcore="mirrored"
   - keep kernelcore="reliable" and minmal printk fix 

> 
> Secondly, does this patchset mean that kernelcore=reliable and
> kernelcore=100M are exclusive?  Or can the user specify
> "kernelcore=reliable,kernelcore=100M" to use 100M of reliable memory
> for kernelcore?

  No, these are exclusive.
> 
> This is unclear from the documentation and I suggest that this be
> spelled out.

  Thanks. I'll update its document.

 Sincerely,
 Taku Izumi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
