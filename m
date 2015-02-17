Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 043CA6B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 16:32:59 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id e89so30117496qgf.9
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 13:32:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 78si7805567qgk.31.2015.02.17.13.32.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 13:32:58 -0800 (PST)
Date: Wed, 18 Feb 2015 10:32:45 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
Message-ID: <20150218103245.3aa3ca87@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1502170959130.4996@gentwo.org>
References: <20150210194804.288708936@linux.com>
	<20150210194811.787556326@linux.com>
	<alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com>
	<alpine.DEB.2.11.1502111243380.3887@gentwo.org>
	<alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
	<20150213023534.GA6592@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1502130941360.9442@gentwo.org>
	<20150217051541.GA15413@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1502170959130.4996@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com

On Tue, 17 Feb 2015 10:03:51 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 17 Feb 2015, Joonsoo Kim wrote:
> 
[...]
> > If we allocate objects from local cache as much as possible, we can
> > keep temporal locality and return objects as fast as possible since
> > returing objects from local cache just needs memcpy from local array
> > cache to destination array.
> 
> I thought the point was that this is used to allocate very large amounts
> of objects. The hotness is not that big of an issue.
>

(My use-case is in area of 32-64 elems)

[...]
> 
> Its not that detailed. It is just layin out the basic strategy for the
> array allocs. First go to the partial lists to decrease fragmentation.
> Then bypass the allocator layers completely and go direct to the page
> allocator if all objects that the page will accomodate can be put into
> the array. Lastly use the cpu hot objects to fill in the leftover (which
> would in any case be less than the objects in a page). 

IMHO this strategy is a bit off, from what I was looking for.

I would prefer the first elements to be cache hot, and the later/rest of
the elements can be more cache-cold. Reasoning behind this is,
subsystem calling this alloc_array have likely ran out of elems (from
it's local store/prev-call) and need to handout one elem immediately
after this call returns.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
