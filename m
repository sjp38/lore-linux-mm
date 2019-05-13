Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE899C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A10CF2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ZVeO12rO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A10CF2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1469C6B0278; Mon, 13 May 2019 10:39:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AA816B027A; Mon, 13 May 2019 10:39:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB3166B027B; Mon, 13 May 2019 10:39:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9FD36B0278
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:53 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id d12so12370735itl.5
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=gJ5tt/4IYtOQ64SjXc4XK/hg4MlEde9v0jqeQXYD/eQ=;
        b=XXG99HjVjAHO3dlGwAOaiMdnrIzcPi4ZGAH94ZWWE86bNav75GOqln8etclmAsaGqO
         YLvP5A5afZOIs/R2pEma0Pov/Wo0EJrEd/Tdm4LyP76qrCtP/ltQsgmo9Hfm7f0OIb2U
         OiFsQ9J/Z5ggVRwnm+CDfFzp4FXJxMFE2XvrrxLrn8oQGn1vuTSrPNJfqnnMQ+6YmVJD
         UbE7/pJ2UT/EE7Pfvl3mjNcqp/702mL2B6MXcE2fBAoOZepmrf/2Cc2GMKC1kWKyY+67
         udq3D/gc0P/e76v11nWTdDCf/rm8qec8zSl9BRyPmSOuK0NEzf7zcNNoWnku15zJ1oii
         /Bgw==
X-Gm-Message-State: APjAAAUrAyS7yzyw/voGund3KfW2+JyRicWs/yR3vXAhF8KgHdDlqklT
	kCxG0R1bTl2sr73i/eKWkINPYp5oKDwHSLuWwapgiM3L3Qtz6RN5sX7pb/vgaW1GPjlJNgsx7Gs
	XF3iwjQep26KA1/iZnBUVAtXwy69iCKXpEZ9sbPZAFcAUyhP5kulF25ZRJSuHeFO2Og==
X-Received: by 2002:a24:a088:: with SMTP id o130mr10509551ite.86.1557758393561;
        Mon, 13 May 2019 07:39:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjRB4QKtcyrveHdDov/7YcDVsgCnvCWUtbj692gEbcgpAngW4hr3V6mvRKZH8wpDNf3iUY
X-Received: by 2002:a24:a088:: with SMTP id o130mr10509498ite.86.1557758392854;
        Mon, 13 May 2019 07:39:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758392; cv=none;
        d=google.com; s=arc-20160816;
        b=vWqz/xI4NE2+Wt2deyI3aYeh+BW8zJMFnCrhh5FX1285VcinvaBymS/Zw3/fUyaiRm
         QGTra8WP/Lye9NZncs6CbkPlqhIDB4t8UZ3pk5hFvP47nQTt2ulMTcRlZwMU1y2QrbpN
         gb5w3o5YHUJT3NBBNUD7a8aHKF3GVYgksaBPH6zMgnAxC9FjRnCIgcKCEHWi+c6peFgg
         KjhIspGWUFYo99qc+OG8qf1T9pFo7PEdlgwv+3SOaLdH+r72P9OhDDuM8xQUC89CGm8g
         aM6Sqo6EDMGCVgBSwsynFTqEDMtZoc3Zb3MkCJuOIno0cZOJ7nmunOBtojsf+UiUzLAw
         jajg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=gJ5tt/4IYtOQ64SjXc4XK/hg4MlEde9v0jqeQXYD/eQ=;
        b=pjcJ+Q6RGZ6VSQR5xoMl966sTiUjnohJsmZmNDbVpQJ6OArL4+0n3ajvH6zyTXyFvj
         INYizz3GlPDE6CVjBY+e9/GT9E3/2sZJWWrZuMHFkuTzl1zlQBnnHzv5XiYlv3faHQ/c
         5vdP9DqD+DAO+SwGUvjOpO0BfNwcsT3MN1U+qtTU4dJc9DJOxvHgqyEB6VKYlAQ8M1gx
         ZzIYQvXebsKIgkMYtJUQ+MQLwvbr8lU7UzPhLYB3JksoHvJQco+jmvb82QWv/IhSx8LM
         OS5UErGmXnub7A/q1IzhjaUvUc0768RtIUsWcX99jfKW3jKjbbJK72hRbBBPA2yvJmNQ
         TgVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZVeO12rO;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 80si8588911itl.77.2019.05.13.07.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZVeO12rO;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEdHlu193231;
	Mon, 13 May 2019 14:39:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=gJ5tt/4IYtOQ64SjXc4XK/hg4MlEde9v0jqeQXYD/eQ=;
 b=ZVeO12rORSnjNn30oKP4IfrRQOnpuWsZZpTFew29AW/A1AopB4vNTvJPzoBUNnLwecR5
 RxfhLqEFwtp98NkffYHLWW/xGFZAMdCGFC1Cm5FhGyQSMCaCSB6w20I2qahvkzKCsFa5
 m/f/wbDM5y5zJuEnz5wG8g9nfWjmPhU8RB2bXp/ASv1kj1gRX0Hrz8Moy8R160Qf+K6H
 gpnLK5eK57XeoRIkkZcloR/MsoTBMRliLnztAGJlyy4fIbv6fkl19QVpaSKUSvXbYn60
 PuCO41ERbdVUgxGByWPWdcyJSJL7JyT3ve6bcXI+B2FmQnOupQrAXYuphyQi5YY9ctn+ Fg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfm05-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:44 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQN022780;
	Mon, 13 May 2019 14:39:36 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 20/27] kvm/isolation: initialize the KVM page table with vmx specific data
Date: Mon, 13 May 2019 16:38:28 +0200
Message-Id: <1557758315-12667-21-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In addition of core memory mappings, the KVM page table has to be
initialized with vmx specific data.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/vmx/vmx.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 0c955bb..f181b3c 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -63,6 +63,7 @@
 #include "vmcs12.h"
 #include "vmx.h"
 #include "x86.h"
+#include "isolation.h"
 
 MODULE_AUTHOR("Qumranet");
 MODULE_LICENSE("GPL");
@@ -7830,6 +7831,24 @@ static int __init vmx_init(void)
 		}
 	}
 
+	if (kvm_isolation()) {
+		pr_debug("mapping vmx init");
+		/* copy mapping of the current module (kvm_intel) */
+		r = kvm_copy_module_mapping();
+		if (r) {
+			vmx_exit();
+			return r;
+		}
+		if (vmx_l1d_flush_pages) {
+			r = kvm_copy_ptes(vmx_l1d_flush_pages,
+					  PAGE_SIZE << L1D_CACHE_ORDER);
+			if (r) {
+				vmx_exit();
+				return r;
+			}
+		}
+	}
+
 #ifdef CONFIG_KEXEC_CORE
 	rcu_assign_pointer(crash_vmclear_loaded_vmcss,
 			   crash_vmclear_local_loaded_vmcss);
-- 
1.7.1

