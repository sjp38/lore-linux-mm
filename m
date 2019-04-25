Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC5F8C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29088206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="FZF6nEOv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29088206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823276B0005; Thu, 25 Apr 2019 13:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 786A66B0006; Thu, 25 Apr 2019 13:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5401F6B0008; Thu, 25 Apr 2019 13:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD676B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:54:46 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x23so571165qka.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=okZ04Hbf/xvutoUxPUXdGy+l77e9OSf9ZFtbgUMB0RT+mU0eehYfnqZr4y5GvNrZOO
         FQLjccfz3lkWz0eot4VtZEl7ckw0NvNYKi8k4w700pYSKPSsBoN8I78NyUT62Zd6riv3
         kCvtnfjCL/5Q2rV+tezpqZmfg3buRFt0mYr4R7TxuDL8q+3fWQl9hZmwuU/SbQsHTcbO
         71VmjHE8ni89UK8NpS6bv65nIwia02Iz/8jrqH4YcXpuCAe5kAWMFgDhF4knWcUJgolP
         +VlVe6cHK/LoDqKdUYvC3GOWGSIcPYjnBDakgYdEfazV73X6I+tMYGSM6bXySJBl+jBE
         D/lQ==
X-Gm-Message-State: APjAAAXYesvlseBOxzif3FyAJJSd5bsJBcp29Ns9UeYoSt/XD7TsZ33N
	z+uMZ6ILNe0HHfRlMf3vDNbh9ui+TV49BawTXnhr4/+6+FvxRMRVjrGuUtXAPHTl1gHbyCJUBo4
	EzPCZhKtiMuAGWyONQeT3PC6l1VAdQXNnI0QA2Pocpo6oQtWbaXjHTQXZxEP7CYCsYw==
X-Received: by 2002:ac8:3132:: with SMTP id g47mr8615226qtb.115.1556214885952;
        Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
X-Received: by 2002:ac8:3132:: with SMTP id g47mr8615172qtb.115.1556214885143;
        Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556214885; cv=none;
        d=google.com; s=arc-20160816;
        b=fWvEzy6Jdh2fVXe2p64dxh50d8JxBvuCRJwzx8ujn0vEUx3t5f0TtwlGB1tMOp7KbW
         hfDIV2TX1qFpRYqECXc55E3TbeFzLQyWeNPcmZZoed+ITd4yy+AbjU6Qhh7FrDqS1EJ9
         G6w+UT07svxnaFDYXhYaVaLOwHGQ+0HN4FhroDpqeIvaMWFqhB28wZEUo0jNvsXURRMB
         YbRIJJ0AqKdaAbCdKVSa4xo/pH3GaEPvNKCAhRNdTJf11I4mf4rjMlMOMxAdArfgKIk2
         f0kxsj1Sof1fWf99VrW/YyV+ohL7FzbkkcRKmnjHeTqOBfhTT/BrIdeksFLHs5yiOipd
         vU0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=H7316pqPMObXWJtpJDogn3r8M3i6d8J5h++jClc1tNMIN27UJvyg4pjnOpJwPpY71c
         TgsGYPL7ZLNheTcFNQsTHYGopryQd/VYHK4GEHsG4pj9vKfsYrWc/HSDXNv8KTTQawnB
         Dq757ILiq1k9guwNbY/BeVsaCgYQvBFmXPEwvUf1v/T9YgZ6uWIuMyRojSbHMeQoW8tg
         NTA5H5M/zcmgchGO8IqoYiWWH3w7flKU8tMzdZXXaIHBwN082RzIv5Kfv5ct78oKXKih
         ud5ZtRUtNAR9utV73K5UOFETsGZNop/diQsdjKv8XYS/2bd60ruFiy0/2bfV1a9l0Bdp
         krNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FZF6nEOv;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y56sor31435108qty.29.2019.04.25.10.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FZF6nEOv;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=FZF6nEOvkk6GoKEHPSU8yrNVtWp+shOUoe4UO+Y1QVavbdMeJb3pHS4V1kVzPNRy52
         pIE4K7PHtduBmym5C1oosmQLKmA858ULLvcXnDc3JTaocoXb9gymmInDKT40sPGkotwB
         M1k8gEB/FW/fye4lxsAR621vCULoQid5fCPik0riLL/6Kkg4Ni5oKxA0zuM14Fbe1ZAR
         d87kNRHFK4jS0G7UBb3QgNtiCdqS+MTyz//EWd8P5HzdPPbLRHjUjqm3a/sU4shQ8s88
         w7NRw7F6mjTKfgF6KS9Y1q6Ge6xEOnLvvRDedjZm3B0QNiRUSIfSPjmMg3sOyK6XDnnL
         Ia9g==
X-Google-Smtp-Source: APXvYqx2mPAlBtDSrF5sJjLTFal+jWlqEJk8hh+f4IJY5XWUWach/YSh/trqMViUk4u3RPlpVSemfA==
X-Received: by 2002:ac8:72d3:: with SMTP id o19mr33151776qtp.274.1556214884917;
        Thu, 25 Apr 2019 10:54:44 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 7sm5950641qtx.20.2019.04.25.10.54.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 10:54:44 -0700 (PDT)
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
Subject: [v3 1/2] device-dax: fix memory and resource leak if hotplug fails
Date: Thu, 25 Apr 2019 13:54:39 -0400
Message-Id: <20190425175440.9354-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190425175440.9354-1-pasha.tatashin@soleen.com>
References: <20190425175440.9354-1-pasha.tatashin@soleen.com>
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

