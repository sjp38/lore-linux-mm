Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 85B2E6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 03:15:42 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so84245650qge.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 00:15:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v92si20322426qgd.85.2015.09.01.00.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 00:15:41 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:15:33 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 1/2] drivers/base/node.c: split loop in
 register_mem_sect_under_node
Message-ID: <20150901071533.GC23114@localhost.localdomain>
References: <1a7c81db42986a6fa27260fe189890bffc8a9cce.1440665740.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a7c81db42986a6fa27260fe189890bffc8a9cce.1440665740.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ccing linux-mm

On 08/27/15 at 04:43pm, Jan Stancek wrote:
> Split single loop going over all pfn in mem_blk into 2 loops,
> where outer loop goes over all sections and inner loop goes over
> pfn from that section.
> 
> This is preparatory patch for next patch:
>   "skip non-present sections in register_mem_sect_under_node"
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  drivers/base/node.c | 41 ++++++++++++++++++++++++-----------------
>  1 file changed, 24 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 31df474d72f4..4c7423a4b5f4 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -379,33 +379,40 @@ static int __init_refok get_nid_for_pfn(unsigned long pfn)
>  int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  {
>  	int ret;
> -	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> +	unsigned long pfn, sect_start_pfn, sect_end_pfn, sect_no;
>  
>  	if (!mem_blk)
>  		return -EFAULT;
>  	if (!node_online(nid))
>  		return 0;
>  
> -	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> -	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
> -	sect_end_pfn += PAGES_PER_SECTION - 1;
> -	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int page_nid;
> +	for (sect_no = mem_blk->start_section_nr;
> +		sect_no <= mem_blk->end_section_nr;
> +		sect_no++) {
>  
> -		page_nid = get_nid_for_pfn(pfn);
> -		if (page_nid < 0)
> -			continue;
> -		if (page_nid != nid)
> -			continue;
> -		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
> -					&mem_blk->dev.kobj,
> -					kobject_name(&mem_blk->dev.kobj));
> -		if (ret)
> -			return ret;
> +		sect_start_pfn = section_nr_to_pfn(sect_no);
> +		sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +
> +		for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> +			int page_nid;
>  
> -		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
> +			page_nid = get_nid_for_pfn(pfn);
> +			if (page_nid < 0)
> +				continue;
> +			if (page_nid != nid)
> +				continue;
> +
> +			ret = sysfs_create_link_nowarn(
> +				&node_devices[nid]->dev.kobj,
> +				&mem_blk->dev.kobj,
> +				kobject_name(&mem_blk->dev.kobj));
> +			if (ret)
> +				return ret;
> +
> +			return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
>  				&node_devices[nid]->dev.kobj,
>  				kobject_name(&node_devices[nid]->dev.kobj));
> +		}
>  	}
>  	/* mem section does not span the specified node */
>  	return 0;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
