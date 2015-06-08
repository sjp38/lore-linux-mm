Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA406B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 19:30:55 -0400 (EDT)
Received: by payr10 with SMTP id r10so1561905pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 16:30:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id du9si6221526pdb.80.2015.06.08.16.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 16:30:54 -0700 (PDT)
Date: Mon, 8 Jun 2015 16:30:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory hotplug: print the last vmemmap region at the
 end of hot add memory
Message-Id: <20150608163053.c481d9a5057513130f760910@linux-foundation.org>
In-Reply-To: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
References: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, rientjes@google.com, n-horiguchi@ah.jp.nec.com, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, fabf@skynet.be

On Mon, 8 Jun 2015 14:44:41 +0800 Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:

> When hot add two nodes continuously, we found the vmemmap region info is a
> bit messed. The last region of node 2 is printed when node 3 hot added,
> like the following:
> Initmem setup node 2 [mem 0x0000000000000000-0xffffffffffffffff]
>  On node 2 totalpages: 0
>  Built 2 zonelists in Node order, mobility grouping on.  Total pages: 16090539
>  Policy zone: Normal
>  init_memory_mapping: [mem 0x40000000000-0x407ffffffff]
>   [mem 0x40000000000-0x407ffffffff] page 1G
>   [ffffea1000000000-ffffea10001fffff] PMD -> [ffff8a077d800000-ffff8a077d9fffff] on node 2
>   [ffffea1000200000-ffffea10003fffff] PMD -> [ffff8a077de00000-ffff8a077dffffff] on node 2
> ...
>   [ffffea101f600000-ffffea101f9fffff] PMD -> [ffff8a074ac00000-ffff8a074affffff] on node 2
>   [ffffea101fa00000-ffffea101fdfffff] PMD -> [ffff8a074a800000-ffff8a074abfffff] on node 2
> Initmem setup node 3 [mem 0x0000000000000000-0xffffffffffffffff]
>  On node 3 totalpages: 0
>  Built 3 zonelists in Node order, mobility grouping on.  Total pages: 16090539
>  Policy zone: Normal
>  init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
>   [mem 0x60000000000-0x607ffffffff] page 1G
>   [ffffea101fe00000-ffffea101fffffff] PMD -> [ffff8a074a400000-ffff8a074a5fffff] on node 2 <=== node 2 ???
>   [ffffea1800000000-ffffea18001fffff] PMD -> [ffff8a074a600000-ffff8a074a7fffff] on node 3
>   [ffffea1800200000-ffffea18005fffff] PMD -> [ffff8a074a000000-ffff8a074a3fffff] on node 3
>   [ffffea1800600000-ffffea18009fffff] PMD -> [ffff8a0749c00000-ffff8a0749ffffff] on node 3
> ...
> 
> The cause is the last region was missed at the and of hot add memory, and
> p_start, p_end, node_start were not reset, so when hot add memory to a new
> node, it will consider they are not contiguous blocks and print the
> previous one. So we print the last vmemmap region at the end of hot add
> memory to avoid the confusion.
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -513,6 +513,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  			break;
>  		err = 0;
>  	}
> +	vmemmap_populate_print_last();
>  
>  	return err;
>  }

vmemmap_populate_print_last() is only available on x86_64, when
CONFIG_SPARSEMEM_VMEMMAP=y.  Are you sure this won't break builds?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
