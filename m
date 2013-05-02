Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0E3806B02FF
	for <linux-mm@kvack.org>; Fri,  3 May 2013 18:58:27 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <matthltc@linux.vnet.ibm.com>;
	Fri, 3 May 2013 18:58:26 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4EA006E803A
	for <linux-mm@kvack.org>; Fri,  3 May 2013 18:58:16 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43MwJAx330972
	for <linux-mm@kvack.org>; Fri, 3 May 2013 18:58:19 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43MwIJE010229
	for <linux-mm@kvack.org>; Fri, 3 May 2013 19:58:18 -0300
Date: Thu, 2 May 2013 10:08:57 -0700
From: Matt Helsley <matthltc@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] pagemap: Introduce the /proc/PID/pagemap2 file
Message-ID: <20130502170857.GB24627@us.ibm.com>
References: <51669E5F.4000801@parallels.com>
 <51669EA5.20209@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51669EA5.20209@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 03:29:41PM +0400, Pavel Emelyanov wrote:
> This file is the same as the pagemap one, but shows entries with bits
> 55-60 being zero (reserved for future use). Next patch will occupy one
> of them.

This approach doesn't scale as well as it could. As best I can see
CRIU would do:

for each vma in /proc/<pid>/smaps
	for each page in /proc/<pid>/pagemap2
		if soft dirty bit
			copy page

(possibly with pfn checks to avoid copying the same page mapped in
multiple locations..)

However, if soft dirty bit changes could be queued up (from say the
fault handler and page table ops that map/unmap pages) and accumulated
in something like an interval tree it could be something like:

for each range of changed pages
	for each page in range
		copy page

IOW something that scales with the number of changed pages rather
than the number of mapped pages.

So I wonder if CRIU would abandon pagemap2 in the future for something
like this.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
