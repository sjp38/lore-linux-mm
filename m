Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFFA6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:58:28 -0400 (EDT)
Received: by igau2 with SMTP id u2so76639143iga.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:58:28 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id e34si3971006ioi.0.2015.07.08.16.58.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:58:28 -0700 (PDT)
Received: by ieru20 with SMTP id u20so23045525ier.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:58:28 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:58:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
In-Reply-To: <55946EA9.2080805@oracle.com>
Message-ID: <alpine.DEB.2.10.1507081653220.16585@chino.kir.corp.google.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com> <55943DC1.6010209@oracle.com> <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com>
 <55946EA9.2080805@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Wed, 1 Jul 2015, Sasha Levin wrote:

> Since we'd BUG at VM_BUG_ON(), this would be something closer to:
> 
> 	if (unlikely(compound_head(page) != head)) {
> 		dump_page(page);
> 		dump_page(head);
> 		VM_BUG_ON(1);
> 	}
> 

I was thinking closer to

	if (VM_WARN_ON(compound_head(page) != head)) {
		...
		BUG();
	}

so we prefix all output with the typical warning diagnostics, emit 
whatever page, vma, etc output we want, and then finally die.  The final 
BUG() here would have to be replaced by something that suppresses the 
repeated output.

If it's really just a warning, then no BUG() needed.

> But my point here was that while one *could* do it that way, no one does because
> it's not intuitive. We both agree that in the example above it would be useful to
> see both 'page' and 'head', and yet the code that was written didn't dump any of
> them. Why? No one wants to write debug code unless it's easy and short.
> 

pr_alert("%pZp %pZv", page, vma) isn't shorter than dump_page(page); 
dump_vma(vma), but it would be a line shorter.  I'm not sure that the 
former is easier, though, and it prevents us from ever expanding dump_*() 
functions for conditional output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
