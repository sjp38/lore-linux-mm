Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8244C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B2D8206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:36:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SFJGOxM0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B2D8206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDE0F6B000E; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB4156B0008; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2E856B0269; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFC46B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w11so14294719iom.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=557xk95OakwCk6FJ0C0EA1LbpPbU7nMPF7pIFxhjjUw=;
        b=Z+y3whT254nyj8QmZyfEvbK0INcZqExAAMj4U3ip6HFqUPgrj3pjib87B0g7YKvGEj
         nHxldnPm5UzpDvPyWLST80CX61/UaijNG/QknvO6OHUmaT2V/yiqbKXZqkVwR8LnFvCm
         LnMLdFm0p/DwhcrNdw2UTswXEp4PJTvAfXb7i7ObszRjyRKPF4aTEh9gziFfnQve2098
         E4aHtIh7OrAoU2r+S7L7D7XN8R8fstgXmHEgROZb5YLVPa5F0lSZoSZ/FFRNTR4AqM21
         a7zJBdSg4cGQTZ7fKJCgevcdP2IVuwngecv/eqJVfu0TeWWD6OBI75EnNGGWxbkRG/uE
         CUUw==
X-Gm-Message-State: APjAAAUwjsWWI7SeTMFFPnirjVAUqp6UWmphGfntLX0N0xJDjygMo1uc
	BzeT6YRJZceoe2pdR3NYdv5dvzFhXvxCxMMwyNaXQE3zfKSP+/FktbCV2jV0O1wuZzwrATGbO+L
	uqpaWk+nNXGiT3IojhylS9RbHS0faJcl51SbFjCy6a6aLXerznHRHQ9V+GrgNb8IT9w==
X-Received: by 2002:a24:7f90:: with SMTP id r138mr1207961itc.163.1554313018369;
        Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbRtofDF3itg+/kv/3uWyEd6KAU3wPZkrIo6ebPn/MOS4959QcPFw8RVvX01CHj2nkrJ5L
X-Received: by 2002:a24:7f90:: with SMTP id r138mr1207894itc.163.1554313017374;
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313017; cv=none;
        d=google.com; s=arc-20160816;
        b=V3/gjA6gmh6a7dHOPtTg1rkb1gvGaguwodjpPkoByk78lU0fP5ffNmVb5ihsRF1HzG
         1c6WWtW3hf3BBZuGe3oaiNdmh9N6d0ZgNt/QYdTgr1Ls0Hnia4Bhlx1v4ZuYt+2AIEzC
         dHMI87U2JiRcwrWPJDeE6Qv4doS++7+e5Nu9NGHpCYroBZ0ix22EXe0+VWvYVzgi2I1O
         qGass3uJKDVg0bVuok2E1MZsoy/fo1I2h6Nil3MZFNC1CC6qb9e3+PwKrVxq72/EPGRQ
         N3r/C19vFK8jgIMmODkdXVdvQzT+UKfqiRws+/1lQvHLNJU/fi0DYDK/9zk5GCBvsCgP
         Csew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=557xk95OakwCk6FJ0C0EA1LbpPbU7nMPF7pIFxhjjUw=;
        b=AIIDm0d+LRlYbZEndnV3K67DXaUtXrmt6bVU7yRyVjzV8bZn0tTAWZf1vEU9w5pb1g
         QrFtQSBxZnSHWzbKwDH5Fayd/cIsVDH+17RqNFHPf1ma3waTIY3/+F7EEePc0LGOftXa
         ArYdgP25wLlMMrEgHUrNfhMgdTG23XPrc/XU9lF5aOosOyqlo831b4xAP3kIoyFe7si7
         xXIn3azECWqUj//Ma7qbIBeNM1NE3C8BF5QAYB2a/+vZOZ1J3yYoFevfeacWevGBfT77
         tYS0pvUQxxyazgirPECq8A0AKeLC3kXLlQW7agBXfecMjkmA5AiMEWd/dxlAGlA77DfK
         D9UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SFJGOxM0;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 75si8623242itw.88.2019.04.03.10.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SFJGOxM0;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNnQk166346;
	Wed, 3 Apr 2019 17:35:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=557xk95OakwCk6FJ0C0EA1LbpPbU7nMPF7pIFxhjjUw=;
 b=SFJGOxM0x82gjwj/Br/Tc+Lkjt5bXEinVRIyhHOAKlVVQmQupdkriXJTTzNhWxREe9w1
 w0Nl7diAhIzsCrldHqcj9mabQt4qhr0L3DCybhSZqCAMMqowLm0MS+s8VBHfcFkM55m0
 ESknyl1X4cl2UqZ3ZiqXBUq7BAV6kZrkkEgghxjkqceObZ80u3Zsu57YJP8p35kjvBku
 dXhPigJE9uMc+kr1u15D+RkpnPH5TgHGWrn/3BXNqKR/7jY+IEUAYBgkZdKXN0F5VmiI
 hfV2B5EUjpENEmr6Izkl3nuC75/VPM0WzGvWfq6UVNy9lKjkHaQipdkHyUNdGeN3AKeo aw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rhyvtahkt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HYCNe081741;
	Wed, 3 Apr 2019 17:35:42 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2rm8f57yp3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZQ8g001194;
	Wed, 3 Apr 2019 17:35:26 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:26 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page fault
Date: Wed,  3 Apr 2019 11:34:03 -0600
Message-Id: <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@tycho.ws>

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

Signed-off-by: Tycho Andersen <tycho@tycho.ws>
CC: x86@kernel.org
Tested-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 arch/x86/mm/fault.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9d5c75f02295..7891add0913f 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -858,6 +858,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
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

