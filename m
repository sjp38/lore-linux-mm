Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4C3266B0160
	for <linux-mm@kvack.org>; Wed, 29 May 2013 20:54:40 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so10091830pbb.19
        for <linux-mm@kvack.org>; Wed, 29 May 2013 17:54:39 -0700 (PDT)
Message-ID: <51A6A34B.6020907@gmail.com>
Date: Thu, 30 May 2013 08:54:35 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sparse: use __aligned() instead of manual padding
 in mem_section
References: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 30 May 2013 07:14:39 AM CST, Cody P Schafer wrote:
> Instead of leaving a trap for the next person who comes along and wants
> to add something to mem_section, add an __aligned() and remove the
> manual padding added for MEMCG.
>
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  include/linux/mmzone.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> ---
>
> Also, does anyone know what causes this alignment to be required here? I found
> this was breaking things in a patchset I'm working on (WARNs in sysfs code
> about duplicate filenames when initing mem_sections). Adding some documentation
> for the reason would be appreciated.
Hi Cody,
        I think the alignment requirement is caused by the way the 
mem_section array is
organized. Basically it requires that PAGE_SIZE could be divided by 
sizeof(struct mem_section).
So your change seems risky too because it should be aligned to power of 
two instead
of 2 * sizeof(long).
Regards!
Gerry

>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 131989a..a8e8056 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1125,9 +1125,8 @@ struct mem_section {
>  	 * section. (see memcontrol.h/page_cgroup.h about this.)
>  	 */
>  	struct page_cgroup *page_cgroup;
> -	unsigned long pad;
>  #endif
> -};
> +} __aligned(2 * sizeof(unsigned long));
>
>  #ifdef CONFIG_SPARSEMEM_EXTREME
>  #define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
