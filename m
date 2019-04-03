Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB762C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73A202147C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73A202147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D4096B0286; Wed,  3 Apr 2019 00:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 183F56B0288; Wed,  3 Apr 2019 00:30:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04C9C6B0289; Wed,  3 Apr 2019 00:30:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABB356B0286
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p90so4225309edp.11
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=B0Km0z7J00nzfFzzN3rWUsWibL2B59QvurZv2eHIpkY=;
        b=j90vDvbr+fUK6OKpxARpWQNhNHLVw1+4sV/bDAavHU+0E7P6LJ7+DURo6BlJEoQvnP
         czKIBWbEZuEPMKEdywIw9rZDpKi0sLRJyVcB3A7DNK/nAN9xxo7mAoluUf9lv6QdaVz9
         vHtclpUqpyXU72eNRtJ17VhbxcZ/2ZpLgUyrdq+jgQyBdBm2CWc7MakR1Iasj+5IjRkS
         RQLtsin18V8fM6uOYFpdQWUlJ2T7Dbv9W+Z5czuZacMQeL7N3aqjSFcm8233Rxk/W1PV
         moy8P5gp9ylnL04OWZbrRVs54zYnmWGVU6WOjQeM/IvsXG3hmMoK3Zf0xUGOvpcnEtt8
         jpGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUYOdJvvJEtWYa6nMK/WVgwqf/+zqZcnOi9jx1Jpi3RGb7AWEcR
	J9toi7ooNvYRnb/6v0KfOl1s8rKl6kG6/6w22oDy9Iwa5DTBUxbGCTFZhM8iDgWNY1V6lZdvQIS
	f8xaAzgTFgOOW269o1WzYff98ad2yv+vFU9E98nhZsLs6OVf2M2rh8tGxr64SkmFXmw==
X-Received: by 2002:a50:86c3:: with SMTP id 3mr49754936edu.143.1554265820221;
        Tue, 02 Apr 2019 21:30:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/j/yfugsr9g4uHqGukZCP6ilftc3StDPXATFmhpZbl3zWyfsAOlZ9dg9WWVmyH6eL9HdF
X-Received: by 2002:a50:86c3:: with SMTP id 3mr49754887edu.143.1554265819145;
        Tue, 02 Apr 2019 21:30:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265819; cv=none;
        d=google.com; s=arc-20160816;
        b=zXzw4HpCAnf3ZHYdeTtCrq6JuFsiHTkjejaxmFIucuo5jPtkzMmILM7vtE15l9fgNS
         sZaMp5ICG9apALjVkV1afJC9DVqPP66RIdbtGjvk+0IHlR6do0xJq5U49Gba0cm33MMF
         dRGCUFkNQ+oogU62G3IOnJ0A5IGEvg9kOpNYHQsXGdAxDJKqv9dBRlsNw30mA5ZwFHsf
         WvZRwNoD/By/9AMiwcp0VMq5vNaBHuE1xGSZlmHvzUmb3x7Rx0a2mPe78ywbnFoVeCNJ
         N5pebiULFPRT5JpnMXWGLWTfMhL7QxKzeimX4hd8NOzyv+/a0ZZVnrC5I04bhZywmssq
         HsQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=B0Km0z7J00nzfFzzN3rWUsWibL2B59QvurZv2eHIpkY=;
        b=rKi6jafma1+MmikBMD1GGEiSuw4KRFsij2kcyEtf3LrEzrxqNwRqX4WVIN/NdX9jrq
         mn+QYpg0kUJzn0oPPIhrF0U4eJljpkxQED/P8YohVcq3vDQCMQC5qjQBQlBI3eJJ5RgP
         q+raQHL3meWB6JKsH9caJPNHBgMO3W80iobNojAK6khQhCYAKxswvH5ZDbqKMQsdwJgP
         CC2pM4wP0LMwU2lwwLzJGjNRd7UAkE6Ew52m8CekjTOS3ZGJ80XdMBKUionkz9G3FDoE
         Uw2KXHY7vkvqbRrWA46cybqy8MoEiC/VN4NUGr74YoR3GBSHiRiNfrV8GV9s1dAkCIS8
         WsnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id dx25si155583ejb.64.2019.04.02.21.30.18
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 13D5F15AD;
	Tue,  2 Apr 2019 21:30:18 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id B6BCE3F721;
	Tue,  2 Apr 2019 21:30:12 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
Date: Wed,  3 Apr 2019 10:00:01 +0530
Message-Id: <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
starting physical address of an entire memory block to be hot added into
the kernel. This is in addition to the existing ACPI based interface. This
just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7e34b9e..a2418fb 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -266,6 +266,15 @@ config HAVE_GENERIC_GUP
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_MEMORY_PROBE
+	bool "Enable /sys/devices/system/memory/probe interface"
+	depends on MEMORY_HOTPLUG
+	help
+	  This option enables a sysfs /sys/devices/system/memory/probe
+	  interface for testing. See Documentation/memory-hotplug.txt
+	  for more information. If you are unsure how to answer this
+	  question, answer N.
+
 config SMP
 	def_bool y
 
-- 
2.7.4

