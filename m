Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 392C56B0385
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z1so10024362pfh.3
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id f25-v6si20518599pgv.47.2018.05.09.00.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:16 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: fix confusion around GFP_* flags and blk_get_request
Date: Wed,  9 May 2018 09:54:02 +0200
Message-Id: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series sorts out the mess around how we use gfp flags in the
block layer get_request interface.

Changes since RFC:
  - don't switch to GFP_NOIO for allocations in blk_get_request.
    blk_get_request is used by the multipath code in potentially dead lock
    prone areas, so this will need a separate audit and maybe a flag.
