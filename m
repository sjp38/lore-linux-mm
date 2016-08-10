Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDB0E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 16:03:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g67so102241676qkf.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:03:59 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id l95si27811249qte.110.2016.08.10.13.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 13:03:58 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id t7so54900694qkh.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:03:58 -0700 (PDT)
Subject: Re: [REGRESSION] !PageLocked(page) assertion with tcpdump
References: <c711e067-0bff-a6cb-3c37-04dfe77d2db1@redhat.com>
 <20160810161345.GA67522@black.fi.intel.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <638c471f-771d-6212-a1a1-8d52ea007c79@redhat.com>
Date: Wed, 10 Aug 2016 13:03:54 -0700
MIME-Version: 1.0
In-Reply-To: <20160810161345.GA67522@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/10/2016 09:13 AM, Kirill A. Shutemov wrote:
> On Wed, Aug 10, 2016 at 07:33:38AM -0700, Laura Abbott wrote:
>> Hi,
>>
>> There have been several reports[1] of assertions tripping when using
>> tcpdump on the latest master:
>>
>> [ 1013.718212] device wlp2s0 entered promiscuous mode
>> [ 1013.736003] page:ffffea0004380000 count:2 mapcount:0 mapping:
>> (null) index:0x0 compound_mapcount: 0
>> [ 1013.736013] flags: 0x17ffffc0004000(head)
>> [ 1013.736017] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
>> [ 1013.736044] ------------[ cut here ]------------
>> [ 1013.736091] kernel BUG at mm/rmap.c:1288!
>
> The patch below should do the trick.
>
> From 8026e3a2cecb7cdd3a63ebc266fb359ef7ec965b Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 10 Aug 2016 18:51:54 +0300
> Subject: [PATCH] mm, rmap: fix false positive VM_BUG() in page_add_file_rmap()
>
> PageTransCompound() doesn't distinguish THP from from any other type of
> compound pages. This can lead to false-positive VM_BUG_ON() in
> page_add_file_rmap() if called on compound page from a driver[1].
>
> I think we can exclude such cases by checking if the page belong to a
> mapping.
>
> The VM_BUG_ON_PAGE() is downgraded to VM_WARN_ON_ONCE(). This path
> should not cause any harm to non-THP page, but good to know if we step
> on anything else.
>
> [1] http://lkml.kernel.org/r/c711e067-0bff-a6cb-3c37-04dfe77d2db1@redhat.com
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Laura Abbott <labbott@redhat.com>

Tested-by: Laura Abbott <labbott@redhat.com>

> ---
>  mm/rmap.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index eee844997bd8..f071d6f7a986 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1286,8 +1286,9 @@ void page_add_file_rmap(struct page *page, bool compound)
>  		else
>  			__inc_node_page_state(page, NR_FILE_PMDMAPPED);
>  	} else {
> -		if (PageTransCompound(page)) {
> -			VM_BUG_ON_PAGE(!PageLocked(page), page);
> +		if (PageTransCompound(page) && page_mapping(page)) {
> +			VM_WARN_ON_ONCE(!PageLocked(page));
> +
>  			SetPageDoubleMap(compound_head(page));
>  			if (PageMlocked(page))
>  				clear_page_mlock(compound_head(page));
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
