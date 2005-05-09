Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j49N46mD613108
	for <linux-mm@kvack.org>; Mon, 9 May 2005 19:04:06 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j49N41FL360318
	for <linux-mm@kvack.org>; Mon, 9 May 2005 17:04:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j49N40gX005978
	for <linux-mm@kvack.org>; Mon, 9 May 2005 17:04:00 -0600
Message-ID: <427FEC57.8060505@austin.ibm.com>
Date: Mon, 09 May 2005 18:03:51 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: sparsemem ppc64 tidy flat memory comments and fix benign mempresent
 call
References: <E1DVAVE-00012m-Pq@pinky.shadowen.org>
In-Reply-To: <E1DVAVE-00012m-Pq@pinky.shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: akpm@osdl.org, anton@samba.org, haveblue@us.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, olof@lixom.net, paulus@samba.org
List-ID: <linux-mm.kvack.org>

> diff -upN reference/arch/ppc64/mm/init.c current/arch/ppc64/mm/init.c
> --- reference/arch/ppc64/mm/init.c
> +++ current/arch/ppc64/mm/init.c
> @@ -631,18 +631,19 @@ void __init do_init_bootmem(void)
>  
>  	max_pfn = max_low_pfn;
>  
> -	/* add all physical memory to the bootmem map. Also, find the first
> -	 * presence of all LMBs*/
> +	/* Add all physical memory to the bootmem map, mark each area
> +	 * present.  The first block has already been marked present above.
> +	 */
>  	for (i=0; i < lmb.memory.cnt; i++) {
>  		unsigned long physbase, size;
>  
>  		physbase = lmb.memory.region[i].physbase;
>  		size = lmb.memory.region[i].size;
> -		if (i) { /* already created mappings for first LMB */
> +		if (i) {
>  			start_pfn = physbase >> PAGE_SHIFT;
>  			end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +			memory_present(0, start_pfn, end_pfn);
>  		}
> -		memory_present(0, start_pfn, end_pfn);
>  		free_bootmem(physbase, size);
>  	}

Instead of moving all that around why don't we just drop the duplicate 
and the if altogether?  I tested and sent a patch back in March that 
cleaned up the non-numa case pretty well.

http://sourceforge.net/mailarchive/message.php?msg_id=11320001

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
