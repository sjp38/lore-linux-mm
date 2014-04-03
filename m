Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id E863F6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 15:09:55 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id b8so1669054lan.40
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:55 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id on7si4106224lbb.221.2014.04.03.12.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 12:09:54 -0700 (PDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so1699606lab.34
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:53 -0700 (PDT)
Message-Id: <20140403184844.260532690@openvz.org>
Date: Thu, 03 Apr 2014 22:48:44 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 0/3] Cleaning up soft-dirty bit usage
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: gorcunov@openvz.org, linux-mm@kvack.org

Hi! I've been trying to clean up soft-dirty bit usage. I can't cleanup
"ridiculous macros in pgtable-2level.h" completely because I need to
define _PAGE_FILE,_PAGE_PROTNONE,_PAGE_NUMA bits in sequence manner
like

#define _PAGE_BIT_FILE		(_PAGE_BIT_PRESENT + 1)	/* _PAGE_BIT_RW */
#define _PAGE_BIT_NUMA		(_PAGE_BIT_PRESENT + 2)	/* _PAGE_BIT_USER */
#define _PAGE_BIT_PROTNONE	(_PAGE_BIT_PRESENT + 3)	/* _PAGE_BIT_PWT */

which can't be done right now because numa code needs to save original
pte bits for example in __split_huge_page_map, if I'm not missing something
obvious.

Also if we ever redefine the bits above we will need to update PAT code
which uses _PAGE_GLOBAL + _PAGE_PRESENT to make pte_present return true
or false.

Another weird thing I found is the following sequence:

   mprotect_fixup
    change_protection (passes @prot_numa = 0 which finally ends up in)
      ...
      change_pte_range(..., prot_numa)

			if (!prot_numa) {
				...
			} else {
				... this seems to be dead code branch ...
			}

    is it intentional, and @prot_numa argument is supposed to be passed
    with prot_numa = 1 one day, or it's leftover from old times?

Note I've not yet tested the series building it now, hopefully finish
testing in a couple of hours.

Linus, by saying "define the bits we use when PAGE_PRESENT==0 separately
and explicitly" you meant complete rework of the bits, right? Not simply
group them in once place in a header?

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
