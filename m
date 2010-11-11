Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 59CFB6B0071
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 23:58:24 -0500 (EST)
Date: Thu, 11 Nov 2010 11:45:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] fix __set_page_dirty_no_writeback() return value
Message-ID: <20101111034546.GA20299@localhost>
References: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
 <20101111032644.GB18483@localhost>
 <AANLkTikCf_bLrLuhxpPmEyheTMgBK-h=B66n1pjJA_WL@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikCf_bLrLuhxpPmEyheTMgBK-h=B66n1pjJA_WL@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kenchen@google.com" <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:36:48AM +0800, Bob Liu wrote:
> On Thu, Nov 11, 2010 at 11:26 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Thu, Nov 11, 2010 at 11:05:54AM +0800, Bob Liu wrote:
> >> __set_page_dirty_no_writeback() should return true if it actually transitioned
> >> the page from a clean to dirty state although it seems nobody used its return
> >> value now.
> >>
> >> Change from v1:
> >> A  A  A  * preserving cacheline optimisation as Andrew pointed out
> >>
> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >> ---
> >> A mm/page-writeback.c | A  A 4 +++-
> >> A 1 files changed, 3 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >> index bf85062..ac7018a 100644
> >> --- a/mm/page-writeback.c
> >> +++ b/mm/page-writeback.c
> >> @@ -1157,8 +1157,10 @@ EXPORT_SYMBOL(write_one_page);
> >> A  */
> >> A int __set_page_dirty_no_writeback(struct page *page)
> >> A {
> >> - A  A  if (!PageDirty(page))
> >> + A  A  if (!PageDirty(page)) {
> >> A  A  A  A  A  A  A  SetPageDirty(page);
> >> + A  A  A  A  A  A  return 1;
> >> + A  A  }
> >> A  A  A  return 0;
> >> A }
> >
> > It's still racy if not using TestSetPageDirty(). In fact
> > set_page_dirty() has a default reference implementation:
> 
> Yes, Andrew had also pointed out that. And I have send v3 fix this.
> Could you ack it?

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks!

> >
> > A  A  A  A if (!PageDirty(page)) {
> > A  A  A  A  A  A  A  A if (!TestSetPageDirty(page))
> > A  A  A  A  A  A  A  A  A  A  A  A return 1;
> 
> return !TestSetPageDirty(page) is more simply?

Yeah that's fine.

> > A  A  A  A }
> > A  A  A  A return 0;
> >
> > It seems the return value currently is only tested for doing
> > balance_dirty_pages_ratelimited(). So not a big problem.
> >
> 
> yeah, all those are small changes no matter with any problem:-).

It's always good to make it correct :) I looked at the users mainly to
answer the question: is it a must fix for 2.6.37 or even 2.6.36.x?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
