Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9EA646B0047
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 15:17:43 -0500 (EST)
Message-ID: <4B97FED5.2030007@redhat.com>
Date: Wed, 10 Mar 2010 22:19:33 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: mm/ksm.c seems to be doing an unneeded _notify.
References: <20100310191842.GL5677@sgi.com>
In-Reply-To: <20100310191842.GL5677@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 03/10/2010 09:18 PM, Robin Holt wrote:
> While reviewing ksm.c, I noticed that ksm.c does:
>
>          if (pte_write(*ptep)) {
>                  pte_t entry;
>
>                  swapped = PageSwapCache(page);
>                  flush_cache_page(vma, addr, page_to_pfn(page));
>                  /*
>                   * Ok this is tricky, when get_user_pages_fast() run it doesnt
>                   * take any lock, therefore the check that we are going to make
>                   * with the pagecount against the mapcount is racey and
>                   * O_DIRECT can happen right after the check.
>                   * So we clear the pte and flush the tlb before the check
>                   * this assure us that no O_DIRECT can happen after the check
>                   * or in the middle of the check.
>                   */
>                  entry = ptep_clear_flush(vma, addr, ptep);
>                  /*
>                   * Check that no O_DIRECT or similar I/O is in progress on the
>                   * page
>                   */
>                  if (page_mapcount(page) + 1 + swapped != page_count(page)) {
>                          set_pte_at_notify(mm, addr, ptep, entry);
>                          goto out_unlock;
>                  }
>                  entry = pte_wrprotect(entry);
>                  set_pte_at_notify(mm, addr, ptep, entry);
>
>
> I would think the error case (where the page has an elevated page_count)
> should not be using set_pte_at_notify.  In that event, you are simply
> restoring the previous value.  Have I missed something or is this an
> extraneous _notify?
>    

Yes, I think you are right set_pte_at(mm, addr, ptep, entry);  would be
enough here.

I can`t remember or think any reason why I have used the _notify...

Lets just get ACK from Andrea and Hugh that they agree it isn't needed

Thanks.

> Thanks,
> Robin Holt
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
