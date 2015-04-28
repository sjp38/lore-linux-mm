Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 94E536B0089
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:27:43 -0400 (EDT)
Received: by wgin8 with SMTP id n8so181063wgi.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:27:43 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ck4si18839215wib.31.2015.04.28.09.27.41
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 09:27:42 -0700 (PDT)
Date: Tue, 28 Apr 2015 19:27:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse the
 page on WP fault
Message-ID: <20150428162734.GA2539@node.dhcp.inet.fi>
References: <001901d0815e$f438b390$dcaa1ab0$@alibaba-inc.com>
 <002001d0815f$ce928750$6bb795f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002001d0815f$ce928750$6bb795f0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Apr 28, 2015 at 11:02:46AM +0800, Hillf Danton wrote:
> > 
> > With new refcounting we will be able map the same compound page with
> > PTEs and PMDs. It requires adjustment to conditions when we can reuse
> > the page on write-protection fault.
> > 
> > For PTE fault we can't reuse the page if it's part of huge page.
> > 
> > For PMD we can only reuse the page if nobody else maps the huge page or
> > it's part. We can do it by checking page_mapcount() on each sub-page,
> > but it's expensive.
> > 
> > The cheaper way is to check page_count() to be equal 1: every mapcount
> > takes page reference, so this way we can guarantee, that the PMD is the
> > only mapping.
> > 
> > This approach can give false negative if somebody pinned the page, but
> > that doesn't affect correctness.
> >
> Then we have to try more to allocate THP if pinned?
> Are we adding new cost?

Yes we do. But that shouldn't be often.

Alternatively, we could iterate over all sub-pages and check their
mapcount.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
