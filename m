Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA6266B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:58:11 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:58:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] reduce stack usage of node_read_meminfo()
Message-Id: <20100708135805.b4411965.akpm@linux-foundation.org>
In-Reply-To: <20100708181629.CD3C.A69D9226@jp.fujitsu.com>
References: <20100708181629.CD3C.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu,  8 Jul 2010 18:20:14 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> Now, cmpilation node_read_meminfo() output following warning. Because
> it has very large sprintf() argument.
> 
> 	drivers/base/node.c: In function 'node_read_meminfo':
> 	drivers/base/node.c:139: warning: the frame size of 848 bytes is
> 	larger than 512 bytes

hm, I'm surprised it's that much.

> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -66,8 +66,7 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
>  	struct sysinfo i;
>  
>  	si_meminfo_node(&i, nid);
> -
> -	n = sprintf(buf, "\n"
> +	n = sprintf(buf,
>  		       "Node %d MemTotal:       %8lu kB\n"
>  		       "Node %d MemFree:        %8lu kB\n"
>  		       "Node %d MemUsed:        %8lu kB\n"
> @@ -78,13 +77,33 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
>  		       "Node %d Active(file):   %8lu kB\n"
>  		       "Node %d Inactive(file): %8lu kB\n"
>  		       "Node %d Unevictable:    %8lu kB\n"
> -		       "Node %d Mlocked:        %8lu kB\n"
> +		       "Node %d Mlocked:        %8lu kB\n",
> +		       nid, K(i.totalram),
> +		       nid, K(i.freeram),
> +		       nid, K(i.totalram - i.freeram),
> +		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
> +				node_page_state(nid, NR_ACTIVE_FILE)),

Why the heck did we decide to print the same node-id 10000 times?

> +	n += sprintf(buf,

You just got caught sending untested patches.

--- a/drivers/base/node.c~drivers-base-nodec-reduce-stack-usage-of-node_read_meminfo-fix
+++ a/drivers/base/node.c
@@ -93,7 +93,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
-	n += sprintf(buf,
+	n += sprintf(buf + n,
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
 		       "Node %d LowTotal:       %8lu kB\n"
@@ -103,7 +103,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalram - i.totalhigh),
 		       nid, K(i.freeram - i.freehigh));
 #endif
-	n += sprintf(buf,
+	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
 		       "Node %d Writeback:      %8lu kB\n"
 		       "Node %d FilePages:      %8lu kB\n"
_


Please, run the code and check that we didn't muck up the output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
