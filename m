Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E133C49ED9
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 02:52:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3671F216F4
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 02:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LRu6iD6Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3671F216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4D16B0005; Tue, 10 Sep 2019 22:52:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 875086B0006; Tue, 10 Sep 2019 22:52:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78A9B6B0007; Tue, 10 Sep 2019 22:52:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 568C76B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:52:03 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id ED22452CE
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:52:02 +0000 (UTC)
X-FDA: 75921115284.19.group48_2ef1cb234684e
X-HE-Tag: group48_2ef1cb234684e
X-Filterd-Recvd-Size: 2678
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:52:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:Message-ID:
	Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PNNRbBM+ZsiFh/QzrWWJo+0Oaes86g1L+e4LhQmEhqk=; b=LRu6iD6ZpZkWtc3muCv5IpCHca
	ATXFJ7baQ1s0PJaPodE7T5TpCUji2Dsyx7KBeo/oYjefxqF9TQuZlJkVWaXg4ldVX0mst/PraGHOS
	J9f6r0LgVWtCl/onz/gkvz1iHEeYktQYLo1Knqn8UoVM65uWhjvTg23NqrYEq65F27IT2mHP6fXB1
	oyMoCbw311mN1anXKXttFPb5deo6F1LpabmaPw3/C80evhPwHj7rBVKBPLxW5lJsEVFemizp32aSD
	+eQD7zcs06MCYxi0ELC/N+7FczQZbnuokJsC9kGK6VM/ulRovQvY1Z5wE/c8H9xszq9RXQjRjJz3I
	3wpLmOuw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i7sje-0007ys-6T; Wed, 11 Sep 2019 02:51:58 +0000
Date: Tue, 10 Sep 2019 19:51:58 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Subject: filemap_fault can lose errors
Message-ID: <20190911025158.GG29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


If we encounter an error on a page, we can lose the error if we've
dropped the mmap_sem while we wait for the I/O.  That can result in
taking the fault multiple times, and retrying the read multiple times.
Spotted by inspection.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Fixes: 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking operations")

diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..37bd4aedfccf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2615,6 +2615,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		if (!PageUptodate(page))
 			error = -EIO;
 	}
+	if (error < 0)
+		ret |= VM_FAULT_SIGBUS;
 	if (fpin)
 		goto out_retry;
 	put_page(page);
@@ -2622,9 +2624,9 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	if (!error || error == AOP_TRUNCATED_PAGE)
 		goto retry_find;
 
-	/* Things didn't work out. Return zero to tell the mm layer so. */
+	/* Things didn't work out. */
 	shrink_readahead_size_eio(file, ra);
-	return VM_FAULT_SIGBUS;
+	return ret;
 
 out_retry:
 	/*


