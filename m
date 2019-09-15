Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A766C4CECC
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E88DD2168B
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:53:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HUwCU5p/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E88DD2168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9876B000C; Sun, 15 Sep 2019 12:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 969C86B000D; Sun, 15 Sep 2019 12:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8809D6B000E; Sun, 15 Sep 2019 12:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 66EDB6B000C
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:53:42 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 10509180AD7C3
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:53:42 +0000 (UTC)
X-FDA: 75937751484.23.flag97_3d5715abf0232
X-HE-Tag: flag97_3d5715abf0232
X-Filterd-Recvd-Size: 13010
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:53:41 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id 4so18003731pgm.12
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:53:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wnjVX8y3jjuiJNFHe5uOkqxCWTM5n6lVUDEKEUO860s=;
        b=HUwCU5p/rPyk8m4saz8aml32uHKw4BTMSh5Y6TIkG4OvTsm0Rb5cgIEbeNfbLpguxi
         E8etezLznc+kI7KhBiJbN0JttJDe2Se/Tp+9Um+EiS3i/nYQrrJwat3cUlEK/n9Vekt+
         TP3TuFIFnFPxRU0+gI1k8D4m8pZUNP5LDDlyp96EdjCiOnwj5lJE2gsAyH3fBJ1y+x7/
         bCl73hBcfDBIwPUnsruU9XuzRHKhWdN9d1Oo6zm5msXXFrVEsvLqWNLO8BJ7KDVpU+lK
         Gzq51dpDFYNhD++DK/3HOYYttS8g/0TodkRqDjoGFlj/I0Zt1xOu4DqCCKcanYoSmzdm
         YYfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wnjVX8y3jjuiJNFHe5uOkqxCWTM5n6lVUDEKEUO860s=;
        b=GW8BuRx25UpjM8BMZe+bexjSxIaYypVH/71QB+w8qQyYSEbR76KaQZGD6ipIuBbuwY
         bJtJ7Lq45jkq8w2yulrlgwYWAyI/iUWnaB/fTH3bAaKvcZwAu0INhUkoPVXob5+s0IuD
         ZQyfDONqbS10EBIOSSkiCT/xzjh22IviGxLJnwPyWugMDHmIou0RRY5FZ3FeNjswxtgY
         3ScHgljpQS+WxFkvNKSaL181r59xBfS9u+gGE0k1RCSOQIoHkkyitPRsoejOET/Wm/mm
         gGzXJunkdC04BYywUZBZE0XAO6NVzpJvCFFp7y0UcCpM1N+tEPW97GA06TL+2K0Wpm90
         eWEw==
X-Gm-Message-State: APjAAAUmyS/p68tcsFfc0xj+XUFBUXHUWThbi6e5AEfk3VmdQgy0c8vc
	PbMF4LS7hvCvXTafXpbQXVgDY4WjAhU=
X-Google-Smtp-Source: APXvYqxWna99YStw5YRBrkDQemXY26rnCJB3XGThI8zr10DbF+qP+8f8JFyPMP+4smD1HBg72y8Ikw==
X-Received: by 2002:aa7:97aa:: with SMTP id d10mr10482490pfq.176.1568566420540;
        Sun, 15 Sep 2019 09:53:40 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.53.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:53:40 -0700 (PDT)
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
Subject: [PATCH v4 7/7] mm, slab_common: modify kmalloc_caches[type][idx] to kmalloc_caches[idx][type]
Date: Mon, 16 Sep 2019 00:51:20 +0800
Message-Id: <20190915165121.7237-12-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915165121.7237-1-lpf.vector@gmail.com>
References: <20190915165121.7237-1-lpf.vector@gmail.com>
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
add/remove: 0/0 grow/shrink: 2/57 up/down: 8/-457 (-449)
Function                                     old     new   delta
tg3_self_test                               4255    4259      +4
nf_queue                                     666     670      +4
kmalloc_slab                                  97      93      -4
i915_sw_fence_await_dma_fence                441     437      -4
__igmp_group_dropped                         619     615      -4
gss_import_sec_context                       176     170      -6
xhci_alloc_command                           212     205      -7
create_kmalloc_caches                        155     148      -7
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
Total: Before=3D14874316, After=3D14873867, chg -0.00%

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
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
index e7903bd28b1f..0f465eae32f6 100644
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
 #ifdef CONFIG_ZONE_DMA
@@ -1168,7 +1168,7 @@ void __init setup_kmalloc_cache_index_table(void)
 static __always_inline void __init
 new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
 {
-	kmalloc_caches[type][idx] =3D create_kmalloc_cache(
+	kmalloc_caches[idx][type] =3D create_kmalloc_cache(
 					kmalloc_info[idx].name[type],
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
@@ -1184,7 +1184,7 @@ void __init create_kmalloc_caches(slab_flags_t flag=
s)
 	int i;
=20
 	for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
-		if (!kmalloc_caches[KMALLOC_NORMAL][i])
+		if (!kmalloc_caches[i][KMALLOC_NORMAL])
 			new_kmalloc_cache(i, KMALLOC_NORMAL, flags);
=20
 		new_kmalloc_cache(i, KMALLOC_RECLAIM,
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


