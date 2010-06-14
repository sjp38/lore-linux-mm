Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F1C166B0212
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:13:32 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EF6jDe016224
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:06:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o5EFDNMY173572
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:13:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EFDISd027652
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 09:13:19 -0600
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100614084810.GT5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>
	 <1276214852.6437.1427.camel@nimitz>
	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>
	 <20100614084810.GT5191@balbir.in.ibm.com>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 08:12:56 -0700
Message-Id: <1276528376.6437.7176.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 14:18 +0530, Balbir Singh wrote:
> 1. A slab page will not be freed until the entire page is free (all
> slabs have been kfree'd so to speak). Normal reclaim will definitely
> free this page, but a lot of it depends on how frequently we are
> scanning the LRU list and when this page got added.

You don't have to be freeing entire slab pages for the reclaim to have
been useful.  You could just be making space so that _future_
allocations fill in the slab holes you just created.  You may not be
freeing pages, but you're reducing future system pressure.

If unmapped page cache is the easiest thing to evict, then it should be
the first thing that goes when a balloon request comes in, which is the
case this patch is trying to handle.  If it isn't the easiest thing to
evict, then we _shouldn't_ evict it.

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
