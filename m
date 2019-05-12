Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C29E5C04A6B
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 05:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52AFB2146F
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 05:49:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="pCdZURrr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52AFB2146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB57A6B0003; Sun, 12 May 2019 01:49:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A036B0005; Sun, 12 May 2019 01:49:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904636B0006; Sun, 12 May 2019 01:49:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2D96B0003
	for <linux-mm@kvack.org>; Sun, 12 May 2019 01:49:10 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o32so11011048qtf.1
        for <linux-mm@kvack.org>; Sat, 11 May 2019 22:49:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=6c2kvC33LANT/dMFRqDq0mJDA8htPkT69/GA1pevljE=;
        b=dnbdZalld4/pnL1Dtvray7t7r7AqWBTmT5qtjj9sL0mivmbFYTZXTT8ZpDr49WZG2a
         mY+YfkTkTzz1kQFEburEd5ozPeoc9v9dtaQ4RpTi0Fz9jXBEhOr2qo2Ga/AuYMR1O+rN
         O6p7PqGXpgOb1TxjFPR9OcEKZh4UlKlO/HQFYA420E1GSyUlUcFVtAoZOfc+DOlh+fOG
         gXA07Ua3wm23KhJtNV2aaxfZEGiGSSaz8nkA8mwJ+Tco+j8uZLdR8yqukZ2LCg4FtgLn
         KR4wMmyjvRwqII2E4HbkcgsStXW5GdRGPElUmrY6v78iXyxGhSg0qxhlabwlPNmHg0IK
         Y8Hg==
X-Gm-Message-State: APjAAAXl15o8Ht+0pyNRhOaEEcQuH7Ut2C7N7aoqzqfoCEzvXE+oqv21
	jy15OgsSc8ageLp6rTd2sfVq/gZ5EshaYkoRbv+XIBHZcjgQqL6C6DHW0XmNmfDp7FwQa6FZxlH
	Js30fbSdErRvZ6ZP00UhPDq5su38ORydudr4RKTCsRGSHwPXSrnP8f5Ocq8e6geuPNQ==
X-Received: by 2002:a0c:d642:: with SMTP id e2mr16735856qvj.5.1557640150051;
        Sat, 11 May 2019 22:49:10 -0700 (PDT)
X-Received: by 2002:a0c:d642:: with SMTP id e2mr16735832qvj.5.1557640149229;
        Sat, 11 May 2019 22:49:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557640149; cv=none;
        d=google.com; s=arc-20160816;
        b=tGz7JvjiIn7608pcG+SUlytm+InZ+AWJ1CtbgTbK9qoiE8aLaJ48FEC2/E9qxEKUIu
         gSmJW3jk1Sw3YRFYCkQ4UAsJwCehku9y4AZ4esIcdKjog5elt3cmyzOSwT52L3AwHx20
         0Hx47RV7MQ1HPQYxR1EAtAxnSfxNAO5fANqzqgLQMlu87YuXFbIsk5+gFkm9K8LsdkrP
         z3RMyLevauOrgt+Vfuz6qWMu+S8cJrBiMrQ5g1GpC8X57ox1tM2JSmLSJ9LuAO+eqK5h
         Gd8pD/HxbCRFasiOrm4MCLT7NXzei6timzZlS3icnRx+e2GIX+e6cLolCiOrRKRJhMfs
         lCgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=6c2kvC33LANT/dMFRqDq0mJDA8htPkT69/GA1pevljE=;
        b=K6VniTGUpOdhfSXUASSva+DCGi0115md6CMf1+gR9/BbuS1WsIr1C8YC+3oKg9m2bw
         g1T7jtVyuoDo55kOnzIDXwBOVCkh2QOlu+ddizZo8OuQLpcLGED3U8xMSoix0Do0KS1d
         R0DU/Jgx9RVpF30T91udrVMPZ1Q1leGqT9iWz3Xb34pX/upc5KeO8I7h64nn/k7ujx+B
         n8ufjpD/JNRrofvU6z1eXWcKgtjd93iDg0mWHoKus8ugrFYU4sfFFRk4rHfTe/cSCEqC
         qwGLxKrjWb/inywn1l1pGfExTnPuTHtyXBfvVUb7KtQ3opgOuiZ9T+0ZHCvUE4I/dRv1
         RPrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=pCdZURrr;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2sor12549420qth.61.2019.05.11.22.49.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 May 2019 22:49:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=pCdZURrr;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=6c2kvC33LANT/dMFRqDq0mJDA8htPkT69/GA1pevljE=;
        b=pCdZURrr3WKxmADSBzXKJit6CTquRKjG0USn5xohP+aXHtXE6fJV34WEWbwB+IYT+O
         HfPnj/7+lDpSUtKsV980fyNsbeTQBc09FmEcc4RmStWOU5+VwMdaDViISH0jqiBc+IPL
         a/GaDOsa7ksme2XwJ/SijZKsxwyIWYr7yyrUIT+Vf9nR7kl5BNg2+7RrHH2t3zxoZ5BL
         BDOXMz+8qZo+G7MM+gIH1yjSFTk/aKVZdkaIhP87QkjZkdUJNhRFBJDXP8fZHYnpjhts
         Q5TdnE1/coSvEIl4Aa7eepZO3AP2FQNKvbjflK8uOT14A4+BlBwyj03+HUhOLC8epeE/
         IeYg==
X-Google-Smtp-Source: APXvYqzW8aSxY6OoX/5athcz/9TnyMOBrzXGyDz3abcE6/hG6s6QeFwc8YHtljDP9ZdUya6aMFrolw==
X-Received: by 2002:ac8:1609:: with SMTP id p9mr17580321qtj.291.1557640148921;
        Sat, 11 May 2019 22:49:08 -0700 (PDT)
Received: from ovpn-121-162.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s17sm1751951qke.60.2019.05.11.22.49.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 May 2019 22:49:07 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	brho@google.com,
	kernelfans@gmail.com,
	dave.hansen@intel.com,
	rppt@linux.ibm.com,
	peterz@infradead.org,
	mpe@ellerman.id.au,
	mingo@elte.hu,
	osalvador@suse.de,
	luto@kernel.org,
	tglx@linutronix.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
Date: Sun, 12 May 2019 01:48:29 -0400
Message-Id: <20190512054829.11899-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit ("x86, numa: always initialize all possible
nodes") introduced a crash below during boot for systems with a
memory-less node. This is due to CPUs that get onlined during SMP boot,
but that onlining triggers a page fault in bus_add_device() during
device registration:

	error = sysfs_create_link(&bus->p->devices_kset->kobj,

bus->p is NULL. That "p" is the subsys_private struct, and it should
have been set in,

	postcore_initcall(register_node_type);

but that happens in do_basic_setup() after smp_init().

The old code had set this node online via alloc_node_data(), so when it
came time to do_cpu_up() -> try_online_node(), the node was already up
and nothing happened.

Now, it attempts to online the node, which registers the node with
sysfs, but that can't happen before the 'node' subsystem is registered.

Since kernel_init() is running by a kernel thread that is in
SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
during the early boot in __try_online_node().

Call Trace:
 device_add+0x43e/0x690
 device_register+0x107/0x110
 __register_one_node+0x72/0x150
 __try_online_node+0x8f/0xd0
 try_online_node+0x2b/0x50
 do_cpu_up+0x46/0xf0
 cpu_up+0x13/0x20
 smp_init+0x6e/0xd0
 kernel_init_freeable+0xe5/0x21f
 kernel_init+0xf/0x180
 ret_from_fork+0x1f/0x30

Reported-by: Barret Rhoden <brho@google.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: Set the node online as it have CPUs. Otherwise, those memory-less nodes will
    end up being not in sysfs i.e., /sys/devices/system/node/.

 mm/memory_hotplug.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b236069ff0d8..6eb2331fa826 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1037,6 +1037,18 @@ static int __try_online_node(int nid, u64 start, bool set_node_online)
 	if (node_online(nid))
 		return 0;
 
+	/*
+	 * Here is called by cpu_up() to online a node without memory from
+	 * kernel_init() which guarantees that "set_node_online" is true which
+	 * will set the node online as it have CPUs but not ready to call
+	 * register_one_node() as "node_subsys" has not been initialized
+	 * properly yet.
+	 */
+	if (system_state == SYSTEM_SCHEDULING) {
+		node_set_online(nid);
+		return 0;
+	}
+
 	pgdat = hotadd_new_pgdat(nid, start);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
-- 
2.20.1 (Apple Git-117)

