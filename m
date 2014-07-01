Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A16566B0035
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:27:19 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so10780899pdb.35
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:27:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id os9si28285165pac.155.2014.07.01.15.27.17
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 15:27:18 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:27:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
 v2
Message-Id: <20140701152716.b9b4b04ee67cf987844b1aa4@linux-foundation.org>
In-Reply-To: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
References: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, 30 Jun 2014 17:32:16 -0700 Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> When a hwpoison page is locked it could change state
> due to parallel modifications.  Check after the lock
> if the page is still the same compound page.
> 
> ...
>
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1168,6 +1168,16 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	lock_page(hpage);
>  
>  	/*
> +	 * The page could have changed compound pages during the locking.
> +	 * If this happens just bail out.
> +	 */
> +	if (compound_head(p) != hpage) {

How can a 4k page change compound pages?  The original compound page
was torn down and then this 4k page became part of a differently-sized
compound page?

> +		action_result(pfn, "different compound page after locking", IGNORED);
> +		res = -EBUSY;
> +		goto out;
> +	}
> +
> +	/*

I don't get it.  We just go and fail the poisoning attempt?  Shouldn't
we go back, grab the new hpage and try again?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
