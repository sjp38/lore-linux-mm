Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 844746B004D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 22:28:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H2SSss018568
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Mar 2010 11:28:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08E6E45DE4E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:28:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B795545DE4F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:28:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 699EFE38007
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:28:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F4F41DB8016
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:28:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA or memory hot-remove
In-Reply-To: <1268412087-13536-5-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-5-git-send-email-mel@csn.ul.ie>
Message-Id: <20100317110748.4C94.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Mar 2010 11:28:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> CONFIG_MIGRATION currently depends on CONFIG_NUMA or on the architecture
> being able to hot-remove memory. The main users of page migration such as
> sys_move_pages(), sys_migrate_pages() and cpuset process migration are
> only beneficial on NUMA so it makes sense.
> 
> As memory compaction will operate within a zone and is useful on both NUMA
> and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
> user selects CONFIG_COMPACTION as an option.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/Kconfig |   20 ++++++++++++++++----
>  1 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9c61158..04e241b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -172,17 +172,29 @@ config SPLIT_PTLOCK_CPUS
>  	default "4"
>  
>  #
> +# support for memory compaction
> +config COMPACTION
> +	bool "Allow for memory compaction"
> +	def_bool y
> +	select MIGRATION
> +	depends on EXPERIMENTAL && HUGETLBFS && MMU
> +	help
> +	  Allows the compaction of memory for the allocation of huge pages.
> +

If select MIGRATION works, we can remove "depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE"
line from config MIGRATION.



> +#
>  # support for page migration
>  #
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
>  	help
>  	  Allows the migration of the physical location of pages of processes
> -	  while the virtual addresses are not changed. This is useful for
> -	  example on NUMA systems to put pages nearer to the processors accessing
> -	  the page.
> +	  while the virtual addresses are not changed. This is useful in
> +	  two situations. The first is on NUMA systems to put pages nearer
> +	  to the processors accessing. The second is when allocating huge
> +	  pages as migration can relocate pages to satisfy a huge page
> +	  allocation instead of reclaiming.
>  
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
