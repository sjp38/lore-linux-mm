Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3BFDC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 05:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D75020870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 05:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D75020870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD2458E0002; Fri, 11 Jan 2019 00:31:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81AF8E0001; Fri, 11 Jan 2019 00:31:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B71EA8E0002; Fri, 11 Jan 2019 00:31:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75C818E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:31:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so7618436plb.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:31:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fLXPITHtHzJzMIL1TEPPn62lZ9RIO5vg7K946BS7rF8=;
        b=XPixGcETgFq6PyaeA55ssYsV/BxkfPM+/can1kUIl+6Fx2szJqmVCuThXKyBTmM2nv
         VOJncXhr8XEGBfm+baEkmfqXUkWx7UBo+jZ98yPmABDjQ4WqMlesvc/5HzFBTjaQ91MA
         4d3g2vdQ+YLfaly1UxvuF4FL84mvjbkMmha/qlnopSwp9vsNEAN6iLGdsYMbSC2z+5yF
         hn0//7oTfOSuAhD391Nya8+aNLQTvD3/Yl5q7BkQJXZEMjJJvsGtoOuLeRLFv6TuORrV
         IBR3+xEah2OtJAq6C8p14a/tk368ngoLuRWENQL1bGhO6+ZyglURkuUfVR/zNmaFHt9a
         vsQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-Gm-Message-State: AJcUukc+NINCJSqhuh4T90IFS60Rhi4TU3Q6/41CPLWbuXspUpdyr4Bv
	uMD2MA0M0iX+vYN+nObsd4dn/4c8E9cKYMokutgj7TwuXDpTdcSzJSi1SJfeS2ntQRQcO8tFto/
	bmLPZphbt8F5AHmoshmpLI6S1/UM47f1qSY5SFTwQCDr0zxxd2Lw+MRLdIvVN1S95MA==
X-Received: by 2002:a62:36c1:: with SMTP id d184mr13250952pfa.242.1547184699115;
        Thu, 10 Jan 2019 21:31:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Y6HX50DV6QaybTc322gYYdcuXEcsWM/8l0ezGH8dwS2s/+EVTMJ3/Vh6fGVYFgg9xGi9l
X-Received: by 2002:a62:36c1:: with SMTP id d184mr13250872pfa.242.1547184697726;
        Thu, 10 Jan 2019 21:31:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547184697; cv=none;
        d=google.com; s=arc-20160816;
        b=p1tiGeAFBuxGeK70zIsAfR6y9SGV5UH2dEH59VuPTtFIXkuMwp94qDNCZWWiTPIHek
         KopXqnYF42fXJnNSKJDZyIwaEGKr1zR2Sujz3RamfFiGf3vUJDBFBAV/+HOHnZyYlmCc
         Ckabc8edM6b74xqQp533te+uVy+zBzwcvKLeoY7UMs16QaUS+PYMpItooMRV7z3D7ZMe
         dR9kmPEN5jWaO92kFXurnjk2itHLhLXsRAdUtuhzjmgExCO3+PsdtyIWTEJDJddf2CNX
         nN2ipfyTRnOPdEpTo/lwCFots5khIgbyI2HwvX3ngZOpHxqIddmZzXNI+YMMghJbW2k3
         CyXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fLXPITHtHzJzMIL1TEPPn62lZ9RIO5vg7K946BS7rF8=;
        b=MsrCsp//BsB88IaP8J9rEDwEylulpfeP6AEn4h6cD2I1hXIaDzdVzj8W4sOHeMkXQx
         73rAeITGMbWMu7/36RO0juCYBGhTwv42LVHTEQ3l4Eu4GzP/JoAlnw5XowCDHRJrg36K
         68w0MzfmbU4+FP+3Pm3qzqwrGdv7lar5BPxkzNY6C3xF+uwcLuh7v0yQNhajKQPYYyyY
         ivufNLPoRh388dkHG/qkHhIKLfMhCaWXzoECYtDpYiDTdJWVhQt7hBx4fAayeGvTNno9
         +T7hY4JwsSo9OaEZCSQ4EcKh8Jc9sruZw42fLfKqAgQSOyNmh5bgWT2CPSGvH0AntptN
         WqIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id c9si5743593pll.439.2019.01.10.21.31.36
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 21:31:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) client-ip=183.91.158.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-IronPort-AV: E=Sophos;i="5.56,464,1539619200"; 
   d="scan'208";a="51768316"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 11 Jan 2019 13:31:35 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id 7D8734BAD914;
	Fri, 11 Jan 2019 13:31:33 +0800 (CST)
Received: from localhost.localdomain (10.167.225.56) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 13:31:32 +0800
Date: Fri, 11 Jan 2019 13:30:37 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
To: Pingfan Liu <kernelfans@gmail.com>
CC: <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin"
	<hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
	<luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki"
	<rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu
	<yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Baoquan He <bhe@redhat.com>,
	Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>, <x86@kernel.org>,
	<linux-acpi@vger.kernel.org>, <linux-mm@kvack.org>
Subject: Re: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
Message-ID: <20190111053036.GA13263@localhost.localdomain>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <1547183577-20309-3-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Originating-IP: [10.167.225.56]
X-yoursite-MailScanner-ID: 7D8734BAD914.AD370
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: fanc.fnst@cn.fujitsu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111053037.yHEZj8Lv_ENx3DQ1bindd1ianXBCf82MPrvkm52d4W8@z>

On Fri, Jan 11, 2019 at 01:12:52PM +0800, Pingfan Liu wrote:
>The current acpi_table_upgrade() relies on initrd_start, but this var is
>only valid after relocate_initrd(). There is requirement to extract the
>acpi info from initrd before memblock-allocator can work(see [2/4]), hence
>acpi_table_upgrade() need to accept the input param directly.
>
>Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
>Acked-by: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>Cc: Thomas Gleixner <tglx@linutronix.de>
>Cc: Ingo Molnar <mingo@redhat.com>
>Cc: Borislav Petkov <bp@alien8.de>
>Cc: "H. Peter Anvin" <hpa@zytor.com>
>Cc: Dave Hansen <dave.hansen@linux.intel.com>
>Cc: Andy Lutomirski <luto@kernel.org>
>Cc: Peter Zijlstra <peterz@infradead.org>
>Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>Cc: Len Brown <lenb@kernel.org>
>Cc: Yinghai Lu <yinghai@kernel.org>
>Cc: Tejun Heo <tj@kernel.org>
>Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
>Cc: Baoquan He <bhe@redhat.com>
>Cc: Juergen Gross <jgross@suse.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>Cc: Vlastimil Babka <vbabka@suse.cz>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: x86@kernel.org
>Cc: linux-acpi@vger.kernel.org
>Cc: linux-mm@kvack.org
>---
> arch/arm64/kernel/setup.c | 2 +-
> arch/x86/kernel/setup.c   | 2 +-
> drivers/acpi/tables.c     | 4 +---
> include/linux/acpi.h      | 4 ++--
> 4 files changed, 5 insertions(+), 7 deletions(-)
>
>diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
>index f4fc1e0..bc4b47d 100644
>--- a/arch/arm64/kernel/setup.c
>+++ b/arch/arm64/kernel/setup.c
>@@ -315,7 +315,7 @@ void __init setup_arch(char **cmdline_p)
> 	paging_init();
> 	efi_apply_persistent_mem_reservations();
> 
>-	acpi_table_upgrade();
>+	acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
> 
> 	/* Parse the ACPI tables for possible boot-time configuration */
> 	acpi_boot_table_init();
>diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>index ac432ae..dc8fc5d 100644
>--- a/arch/x86/kernel/setup.c
>+++ b/arch/x86/kernel/setup.c
>@@ -1172,8 +1172,8 @@ void __init setup_arch(char **cmdline_p)
> 
> 	reserve_initrd();
> 
>-	acpi_table_upgrade();
> 
I wonder whether this will cause two blank lines together.

Thanks,
Chao Fan

>+	acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
> 	vsmp_init();
> 
> 	io_delay_init();
>diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
>index 61203ee..84e0a79 100644
>--- a/drivers/acpi/tables.c
>+++ b/drivers/acpi/tables.c
>@@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
> 
> #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
> 
>-void __init acpi_table_upgrade(void)
>+void __init acpi_table_upgrade(void *data, size_t size)
> {
>-	void *data = (void *)initrd_start;
>-	size_t size = initrd_end - initrd_start;
> 	int sig, no, table_nr = 0, total_offset = 0;
> 	long offset = 0;
> 	struct acpi_table_header *table;
>diff --git a/include/linux/acpi.h b/include/linux/acpi.h
>index ed80f14..0b6e0b6 100644
>--- a/include/linux/acpi.h
>+++ b/include/linux/acpi.h
>@@ -1254,9 +1254,9 @@ acpi_graph_get_remote_endpoint(const struct fwnode_handle *fwnode,
> #endif
> 
> #ifdef CONFIG_ACPI_TABLE_UPGRADE
>-void acpi_table_upgrade(void);
>+void acpi_table_upgrade(void *data, size_t size);
> #else
>-static inline void acpi_table_upgrade(void) { }
>+static inline void acpi_table_upgrade(void *data, size_t size) { }
> #endif
> 
> #if defined(CONFIG_ACPI) && defined(CONFIG_ACPI_WATCHDOG)
>-- 
>2.7.4
>
>
>


