Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 573C26B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 09:24:41 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id pv20so4674515lab.24
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 06:24:40 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id 1si12291386lam.90.2014.04.07.06.24.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 06:24:39 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id pv20so4736169lab.38
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 06:24:39 -0700 (PDT)
Date: Mon, 7 Apr 2014 17:24:37 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [rfc 0/3] Cleaning up soft-dirty bit usage
Message-ID: <20140407132437.GH1444@moon>
References: <20140403184844.260532690@openvz.org>
 <20140407130701.GA16677@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140407130701.GA16677@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 07, 2014 at 04:07:01PM +0300, Kirill A. Shutemov wrote:
> On Thu, Apr 03, 2014 at 10:48:44PM +0400, Cyrill Gorcunov wrote:
> > Hi! I've been trying to clean up soft-dirty bit usage. I can't cleanup
> > "ridiculous macros in pgtable-2level.h" completely because I need to
> > define _PAGE_FILE,_PAGE_PROTNONE,_PAGE_NUMA bits in sequence manner
> > like
> > 
> > #define _PAGE_BIT_FILE		(_PAGE_BIT_PRESENT + 1)	/* _PAGE_BIT_RW */
> > #define _PAGE_BIT_NUMA		(_PAGE_BIT_PRESENT + 2)	/* _PAGE_BIT_USER */
> > #define _PAGE_BIT_PROTNONE	(_PAGE_BIT_PRESENT + 3)	/* _PAGE_BIT_PWT */
> > 
> > which can't be done right now because numa code needs to save original
> > pte bits for example in __split_huge_page_map, if I'm not missing something
> > obvious.
> 
> Sorry, I didn't get this. How __split_huge_page_map() does depend on pte
> bits order?

__split_huge_page_map
  ...
  for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
    ...
    here we modify with pte bits
    entry = pte_mknuma(entry); --> clean _PAGE_PRESENT and set _PAGE_NUMA

    pte bits must remain valid and meaningful, for example we might
    have set _PAGE_RW here

> >     is it intentional, and @prot_numa argument is supposed to be passed
> >     with prot_numa = 1 one day, or it's leftover from old times?
> 
> I see one more user of change_protection() -- change_prot_numa(), which
> has .prot_numa == 1.

Yeah, thanks, managed to miss this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
