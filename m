Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A38C282DD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:38:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DED6620863
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:38:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="BsYKWOSx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DED6620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 419DA6B0266; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CA416B0269; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B96B6B026A; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB5706B0266
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 22:38:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so9394323pfn.13
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 19:38:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=tzoD7/UP5hn6NP3TTucEhZEEXF13u+yP12/csDZED9Y=;
        b=aBwiZ3BEcLp/rPDHgxg06oKNk8mJmfvU5/jB3bjFPKEu9r9RqTbXCIAIctwA8TflEs
         5Q9/1TouryNJzobRqymFeYdh/nrQ2DKrpWbxDlJouNhtteWHVaDFjVBkT/fei2piBc/j
         choVbqduFsgagj5YEIleMoA4x6Mtjw2o3U3TOeW08WrVLEz8GN1PREvujnCyLIGdDYBP
         8d7DEB0rEAoL9/GkkxpaPlDi7uneDbaOLXnEmZXnS/SqQCIsmRXXdpmMPFyhmUgrfnui
         4jtNwutF7MVJPwr6oGjoc4qMSXsLpRT5fT05j0ZRAKqihoQmCPD7/pkc2rE50g16KYrG
         uSyQ==
X-Gm-Message-State: APjAAAUu/YBNBsTBUfjlPvmw1aRTcjQd9FCZVNTd+DQc3VrryZwg1wOV
	OcL9q8fReHofuws57t/jg9Ex02VzGIL7KFxqxRXJFlJkVfHqObFd62vV9zfcLynem2y7mMSsz5I
	q1GYf6C0qGpPgrfg0Vb5/97kro0SUye+bnBPMG4NFPkY1eSNQUnM1if/25RjYYFVIUA==
X-Received: by 2002:aa7:8c13:: with SMTP id c19mr26844971pfd.225.1554691097380;
        Sun, 07 Apr 2019 19:38:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRO9UG2ABxMnbKaMk39cINYojoi8LUtbVNUjt+pEOmAFCrXWC18dWpgqYlUwulau6x9A8l
X-Received: by 2002:aa7:8c13:: with SMTP id c19mr26844909pfd.225.1554691096493;
        Sun, 07 Apr 2019 19:38:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554691096; cv=none;
        d=google.com; s=arc-20160816;
        b=jJtekN6yJn158GGjL1zbq3iIW3VRVpHO8soQpHlDwbVSMgjkjuRerTkpHhIQ7Bkz66
         XW4mDeHKm9bNO2AJhrJufjTFIHV/upKJQzBu4lyfedOOWmzMEalJWFru6a91qIKcdcVF
         811T8Ll6Uu+T/rDV3O6kmmOrdOb5U5BUvBbqeI3wdhPlOlo7YVwtHWhT6JK/Xng/HO2E
         uChYSpGaHnd5MqUum30/h40LUVEBbIeE1muIFuA0n7/JvHJUdGhwonAaw2lgJX0MdXwv
         Pu0FjdSZXBQm9FdC+Evfp5YectAtSjF2KXzfmdWoD/9fpjEKzHfNM8hf+bCgmybE3BKY
         /ggw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=tzoD7/UP5hn6NP3TTucEhZEEXF13u+yP12/csDZED9Y=;
        b=erh7xPJ0Z1PTMZNkcdXHnTVRkW6lJfH6DtciFdsyXUJhneywO559mjQ/uItxExLNv8
         UeKOR8g/3k1Oi0tvgW4y6CpQWEVdsKbnUPQpOrWYoOXGl71Ox+uspKqPpZtLFMka3xEV
         msMXHyHdXo/wKFAwNjmty1fHNMwDcJX0uXn0j5vXhIfjHufjCYu5NwnZQfaGjHSCQb2q
         94J48oN59xHyVSm2E9Bztuu5MvlvxjcfgARCFIAnwJofYM6qD4Vx4JDU4Xiw7jZt3gE0
         4W6A/JsvuWZk4BDukKKsy4SHRxjJPsXtLHMpTB5GjHKeOW6Zd7ek+Po3iC4CjqjyCxEi
         IgBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=BsYKWOSx;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id y70si23704049pgd.359.2019.04.07.19.38.15
        for <linux-mm@kvack.org>;
        Sun, 07 Apr 2019 19:38:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=BsYKWOSx;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-78bff700000078a3-e6-5caab416f80f
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id 18.E3.30883.614BAAC5; Mon,  8 Apr 2019 10:38:14 +0800 (HKT)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554691094; h=from:subject:to:date:message-id;
	bh=tzoD7/UP5hn6NP3TTucEhZEEXF13u+yP12/csDZED9Y=;
	b=BsYKWOSxOXzNpyWhKBsZ8PghVoln3efa5ivV1tuSkkiQm8YFTJay0XANorprR+Rzw790+iJRc0N
	sfs7a1RYeVx86aoORubAeds/CVpzfubkijCsZDshgj/+IhJS8AZvi0NOgs+GpKKGCbQDY5soOuKNo
	DAKqtoEAqrLTfCTXFM4=
Received: from hsj-Precision-5520.iluvatar.local (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Mon, 8 Apr 2019 10:38:14 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: <akpm@linux-foundation.org>
CC: <william.kucharski@oracle.com>, <ira.weiny@intel.com>,
	<palmer@sifive.com>, <axboe@kernel.dk>, <keescook@chromium.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Huang Shijie
	<sjhuang@iluvatar.ai>
Subject: [PATCH 1/2] mm/gup.c: fix the wrong comments
Date: Mon, 8 Apr 2019 10:37:45 +0800
Message-ID: <20190408023746.16916-1-sjhuang@iluvatar.ai>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-105.iluvatar.local (10.101.1.105) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFrrLLMWRmVeSWpSXmKPExsXClcqYpiu2ZVWMwakl2hZz1q9hs1h9t5/N
	Yv/T5ywWZ7pzLS7vmsNmcW/Nf1aLzRMWAInFXUwOHB6zGy6yeCze85LJ4/LZUo9Nnyaxe5yY
	8ZvF4+PTWywel5qvs3t83iQXwBHFZZOSmpNZllqkb5fAlXF2nljBXr6Ks7ubmRoYD3N3MXJy
	SAiYSLycd5q5i5GLQ0jgBKPErysN7CAJZgEJiYMvXoAlWATeMklca/8MVdXKJHFu6ySwKjYB
	DYm5J+4yg9giAvISTV8esYMUMQvcYpTYMeEJC0hCWMBUYvXCrawgNouAisSp3U1sIDavgIXE
	uvaFjBB3yEus3nCAGSIuKHFyJkgvB9A2BYkXK7UgSpQkluydxQRhF0rMmLiCcQKjwCwkx85C
	0r2AkWkVI39xbrpeZk5pWWJJYpFeYuYmRkiYJ+5gvNH5Uu8QowAHoxIP743sVTFCrIllxZW5
	hxglOJiVRHh3TgUK8aYkVlalFuXHF5XmpBYfYpTmYFES5y2baBIjJJCeWJKanZpakFoEk2Xi
	4JRqYJouIcXQe+yH0/Y9LvEL78nlMFkEtvP1WJ4unR2kHTZTL6/LOv1q8NdNlVwee822Ten5
	vCys9Xaho3lIiZLgyd5qNgvFhL9blXapRt5bOkvi6ZSz1/P8tytKcOx3r7H8tynr+6q4Caev
	TZM9dzCp7diNWhfNPRJHtuUu3HeM9cGctzH3Jhz5G31QVXfj1oyp9asMUta6RV9JO+Rfyq7B
	eWqvnfRTpV/vXvKfSuj1N2898f2nRsmJLdbuETyV3j2px9U/XHvKN3PhrR/iTDE7Qqu+NfzZ
	YaD3y7bbYBbHvIY3ljJXTzD2WfArJeW28bgq14nvU1oz+2HZRhVPp2e99vVrmUK8FVaK/OFm
	X5EYpsRSnJFoqMVcVJwIAJl6forwAgAA
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
get_user_pages_fast().

In the following scenario, we will may meet the bug in the DMA case:
	    .....................
	    get_user_pages_fast(start,,, pages);
	        ......
	    sg_alloc_table_from_pages(, pages, ...);
	    .....................

The root cause is that sg_alloc_table_from_pages() requires the
page order to keep the same as it used in the user space, but
get_user_pages_fast() will mess it up.

So change the comments, and make it more clear for the driver
users.

Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
---
 mm/gup.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 22acdd0f79ff..fb11ff90ba3b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1129,10 +1129,6 @@ EXPORT_SYMBOL(get_user_pages_locked);
  *  with:
  *
  *      get_user_pages_unlocked(tsk, mm, ..., pages);
- *
- * It is functionally equivalent to get_user_pages_fast so
- * get_user_pages_fast should be used instead if specific gup_flags
- * (e.g. FOLL_FORCE) are not required.
  */
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
@@ -2147,6 +2143,10 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * If not successful, it will fall back to taking the lock and
  * calling get_user_pages().
  *
+ * Note this routine may fill the pages array with entries in a
+ * different order than get_user_pages_unlocked(), which may cause
+ * issues for callers expecting the routines to be equivalent.
+ *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
-- 
2.17.1

