Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0985EC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C523A208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C523A208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 602D16B0003; Sat, 27 Apr 2019 02:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D7526B0005; Sat, 27 Apr 2019 02:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED116B0006; Sat, 27 Apr 2019 02:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0196C6B0003
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:18:17 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r7so5760291wrv.19
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:18:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5bn7149UBqTO/bGoYDflR+GGrfgzfwoiCgZqrYPyQME=;
        b=NZ1X1sJSPyABVC/T9B3f2YHPfjwiKyyzEBJ6g+qF124quFNGzEBggQkkZTGwqZ11Bz
         Z5WFP80ujI01oOPPgZ6yNkrHv6GYry93oUTkKkyujbmTjONsKnki3Rm3OBMzByk1sHvT
         uMPz8ojKaGND6yKvRqPNvKwdQolKew30HNxjyxxFkCufnoqxDpvZx19IAfrJupYYI6oq
         /JUt4ItgUOyLOf8X61IaIIS4B6b5ywI4FbMh6JZfuGu8m4NKKyQBzOXCCmwd0qRyEY3U
         7l+yylgDoOloAPhcnh3gfn8bd7BQJ5M4jhwSrt9WjRXzbrauqzmurmsK8vWIAa0CiQOw
         FhGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVS30KdPQagwa+Y7dY0wGpXWqbHFW2I2zRnfypt5AFqfL748PbO
	F85EJ4eU5b+A+n4Rp9XAhiLAKWAhTVsHFqFOcqxlsftCXt78gycEmiuX2/iRFO9/ZHA9/uKIOrw
	Dduu1pDseRwT/66KeIJHp5OO01s90KYqDIY45QEIr79WSJSwZjI18PG4E01R4FTs1xQ==
X-Received: by 2002:a05:600c:28b:: with SMTP id 11mr10121344wmk.153.1556345896513;
        Fri, 26 Apr 2019 23:18:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/tCTpE6inqlDsKnL5gL+5YfSbjjLEv3CQq7Ew/7C1lpicTNJbFfGLcp9vA/VmYibCXFrZ
X-Received: by 2002:a05:600c:28b:: with SMTP id 11mr10121308wmk.153.1556345895640;
        Fri, 26 Apr 2019 23:18:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556345895; cv=none;
        d=google.com; s=arc-20160816;
        b=S9raZkQpn0atwzgAnHJVKifGtolPsk+qeinvXPadBfiVdjEyknQ45tr5qzZUpf4GyA
         yfXmCL1L3ScIhZOzp5WLITjKZVYIK08j0/ZSuItnyVGh3SVaW54LirZzrski68Vsdbnn
         ywZGXMrV4WnEerr7HkY56TefEalV0MK0zFhIpDGCo5VIlmOox7jVuYpV3/rEDsM8x2kR
         NIhR3ps3OG3iAAOFA1TcuQiM3bw1qlHzqNQq4jKugbKbcsNeG0MY6PtIDffSLcNrGg87
         gp1Lb2/o5DhHm8YMSA5FAuYwLRozKVsCsKzsMXmr4MWT2juAZ8PG6AiC5q5K9D9T+aY5
         nkhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5bn7149UBqTO/bGoYDflR+GGrfgzfwoiCgZqrYPyQME=;
        b=dIQCP7sfZCKgvjALyvOIzQbcnj+Aa1VnFSwZTZyEEJB2ojcweK8xw+dDe6t2LYgZ8T
         Y2gcMXxPrFWVmNTa6gdenZVDCHjwjmwXZw3Si1o16vzjHDVWwhFCUMti1PurWAXBOvrr
         bSxUM+mLJENzNne4ZcexOj4Dpy7zfMzuARNUn+rQWDwzAFU2GRy5pb2oHI0MpykZaSBf
         MOtTyIKufF0uoWgbIF+RSm9e6gdw+rUGUl7kazX2EQL+6ea87zJlGsT+8QS587jquFpp
         pAWYrbWhNMSgB/Vyfo4N9gdiYuCTThH8GWW5ZamrJ9lylI37G5WW1pQla51h6C2Wcf+f
         09sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 14si5883965wmi.49.2019.04.26.23.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:18:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id DEBE668BFE; Sat, 27 Apr 2019 08:17:59 +0200 (CEST)
Date: Sat, 27 Apr 2019 08:17:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v5 1/3] iomap: Fix use-after-free error in page_done
 callback
Message-ID: <20190427061759.GA21795@lst.de>
References: <20190426131127.19164-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426131127.19164-1-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This looks ok to me, holding the page over the i_size update
and mark_inode_dirty should be ok.  But I think it would be a lot
cleaner if rebased ontop of this cleanup, which you could add to the
front of the series:

---
From 908dbc5e7c26035f992fef84886976e0cda10b98 Mon Sep 17 00:00:00 2001
From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Apr 2019 08:13:38 +0200
Subject: iomap: cleanup __generic_write_end calling conventions

Move the call to __generic_write_end into the common code flow instead
of duplicating it in each of the three branches.  This requires open
coding the generic_write_end for the buffer_head case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index abdd18e404f8..cfc8a10b3fd8 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -738,13 +738,11 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	 * uptodate page as a zero-length write, and force the caller to redo
 	 * the whole thing.
 	 */
-	if (unlikely(copied < len && !PageUptodate(page))) {
-		copied = 0;
-	} else {
-		iomap_set_range_uptodate(page, offset_in_page(pos), len);
-		iomap_set_page_dirty(page);
-	}
-	return __generic_write_end(inode, pos, copied, page);
+	if (unlikely(copied < len && !PageUptodate(page)))
+		return 0;
+	iomap_set_range_uptodate(page, offset_in_page(pos), len);
+	iomap_set_page_dirty(page);
+	return copied;
 }
 
 static int
@@ -761,7 +759,6 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
 	kunmap_atomic(addr);
 
 	mark_inode_dirty(inode);
-	__generic_write_end(inode, pos, copied, page);
 	return copied;
 }
 
@@ -774,12 +771,13 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	if (iomap->type == IOMAP_INLINE) {
 		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
 	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
-		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
-				copied, page, NULL);
+		ret = block_write_end(NULL, inode->i_mapping, pos, len, copied,
+				page, NULL);
 	} else {
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
+	ret = __generic_write_end(inode, pos, ret, page);
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
 
-- 
2.20.1

