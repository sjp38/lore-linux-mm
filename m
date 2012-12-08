Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 675406B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:17:50 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 7 Dec 2012 19:17:49 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1EB30C9001C
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:17:47 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB80HkVL283266
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 19:17:46 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB80HjIq024553
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 22:17:46 -0200
Message-ID: <50C28720.3070205@linux.vnet.ibm.com>
Date: Fri, 07 Dec 2012 16:17:36 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net> <20121207155125.d3117244.akpm@linux-foundation.org>
In-Reply-To: <20121207155125.d3117244.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/07/2012 03:51 PM, Andrew Morton wrote:
>> > +static ssize_t node_read_memrange(struct device *dev,
>> > +				  struct device_attribute *attr, char *buf)
>> > +{
>> > +	int nid = dev->id;
>> > +	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
>> > +	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
> hm.  Is this correct for all for
> FLATMEM/SPARSEMEM/SPARSEMEM_VMEMMAP/DISCONTIGME/etc?

It's not _wrong_ per se, but it's not super precise, either.

The problem is, it's quite valid to have these node_start/spanned ranges
overlap between two or more nodes on some hardware.  So, if the desired
purpose is to map nodes to DIMMs, then this can only accomplish this on
_some_ hardware, not all.  It would be completely useless for that
purpose for some configurations.

Seems like the better way to do this would be to expose the DIMMs
themselves in some way, and then map _those_ back to a node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
