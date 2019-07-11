Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0336C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BC17216B7
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IZOylVir"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BC17216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92298E00D5; Thu, 11 Jul 2019 10:26:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF5018E00C4; Thu, 11 Jul 2019 10:26:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6FAB8E00D5; Thu, 11 Jul 2019 10:26:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F76D8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:55 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h3so6950446iob.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=j5hNYpa6Ps4ofAY49xQlyVzas1I7FTDoeSXSCbctYus=;
        b=KaP++4x2o5IsXUxZJz/U+OjhpwJH51Oe35ILVu6HJhsBnc2jYUv5BAsBbzRfKWdE6Y
         aWmz/ue/Ppu0sm6U1NZr34OVjqlOzMuzgdHEkVY4h/9/SojJjdDn4JjvcStpiRlA/WTT
         72SJTis9CKx4c1xMNslZXk5yAjmKHAIbcIjdNIuSFeGDO9TLp5Zz6+kjl5qK41pjolhH
         9rue8y0hBoVxcgbx3eoAm7V3+Im8zGV55PcXJHqszTx9G7dyJm+bvccUlbVJMRW+yf84
         LRCznUdS4TTbtP0Gptd6GkYm9pR10YJGIJT+e5p12ABElXBkdlqPX2IyZvLn1s7I1qqR
         +OfQ==
X-Gm-Message-State: APjAAAVJGjHJf4Y+X66jrYZXKO1qT06BwR94tR7DjbG8bJHbBIM7KkY1
	fVR+9DOH+87NiRWzDduRdHx+VH6nNDI4/mzrlkh4m4zJdYbq/u11u0QV4qIgpQhFOqBadTh+iGs
	H0ifEAGQfo3/1v6cdd392O625lXlbn+abuSuxapsvaUwpw3Q+mGMIbucqBO1svuPiAQ==
X-Received: by 2002:a6b:f90f:: with SMTP id j15mr4571740iog.43.1562855215318;
        Thu, 11 Jul 2019 07:26:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvdo5d/WssBNUo3rE+k+Edg/hMx7olZ5D4MyMyXi80azhA2Fyagt9Kclr1PBsQabUKYUm8
X-Received: by 2002:a6b:f90f:: with SMTP id j15mr4571694iog.43.1562855214709;
        Thu, 11 Jul 2019 07:26:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855214; cv=none;
        d=google.com; s=arc-20160816;
        b=bn5HZ/yTsYmskjWRun+HTOiSJdm4OlviNgTI0aOyM/CvP7h3Zbfztr0hRi/KfwROpY
         0H1KnLy7As2CJLON7MwUi0KHNk0PAWRStDQRonSxrdxmj8VW06nc4i10oZ2pqAbDrYLF
         kp9kdnxF0ij1c/ZPId3qSwEHxBRILLoR9L6UPE3l3bSl2ah8e81kp9GFn/lJdPjWBfGS
         poZhb/qoKPGFBT9VLUcsJUS2fm7OWx+Scdz17u24A8uWF3vzJ4pE5Ze4+GoBbtXrr8Go
         w9aDiGuU65vpaLTjkhSF8Zm8Sy6LyHLpfQZWkkLm63MfPDnNLUgFWe1fTM0dKcrKaY9L
         SisA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=j5hNYpa6Ps4ofAY49xQlyVzas1I7FTDoeSXSCbctYus=;
        b=d/sWo3i0dE2G5FxY5+44gW6k3U2bgAb9Bo9U9cGhRpEcDXy+8XD3heJpjTCTtVr+yE
         6nNIhPwyXcCtH0QavibcLZTAxCZVrI0Bta7yxVAxonZNjkVQKosvUDYzSlSy/UO73L7T
         OJTu8/T9yaW7JCNoUr2TtSUJbpbYOAcHVJATrdGi18YhqrO6EOGsM2RuwRbg2Nk3fho8
         iCjWsHJjpKe8p1805a4SGPnIs8GbBcDp50qDdpX0t6cQJHAuBMEiijWGHiW/BAN00xy1
         WY4i+froI5hp89Roi1/ZN8wkm8+TB8CZnFz2JXDXC1QJKVt+65eMIDfSCkhk6gXBtlg7
         SoxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IZOylVir;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v3si7768588iot.133.2019.07.11.07.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IZOylVir;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO8Kr001447;
	Thu, 11 Jul 2019 14:26:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=j5hNYpa6Ps4ofAY49xQlyVzas1I7FTDoeSXSCbctYus=;
 b=IZOylVirFWDOmZYSdGDrwFnJwm9CEHLxntE+KdhdKKVzqt1gSAfqZTTsVwqNsGzmUzgE
 PAj74VbhDOsq4BCutkFXYEtKMfHv6uDQN4EwPs/i8mhcZpVyCpdqZIKiMK3B0iniWbhc
 nCHcdwRFI9A6XWvL9fDPRjGkqCOObfWGxfS7XmG6Q9mdYcz4LapWwYkhkHzoQvWylY6M
 ysC+FaRK07kBZ2670+CaYM92TpCurpQy/wzZmTZFtJvwBPFzsFwFvWvwJU5DIkIsFNK3
 zM5EMYBeH4z52ZPL8IQ1EjyFUcZnoz5RUscIoFGUEJ9sBLvHsPC7wF+/3bg5aRqA88yQ 5g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e1m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:44 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuB021444;
	Thu, 11 Jul 2019 14:26:41 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 18/26] rcu: Make percpu rcu_data non-static
Date: Thu, 11 Jul 2019 16:25:30 +0200
Message-Id: <1562855138-19507-19-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make percpu rcu_data non-static so that it can be mapped into an
isolation address space page-table. This will allow address space
isolation to use RCU without faulting.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 kernel/rcu/tree.c |    2 +-
 kernel/rcu/tree.h |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 44dd3b4..2827b2b 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -126,7 +126,7 @@ static void rcu_check_gp_start_stall(struct rcu_node *rnp, struct rcu_data *rdp,
 #define rcu_eqs_special_exit() do { } while (0)
 #endif
 
-static DEFINE_PER_CPU_SHARED_ALIGNED(struct rcu_data, rcu_data) = {
+DEFINE_PER_CPU_SHARED_ALIGNED(struct rcu_data, rcu_data) = {
 	.dynticks_nesting = 1,
 	.dynticks_nmi_nesting = DYNTICK_IRQ_NONIDLE,
 	.dynticks = ATOMIC_INIT(RCU_DYNTICK_CTRL_CTR),
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index 9790b58..a043fde 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -394,3 +394,4 @@ struct rcu_state {
 int rcu_dynticks_snap(struct rcu_data *rdp);
 void call_rcu(struct rcu_head *head, rcu_callback_t func);
 
+DECLARE_PER_CPU_SHARED_ALIGNED(struct rcu_data, rcu_data);
-- 
1.7.1

