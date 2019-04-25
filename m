Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF59EC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:01:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEE0B206BF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:01:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEE0B206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23DE76B0003; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EDDA6B0005; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DD936B0006; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAEF36B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:01:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so482756pgn.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:01:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dl50EyAO/zUZFJX7h1va0pW7HVv9gQqFfeBEraou6p0=;
        b=tGCeiuz1U/ZrAKyIopqWShfNgJwGH+0M1SEeq7WCr5+DpRkbDaOCJseGjSoUbkbxKC
         gXz64hJfY/DXouvNJvnil6rc/jQ0XdJqzWAqWN4eZsNtArpFe8w+qw1NuAcQqPU6nHP5
         EXh80h4HUDQgy2Tivz5BYhmb2ZiJF3W/qwVXtuemli88dz+IUHAJ6AjkOLIkBLIR28ae
         HhGAAVrDcJJ/NXD7hO2226Kbx3i5JR7vcx5HU/JLS3m7aM7rTW13lwlAN9R0M5BNTO37
         pheJyCD7LBCoCjx+WtYqlcPlXZfb1Zrs8eh4n8CoG8Lsk2TYJuQ6uokFhPUSVJZEkguY
         SLLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWbcF5JvUguhfxpqzlR3RK6nGLNrShCN9w+qu08bw9R62Vq7iIm
	as51SBHn4jDVrMDJyjQLM4klqyguOZLhYRKJjxrKj6nqni7VJNKniRreSYykQMPOqk28ML+tuLF
	eLBXpRBvz97sY0r2aPyhK+uCYv04Jvgi3xGTEY/jPyvR1CBEs9KWxNXd+K1Jmc8qorQ==
X-Received: by 2002:a17:902:441:: with SMTP id 59mr41864241ple.242.1556226089496;
        Thu, 25 Apr 2019 14:01:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1KaUGoSTBR2xg4M0lbIEh8Z/STK4Q6mYOdkqH8sTdkNbeeVqDLYrDidk8nPvqRT8WqJvR
X-Received: by 2002:a17:902:441:: with SMTP id 59mr41864162ple.242.1556226088696;
        Thu, 25 Apr 2019 14:01:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556226088; cv=none;
        d=google.com; s=arc-20160816;
        b=HPMT4JLUQtsp2eTExicx84v1/4F1iV1IV/RhhPoGj6PGGUj/axxaCQntrBd86atvV1
         PyHZStAMLUZ9T6XWFj94bkWwl5NfNioTVXRm1ghIRInqpIK3Rikcz3cIh/vkudoo7AFI
         GQcq4Y1DXF98aVtYUVaNSweXaPekyATmQ1yuAzpkm71EmKhLmI1QX1cRpCJPLLxG9stZ
         s0wJQ5sjFpeLo7Hg8MeS3Ji6hq651Lj/da32VJSPtSwhn6QNg53MqDHGV/vNoFCxAC9U
         3F30weSrO419H3Q2iWwxL6FYUUl/fQhigxUkIdAh0wR+cBooRNZWeKvoopW1P9x1WoLw
         YwiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dl50EyAO/zUZFJX7h1va0pW7HVv9gQqFfeBEraou6p0=;
        b=NI7glU+jGFLjWkr1T2rTeg5g6AfLRb+m4iUYPJ9KfAFRnUpDHl073mTYQLoUHfbxy3
         OaZcat3cLcbKI5XbwAP0KyymSH+0mjuwUbz2rxGT3atjwYZ9TgrJFAZm0aRGfE0sll3e
         Wd8BwL17WKfJ8QCDwf+YE/cgRnGXiIRESy6EIyMqpNfo0QCY8ab49L5ccOaRYqKDkK25
         zfucYl//G+oZk99SJUaHO53s04PSQ9NaaOG3zk1XK6U6hVNZXH8AFcIcyOtKgxwuBfmO
         FgcqEnPJJjRhSVM55LW+TqLkKa5/FWMm/g9Z1ApGls/Evs2D7czrGlUZhxW2Jm86eIuE
         DMlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id g14si23057544plo.287.2019.04.25.14.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:01:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 14:01:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="165124647"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga004.fm.intel.com with ESMTP; 25 Apr 2019 14:01:25 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJlUj-0005RY-FE; Fri, 26 Apr 2019 05:01:25 +0800
Date: Fri, 26 Apr 2019 05:01:20 +0800
From: kbuild test robot <lkp@intel.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: kbuild-all@01.org, cluster-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC PATCH] gfs2: gfs2_iomap_page_ops can be static
Message-ID: <20190425210120.GA165926@ivb43>
References: <20190425160913.1878-2-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425160913.1878-2-agruenba@redhat.com>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Fixes: 9167204805d5 ("gfs2: Fix iomap write page reclaim deadlock")
Signed-off-by: kbuild test robot <lkp@intel.com>
---
 bmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 2fae3f4..27c82f4 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -1011,7 +1011,7 @@ static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
 	gfs2_trans_end(sdp);
 }
 
-const struct iomap_page_ops gfs2_iomap_page_ops = {
+static const struct iomap_page_ops gfs2_iomap_page_ops = {
 	.page_prepare = gfs2_iomap_page_prepare,
 	.page_done = gfs2_iomap_page_done,
 };

