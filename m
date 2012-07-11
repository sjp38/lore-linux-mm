Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 8A7036B005A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 11:37:05 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 11:37:03 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BCA5C6E8112
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 11:30:25 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BFUP9S417066
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 11:30:25 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BFUOU9004412
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 12:30:25 -0300
Message-ID: <4FFD9C08.2070502@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 08:30:16 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/13] memory-hotplug : unify argument of firmware_map_add_early/hotplug
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB17F.2090209@jp.fujitsu.com>
In-Reply-To: <4FFAB17F.2090209@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On 07/09/2012 03:25 AM, Yasuaki Ishimatsu wrote:
> @@ -642,7 +642,7 @@ int __ref add_memory(int nid, u64 start,
>  	}
> 
>  	/* create new memmap entry */
> -	firmware_map_add_hotplug(start, start + size, "System RAM");
> +	firmware_map_add_hotplug(start, start + size - 1, "System RAM");

I know the firmware_map_*() calls use inclusive end addresses
internally, but do we really need to expose them?  Both of the callers
you mentioned do:

	firmware_map_add_hotplug(start, start + size - 1, "System RAM");

or

                firmware_map_add_early(entry->addr,
                        entry->addr + entry->size - 1,
                        e820_type_to_string(entry->type));

So it seems a _bit_ silly to keep all of the callers doing this size-1
thing.  I also noted that the new caller that you added does the same
thing.  Could we just change the external calling convention to be
exclusive?

BTW, this patch should probably be first in your series.  It's a real
bugfix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
