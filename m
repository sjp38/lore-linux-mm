Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 699BA6B0037
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:49:53 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so4364214pbb.1
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 11:49:53 -0700 (PDT)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
        by mx.google.com with ESMTPS id tk5si2680553pbc.510.2014.04.10.11.49.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 11:49:52 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so4214605pdj.23
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 11:49:51 -0700 (PDT)
Message-ID: <5346E7CB.2010500@linaro.org>
Date: Thu, 10 Apr 2014 11:49:47 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] vrange: Add page purging logic & SIGBUS trap
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-4-git-send-email-john.stultz@linaro.org> <CAHGf_=q_1ZxDOdA7HCVUh2LYK9wwKbLsru__nXrXEQ2WEdjguQ@mail.gmail.com>
In-Reply-To: <CAHGf_=q_1ZxDOdA7HCVUh2LYK9wwKbLsru__nXrXEQ2WEdjguQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hey Kosaki-san,
  Just a few follow ups on your comments here in preparation for v13.

On 03/23/2014 04:44 PM, KOSAKI Motohiro wrote:
> On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
> @@ -683,6 +684,7 @@ enum page_references {
>         PAGEREF_RECLAIM,
>         PAGEREF_RECLAIM_CLEAN,
>         PAGEREF_KEEP,
> +       PAGEREF_DISCARD,
> "discard" is alread used in various place for another meanings.
> another name is better.

Any suggestions here? Is PAGEREF_PURGE better?


>
>>         PAGEREF_ACTIVATE,
>>  };
>>
>> @@ -703,6 +705,13 @@ static enum page_references page_check_references(struct page *page,
>>         if (vm_flags & VM_LOCKED)
>>                 return PAGEREF_RECLAIM;
>>
>> +       /*
>> +        * If volatile page is reached on LRU's tail, we discard the
>> +        * page without considering recycle the page.
>> +        */
>> +       if (vm_flags & VM_VOLATILE)
>> +               return PAGEREF_DISCARD;
>> +
>>         if (referenced_ptes) {
>>                 if (PageSwapBacked(page))
>>                         return PAGEREF_ACTIVATE;
>> @@ -930,6 +939,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>                 switch (references) {
>>                 case PAGEREF_ACTIVATE:
>>                         goto activate_locked;
>> +               case PAGEREF_DISCARD:
>> +                       if (may_enter_fs && !discard_vpage(page))
> Wny may-enter-fs is needed? discard_vpage never enter FS.

I think this is a hold over from the file based/shared volatility.
Thanks for pointing it out, I've dropped the may_enter_fs check.


>> +       /*
>> +        * During interating the loop, some processes could see a page as
>> +        * purged while others could see a page as not-purged because we have
>> +        * no global lock between parent and child for protecting vrange system
>> +        * call during this loop. But it's not a problem because the page is
>> +        * not *SHARED* page but *COW* page so parent and child can see other
>> +        * data anytime. The worst case by this race is a page was purged
>> +        * but couldn't be discarded so it makes unnecessary page fault but
>> +        * it wouldn't be severe.
>> +        */
>> +       anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
>> +               struct vm_area_struct *vma = avc->vma;
>> +
>> +               if (!(vma->vm_flags & VM_VOLATILE))
>> +                       continue;
> When you find !VM_VOLATILE vma, we have no reason to continue pte zapping.
> Isn't it?

Sounds reasonable. I'll switch to breaking out here and returning an
error if Minchan doesn't object.


>
>> +               try_to_discard_one(page, vma);
>> +       }
>> +       page_unlock_anon_vma_read(anon_vma);
>> +       return 0;
>> +}
>> +
>> +
>> +/**
>> + * discard_vpage - If possible, discard the specified volatile page
>> + *
>> + * Attempts to discard a volatile page, and if needed frees the swap page
>> + *
>> + * Returns 0 on success, -1 on error.
>> + */
>> +int discard_vpage(struct page *page)
>> +{
>> +       VM_BUG_ON(!PageLocked(page));
>> +       VM_BUG_ON(PageLRU(page));
>> +
>> +       /* XXX - for now we only support anonymous volatile pages */
>> +       if (!PageAnon(page))
>> +               return -1;
>> +
>> +       if (!try_to_discard_vpage(page)) {
>> +               if (PageSwapCache(page))
>> +                       try_to_free_swap(page);
> This looks strange. try_to_free_swap can't handle vpurge pseudo entry.

So I may be missing some of the subtleties of the swap code, but the
vpurge pseudo swp entry is on the pte, where as here we're just trying
to make sure that before we drop the page we disconnect any swap-backing
the page may have (if it were swapped out previously before being marked
volatile). Let me know if I'm just not understanding the code or your point.


>> +
>> +               if (page_freeze_refs(page, 1)) {
> Where is page_unfreeze_refs() for the pair of this?

Since we're about to free the page I don't think we need a unfreeze_refs
pair? Or am I just misunderstanding the rules here?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
