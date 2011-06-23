Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 14B51900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 11:38:20 -0400 (EDT)
Subject: Re: [PATCH] Add zv_pool_pages_count to zcache sysfs
From: Dave Hansen <dave@sr71.net>
In-Reply-To: <4E024122.5020601@linux.vnet.ibm.com>
References: <4E023F61.8080904@linux.vnet.ibm.com>
	 <4E024122.5020601@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 23 Jun 2011 08:38:10 -0700
Message-ID: <1308843490.11430.419.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

On Wed, 2011-06-22 at 14:23 -0500, Seth Jennings wrote:
> +#ifdef CONFIG_SYSFS

There are a couple of #ifdef CONFIG_SYSFS blocks in zcache.c already.
Could this go inside one of those instead of being off by itself?

> +static int zv_show_pool_pages_count(char *buf)
> +{
> +	char *p = buf;
> +	unsigned long numpages;
> +
> +	if (zcache_client.xvpool == NULL)
> +		p += sprintf(p, "%d\n", 0);
> +	else {

^^ That's probably a good spot to include brackets.  They don't take up
any more lines, and it keeps folks from introducing bugs doing things
like:

	if (zcache_client.xvpool == NULL)
		p += sprintf(p, "%d\n", 0);
		bar();
	else {

> +		numpages = xv_get_total_size_bytes(zcache_client.xvpool);
> +		p += sprintf(p, "%lu\n", numpages >> PAGE_SHIFT);
> +	}

In this case 'numpages' doesn't actually store a number of pages; it
stores a number of bytes.  I'd probably rename it.

Also 'numpages' is an 'unsigned long' while xv_get_total_size_bytes()
returns a u64.  'unsigned long' is only 32-bits on 32-bit architectures,
so it's possible that large buffers sizes could overflow.  The easiest
way to fix this is probably to just make 'numpages' a u64.


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
