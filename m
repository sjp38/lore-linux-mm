Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C17DC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1150421873
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:21:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1150421873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A08C96B0005; Fri, 19 Jul 2019 13:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA456B0006; Fri, 19 Jul 2019 13:21:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A8D38E0001; Fri, 19 Jul 2019 13:21:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 519866B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 13:21:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n4so15685893plp.4
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:21:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=yY7wVszP4LQpvcp04DDsW2dLXC6w205iMAAghbL05/M=;
        b=XzNFiy480C5nTPmH6pchqPqUgZpEQiFKvS8+JYZMztcNuL3fMcHr1ZVoz/YuORM17X
         KGinsK/6aBCuPsYJC16qdTzazstOPXtI6KtRF1Q8403UgOEO6pzvLIrBeTw5jsF06sGe
         JQbd8zuF/GdFKDlgkXCpb0zZUgbmYmx/MEuiI4ZmBV3L5mP4QzBxVirXKSTX3968Ry90
         cWL2B1WSzqKM4Zol/kNzDCkBBnowSIo3PRHU2wuH5dtkEdKrJKuiafQcqTQ3Z0K4ZU8Z
         lf6caZzbBMy+o8aosBxV7n8+2qUZLMMfbL94vww/T2m3wunQJ9kazc0Ha5UxwtiMag7e
         jXGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVKVLeDgk3xtPyPymRt0m4jBhSA2hr+InuqA0gs6GhImFc6eGkr
	M6QYB5IzBzZ1dOwthY7dLiz6RsyWEwdnd3zpoABEHaOkvqvBaObnrqbbV5LS7Y5E70ZZbI8cd6K
	ic1eg/rimUVxacE+xnLOt/k1FLtCa7cvW1R5g1Ach30HMt40hbbgLrJJwV4h/RtZIow==
X-Received: by 2002:a63:f443:: with SMTP id p3mr10501685pgk.345.1563556891833;
        Fri, 19 Jul 2019 10:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0D1tbj050BVgZzEdiGtHHHOu2EkE9b0S/1Yd0Ze7cYnpltY5a+EEX49VqEbhVZ89vMiBX
X-Received: by 2002:a63:f443:: with SMTP id p3mr10501588pgk.345.1563556890435;
        Fri, 19 Jul 2019 10:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563556890; cv=none;
        d=google.com; s=arc-20160816;
        b=otO431At5+sJuk9PokAemlrfIYmSSVh5VmV8D5/9q8ZZzoZZuG2pnwzXIJm6IzHSsX
         bR/mwR5U029oEvqGv9Jw4x+3Z2+lJqwASrosmttMbNFoJ5n82HaZLQ6F+0RcqL0yw0R9
         aFqPUfXA2gygKVIUp02A7dBaPIsyHGzCrhQVehgnRNEyntFH95aGlTETxh8l2zt9lSS4
         LPsenWGBweqyrpNCrLLC1rh4IVgDEZUSPhrZzpJzR6mly0Y45XxznggnSVrPxIk8w2fn
         no5HgaktJ+M2b9wUR0wQI/yp4OQNlaj3d7FxDKGDm9Wfwvpki5EOWp/sXEPzJZWEFuoy
         YtqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=yY7wVszP4LQpvcp04DDsW2dLXC6w205iMAAghbL05/M=;
        b=eXQk0s3AVi5Qx9IB5fpeaz/q9gdPJ1UnGRNvJjaIxHQJTJXuaOu2QVi4TW0XWDtnxd
         AYSYc83JliWdA4ehwwQ6ZqpFfn3l0guyTrZmtYVTie8Q8RGsTcyyNjoCKDSu2Y6QTcva
         kWXqhVUp3ZaEiL7Sk9ol35TsuKQXoPg2to61i9GJAeOdlLx7bM35cZ/EgYRLR402raUU
         GqudMaKdnHyC295//b6Po5fuqnwp8jfAfB5nrW2d2jssMmRN9WKxOwVhULguy8K3Cqe7
         r7rKCJh8W7jE+ffd5bM7VVBilItcoJDVPe40UXTvdQY1c4hvUKJor5T8WNESjVPbPMTF
         EXAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id o2si16115698pgp.288.2019.07.19.10.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 10:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TXIdl-p_1563556863;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXIdl-p_1563556863)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Jul 2019 01:21:14 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: [v4 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent behavior for unmovable pages
Date: Sat, 20 Jul 2019 01:21:00 +0800
Message-Id: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Changelog
v4: * Fixed the comments from Vlastimil.
    * Collected Vlastimil's Reviewed-by.
v3: * Adopted the suggestions from Vlastimil.  Saved another 20 lines.
      Using flag in struct queue_pages looks not outperform renumbering retval
      too much since we still have to return 1 to tell the caller there are
      unmovable pages.  So just renumber the retval.
    * Manpage is not very clear about shared pages when MPOL_MF_MOVE is
      specified, just leave it as it is for now till it gets clarified.
v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
      immediately by a separate patch (patch 1/2), and this is also the
      preparation for patch 2/2. For the details please see the commit
      log.  Per Vlastimil.
    * Not abort immediately if unmovable page is met. This should handle
      non-LRU movable pages and temporary off-LRU pages more friendly.
      Per Vlastimil and Michal Hocko.


Yang Shi (2):
      mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
      mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind

 mm/mempolicy.c | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 73 insertions(+), 27 deletions(-)

