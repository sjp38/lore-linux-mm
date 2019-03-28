Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D137C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC1B21773
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC1B21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 530046B026D; Thu, 28 Mar 2019 12:45:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 466BA6B026F; Thu, 28 Mar 2019 12:45:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 355136B0270; Thu, 28 Mar 2019 12:45:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E693A6B026D
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o4so16680999pgl.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I94rqhDRqoRaPN0ZLeXgilZosbFseXlIxesNkZOMp5Q=;
        b=HRgBEu1R2rV4AdToORuvCIbWRqdsa6RnoJQFLgnbm5X0QqMRhBrit0+6S4R4V+Lu5U
         a9wVX8foiiMmR7MO7j1qaVpisPfanHd6AU1coMV/u0LFY3esmbr7KdBwN4+xYX4idnYf
         YFX8qzgpUkt+nIFUtZ9DZzdRgKXNhwEH0vgB6T3qk3sJpI/gaclYMzU009JiDDR6Y04s
         XJclC7unNFr0dk0sIel04KP7hZyJMhcue99w98X2f/SaV+lkhSfszJEAa/0YgywL2l/Y
         BNKUY+Bn5bUMo2NLpadnh/DdTz6SD7q2K1OsCv6RTIXeaDAOGzw2URort4tCu4BmICon
         OJaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVnEWe/uKSOtKAJsS93U2qJxBa6xJ14pf1HBA0Y9EYokwlQsDY4
	3mbTXdb3tuNJmzfuA/lWXQZWPDkFsLwMyrAzvMMBmUAT8mYx2+w01/HxfVS+2Ebp4djQWTxlwvP
	wgGvHWDhmuZPmJwpgq5RtTqawS99QeY2CPuT2qk5gqqItEGvnQLPRVWl4CktFVvXrwA==
X-Received: by 2002:a63:be02:: with SMTP id l2mr18808673pgf.48.1553791542609;
        Thu, 28 Mar 2019 09:45:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+nNSyKte6CmiB8FyxeNo0cJskpqU9fkJa5U2fI86lnQnuueCZ2Y+lo+UsH5Icag6r3r1P
X-Received: by 2002:a63:be02:: with SMTP id l2mr18808626pgf.48.1553791541876;
        Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791541; cv=none;
        d=google.com; s=arc-20160816;
        b=h/V/DSfJf+1NuE/xbiA6WVLS1D6lGn81/+3LiWw5bRN6aDfpqh+sa5B2ZAoN1LrT5c
         IL+hBbki78SkcYSOBPmEDFGclFqsbuA8K9GfY/jJF9Tf/ND0D1D+K3z8nmblXfgTiTWG
         ax9N9CK/OwBVf+7EjplnC79zmohB8Xk0bMfzeq0dgpJXHe+idfg/we/WsFqfzQdxQR2e
         IawUmWrAgibWw5o4EJK1S5C+zK8ZLayPdN1IzpAHZ6aYz8Bf+K/NKvL/jVNyjeI/u15m
         ZyTEd6GH/PRu1P5Ol31KglXixNNwUlYF9KFrWX7QH8+5qLeWzgOTabi0qeToTDZWOi7E
         e33w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I94rqhDRqoRaPN0ZLeXgilZosbFseXlIxesNkZOMp5Q=;
        b=YBObYd6HXb0EON901zX/XXpe3EiNufxDF4UVMPzYgbViRIKTmJGeWR1fWlPpIdh8J7
         yO37uub7tZjLD+JiftTEh8mPRQq2YQiHThvtohIhcaQMPLRzhewKJkwoV3lvjspbOKQR
         Tqbnsqr7pvap8XmeX8wj8Cm0bMkyDrn9IuPBSs/1DRRPRPdVQpz/BOwLAYGLgTOhrIqG
         7DHvT+TzjrfgV0mkKI6Hj7xgjZ2IMM7IX3om8P2wCT7GuolTOAxoGQeYQMDFyVZQ1Wfa
         9bgpptNvU+YD4JJypeHOBfRnEaVjQQo+JoH9ImYDI2OhVhGlXfY1X+UtUexfjddvb/3/
         bPvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460227"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:40 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 7/7] IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Thu, 28 Mar 2019 01:44:22 -0700
Message-Id: <20190328084422.29911-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328084422.29911-1-ira.weiny@intel.com>
References: <20190328084422.29911-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
FS DAX pages being mapped.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2:
	<none>

 drivers/infiniband/hw/mthca/mthca_memfree.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 112d2f38e0de..8ff0e90d7564 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,8 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
+	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1,
+				  FOLL_WRITE | FOLL_LONGTERM, pages);
 	if (ret < 0)
 		goto out;
 
-- 
2.20.1

