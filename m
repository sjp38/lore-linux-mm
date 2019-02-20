Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7EC3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:03:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98DDE21773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:03:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="BnApq3GT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98DDE21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 250D58E0003; Tue, 19 Feb 2019 21:03:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FE3C8E0002; Tue, 19 Feb 2019 21:03:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ECFE8E0003; Tue, 19 Feb 2019 21:03:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D83A28E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:03:24 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b6so1343097qkg.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:03:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=00qWdP9yJCrrDj9GrrSLCkpLfkNqrzhgL2CKjBjnWLM=;
        b=f9tnB1CdmO0NHcQKGMsaKLylYaHwgnaOwATCsZIff0cgCI6iu1d/dbfXq7EvAuIbpd
         XaT6kKlFxBADqj4jDXAz8mBqeOn30XQ9hUcdbSyLEy/5/wwkxv+q1qK14nfplAGDpQiI
         V88WKcDUfFedVBgBuTR9vuZ0eiuWw2WdJ+vq2WVaTn+7zVWd4lcaNYNDrS9Y2SXY8Leb
         KtB0tdQBarMEscCT8DQdt9WocoXZ7g4+68Y/MvjZpolyDjdaWWJnJNVINWCs+v9PXpR7
         Zv33kDhe1QmcitldUsQuFXxizRuwU6RTGbv5nsv4nUwqaQdzbCIECTHf/9nEZrZHCAKR
         PSfA==
X-Gm-Message-State: AHQUAuZSYDsEBTdKIWVHQqFKYofHhiqRSWgEnxOqTTk3ERgKtsS7kZ+5
	uoo6BxQf3QKOTaZGjkMlhjrxeGDgTwsZ6Aet3LEYu6yFMuOf2ReMHeukJlNxyFO8moyZEwWCfCv
	VkVMKSQE60m570NcyBh6KV59rKsQ/aLyl01WejvCE+hw4Q4hquAAOdiHDcQXUCWxUD9vlQFvw6W
	4k0FwCalFy6vluOeHvwJWlbcHwudiKZ+PeNIPtYisOVsS9E+kAd0YdT21jIQZJ2Oo3AE/amKpwf
	GNReHwcCOVXOeN4vXkjJomy1+K/9ds7O+AoPUyaRTwjIFhNh1H9EUyizcme3ngpoNAE30N3O4Aw
	/rnW5jDSaf0zF0sNrekoVnZ7wbBA4vbhdbp0svSY55haaL90Gp1rygFTGiJ4Vh3QB6hdksQYKG+
	Z
X-Received: by 2002:a37:2cc2:: with SMTP id s185mr10195521qkh.72.1550628204576;
        Tue, 19 Feb 2019 18:03:24 -0800 (PST)
X-Received: by 2002:a37:2cc2:: with SMTP id s185mr10195479qkh.72.1550628203778;
        Tue, 19 Feb 2019 18:03:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550628203; cv=none;
        d=google.com; s=arc-20160816;
        b=hp9ZS0QaKJj4z1qFlFXFbjxTlS8ydcG9nhwcCOaw70m5QkeUfaDOp5GCiy7elXdSaV
         UK/TUp52rIDISudKa6IlnPjG4ttoIq/T8UI9E3lwxG79A5+SPdPQztjmBzjbnCwjErb8
         rqkbuyvfd7Ti60TWN+ahSkuaivmfNx54KYSLJQ8nIVj0pm/w8NsRpXOez+s0ZSxz7FPA
         NdN05wOoH8wMcjX2WNAEgJDnP12rea0kxPozcVBjEuS70I8YUAfNjn+3kE6whzLXk/Ff
         z2EotfPIUSEVUgPuJfInc9abfU0kKlHrCwg/TZORDW9PYkHFFVEblRo9u41XuaG1XzWx
         Axiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=00qWdP9yJCrrDj9GrrSLCkpLfkNqrzhgL2CKjBjnWLM=;
        b=kHr5q5AUOQvkZbozQm9ocb6wJ8YWaT0c9eJwCD8OTDhvjdGpuI1H+ESHJPu3ggXsrO
         tAFHrVDPQkhS0ERdbXkO8G5JSxf5FCjOXylHB3sxSPy1wq87LcIHrbfYbwPOFS51n9Tg
         QeD1PI0uoF+05etGhw8farFL1rB4/fY+XMdaQnPNVqs6a78F2NmzRqjhSgBQeUWYvNaV
         lIvaaU845Q+7RbjlGYwvAhj9rQDBL+eHJ+r7hukj/JCvfcgW+IQssfOpUKfw/b1mJ/UC
         oBOWd06LeefhcVzRbioTl9jSQfDDfyVR2CRlH+IBDadk3SQ6/+cmvCTG5UIJIGYLyPA8
         wv6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=BnApq3GT;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a56sor6678624qte.27.2019.02.19.18.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 18:03:23 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=BnApq3GT;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=00qWdP9yJCrrDj9GrrSLCkpLfkNqrzhgL2CKjBjnWLM=;
        b=BnApq3GTgw/vvlNZI7FNmBPS6n5zAgj8+gng584kXntro/o/4d3yK/K1GqbqVIt5J/
         4dWgdLiVcGX04J3Ahj3NTbNr+rHgqyAzlabCxSIQT/CkYh+bVSz/4yVO/Fp3PkXsJKOG
         lvbeMslDs67sZ4FOicVtbp5NovgZvgW/FPKuinmAHSB2qR1RfyYfdjZhGe3En70tnO4P
         AjSWgHZcvLShMZhQfyqEbDcA8LB5l9B+VYPsnF89Z4Q9y3zS4cxChtuEr8uUB0hwmr2m
         eoirL4T/QlY8a2eOzNlWp3c2SM88Mgs875pIXRiz+pGPCSKQb9NH+lWQ6zB0WJdqeyWH
         Ks5g==
X-Google-Smtp-Source: AHgI3IbqioLYY6MZWt0VLZUZEcVvkIibUz03IZ0UH5ZlE5Bt0+S3R13iIIe2HPiShH2SvsrYq5SbzA==
X-Received: by 2002:ac8:3fd4:: with SMTP id v20mr24404066qtk.188.1550628203480;
        Tue, 19 Feb 2019 18:03:23 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id f29sm13571153qte.11.2019.02.19.18.03.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 18:03:23 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com
Cc: andreyknvl@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slub: fix a crash with SLUB_DEBUG + KASAN_SW_TAGS
Date: Tue, 19 Feb 2019 21:02:51 -0500
Message-Id: <20190220020251.82039-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In process_slab(), "p = get_freepointer()" could return a tagged
pointer, but "addr = page_address()" always return a native pointer. As
the result, slab_index() is messed up here,

return (p - addr) / s->size;

All other callers of slab_index() have the same situation where "addr"
is from page_address(), so just need to untag "p".

 # cat /sys/kernel/slab/hugetlbfs_inode_cache/alloc_calls

[18868.759419] Unable to handle kernel paging request at virtual address 2bff808aa4856d48
[18868.767341] Mem abort info:
[18868.770133]   ESR = 0x96000007
[18868.773187]   Exception class = DABT (current EL), IL = 32 bits
[18868.779103]   SET = 0, FnV = 0
[18868.782155]   EA = 0, S1PTW = 0
[18868.785292] Data abort info:
[18868.788170]   ISV = 0, ISS = 0x00000007
[18868.792003]   CM = 0, WnR = 0
[18868.794973] swapper pgtable: 64k pages, 48-bit VAs, pgdp = 0000000002498338
[18868.801932] [2bff808aa4856d48] pgd=00000097fcfd0003, pud=00000097fcfd0003, pmd=00000097fca30003, pte=00e8008b24850712
[18868.812597] Internal error: Oops: 96000007 [#1] SMP
[18868.835088] CPU: 3 PID: 79210 Comm: read_all Tainted: G             L    5.0.0-rc7+ #84
[18868.843087] Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.6 07/10/2018
[18868.852915] pstate: 00400089 (nzcv daIf +PAN -UAO)
[18868.857710] pc : get_map+0x78/0xec
[18868.861109] lr : get_map+0xa0/0xec
[18868.864505] sp : aeff808989e3f8e0
[18868.867816] x29: aeff808989e3f940 x28: ffff800826200000
[18868.873128] x27: ffff100012d47000 x26: 9700000000002500
[18868.878440] x25: 0000000000000001 x24: 52ff8008200131f8
[18868.883753] x23: 52ff8008200130a0 x22: 52ff800820013098
[18868.889065] x21: ffff800826200000 x20: ffff100013172ba0
[18868.894377] x19: 2bff808a8971bc00 x18: ffff1000148f5538
[18868.899690] x17: 000000000000001b x16: 00000000000000ff
[18868.905002] x15: ffff1000148f5000 x14: 00000000000000d2
[18868.910314] x13: 0000000000000001 x12: 0000000000000000
[18868.915626] x11: 0000000020000002 x10: 2bff808aa4856d48
[18868.920937] x9 : 0000020000000000 x8 : 68ff80082620ebb0
[18868.926249] x7 : 0000000000000000 x6 : ffff1000105da1dc
[18868.931561] x5 : 0000000000000000 x4 : 0000000000000000
[18868.936872] x3 : 0000000000000010 x2 : 2bff808a8971bc00
[18868.942184] x1 : ffff7fe002098800 x0 : ffff80082620ceb0
[18868.947499] Process read_all (pid: 79210, stack limit = 0x00000000f65b9361)
[18868.954454] Call trace:
[18868.956899]  get_map+0x78/0xec
[18868.959952]  process_slab+0x7c/0x47c
[18868.963526]  list_locations+0xb0/0x3c8
[18868.967273]  alloc_calls_show+0x34/0x40
[18868.971107]  slab_attr_show+0x34/0x48
[18868.974768]  sysfs_kf_seq_show+0x2e4/0x570
[18868.978864]  kernfs_seq_show+0x12c/0x1a0
[18868.982786]  seq_read+0x48c/0xf84
[18868.986099]  kernfs_fop_read+0xd4/0x448
[18868.989935]  __vfs_read+0x94/0x5d4
[18868.993334]  vfs_read+0xcc/0x194
[18868.996560]  ksys_read+0x6c/0xe8
[18868.999786]  __arm64_sys_read+0x68/0xb0
[18869.003622]  el0_svc_handler+0x230/0x3bc
[18869.007544]  el0_svc+0x8/0xc
[18869.010428] Code: d3467d2a 9ac92329 8b0a0e6a f9800151 (c85f7d4b)
[18869.016742] ---[ end trace a383a9a44ff13176 ]---
[18869.021356] Kernel panic - not syncing: Fatal exception
[18869.026705] SMP: stopping secondary CPUs
[18870.254279] SMP: failed to stop secondary CPUs 1-7,32,40,127
[18870.259942] Kernel Offset: disabled
[18870.263434] CPU features: 0x002,20000c18
[18870.267358] Memory Limit: none
[18870.270725] ---[ end Kernel panic - not syncing: Fatal exception ]---

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4a61959e1887..289c22f1b0c4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -311,7 +311,7 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 /* Determine object index from a given position */
 static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
-	return (p - addr) / s->size;
+	return (kasan_reset_tag(p) - addr) / s->size;
 }
 
 static inline unsigned int order_objects(unsigned int order, unsigned int size)
-- 
2.17.2 (Apple Git-113)

