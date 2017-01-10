Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8587A6B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:48:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so140731319pfy.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:48:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u22si3715503plj.69.2017.01.10.15.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 15:48:45 -0800 (PST)
Date: Tue, 10 Jan 2017 15:48:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: Skip over regions of invalid pfns where
 possible
Message-Id: <20170110154844.e3fafdb927134b3737a6e1b0@linux-foundation.org>
In-Reply-To: <0f03d5c6-182c-d30f-68ef-8d1a767bfcf8@imgtec.com>
References: <20161125185518.29885-1-paul.burton@imgtec.com>
	<20170106144348.f7d207baa7b3190a95aaeb2e@linux-foundation.org>
	<0f03d5c6-182c-d30f-68ef-8d1a767bfcf8@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartley <james.hartley@imgtec.com>
Cc: Paul Burton <paul.burton@imgtec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 10 Jan 2017 23:37:53 +0000 James Hartley <james.hartley@imgtec.com> wrote:

> 
> On 06/01/17 22:43, Andrew Morton wrote:
> > On Fri, 25 Nov 2016 18:55:18 +0000 Paul Burton <paul.burton@imgtec.com> wrote:
> >
> >> When using a sparse memory model memmap_init_zone() when invoked with
> >> the MEMMAP_EARLY context will skip over pages which aren't valid - ie.
> >> which aren't in a populated region of the sparse memory map. However if
> >> the memory map is extremely sparse then it can spend a long time
> >> linearly checking each PFN in a large non-populated region of the memory
> >> map & skipping it in turn.
> >>
> >> When CONFIG_HAVE_MEMBLOCK_NODE_MAP is enabled, we have sufficient
> >> information to quickly discover the next valid PFN given an invalid one
> >> by searching through the list of memory regions & skipping forwards to
> >> the first PFN covered by the memory region to the right of the
> >> non-populated region. Implement this in order to speed up
> >> memmap_init_zone() for systems with extremely sparse memory maps.
> > Could we have a changelog which includes some timing measurements? 
> > That permits others to understand the value of this patch.
> >
> I have tested this patch on a virtual model of a Samurai CPU with a
> sparse memory map.  The kernel boot time drops from 109 to 62 seconds. 

Thanks.  Nice.  I updated the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
