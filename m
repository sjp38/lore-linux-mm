Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5NHDxll021472
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 13:14:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5NHDx6g288406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 13:13:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5NHDxOr003681
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 13:13:59 -0400
Subject: Re: [RFC] patch [1/1] x86_64 numa aware sparsemem add_memory
	functinality
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1150868581.8518.28.camel@keithlap>
References: <1150868581.8518.28.camel@keithlap>
Content-Type: text/plain
Date: Fri, 23 Jun 2006 10:13:53 -0700
Message-Id: <1151082833.10877.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: lhms-devel <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, konrad <darnok@us.ibm.com>, Prarit Bhargava--redhat <prarit@redhat.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

>  int add_memory(u64 start, u64 size)
>  {
> -       struct pglist_data *pgdat = NODE_DATA(0);
> +       struct pglist_data *pgdat = NODE_DATA(new_memory_to_node(start,start+size));
>         struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;

How about just having new_memory_to_node() take the range and return the
pgdat?  Should make that line a bit shorter.

> -#ifndef RESERVE_HOTADD 
> +#if !defined(RESERVE_HOTADD) && !defined(CONFIG_MEMORY_HOTPLUG)
>  #define hotadd_percent 0       /* Ignore all settings */
>  #endif
>  static u8 pxm2node[256] = { [0 ... 255] = 0xff };
> @@ -219,9 +219,9 @@
>         allocated += mem;
>         return 1;
>  }
> -
> +#endif
>  /*

Could this use another Kconfig option which gives a name to this
condition?

> +#ifdef RESERVE_HOTADD
>         if (!hotadd_enough_memory(&nodes_add[node]))  {
>                 printk(KERN_ERR "SRAT: Hotplug area too large\n");
>                 return -1;
>         }
> -
> +#endif 

This #ifdef is probably better handled by an #ifdef in the header for
hotadd_enough_memory().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
