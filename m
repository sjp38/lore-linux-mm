Received: by uproxy.gmail.com with SMTP id q2so454398uge
        for <linux-mm@kvack.org>; Sun, 05 Feb 2006 00:57:47 -0800 (PST)
Message-ID: <2cd57c900602050057p1b5a813bh@mail.gmail.com>
Date: Sun, 5 Feb 2006 16:57:46 +0800
From: Coywolf Qi Hunt <coywolf@gmail.com>
Subject: Re: [PATCH 2/4] Split the free lists into kernel and user parts
In-Reply-To: <20060120115455.16475.93688.sendpatchset@skynet.csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060120115415.16475.8529.sendpatchset@skynet.csn.ul.ie>
	 <20060120115455.16475.93688.sendpatchset@skynet.csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, jschopp@austin.ibm.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

2006/1/20, Mel Gorman <mel@csn.ul.ie>:
>
> This patch adds the core of the anti-fragmentation strategy. It works by
> grouping related allocation types together. The idea is that large groups of
> pages that may be reclaimed are placed near each other. The zone->free_area
> list is broken into RCLM_TYPES number of lists.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
> diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.16-rc1-mm1-001_antifrag_flags/include/linux/mmzone.h linux-2.6.16-rc1-mm1-002_fragcore/include/linux/mmzone.h
> --- linux-2.6.16-rc1-mm1-001_antifrag_flags/include/linux/mmzone.h      2006-01-19 11:21:59.000000000 +0000
> +++ linux-2.6.16-rc1-mm1-002_fragcore/include/linux/mmzone.h    2006-01-19 21:51:05.000000000 +0000
> @@ -22,8 +22,16 @@
>  #define MAX_ORDER CONFIG_FORCE_MAX_ZONEORDER
>  #endif
>
> +#define RCLM_NORCLM 0

better be RCLM_NORMAL

> +#define RCLM_EASY   1
> +#define RCLM_TYPES  2
> +
> +#define for_each_rclmtype_order(type, order) \
> +       for (order = 0; order < MAX_ORDER; order++) \
> +               for (type = 0; type < RCLM_TYPES; type++)
> +
>  struct free_area {
> -       struct list_head        free_list;
> +       struct list_head        free_list[RCLM_TYPES];
>         unsigned long           nr_free;
>  };
>


--
Coywolf Qi Hunt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
