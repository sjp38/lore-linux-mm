Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id D78936B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:47:41 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id q200so3721927ykb.1
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:47:41 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o44si5467593yhb.1.2015.01.19.07.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 07:47:40 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 0/2] mm: infrastructure for correctly handling foreign pages on Xen
Date: Mon, 19 Jan 2015 15:47:21 +0000
Message-ID: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org

These two patches are the common parts of a larger Xen series[1]
fixing several long-standing bugs the handling of foreign[2] pages in
Xen guests.

Andrew, these are best merged via the Xen tree.  Can I have an acked-by?

The first patch is required to fix get_user_pages[_fast]() with
userspace space mappings of such foreign pages.  Basically, pte_page()
doesn't work so an alternate mechanism is needed to get the page from
a VMA and address.  By requiring mappings needing this method are
'special' this should not have an impact on the common use cases.

The second patch isn't essential but helps with readability of the
resulting user of the page flag.

For further background reading see:

  http://xenbits.xen.org/people/dvrabel/grant-improvements-C.pdf

Changes in v3:

- find_page renamed to find_special_page.
- added documentation.

Changes in v2:

- Add a find_page VMA op instead of the pages field so: a) the size of
  struct vm_area_struct does not increase; and b) the common code need
  not handling splitting the pages area.

David

[1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg00979.html

[2] Another guest's page temporarily granted to this guest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
