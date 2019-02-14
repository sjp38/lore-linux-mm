Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EC25C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F0C218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fZ7BPquZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F0C218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B41E8E0009; Wed, 13 Feb 2019 19:02:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7392B8E0005; Wed, 13 Feb 2019 19:02:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 629288E0009; Wed, 13 Feb 2019 19:02:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF948E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so3217165pfk.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=BVvtye26KZIs7muho5hLhXsAoOpu90yJN7XQD4ZHF6s=;
        b=unEHy70hhzKL0tnS8cl2jjcwPtuZ8nAdi+2+ZQxA53/mnKfq1lf361f8JpFliknMVw
         q+VKHOKYrIWshMTwqyHCzfPNxGW7jzKk9m7+GD94qOuEAlkkDIZVH6/+q9ztRoYL08aT
         ZjGGgivrWFEYI+onyKAHYm63o5BbaWrvlYMyRg263rGy4ieSjwfsqTJFMLualxZnjrD3
         M3b/ER4tJKblvurWXwNFyj25By9VTWIKtgJ+vFl8aGsb23FFxPsZHIrBL8y5eHa+2/Wh
         NPo8cxOrKlrAIxL3mx8USNOgnfbpOCD3r5iQRvEbBJRtNiGZmv1Z2k5Esei1n7GNkhgc
         vVZw==
X-Gm-Message-State: AHQUAuaXo9R887iYeGHHAfORMAc1Uytn6esLr9GlW3Gm4WRmBVCPqtNd
	DBr2IapWCFkCoWf1R0wBTa0Rj9hu2gLWDgMVJj4+u/QGUSHT+82wgnQFzIJrml5TiGFoq9+Xh1E
	PXXW68HpBUF6/KhtgSZX9cFl/uQX9LwBjP8G55x/eljjXeo7pwLqnyqqIcLV8WElj0Q==
X-Received: by 2002:a62:2008:: with SMTP id g8mr849384pfg.121.1550102565739;
        Wed, 13 Feb 2019 16:02:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0bGWEapqYPOqvqYfEjLTTSMiFMS6pORptQwrf6Vs35u3/jWcy70Rn4C4mHEH5GV2GZuGr
X-Received: by 2002:a62:2008:: with SMTP id g8mr849303pfg.121.1550102564870;
        Wed, 13 Feb 2019 16:02:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102564; cv=none;
        d=google.com; s=arc-20160816;
        b=p7lKYOUnOjUBlob+qF7F5Pbl5qNZRkTdLzFHxXoJf3mODWUVquaKn/fP5mi3uRZPXb
         muamW4NPn/LdXnsSEftrEBjFvC/8nG34ujQgxP4776qftX9McWajN250q36zUwEDJ3SJ
         rQkrEdIJmXladTEl3bu5ACXWu02O390P580NSRChtHuV8hYsU88FZ3Vdv+9jyGG1wAHQ
         KgAsrDNs/zG+ZvfkH6F4ZMaVoAbIk99vgJdV55NqYgvXb9cUX6Wgi6IBwNy+bA9S4eeM
         7oNWfo/UXg1+vPPq/3l2yQmFrLKeDHYpH5n47TD21uoh4zLoybTdbyqWexF/vHkMmNs7
         8RAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=BVvtye26KZIs7muho5hLhXsAoOpu90yJN7XQD4ZHF6s=;
        b=JUyXU/ysUsre/OtLP6vOm/hQPpAzMO6QXgiUt5VPBXl5sQEMOF/uF4YeoE6CO2yC95
         WfPlMDDcB5RcI4qm0HhAc8epv2TJTSFYamCBEbbAqdKtdEgMQwSThSg8Et66/zkltCTN
         xOxFSJeh+2oATEv8n0V67Jv1alp7qfF/l7NqbqWvx1G4uIcbUJgnO5S1OWBv4NV/K5Ga
         ADaSreMhhSysWHwQMJdHqTH1Ds1i73EP8gEu3V6SwojLJzSPSlv5JHsXH6Z5J6HKlLFO
         ZODAmLb0+7xufsOiBei+9IDjQnMNQoLW2551Gj4eBZ1+Ljev9/nU0zZYCPZ+dOeGWd1c
         YBNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fZ7BPquZ;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i5si712705pgg.279.2019.02.13.16.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:44 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fZ7BPquZ;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwlSC100511;
	Thu, 14 Feb 2019 00:02:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=BVvtye26KZIs7muho5hLhXsAoOpu90yJN7XQD4ZHF6s=;
 b=fZ7BPquZinNkNfviJmu2aj5OWxvfaEW6ze9/DO2c6uAP65Cc4e4Cl3T1X2A+uS3/Cnnj
 FXw2tAJbgFiECJbQ4WvubRBn8pxAj4qhxLwEmJiaDQgis7w2FmPwW2j42M7DueNqyBGy
 EyJX2fW7sQZHaipQdaHrDl4Ch27fK6OjK5xHCrNaGpwnUD2AjFaKdF5KlkO1RjMlgz7E
 wO+hNUWeMh8kKPGfqr2rZVzyWdP8lbCxRvKmyeYtHEahIc8wLWsnl9jqQNQFXSxMWNlu
 3RxQ4F/6tOJWAzRs4vywbeqWiVdLGC3PRvx47Ai+oOoMdEY1LwrLa/ajJI34d9cE7gWR uA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3u7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:02 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E021Ic025030
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:02 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E01w4G032279;
	Thu, 14 Feb 2019 00:02:00 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:01:57 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH v8 02/14] x86: always set IF before oopsing from page fault
Date: Wed, 13 Feb 2019 17:01:25 -0700
Message-Id: <b3c439c8187f843a03a514f7d8005dc15fcc909e.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=885 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@docker.com>

Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
that might sleep:

Aug 23 19:30:27 xpfo kernel: [   38.302714] BUG: sleeping function called from invalid context at ./include/linux/percpu-rwsem.h:33
Aug 23 19:30:27 xpfo kernel: [   38.303837] in_atomic(): 0, irqs_disabled(): 1, pid: 1970, name: lkdtm_xpfo_test
Aug 23 19:30:27 xpfo kernel: [   38.304758] CPU: 3 PID: 1970 Comm: lkdtm_xpfo_test Tainted: G      D         4.13.0-rc5+ #228
Aug 23 19:30:27 xpfo kernel: [   38.305813] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1 04/01/2014
Aug 23 19:30:27 xpfo kernel: [   38.306926] Call Trace:
Aug 23 19:30:27 xpfo kernel: [   38.307243]  dump_stack+0x63/0x8b
Aug 23 19:30:27 xpfo kernel: [   38.307665]  ___might_sleep+0xec/0x110
Aug 23 19:30:27 xpfo kernel: [   38.308139]  __might_sleep+0x45/0x80
Aug 23 19:30:27 xpfo kernel: [   38.308593]  exit_signals+0x21/0x1c0
Aug 23 19:30:27 xpfo kernel: [   38.309046]  ? blocking_notifier_call_chain+0x11/0x20
Aug 23 19:30:27 xpfo kernel: [   38.309677]  do_exit+0x98/0xbf0
Aug 23 19:30:27 xpfo kernel: [   38.310078]  ? smp_reader+0x27/0x40 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.310604]  ? kthread+0x10f/0x150
Aug 23 19:30:27 xpfo kernel: [   38.311045]  ? read_user_with_flags+0x60/0x60 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.311680]  rewind_stack_do_exit+0x17/0x20

To be safe, let's just always enable irqs.

The particular case I'm hitting is:

Aug 23 19:30:27 xpfo kernel: [   38.278615]  __bad_area_nosemaphore+0x1a9/0x1d0
Aug 23 19:30:27 xpfo kernel: [   38.278617]  bad_area_nosemaphore+0xf/0x20
Aug 23 19:30:27 xpfo kernel: [   38.278618]  __do_page_fault+0xd1/0x540
Aug 23 19:30:27 xpfo kernel: [   38.278620]  ? irq_work_queue+0x9b/0xb0
Aug 23 19:30:27 xpfo kernel: [   38.278623]  ? wake_up_klogd+0x36/0x40
Aug 23 19:30:27 xpfo kernel: [   38.278624]  trace_do_page_fault+0x3c/0xf0
Aug 23 19:30:27 xpfo kernel: [   38.278625]  do_async_page_fault+0x14/0x60
Aug 23 19:30:27 xpfo kernel: [   38.278627]  async_page_fault+0x28/0x30

When a fault is in kernel space which has been triggered by XPFO.

Signed-off-by: Tycho Andersen <tycho@docker.com>
CC: x86@kernel.org
Tested-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/x86/mm/fault.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 71d4b9d4d43f..ba51652fbd33 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -748,6 +748,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 	/* Executive summary in case the body of the oops scrolled away */
 	printk(KERN_DEFAULT "CR2: %016lx\n", address);
 
+	/*
+	 * We're about to oops, which might kill the task. Make sure we're
+	 * allowed to sleep.
+	 */
+	flags |= X86_EFLAGS_IF;
+
 	oops_end(flags, regs, sig);
 }
 
-- 
2.17.1

