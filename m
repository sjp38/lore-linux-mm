Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DF5A76B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 20:03:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 05:24:38 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 18F36E0054
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 05:33:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6203sh921168366
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 05:33:55 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6203THw029006
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 00:03:30 GMT
Date: Tue, 2 Jul 2013 08:03:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm/slub: Fix slub calculate active slabs uncorrectly
Message-ID: <20130702000329.GC14358@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <0000013f9b8d6897-d2399224-d203-4dc5-a700-90dea9be7536-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f9b8d6897-d2399224-d203-4dc5-a700-90dea9be7536-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 06:45:03PM +0000, Christoph Lameter wrote:
>On Thu, 27 Jun 2013, Wanpeng Li wrote:
>
>> Enough slabs are queued in partial list to avoid pounding the page allocator
>> excessively. Entire free slabs are not discarded immediately if there are not
>> enough slabs in partial list(n->partial < s->min_partial). The number of total
>> slabs is composed by the number of active slabs and the number of entire free
>> slabs, however, the current logic of slub implementation ignore this which lead
>> to the number of active slabs and the number of total slabs in slabtop message
>> is always equal. This patch fix it by substract the number of entire free slabs
>> in partial list when caculate active slabs.
>
>What do you mean by "active" slabs? If this excludes the small number of
>empty slabs that could be present then indeed you will not have that
>number. But why do you need that?
>
>The number of total slabs is the number of partial slabs, plus the number
>of full slabs plus the number of percpu slabs.

Before patch:
Active / Total Slabs (% used) : 59018 / 59018 (100.0%)

After patch:
Active / Total Slabs (% used) : 11086 / 11153 (99.4%)

These numbers are dump from slabtop for monitor slub, before patch Active / Total 
Slabs are always 100%, this is not truth since empty slabs present. However, the 
slab allocator can caculate its Active / Total Slabs correctly and its value is 
less than 100.0%. By comparison, slub is more efficient than slab through slabtop 
observation, however, it is not truth since slub uncorrectly calculate its 
Active / Total Slabs.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
