Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 04A0F6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 05:01:53 -0400 (EDT)
Received: by padev16 with SMTP id ev16so35511380pad.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 02:01:52 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ms6si3166505pdb.76.2015.06.08.02.01.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 02:01:52 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory hotplug: print the last vmemmap region at the
 end of hot add memory
Date: Mon, 8 Jun 2015 08:52:00 +0000
Message-ID: <20150608085200.GC4210@hori1.linux.bs1.fc.nec.co.jp>
References: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
In-Reply-To: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <99F58657E630984C8BA87337A9A1E6C5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "rientjes@google.com" <rientjes@google.com>, "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "wangnan0@huawei.com" <wangnan0@huawei.com>, "fabf@skynet.be" <fabf@skynet.be>

On Mon, Jun 08, 2015 at 02:44:41PM +0800, Zhu Guihua wrote:
> When hot add two nodes continuously, we found the vmemmap region info is =
a
> bit messed. The last region of node 2 is printed when node 3 hot added,
> like the following:
> Initmem setup node 2 [mem 0x0000000000000000-0xffffffffffffffff]
>  On node 2 totalpages: 0
>  Built 2 zonelists in Node order, mobility grouping on.  Total pages: 160=
90539
>  Policy zone: Normal
>  init_memory_mapping: [mem 0x40000000000-0x407ffffffff]
>   [mem 0x40000000000-0x407ffffffff] page 1G
>   [ffffea1000000000-ffffea10001fffff] PMD -> [ffff8a077d800000-ffff8a077d=
9fffff] on node 2
>   [ffffea1000200000-ffffea10003fffff] PMD -> [ffff8a077de00000-ffff8a077d=
ffffff] on node 2
> ...
>   [ffffea101f600000-ffffea101f9fffff] PMD -> [ffff8a074ac00000-ffff8a074a=
ffffff] on node 2
>   [ffffea101fa00000-ffffea101fdfffff] PMD -> [ffff8a074a800000-ffff8a074a=
bfffff] on node 2
> Initmem setup node 3 [mem 0x0000000000000000-0xffffffffffffffff]
>  On node 3 totalpages: 0
>  Built 3 zonelists in Node order, mobility grouping on.  Total pages: 160=
90539
>  Policy zone: Normal
>  init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
>   [mem 0x60000000000-0x607ffffffff] page 1G
>   [ffffea101fe00000-ffffea101fffffff] PMD -> [ffff8a074a400000-ffff8a074a=
5fffff] on node 2 <=3D=3D=3D node 2 ???
>   [ffffea1800000000-ffffea18001fffff] PMD -> [ffff8a074a600000-ffff8a074a=
7fffff] on node 3
>   [ffffea1800200000-ffffea18005fffff] PMD -> [ffff8a074a000000-ffff8a074a=
3fffff] on node 3
>   [ffffea1800600000-ffffea18009fffff] PMD -> [ffff8a0749c00000-ffff8a0749=
ffffff] on node 3
> ...
>=20
> The cause is the last region was missed at the and of hot add memory, and
> p_start, p_end, node_start were not reset, so when hot add memory to a ne=
w
> node, it will consider they are not contiguous blocks and print the
> previous one. So we print the last vmemmap region at the end of hot add
> memory to avoid the confusion.
>=20
> Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory_hotplug.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 457bde5..58fb223 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -513,6 +513,7 @@ int __ref __add_pages(int nid, struct zone *zone, uns=
igned long phys_start_pfn,
>  			break;
>  		err =3D 0;
>  	}
> +	vmemmap_populate_print_last();
> =20
>  	return err;
>  }
> --=20
> 1.9.3
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
