Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C90E7C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F4C32171F
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AchZsL8y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F4C32171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B03B6B0266; Mon, 16 Sep 2019 10:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 061766B0269; Mon, 16 Sep 2019 10:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E69496B026A; Mon, 16 Sep 2019 10:47:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id C42176B0266
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:47:39 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 744BE181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:39 +0000 (UTC)
X-FDA: 75941062638.25.eye33_25a857d616531
X-HE-Tag: eye33_25a857d616531
X-Filterd-Recvd-Size: 12799
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:38 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id q12so21941pff.9
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:47:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ap/iQx5BaMbDDbZ/PwDKM/VLAAqHmAWjY/d3zJTaoAw=;
        b=AchZsL8y6BmUqWecrjwrDZRs3JX50sZmVyMFL+4oB7VoOrNc/t5iJWTxnY8NsH5YEj
         qMeD1dS0cG6M3gPTCzZKsHJJIjoi2VPObz53IzelsjfKryKMzAEjfryn045BdGi1sNOW
         IYhGY+eHzjT7iNX/N6uIJH9o4N0QyJFFmAU6kSPSEG3NYjNJ3mOZB9IYU40rKBG33RHT
         tmdu7z4cBD5synBIxIYxd5l+lnr9tILaWiJQNGxROu290GRwmH/0P/S+VDJMjmO8fn3V
         bql3ZTfBmNUpKJRv4ToX/dIt+N0R6p0hYu7ID9V4j+7+JeoIRc+PghJ2WsGol6Rkmigs
         Ftdw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ap/iQx5BaMbDDbZ/PwDKM/VLAAqHmAWjY/d3zJTaoAw=;
        b=gw5ZdapwVh2STUFx8n6WA6P0PIgzlkW3W4R9kVhZ5HpPqL8302dSPnNZalm6ijkMBe
         iA0hVHQ4t2ssZkrUpd9J554rN/P1bCMBQ1hBW0eZhWcp0a56BMQoMNlQv0OLAi0qtZsE
         qjoaTN79hQKuggFgNsVrRH2FdDARLexfmf/dGF/d9I4oG+nuTjLnw4eta+XTNU3eL+Fa
         TjtAD2SWQyfv6YdbGh/IQj/0KyboSR+tKZb276FKI+RygeVZcuKtcCG/NVF0SiD/J4ex
         uF4u8DWzL6Za2lkPqML898ZwrZk7k/t0j1WYn1MBCZ6j/13A/cX2FROzXvgR0wPdkGEs
         wmRA==
X-Gm-Message-State: APjAAAUe94XrygppQ6UL+pceWFJW3Eg5JywejsYg0ZUAa5H9eL/Cr/aE
	AaCRGowkcBi7FDNPraNIUP0=
X-Google-Smtp-Source: APXvYqxbiDWKbgfGTpb2sMSxrCcFiHNB9BEpZjV/ztznrOFPIyCbL79PaQnFlxxN67IWT8Towcojxw==
X-Received: by 2002:a62:76d1:: with SMTP id r200mr73535722pfc.27.1568645257576;
        Mon, 16 Sep 2019 07:47:37 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.47.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:47:37 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v5 7/7] mm, slab_common: Modify kmalloc_caches[type][idx] to kmalloc_caches[idx][type]
Date: Mon, 16 Sep 2019 22:45:58 +0800
Message-Id: <20190916144558.27282-8-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190916144558.27282-1-lpf.vector@gmail.com>
References: <20190916144558.27282-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

KMALLOC_NORMAL is the most frequently accessed, and kmalloc_caches[]
is initialized by different types of the same size.

So modifying kmalloc_caches[type][idx] to kmalloc_caches[idx][type]
will benefit performance.

$ ./scripts/bloat-o-meter vmlinux.patch_1-6 vmlinux.patch_1-7
add/remove: 0/0 grow/shrink: 2/57 up/down: 8/-458 (-450)
Function                                     old     new   delta
tg3_self_test                               4255    4259      +4
nf_queue                                     666     670      +4
kmalloc_slab                                  97      93      -4
i915_sw_fence_await_dma_fence                441     437      -4
__igmp_group_dropped                         619     615      -4
gss_import_sec_context                       176     170      -6
xhci_alloc_command                           212     205      -7
xprt_switch_alloc                            136     128      -8
xhci_segment_alloc                           297     289      -8
xhci_ring_alloc                              369     361      -8
xhci_mem_init                               3664    3656      -8
xhci_alloc_virt_device                       496     488      -8
xhci_alloc_tt_info                           346     338      -8
xhci_alloc_stream_info                       718     710      -8
xhci_alloc_container_ctx                     215     207      -8
xfrm_policy_alloc                            271     263      -8
tcp_sendmsg_locked                          3120    3112      -8
tcp_md5_do_add                               774     766      -8
tcp_fastopen_defer_connect                   270     262      -8
sr_read_tochdr.isra                          251     243      -8
sr_read_tocentry.isra                        328     320      -8
sr_is_xa                                     376     368      -8
sr_get_mcn                                   260     252      -8
selinux_sk_alloc_security                    113     105      -8
sdev_evt_send_simple                         118     110      -8
sdev_evt_alloc                                79      71      -8
scsi_probe_and_add_lun                      2938    2930      -8
sbitmap_queue_init_node                      418     410      -8
ring_buffer_read_prepare                      94      86      -8
request_firmware_nowait                      396     388      -8
regulatory_hint_found_beacon                 394     386      -8
ohci_urb_enqueue                            3176    3168      -8
nla_strdup                                   142     134      -8
nfs_alloc_seqid                               87      79      -8
nfs4_get_state_owner                        1040    1032      -8
nfs4_do_close                                578     570      -8
nf_ct_tmpl_alloc                              85      77      -8
mempool_create_node                          164     156      -8
ip_setup_cork                                362     354      -8
ip6_setup_cork                              1021    1013      -8
gss_create_cred                              140     132      -8
drm_flip_work_allocate_task                   70      62      -8
dma_pool_alloc                               410     402      -8
devres_open_group                            214     206      -8
create_kmalloc_caches                        203     195      -8
cfg80211_stop_iface                          260     252      -8
cfg80211_sinfo_alloc_tid_stats                77      69      -8
cfg80211_port_authorized                     212     204      -8
cfg80211_parse_mbssid_data                  2397    2389      -8
cfg80211_ibss_joined                         335     327      -8
call_usermodehelper_setup                    149     141      -8
bpf_prog_alloc_no_stats                      182     174      -8
blk_alloc_flush_queue                        191     183      -8
bdi_alloc_node                               195     187      -8
audit_log_d_path                             196     188      -8
_netlbl_catmap_getnode                       247     239      -8
____ip_mc_inc_group                          475     467      -8
__i915_sw_fence_await_sw_fence               417     405     -12
ida_alloc_range                              955     934     -21
Total: Before=3D14788957, After=3D14788507, chg -0.00%

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 include/linux/slab.h |  6 +++---
 mm/slab.c            |  4 ++--
 mm/slab_common.c     |  8 ++++----
 mm/slub.c            | 12 ++++++------
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index f53bb6980110..0842db5f7053 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -340,7 +340,7 @@ enum kmalloc_cache_type {
=20
 #ifndef CONFIG_SLOB
 extern struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_CACHE_NUM];
+kmalloc_caches[KMALLOC_CACHE_NUM][NR_KMALLOC_TYPES];
=20
 static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
 {
@@ -582,7 +582,7 @@ static __always_inline void *kmalloc(size_t size, gfp=
_t flags)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_trace(
-				kmalloc_caches[kmalloc_type(flags)][index],
+				kmalloc_caches[index][kmalloc_type(flags)],
 				flags, size);
 #endif
 	}
@@ -600,7 +600,7 @@ static __always_inline void *kmalloc_node(size_t size=
, gfp_t flags, int node)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_node_trace(
-				kmalloc_caches[kmalloc_type(flags)][i],
+				kmalloc_caches[i][kmalloc_type(flags)],
 						flags, node, size);
 	}
 #endif
diff --git a/mm/slab.c b/mm/slab.c
index 7bc4e90e1147..079c3e6ced1f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1246,7 +1246,7 @@ void __init kmem_cache_init(void)
 	 * Initialize the caches that provide memory for the  kmem_cache_node
 	 * structures first.  Without this, further allocations will bug.
 	 */
-	kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE] =3D create_kmalloc_cache(
+	kmalloc_caches[INDEX_NODE][KMALLOC_NORMAL] =3D create_kmalloc_cache(
 				kmalloc_info[INDEX_NODE].name[KMALLOC_NORMAL],
 				kmalloc_info[INDEX_NODE].size,
 				ARCH_KMALLOC_FLAGS, 0,
@@ -1263,7 +1263,7 @@ void __init kmem_cache_init(void)
 		for_each_online_node(nid) {
 			init_list(kmem_cache, &init_kmem_cache_node[CACHE_CACHE + nid], nid);
=20
-			init_list(kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE],
+			init_list(kmalloc_caches[INDEX_NODE][KMALLOC_NORMAL],
 					  &init_kmem_cache_node[SIZE_NODE + nid], nid);
 		}
 	}
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 00f2cfc66dbd..03d4c1521d21 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1028,7 +1028,7 @@ struct kmem_cache *__init create_kmalloc_cache(cons=
t char *name,
 }
=20
 struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_CACHE_NUM] __ro_after_init =3D
+kmalloc_caches[KMALLOC_CACHE_NUM][NR_KMALLOC_TYPES] __ro_after_init =3D
 { /* initialization for https://bugs.llvm.org/show_bug.cgi?id=3D42570 */=
 };
 EXPORT_SYMBOL(kmalloc_caches);
=20
@@ -1090,7 +1090,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t =
flags)
 		index =3D fls(size - 1) - KMALLOC_IDX_ADJ_2;
 	}
=20
-	return kmalloc_caches[kmalloc_type(flags)][index];
+	return kmalloc_caches[index][kmalloc_type(flags)];
 }
=20
=20
@@ -1171,10 +1171,10 @@ void __init setup_kmalloc_cache_index_table(void)
 static __always_inline void __init
 new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
 {
-	if (kmalloc_caches[type][idx])
+	if (kmalloc_caches[idx][type])
 		return;
=20
-	kmalloc_caches[type][idx] =3D create_kmalloc_cache(
+	kmalloc_caches[idx][type] =3D create_kmalloc_cache(
 					kmalloc_info[idx].name[type],
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
diff --git a/mm/slub.c b/mm/slub.c
index 0e92ebdcacc9..e87243a16768 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4711,7 +4711,7 @@ static void __init resiliency_test(void)
 	pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
 	       p + 16);
=20
-	validate_slab_cache(kmalloc_caches[type][1]);
+	validate_slab_cache(kmalloc_caches[1][type]);
=20
 	/* Hmmm... The next two are dangerous */
 	p =3D kzalloc(32, GFP_KERNEL);
@@ -4720,33 +4720,33 @@ static void __init resiliency_test(void)
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
=20
-	validate_slab_cache(kmalloc_caches[type][2]);
+	validate_slab_cache(kmalloc_caches[2][type]);
 	p =3D kzalloc(64, GFP_KERNEL);
 	p +=3D 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p =3D 0x56;
 	pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches[type][3]);
+	validate_slab_cache(kmalloc_caches[3][type]);
=20
 	pr_err("\nB. Corruption after free\n");
 	p =3D kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p =3D 0x78;
 	pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][5]);
+	validate_slab_cache(kmalloc_caches[5][type]);
=20
 	p =3D kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] =3D 0x9a;
 	pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][7]);
+	validate_slab_cache(kmalloc_caches[7][type]);
=20
 	p =3D kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] =3D 0xab;
 	pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][8]);
+	validate_slab_cache(kmalloc_caches[8][type]);
 }
 #else
 #ifdef CONFIG_SYSFS
--=20
2.21.0


