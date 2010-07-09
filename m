Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2C5226B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:14:36 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o690EXCi004265
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 09:14:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A3845DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:14:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AEABE45DE52
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:14:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 116741DB805E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:14:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A2D8F1DB805B
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 09:14:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] reduce stack usage of node_read_meminfo()
In-Reply-To: <20100708135805.b4411965.akpm@linux-foundation.org>
References: <20100708181629.CD3C.A69D9226@jp.fujitsu.com> <20100708135805.b4411965.akpm@linux-foundation.org>
Message-Id: <20100709091138.CD57.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 09:14:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu,  8 Jul 2010 18:20:14 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 
> > Now, cmpilation node_read_meminfo() output following warning. Because
> > it has very large sprintf() argument.
> > 
> > 	drivers/base/node.c: In function 'node_read_meminfo':
> > 	drivers/base/node.c:139: warning: the frame size of 848 bytes is
> > 	larger than 512 bytes
> 
> hm, I'm surprised it's that much.

me too.

> 
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -66,8 +66,7 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
> >  	struct sysinfo i;
> >  
> >  	si_meminfo_node(&i, nid);
> > -
> > -	n = sprintf(buf, "\n"
> > +	n = sprintf(buf,
> >  		       "Node %d MemTotal:       %8lu kB\n"
> >  		       "Node %d MemFree:        %8lu kB\n"
> >  		       "Node %d MemUsed:        %8lu kB\n"
> > @@ -78,13 +77,33 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
> >  		       "Node %d Active(file):   %8lu kB\n"
> >  		       "Node %d Inactive(file): %8lu kB\n"
> >  		       "Node %d Unevictable:    %8lu kB\n"
> > -		       "Node %d Mlocked:        %8lu kB\n"
> > +		       "Node %d Mlocked:        %8lu kB\n",
> > +		       nid, K(i.totalram),
> > +		       nid, K(i.freeram),
> > +		       nid, K(i.totalram - i.freeram),
> > +		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
> > +				node_page_state(nid, NR_ACTIVE_FILE)),
> 
> Why the heck did we decide to print the same node-id 10000 times?

dunno. but I don't want to make behavior change for only stack reducing.


> 
> > +	n += sprintf(buf,
> 
> You just got caught sending untested patches.
> 
> --- a/drivers/base/node.c~drivers-base-nodec-reduce-stack-usage-of-node_read_meminfo-fix
> +++ a/drivers/base/node.c
> @@ -93,7 +93,7 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(node_page_state(nid, NR_MLOCK)));
>  
>  #ifdef CONFIG_HIGHMEM
> -	n += sprintf(buf,
> +	n += sprintf(buf + n,
>  		       "Node %d HighTotal:      %8lu kB\n"
>  		       "Node %d HighFree:       %8lu kB\n"
>  		       "Node %d LowTotal:       %8lu kB\n"
> @@ -103,7 +103,7 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(i.totalram - i.totalhigh),
>  		       nid, K(i.freeram - i.freehigh));
>  #endif
> -	n += sprintf(buf,
> +	n += sprintf(buf + n,
>  		       "Node %d Dirty:          %8lu kB\n"
>  		       "Node %d Writeback:      %8lu kB\n"
>  		       "Node %d FilePages:      %8lu kB\n"
> _
> 
> 
> Please, run the code and check that we didn't muck up the output.

100% my fault. I ran it, but I forgot to merge two patches ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
