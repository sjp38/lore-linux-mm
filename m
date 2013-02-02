Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 633386B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 19:24:01 -0500 (EST)
Date: Fri, 1 Feb 2013 16:23:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/9] mmzone: add pgdat_{end_pfn,is_empty}() helpers &
 consolidate.
Message-Id: <20130201162359.ddb66f62.akpm@linux-foundation.org>
In-Reply-To: <1358463181-17956-6-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
	<1358463181-17956-6-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>

On Thu, 17 Jan 2013 14:52:57 -0800
Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> From: Cody P Schafer <jmesmon@gmail.com>
> 
> Add pgdat_end_pfn() and pgdat_is_empty() helpers which match the similar
> zone_*() functions.
> 
> Change node_end_pfn() to be a wrapper of pgdat_end_pfn().
> 
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -772,11 +772,17 @@ typedef struct pglist_data {
>  #define nid_page_nr(nid, pagenr) 	pgdat_page_nr(NODE_DATA(nid),(pagenr))
>  
>  #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
> +#define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))

I wonder if these could be implemented in nice C code rather than nasty
cpp code.

> -#define node_end_pfn(nid) ({\
> -	pg_data_t *__pgdat = NODE_DATA(nid);\
> -	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;\
> -})
> +static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
> +{
> +	return pgdat->node_start_pfn + pgdat->node_spanned_pages;
> +}

It wouldn't hurt to add a little comment pointing out that this returns
"end pfn plus one", or similar.  ie, it is exclusive, not inclusive. 
Ditto the "zone_*() functions", if needed.

> +static inline bool pgdat_is_empty(pg_data_t *pgdat)
> +{
> +	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
