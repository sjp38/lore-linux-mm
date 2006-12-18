Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBILE4S7020034
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 16:14:04 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBILE1pv541266
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 14:14:04 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBILE1mC008447
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 14:14:01 -0700
Subject: Re: [PATCH] Fix sparsemem on Cell
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20061216170353.2dfa27b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061215165335.61D9F775@localhost.localdomain>
	 <4582D756.7090702@shadowen.org>
	 <1166203440.8105.22.camel@localhost.localdomain>
	 <20061215114536.dc5c93af.akpm@osdl.org>
	 <20061216170353.2dfa27b1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 18 Dec 2006 13:13:57 -0800
Message-Id: <1166476437.8648.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, mkravetz@us.ibm.com, hch@infradead.org, jk@ozlabs.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, gone@us.ibm.com, kmannth@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 2006-12-16 at 17:03 +0900, KAMEZAWA Hiroyuki wrote:
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> @@ -273,10 +284,13 @@
>  		if (ret)
>  			goto error;
>  	}
> +	atomic_inc(&memory_hotadd_count);
>  
>  	/* call arch's memory hotadd */
>  	ret = arch_add_memory(nid, start, size);
>  
> +	atomic_dec(&memory_hotadd_count);

I'd be willing to be that this will work just fine.  But, I think we can
do it without any static state at all, if we just pass a runtime-or-not
flag down into the arch_add_memory() call chain.

I'll code that up so we can compare to yours.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
