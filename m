Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 633848D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:26:39 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KH93sC001155
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:09:09 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AEC014DE81F5
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:22:14 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KHPS9q354796
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:25:28 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KHPR2G007530
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 15:25:28 -0200
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110120142844.GA28358@barrios-desktop>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	 <20110120142844.GA28358@barrios-desktop>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 20 Jan 2011 09:25:13 -0800
Message-ID: <1295544313.9039.618.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KyongHo Cho <pullip.cho@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Ilho Lee <ilho215.lee@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 23:28 +0900, Minchan Kim wrote:
> On Thu, Jan 20, 2011 at 06:45:39PM +0900, KyongHo Cho wrote:
> > Sparsemem allows that a bank of memory spans over several adjacent
> > sections if the start address and the end address of the bank
> > belong to different sections.
> > When gathering statictics of physical memory in mem_init() and
> > show_mem(), this possiblity was not considered.
> 
> Please write down the result if we doesn't consider this patch.
> I can understand what happens but for making good description and review,
> merging easily, it would be better to write down the result without 
> the patch explicitly. 

You'll oops.  __section_mem_map_addr() in:

> #define __pfn_to_page(pfn)                              \
> ({      unsigned long __pfn = (pfn);                    \
>         struct mem_section *__sec = __pfn_to_section(__pfn);    \
>         __section_mem_map_addr(__sec) + __pfn;          \
> })

will return NULL, you'll add some fuzz on to it with __pfn, then you'll
oops when the arm show_mem() does PageReserved() and dereferences
page->flags.

Ether that, or with the sparsemem vmemmap variant, you'll get a
valid-looking pointer with no backing memory, and oops as well.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
