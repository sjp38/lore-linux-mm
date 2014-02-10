Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 49FA36B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:35:40 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so6762716pad.11
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:35:39 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id b4si5068303pbe.178.2014.02.10.13.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 13:35:39 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so6703368pab.19
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:35:38 -0800 (PST)
Date: Mon, 10 Feb 2014 13:35:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <52F8C556.6090006@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
 <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com> <52F88C16.70204@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com> <52F8C556.6090006@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 10 Feb 2014, Raghavendra K T wrote:

> So I understood that you are suggesting implementations like below
> 
> 1) I do not have problem with the below approach, I could post this in
> next version.
> ( But this did not include 4k limit Linus mentioned to apply)
> 
> unsigned long max_sane_readahead(unsigned long nr)
> {
>         unsigned long local_free_page;
>         int nid;
> 
>         nid = numa_mem_id();
> 
>         /*
>          * We sanitize readahead size depending on free memory in
>          * the local node.
>          */
>         local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
>                           + node_page_state(nid, NR_FREE_PAGES);
>         return min(nr, local_free_page / 2);
> }
> 
> 2) I did not go for below because Honza (Jan Kara) had some
> concerns for 4k limit for normal case, and since I am not
> the expert, I was waiting for opinions.
> 
> unsigned long max_sane_readahead(unsigned long nr)
> {
>         unsigned long local_free_page, sane_nr;
>         int nid;
> 
>         nid = numa_mem_id();
> 	/* limit the max readahead to 4k pages */
> 	sane_nr = min(nr, MAX_REMOTE_READAHEAD);
> 
>         /*
>          * We sanitize readahead size depending on free memory in
>          * the local node.
>          */
>         local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
>                           + node_page_state(nid, NR_FREE_PAGES);
>         return min(sane_nr, local_free_page / 2);
> }
> 

I have no opinion on the 4KB pages, either of the above is just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
