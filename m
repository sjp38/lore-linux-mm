Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FBCCC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0257E204FD
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Ln6d07+p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0257E204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 946906B0005; Thu,  2 May 2019 14:43:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F78D6B0007; Thu,  2 May 2019 14:43:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BF216B0008; Thu,  2 May 2019 14:43:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 627EB6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:43:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c2so3318298qkm.4
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:43:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=OQ8LI109FDHiBPeS+yUXMPYI1RK/SMF573vQYbN2uKuxoQpTlM8cZx9SBaCrpmNmbg
         t4725DbCfzqg1MufXS5O7X5uOOZ5fjyLSFbuhj9QzjdHOqFgW+zNhC+BtHFMfGa3raSv
         RGQsr3OOsbcMFBOE58rTBKvURiAT3Ec4sCvjEVidDM3iiuGl6Qaudrvn74BhQp3Juw8y
         lMWuYhMjmI9FgM4gdLVikRp35VW2RhD378NhYWaLdrKfxPJD1DYKzH9b8eOyZjTcOV2K
         43E3JgrICr1dQDxiFCczxYzREvWm54IOnhlH9Lj3GQEFnnV0Y5omPWUoc6nhMvboyP/d
         i8QA==
X-Gm-Message-State: APjAAAUAZ8DJ+BwyVgQwWGCHMvzPB+1v6StE6fPL24tqrm10rNlBO8B/
	ZpcjUO6NmDMF1xzmwcMLOZek3Bv6BluDciPSQN8WmdRwMDcl9fvqbvHhLdtfYjN/Hz6VbVhcXVS
	DJD2CgBTfdpflwhauoGihD2HE9+kDWFZDaulyZP4Hg8U6KtdKH03Ax5bFFb5ZLA4zew==
X-Received: by 2002:a37:8f44:: with SMTP id r65mr4133869qkd.311.1556822624180;
        Thu, 02 May 2019 11:43:44 -0700 (PDT)
X-Received: by 2002:a37:8f44:: with SMTP id r65mr4133781qkd.311.1556822622847;
        Thu, 02 May 2019 11:43:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556822622; cv=none;
        d=google.com; s=arc-20160816;
        b=jvQkWAqyBkrKCQWB5+IonFN9ZqhmzoHu1hpSkg4tAdXC+AH6B2zLrnW18FRZWtA1OC
         +E8MBc0+tCGFwBpO1dGSOyoiEOpfp33fd0wbW1mhSZTreyskapwVkFloChdjGjBCLPgP
         1yYexdj7Tjl7/8/mtQgOo+TO3+uTeutRNGPckJ4F1HTVdfpKtYmIN/vIfnstQIucj/z5
         GPp6IeXJ0G0poCxMb8nMJ+AYlZSafKoe/gNHawobV1ICjPBh3vJlAU06lWVGSjH7CsNB
         p8C+cT9cOh9d0uqeM/tN4zK2OeomUceSG7fBamhcFG3MUGektbR9o/hMfy2lfRn3WtqV
         PdOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=Of9NpsYpxxqAemVtGVdiplmS98WKAjvVHbkDLGHWWllOZaPUKadexsEYUSuI+nRxK2
         ig4Y0IWxXGiJtFfKocGjxADORyBtxHvNB18e+4qRq+EP4+Yft7juk2UEfG1cxC27Mqwk
         o9+DZpWxErpbwa6VSnV9BrJtXSTegm2Iz2WmxYYsXX/lE5la7f5vGKVfdD5h+d5jgQaV
         w/+EG0JOM6wu8WmTHUNN4dFM4EGMXgo93Pn09be/pN+HycAgnhmc5hLfDWuMzgyrYlde
         GqtEL5Xql61yvhZv5XgH6UFCF5ErWv+W7AxBFaSLq6zUuKcHewOPUADwHkh8oAqo141e
         4ddw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Ln6d07+p;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 131sor1180706qkj.39.2019.05.02.11.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 11:43:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Ln6d07+p;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=Ln6d07+pCYwbOjMFJVcdvs72qSgpRQCxY10mk5EhNLZCCmdMu75C3Wt5remthzgW67
         V4y5TmsCpIkhCATiM5w4PnSDvo+2ad76snqHZ1BlD/WCqdONPaNhAwrZFGW7OAb2V9sj
         evPR4Ort8jUgIJ58yqKrItZUPn32mS83xIUWpb8GYaC/nJNhKZfZFK2fc9lv+R9s3DTG
         rK2ZAUdIL3A7/jl4Mu2oUqA6qXaATfKDsG8ix3Umce3pVsoYEm7Xh9DaPp/mD9BhTRUD
         bFZMZj89CQS8F/ao/RoBvjb13qg+71zc3NWtzG51TmtvQZg+zD8u9n/dnSikt9j6kBv5
         Etsw==
X-Google-Smtp-Source: APXvYqwuy9FOxLCdwhhUyWDJtB7mrIu4/W4cCEop6zwbua1nKA58RqCKUegUOS0f+XcEcCAv92SrIA==
X-Received: by 2002:a37:4247:: with SMTP id p68mr2794611qka.89.1556822622604;
        Thu, 02 May 2019 11:43:42 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 8sm25355751qtr.32.2019.05.02.11.43.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 11:43:40 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v5 1/3] device-dax: fix memory and resource leak if hotplug fails
Date: Thu,  2 May 2019 14:43:35 -0400
Message-Id: <20190502184337.20538-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190502184337.20538-1-pasha.tatashin@soleen.com>
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When add_memory() function fails, the resource and the memory should be
freed.

Fixes: c221c0b0308f ("device-dax: "Hotplug" persistent memory for use like normal RAM")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Dave Hansen <dave.hansen@intel.com>
---
 drivers/dax/kmem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index a02318c6d28a..4c0131857133 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -66,8 +66,11 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->name = dev_name(dev);
 
 	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
-	if (rc)
+	if (rc) {
+		release_resource(new_res);
+		kfree(new_res);
 		return rc;
+	}
 
 	return 0;
 }
-- 
2.21.0

