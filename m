Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 51DDC8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 19:23:15 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p36N1UAf006775
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 19:01:30 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B1CE238C8039
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 19:23:03 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p36NMjPR205212
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 19:22:47 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p36NMi3o004970
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 17:22:44 -0600
Subject: Re: [PATCH 2/5] kstaled: page_referenced_kstaled() and supporting
 infrastructure.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1301042635-11180-3-git-send-email-walken@google.com>
References: <1301042635-11180-1-git-send-email-walken@google.com>
	 <1301042635-11180-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 06 Apr 2011 16:22:42 -0700
Message-ID: <1302132162.8184.517.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 2011-03-25 at 01:43 -0700, Michel Lespinasse wrote:
> +PAGEFLAG(Young, young)
> +
> +PAGEFLAG(Idle, idle)
> +
> +static inline void set_page_young(struct page *page)
> +{
> +       if (!PageYoung(page))
> +               SetPageYoung(page);
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +       if (PageIdle(page))
> +               ClearPageIdle(page);
> +} 

Is it time for a CONFIG_X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG config
option?  If folks want these kinds of features, then they need to suck
it up and make their 'struct page' 36 bytes.  Any of these new page
flags features could:

	config EXTENDED_PAGE_FLAGS
		depends on 64BIT || X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG

	config KSTALED
		depends on EXTENDED_PAGE_FLAGS

And then we can wrap the "enum pageflags" entries for them in #ifdefs,
along with making page->flags a u64 when
X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG is set.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
