Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC4506B0207
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 03:00:56 -0400 (EDT)
Received: from il27vts01 (il27vts01.cig.mot.com [10.17.196.85])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with SMTP id o3270iNf027709
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 01:00:44 -0600 (MDT)
Received: from mail-gw0-f54.google.com (mail-gw0-f54.google.com [74.125.83.54])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with ESMTP id o326xZ6r027494
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 01:00:44 -0600 (MDT)
Received: by mail-gw0-f54.google.com with SMTP id a20so423405gwa.27
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 00:00:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <z2x28c262361004012215h2b2ea3dbu5260724f97f55b95@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <20100402140406.d3d7f18e.kamezawa.hiroyu@jp.fujitsu.com>
	 <z2x28c262361004012215h2b2ea3dbu5260724f97f55b95@mail.gmail.com>
Date: Fri, 2 Apr 2010 15:00:52 +0800
Message-ID: <z2w5f4a33681004020000td60331aam2c6947954d78e46@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, TAO HU <taohu@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi, kamezawa hiroyu

Thanks for the hint!

Hi, Minchan Kim

Sorry. Not exactly sure your idea about <grep "page handling">.
Below is a result of $ grep -n -r "list_del(&page->lru)" * in our src tree

arch/s390/mm/pgtable.c:83:	list_del(&page->lru);
arch/s390/mm/pgtable.c:226:		list_del(&page->lru);
arch/x86/mm/pgtable.c:60:	list_del(&page->lru);
drivers/xen/balloon.c:154:	list_del(&page->lru);
drivers/virtio/virtio_balloon.c:143:		list_del(&page->lru);
fs/cifs/file.c:1780:		list_del(&page->lru);
fs/btrfs/extent_io.c:2584:		list_del(&page->lru);
fs/mpage.c:388:		list_del(&page->lru);
include/linux/mm_inline.h:37:	list_del(&page->lru);
include/linux/mm_inline.h:47:	list_del(&page->lru);
kernel/kexec.c:391:		list_del(&page->lru);
kernel/kexec.c:711:			list_del(&page->lru);
mm/migrate.c:69:		list_del(&page->lru);
mm/migrate.c:695: 		list_del(&page->lru);
mm/hugetlb.c:467:			list_del(&page->lru);
mm/hugetlb.c:509:			list_del(&page->lru);
mm/hugetlb.c:836:		list_del(&page->lru);
mm/hugetlb.c:844:			list_del(&page->lru);
mm/hugetlb.c:900:			list_del(&page->lru);
mm/hugetlb.c:1130:			list_del(&page->lru);
mm/hugetlb.c:1809:		list_del(&page->lru);
mm/vmscan.c:597:		list_del(&page->lru);
mm/vmscan.c:1148:			list_del(&page->lru);
mm/vmscan.c:1246:		list_del(&page->lru);
mm/slub.c:827:	list_del(&page->lru);
mm/slub.c:1249:	list_del(&page->lru);
mm/slub.c:1263:		list_del(&page->lru);
mm/slub.c:2419:			list_del(&page->lru);
mm/slub.c:2809:				list_del(&page->lru);
mm/readahead.c:65:		list_del(&page->lru);
mm/readahead.c:100:		list_del(&page->lru);
mm/page_alloc.c:532:		list_del(&page->lru);
mm/page_alloc.c:679:		list_del(&page->lru);
mm/page_alloc.c:741:		list_del(&page->lru);
mm/page_alloc.c:820:			list_del(&page->lru);
mm/page_alloc.c:1107:		list_del(&page->lru);
mm/page_alloc.c:4784:		list_del(&page->lru);

On Fri, Apr 2, 2010 at 1:15 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Apr 2, 2010 at 2:04 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Fri, 2 Apr 2010 11:51:33 +0800
>> TAO HU <tghk48@motorola.com> wrote:
>>
>>> 2 patches related to page_alloc.c were applied.
>>> Does anyone see a connection between the 2 patches and the panic?
>>> NOTE: the full patches are attached.
>>>
>>
>> I don't think there are relationship between patches and your panic.
>>
>> BTW, there is other case about the backlog rather than race in alloc_pages()
>> itself. If someone list_del(&page->lru) and the page is already freed,
>> you'll see the same backlog later.
>> Then, I doubt use-after-free case rather than complicated races.
>
> It does make sense.
> Please, grep "page handling" by out-of-mainline code.
> If you found out, Please, post it.
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
