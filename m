Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0AC0B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:19:01 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so363838pbc.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 09:19:01 -0700 (PDT)
Message-ID: <4F96D27A.2050005@gmail.com>
Date: Tue, 24 Apr 2012 12:19:06 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F96CDE1.5000909@redhat.com>
In-Reply-To: <4F96CDE1.5000909@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@gmail.com

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 47296fe..6c189fa 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1012,6 +1012,16 @@ int do_migrate_pages(struct mm_struct *mm,
>  		int dest = 0;
>
>  		for_each_node_mask(s, tmp) {
> +
> +			/* IFF there is an equal number of source and
> +			 * destination nodes, maintain relative node distance
> +			 * even when source and destination nodes overlap.
> +			 * However, when the node weight is unequal, never move
> +			 * memory out of any destination nodes */

Please use

/*
  * foo bar
  */

style comment. and this comment only explain how code work but don't explain why.
I hope the comment describe HPC usecase require to migrate if src and dest have the
same weight.

Otherwise looks ok. please feel free to use my ack to your next spin.
  Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> +			if ((nodes_weight(*from_nodes) != nodes_weight(*to_nodes)) &&
> +						(node_isset(s, *to_nodes)))
> +				continue;
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
