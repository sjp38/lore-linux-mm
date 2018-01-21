Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 728AA6B0003
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 18:49:43 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 9so5285122otu.17
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 15:49:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 100si467962oti.126.2018.01.21.15.49.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Jan 2018 15:49:42 -0800 (PST)
Message-Id: <201801212349.w0LNna1E022604@www262.sakura.ne.jp>
Subject: Re: [PATCHv2] mm, =?ISO-2022-JP?B?cGFnZV92bWFfbWFwcGVkOiBEcm9wIGZhdWx0?=
 =?ISO-2022-JP?B?eSBwb2ludGVyIGFyaXRobWV0aWNzIGluIGNoZWNrX3B0ZSgp?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Mon, 22 Jan 2018 08:49:36 +0900
References: <20180119124924.25642-1-kirill.shutemov@linux.intel.com> <CA+55aFxobYQ5cqnCZuf8xVWr3hCUmg=rTxDPV3zHWqeQysVkxA@mail.gmail.com>
In-Reply-To: <CA+55aFxobYQ5cqnCZuf8xVWr3hCUmg=rTxDPV3zHWqeQysVkxA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>

Linus Torvalds wrote:
> On Fri, Jan 19, 2018 at 4:49 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > +       if (pfn < page_to_pfn(pvmw->page))
> > +               return false;
> > +
> > +       /* THP can be referenced by any subpage */
> > +       if (pfn - page_to_pfn(pvmw->page) >= hpage_nr_pages(pvmw->page))
> > +               return false;
> > +
> 
> Is gcc actually clever enough to merge these? The "page_to_pfn()"
> logic can be pretty expensive (exactly for the sparsemem case, but
> per-node DISCOTIGMEM has some complexity too.

As far as I tested, using helper function made no difference. Unless I
explicitly insert barriers like cpu_relax() or smp_mb() between these,
the object side does not change.

> 
> So I'd prefer to make that explicit, perhaps by having a helper
> function that does this something like
> 
>    static inline bool pfn_in_hpage(unsigned long pfn, struct page *hpage)
>    {
>         unsigned long hpage_pfn = page_to_pfn(hpage);
> 
>         return pfn >= hpage_pfn &&  pfn - hpage_pfn < hpage_nr_pages(hpage);
>     }
> 
> and then just use
> 
>     return pfn_in_hpage(pfn, pvmw->page);
> 
> in that caller. Hmm? Wouldn't that be more legible, and avoid the
> repeated pvmw->page and page_to_pfn() cases?
> 
> Even if maybe gcc can do the CSE and turn it all into the same thing
> in the end..

You can apply with

  Acked-by: Michal Hocko <mhocko@suse.com> 
  Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
