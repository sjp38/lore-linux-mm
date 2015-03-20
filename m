Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E37696B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 04:04:25 -0400 (EDT)
Received: by wgra20 with SMTP id a20so82588867wgr.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 01:04:25 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id e5si6031426wjy.124.2015.03.20.01.04.24
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 01:04:24 -0700 (PDT)
Date: Fri, 20 Mar 2015 10:04:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/16] page-flags: define PG_locked behavior on compound
 pages
Message-ID: <20150320080416.GA15877@node.dhcp.inet.fi>
References: <010501d062df$05125160$0f36f420$@alibaba-inc.com>
 <010601d062df$f7b5a4d0$e720ee70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010601d062df$f7b5a4d0$e720ee70$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Mar 20, 2015 at 03:32:05PM +0800, Hillf Danton wrote:
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -269,7 +269,7 @@ static inline struct page *compound_head_fast(struct page *page)
> >  	return page;
> >  }
> > 
> > -TESTPAGEFLAG(Locked, locked, ANY)
> > +__PAGEFLAG(Locked, locked, NO_TAIL)
> >  PAGEFLAG(Error, error, ANY) TESTCLEARFLAG(Error, error, ANY)
> >  PAGEFLAG(Referenced, referenced, ANY) TESTCLEARFLAG(Referenced, referenced, ANY)
> >  	__SETPAGEFLAG(Referenced, referenced, ANY)
> [...]
> > @@ -490,9 +481,9 @@ extern int wait_on_page_bit_killable_timeout(struct page *page,
> > 
> >  static inline int wait_on_page_locked_killable(struct page *page)
> >  {
> > -	if (PageLocked(page))
> > -		return wait_on_page_bit_killable(page, PG_locked);
> > -	return 0;
> > +	if (!PageLocked(page))
> > +		return 0;
> 
> I am lost here: can we feed any page to NO_TAIL operation?

NO_TAIL triggers VM_BUG on set/clear, but not on checks. PageLocked() will
look on head page.

I tried to enforce policy for checks too, but it triggers all over the
kernel. We tend to check random pages.

We can try apply enforcing for *some* flags, but I didn't evaluate that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
