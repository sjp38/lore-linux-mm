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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22AC1C4CECC
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD14E21479
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:09:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ujcLG8mr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD14E21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67A7C6B026A; Sun, 15 Sep 2019 13:09:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 602CC6B026D; Sun, 15 Sep 2019 13:09:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A3806B026E; Sun, 15 Sep 2019 13:09:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 190996B026A
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:09:06 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A19BA3AA1
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:09:05 +0000 (UTC)
X-FDA: 75937790250.06.pain04_3230bb5e6c72f
X-HE-Tag: pain04_3230bb5e6c72f
X-Filterd-Recvd-Size: 24931
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:09:04 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id x127so21120443pfb.7
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:09:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rGRlPiR3gI4yFwzk+whmCLzMmdtttoXjltpehi5xOx0=;
        b=ujcLG8mr1QGRIHRPIN2o0e+PNjRE8D6EaZ2BB2xMmMCzb3DAuKcqckNryObAbI+5D+
         bliWv10crUkj0ONMrKKvAKQxkaH5AI0/4jXgWg1OXm2OK1jQo6rODhms5md/61y3UU/e
         5d+acT1oYKvkCZG9V8dWkfZhU3awNNnuLeBMcTIX3aYjVNhC6C2IS5EfDC1U0wdlrpOJ
         1QC7HQHeSXifLUA6EuhQF2VuSBGjfWV/bMCeO5qRe9LVmHIZ++MBLIMJcBv7AOId9aQS
         WTIBlWZoRxLJEuJkLCy+ZPtw859/CktMp/E+jrX/3V0VxujwV/iAIZvqINtRbMeY16vN
         IKuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=rGRlPiR3gI4yFwzk+whmCLzMmdtttoXjltpehi5xOx0=;
        b=fJ0Gb9tsh5gfdxfTj2lHSBPNOLXPYbgy7JimXGJkDfORl8AX+3i2YUVC+mMC2ozUXX
         /gliAWg3OITEuGlefNMpUE55FggC1t2ABlH9euEO8CkmrMG/1NbqQh/aeDTXLL+Oc7mc
         o4tLm+qzYQzrZEqLwICNtKpQtSdsuGnsMCIFooZY3JhY8aJdKq04wxQgsJaqBhKiJVsw
         cknDmpdZJ1JZTiudyYnpf25jeZ3mnGt6GrsxqN67igt+GVn0XgzgkclqRJqQvYHUBCbY
         ueuTSmO5gRxUggNtSCouhFIZQWP0oNEruMTKmxWj+3dxSWI5R2DC7os9TqwPO3ITGVxF
         ijNw==
X-Gm-Message-State: APjAAAVSQ/mGNQO84FUoT2Lj2LOe9tUxspFEazwKUVtpeR3vB9ZUory2
	Of1pGkZXjm7Vw/A5nW06nAZVruwUh30=
X-Google-Smtp-Source: APXvYqyGkYGDeP6KtbPOZLi6Mjm/SizTDUMf/FE5JXKA1pf9pkJoW0m3qFCQeXGeS5ohyMQFi3h3sA==
X-Received: by 2002:a63:ee04:: with SMTP id e4mr52473187pgi.53.1568567343480;
        Sun, 15 Sep 2019 10:09:03 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.08.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:09:03 -0700 (PDT)
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
Subject: [RESEND v4 5/7] mm, slab_common: Make kmalloc_caches[] start at size KMALLOC_MIN_SIZE
Date: Mon, 16 Sep 2019 01:08:07 +0800
Message-Id: <20190915170809.10702-6-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915170809.10702-1-lpf.vector@gmail.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, kmalloc_cache[] is not sorted by size, kmalloc_cache[0]
is kmalloc-96, kmalloc_cache[1] is kmalloc-192 (when ARCH_DMA_MINALIGN
is not defined).

As suggested by Vlastimil Babka,

"Since you're doing these cleanups, have you considered reordering
kmalloc_info, size_index, kmalloc_index() etc so that sizes 96 and 192
are ordered naturally between 64, 128 and 256? That should remove
various special casing such as in create_kmalloc_caches(). I can't
guarantee it will be possible without breaking e.g. constant folding
optimizations etc., but seems to me it should be feasible. (There are
definitely more places to change than those I listed.)"

So this patch reordered kmalloc_info[], kmalloc_caches[], and modified
kmalloc_index() and kmalloc_slab() accordingly.

As a result, there is no subtle judgment about size in
create_kmalloc_caches(). And initialize kmalloc_cache[] from 0 instead
of KMALLOC_SHIFT_LOW.

I used ./scripts/bloat-o-meter to measure the impact of this patch on
performance. The results show that it brings some benefits.

Considering the size change of kmalloc_info[], the size of the code is
actually about 641 bytes less.

(Note: The original kmalloc_info[] was renamed to all_kmalloc_info[])

$ ./scripts/bloat-o-meter vmlinux.old vmlinux.patch_1-5
add/remove: 1/2 grow/shrink: 6/64 up/down: 872/-1113 (-241)
Function                                     old     new   delta
all_kmalloc_info                               -     832    +832
crypto_create_tfm                            211     225     +14
ieee80211_key_alloc                         1159    1169     +10
nl80211_parse_sched_scan                    2787    2795      +8
ida_alloc_range                              951     955      +4
find_get_context.isra                        634     637      +3
sd_probe                                     947     948      +1
nla_strdup                                   143     142      -1
trace_parser_get_init                         71      69      -2
pkcs7_verify.cold                            318     316      -2
xhci_alloc_tt_info                           349     346      -3
units                                        323     320      -3
nl80211_set_reg                              642     639      -3
i915_sw_fence_await_dma_fence                445     441      -4
nf_queue                                     671     666      -5
kmalloc_slab                                 102      97      -5
xhci_segment_alloc                           303     297      -6
xhci_alloc_container_ctx                     221     215      -6
xfrm_policy_alloc                            277     271      -6
selinux_sk_alloc_security                    119     113      -6
sdev_evt_send_simple                         124     118      -6
sdev_evt_alloc                                85      79      -6
sbitmap_queue_init_node                      424     418      -6
regulatory_hint_found_beacon                 400     394      -6
nf_ct_tmpl_alloc                              91      85      -6
gss_create_cred                              146     140      -6
drm_flip_work_allocate_task                   76      70      -6
cfg80211_stop_iface                          266     260      -6
cfg80211_sinfo_alloc_tid_stats                83      77      -6
cfg80211_port_authorized                     218     212      -6
cfg80211_ibss_joined                         341     335      -6
call_usermodehelper_setup                    155     149      -6
bpf_prog_alloc_no_stats                      188     182      -6
blk_alloc_flush_queue                        197     191      -6
bdi_alloc_node                               201     195      -6
_netlbl_catmap_getnode                       253     247      -6
____ip_mc_inc_group                          481     475      -6
pkcs7_verify                                1503    1495      -8
audit_log_d_path                             204     196      -8
xprt_switch_alloc                            145     136      -9
xhci_ring_alloc                              378     369      -9
xhci_mem_init                               3673    3664      -9
xhci_alloc_virt_device                       505     496      -9
xhci_alloc_stream_info                       727     718      -9
xhci_alloc_command                           221     212      -9
tcp_sendmsg_locked                          3129    3120      -9
tcp_md5_do_add                               783     774      -9
tcp_fastopen_defer_connect                   279     270      -9
sr_read_tochdr.isra                          260     251      -9
sr_read_tocentry.isra                        337     328      -9
sr_is_xa                                     385     376      -9
sr_get_mcn                                   269     260      -9
scsi_probe_and_add_lun                      2947    2938      -9
ring_buffer_read_prepare                     103      94      -9
request_firmware_nowait                      405     396      -9
ohci_urb_enqueue                            3185    3176      -9
nfs_alloc_seqid                               96      87      -9
nfs4_get_state_owner                        1049    1040      -9
nfs4_do_close                                587     578      -9
mempool_create_node                          173     164      -9
ip6_setup_cork                              1030    1021      -9
dma_pool_alloc                               419     410      -9
devres_open_group                            223     214      -9
cfg80211_parse_mbssid_data                  2406    2397      -9
__igmp_group_dropped                         629     619     -10
gss_import_sec_context                       187     176     -11
ip_setup_cork                                374     362     -12
__i915_sw_fence_await_sw_fence               429     417     -12
kmalloc_caches                               336     312     -24
create_kmalloc_caches                        270     214     -56
kmalloc_cache_name                            57       -     -57
new_kmalloc_cache                            112       -    -112
kmalloc_info                                 432       8    -424
Total: Before=3D14874616, After=3D14874375, chg -0.00%

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/slab.h |  96 ++++++++++++++++----------
 mm/slab.h            |  10 +--
 mm/slab_common.c     | 158 ++++++++++++++++---------------------------
 mm/slub.c            |  12 ++--
 4 files changed, 133 insertions(+), 143 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1f05f68f2c3e..f53bb6980110 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -297,6 +297,23 @@ static inline void __check_heap_object(const void *p=
tr, unsigned long n,
 #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif
=20
+#define KMALLOC_CACHE_MIN_NUM	(KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + =
1)
+
+#if KMALLOC_MIN_SIZE > 64
+	#define KMALLOC_SIZE_96_EXIST	(0)
+	#define KMALLOC_SIZE_192_EXIST	(0)
+#elif KMALLOC_MIN_SIZE > 32
+	#define KMALLOC_SIZE_96_EXIST	(0)
+	#define KMALLOC_SIZE_192_EXIST	(1)
+#else
+	#define KMALLOC_SIZE_96_EXIST	(1)
+	#define KMALLOC_SIZE_192_EXIST	(1)
+#endif
+
+#define KMALLOC_CACHE_NUM	(KMALLOC_CACHE_MIN_NUM			\
+					+ KMALLOC_SIZE_96_EXIST		\
+					+ KMALLOC_SIZE_192_EXIST)
+
 /*
  * This restriction comes from byte sized index implementation.
  * Page size is normally 2^12 bytes and, in this case, if we want to use
@@ -323,7 +340,7 @@ enum kmalloc_cache_type {
=20
 #ifndef CONFIG_SLOB
 extern struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_CACHE_NUM];
=20
 static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
 {
@@ -345,13 +362,18 @@ static __always_inline enum kmalloc_cache_type kmal=
loc_type(gfp_t flags)
 #endif
 }
=20
+/* kmalloc_index adjust size: (0, 96] */
+#define KMALLOC_IDX_ADJ_0	(KMALLOC_SHIFT_LOW)
+
+/* kmalloc_index adjust size: (96, 192] */
+#define KMALLOC_IDX_ADJ_1	(KMALLOC_IDX_ADJ_0 - KMALLOC_SIZE_96_EXIST)
+
+/* kmalloc_index adjust size: (192, N] */
+#define KMALLOC_IDX_ADJ_2	(KMALLOC_IDX_ADJ_1 - KMALLOC_SIZE_192_EXIST)
+
 /*
  * Figure out which kmalloc slab an allocation of a certain size
  * belongs to.
- * 0 =3D zero alloc
- * 1 =3D  65 .. 96 bytes
- * 2 =3D 129 .. 192 bytes
- * n =3D 2^(n-1)+1 .. 2^n
  */
 static __always_inline unsigned int kmalloc_index(size_t size)
 {
@@ -359,36 +381,40 @@ static __always_inline unsigned int kmalloc_index(s=
ize_t size)
 		return ZERO_SIZE_ALLOC;
=20
 	if (size <=3D KMALLOC_MIN_SIZE)
-		return KMALLOC_SHIFT_LOW;
-
-	if (KMALLOC_MIN_SIZE <=3D 32 && size > 64 && size <=3D 96)
-		return 1;
-	if (KMALLOC_MIN_SIZE <=3D 64 && size > 128 && size <=3D 192)
-		return 2;
-	if (size <=3D          8) return 3;
-	if (size <=3D         16) return 4;
-	if (size <=3D         32) return 5;
-	if (size <=3D         64) return 6;
-	if (size <=3D        128) return 7;
-	if (size <=3D        256) return 8;
-	if (size <=3D        512) return 9;
-	if (size <=3D       1024) return 10;
-	if (size <=3D   2 * 1024) return 11;
-	if (size <=3D   4 * 1024) return 12;
-	if (size <=3D   8 * 1024) return 13;
-	if (size <=3D  16 * 1024) return 14;
-	if (size <=3D  32 * 1024) return 15;
-	if (size <=3D  64 * 1024) return 16;
-	if (size <=3D 128 * 1024) return 17;
-	if (size <=3D 256 * 1024) return 18;
-	if (size <=3D 512 * 1024) return 19;
-	if (size <=3D 1024 * 1024) return 20;
-	if (size <=3D  2 * 1024 * 1024) return 21;
-	if (size <=3D  4 * 1024 * 1024) return 22;
-	if (size <=3D  8 * 1024 * 1024) return 23;
-	if (size <=3D  16 * 1024 * 1024) return 24;
-	if (size <=3D  32 * 1024 * 1024) return 25;
-	if (size <=3D  64 * 1024 * 1024) return 26;
+		return 0;
+
+#if KMALLOC_SIZE_96_EXIST =3D=3D 1
+	if (size > 64 && size <=3D 96) return (7 - KMALLOC_IDX_ADJ_0);
+#endif
+
+#if KMALLOC_SIZE_192_EXIST =3D=3D 1
+	if (size > 128 && size <=3D 192) return (8 - KMALLOC_IDX_ADJ_1);
+#endif
+
+	if (size <=3D                8) return ( 3 - KMALLOC_IDX_ADJ_0);
+	if (size <=3D               16) return ( 4 - KMALLOC_IDX_ADJ_0);
+	if (size <=3D               32) return ( 5 - KMALLOC_IDX_ADJ_0);
+	if (size <=3D               64) return ( 6 - KMALLOC_IDX_ADJ_0);
+	if (size <=3D              128) return ( 7 - KMALLOC_IDX_ADJ_1);
+	if (size <=3D              256) return ( 8 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D              512) return ( 9 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D             1024) return (10 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D         2 * 1024) return (11 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D         4 * 1024) return (12 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D         8 * 1024) return (13 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D        16 * 1024) return (14 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D        32 * 1024) return (15 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D        64 * 1024) return (16 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D       128 * 1024) return (17 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D       256 * 1024) return (18 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D       512 * 1024) return (19 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D      1024 * 1024) return (20 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D  2 * 1024 * 1024) return (21 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D  4 * 1024 * 1024) return (22 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D  8 * 1024 * 1024) return (23 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D 16 * 1024 * 1024) return (24 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D 32 * 1024 * 1024) return (25 - KMALLOC_IDX_ADJ_2);
+	if (size <=3D 64 * 1024 * 1024) return (26 - KMALLOC_IDX_ADJ_2);
 	BUG();
=20
 	/* Will never be reached. Needed because the compiler may complain */
diff --git a/mm/slab.h b/mm/slab.h
index 2fc8f956906a..3ada65ef1118 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -63,6 +63,11 @@ enum slab_state {
 	FULL			/* Everything is working */
 };
=20
+struct kmalloc_info_struct {
+	const char *name[NR_KMALLOC_TYPES];
+	unsigned int size;
+};
+
 extern enum slab_state slab_state;
=20
 /* The slab cache mutex protects the management structures during change=
s */
@@ -75,10 +80,7 @@ extern struct list_head slab_caches;
 extern struct kmem_cache *kmem_cache;
=20
 /* A table of kmalloc cache names and sizes */
-extern const struct kmalloc_info_struct {
-	const char *name[NR_KMALLOC_TYPES];
-	unsigned int size;
-} kmalloc_info[];
+extern const struct kmalloc_info_struct * const kmalloc_info;
=20
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index af45b5278fdc..2aed30deb071 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1028,7 +1028,7 @@ struct kmem_cache *__init create_kmalloc_cache(cons=
t char *name,
 }
=20
 struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init=
 =3D
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_CACHE_NUM] __ro_after_init =3D
 { /* initialization for https://bugs.llvm.org/show_bug.cgi?id=3D42570 */=
 };
 EXPORT_SYMBOL(kmalloc_caches);
=20
@@ -1039,30 +1039,30 @@ EXPORT_SYMBOL(kmalloc_caches);
  * fls.
  */
 static u8 size_index[24] __ro_after_init =3D {
-	3,	/* 8 */
-	4,	/* 16 */
-	5,	/* 24 */
-	5,	/* 32 */
-	6,	/* 40 */
-	6,	/* 48 */
-	6,	/* 56 */
-	6,	/* 64 */
-	1,	/* 72 */
-	1,	/* 80 */
-	1,	/* 88 */
-	1,	/* 96 */
-	7,	/* 104 */
-	7,	/* 112 */
-	7,	/* 120 */
-	7,	/* 128 */
-	2,	/* 136 */
-	2,	/* 144 */
-	2,	/* 152 */
-	2,	/* 160 */
-	2,	/* 168 */
-	2,	/* 176 */
-	2,	/* 184 */
-	2	/* 192 */
+	(3 - KMALLOC_IDX_ADJ_0),	/*  8 */
+	(4 - KMALLOC_IDX_ADJ_0),	/* 16 */
+	(5 - KMALLOC_IDX_ADJ_0),	/* 24 */
+	(5 - KMALLOC_IDX_ADJ_0),	/* 32 */
+	(6 - KMALLOC_IDX_ADJ_0),	/* 40 */
+	(6 - KMALLOC_IDX_ADJ_0),	/* 48 */
+	(6 - KMALLOC_IDX_ADJ_0),	/* 56 */
+	(6 - KMALLOC_IDX_ADJ_0),	/* 64 */
+	(7 - KMALLOC_IDX_ADJ_0),	/* 72 */
+	(7 - KMALLOC_IDX_ADJ_0),	/* 80 */
+	(7 - KMALLOC_IDX_ADJ_0),	/* 88 */
+	(7 - KMALLOC_IDX_ADJ_0),	/* 96 */
+	(7 - KMALLOC_IDX_ADJ_1),	/* 104 */
+	(7 - KMALLOC_IDX_ADJ_1),	/* 112 */
+	(7 - KMALLOC_IDX_ADJ_1),	/* 120 */
+	(7 - KMALLOC_IDX_ADJ_1),	/* 128 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 136 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 144 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 152 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 160 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 168 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 176 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 184 */
+	(8 - KMALLOC_IDX_ADJ_1),	/* 192 */
 };
=20
 static inline unsigned int size_index_elem(unsigned int bytes)
@@ -1086,13 +1086,17 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_=
t flags)
 	} else {
 		if (WARN_ON_ONCE(size > KMALLOC_MAX_CACHE_SIZE))
 			return NULL;
-		index =3D fls(size - 1);
+
+		index =3D fls(size - 1) - KMALLOC_IDX_ADJ_2;
 	}
=20
 	return kmalloc_caches[kmalloc_type(flags)][index];
 }
=20
 #ifdef CONFIG_ZONE_DMA
+
+#define KMALLOC_INFO_SHIFT_LOW	(3)
+#define KMALLOC_INFO_START_IDX	(KMALLOC_SHIFT_LOW - KMALLOC_INFO_SHIFT_L=
OW)
 #define SET_KMALLOC_SIZE(__size, __short_size)			\
 {								\
 	.name[KMALLOC_NORMAL]  =3D "kmalloc-" #__short_size,	\
@@ -1110,40 +1114,35 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_=
t flags)
 #endif
=20
 /*
- * kmalloc_info[] is to make slub_debug=3D,kmalloc-xx option work at boo=
t time.
- * kmalloc_index() supports up to 2^26=3D64MB, so the final entry of the=
 table is
- * kmalloc-67108864.
+ * all_kmalloc_info[] is to make slub_debug=3D, kmalloc-xx option work a=
t boot
+ * time. kmalloc_index() supports up to 2^26=3D64MB, so the final entry =
of the
+ * table is kmalloc-67108864.
  */
-const struct kmalloc_info_struct kmalloc_info[] __initconst =3D {
-	SET_KMALLOC_SIZE(0, 0),
-	SET_KMALLOC_SIZE(96, 96),
-	SET_KMALLOC_SIZE(192, 192),
-	SET_KMALLOC_SIZE(8, 8),
-	SET_KMALLOC_SIZE(16, 16),
-	SET_KMALLOC_SIZE(32, 32),
-	SET_KMALLOC_SIZE(64, 64),
-	SET_KMALLOC_SIZE(128, 128),
-	SET_KMALLOC_SIZE(256, 256),
-	SET_KMALLOC_SIZE(512, 512),
-	SET_KMALLOC_SIZE(1024, 1k),
-	SET_KMALLOC_SIZE(2048, 2k),
-	SET_KMALLOC_SIZE(4096, 4k),
-	SET_KMALLOC_SIZE(8192, 8k),
-	SET_KMALLOC_SIZE(16384, 16k),
-	SET_KMALLOC_SIZE(32768, 32k),
-	SET_KMALLOC_SIZE(65536, 64k),
-	SET_KMALLOC_SIZE(131072, 128k),
-	SET_KMALLOC_SIZE(262144, 256k),
-	SET_KMALLOC_SIZE(524288, 512k),
-	SET_KMALLOC_SIZE(1048576, 1M),
-	SET_KMALLOC_SIZE(2097152, 2M),
-	SET_KMALLOC_SIZE(4194304, 4M),
-	SET_KMALLOC_SIZE(8388608, 8M),
-	SET_KMALLOC_SIZE(16777216, 16M),
-	SET_KMALLOC_SIZE(33554432, 32M),
-	SET_KMALLOC_SIZE(67108864, 64M)
+const struct kmalloc_info_struct all_kmalloc_info[] __initconst =3D {
+	SET_KMALLOC_SIZE(       8,    8),    SET_KMALLOC_SIZE(      16,   16),
+	SET_KMALLOC_SIZE(      32,   32),    SET_KMALLOC_SIZE(      64,   64),
+#if KMALLOC_SIZE_96_EXIST =3D=3D 1
+	SET_KMALLOC_SIZE(      96,   96),
+#endif
+	SET_KMALLOC_SIZE(     128,  128),
+#if KMALLOC_SIZE_192_EXIST =3D=3D 1
+	SET_KMALLOC_SIZE(     192,  192),
+#endif
+	SET_KMALLOC_SIZE(     256,  256),    SET_KMALLOC_SIZE(     512,  512),
+	SET_KMALLOC_SIZE(    1024,   1k),    SET_KMALLOC_SIZE(    2048,   2k),
+	SET_KMALLOC_SIZE(    4096,   4k),    SET_KMALLOC_SIZE(    8192,   8k),
+	SET_KMALLOC_SIZE(   16384,  16k),    SET_KMALLOC_SIZE(   32768,  32k),
+	SET_KMALLOC_SIZE(   65536,  64k),    SET_KMALLOC_SIZE(  131072, 128k),
+	SET_KMALLOC_SIZE(  262144, 256k),    SET_KMALLOC_SIZE(  524288, 512k),
+	SET_KMALLOC_SIZE( 1048576,   1M),    SET_KMALLOC_SIZE( 2097152,   2M),
+	SET_KMALLOC_SIZE( 4194304,   4M),    SET_KMALLOC_SIZE( 8388608,   8M),
+	SET_KMALLOC_SIZE(16777216,  16M),    SET_KMALLOC_SIZE(33554432,  32M),
+	SET_KMALLOC_SIZE(67108864,  64M)
 };
=20
+const struct kmalloc_info_struct * const __initconst
+kmalloc_info =3D &all_kmalloc_info[KMALLOC_INFO_START_IDX];
+
 /*
  * Patch up the size_index table if we have strange large alignment
  * requirements for the kmalloc array. This is only the case for
@@ -1162,33 +1161,8 @@ void __init setup_kmalloc_cache_index_table(void)
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
=20
-	for (i =3D 8; i < KMALLOC_MIN_SIZE; i +=3D 8) {
-		unsigned int elem =3D size_index_elem(i);
-
-		if (elem >=3D ARRAY_SIZE(size_index))
-			break;
-		size_index[elem] =3D KMALLOC_SHIFT_LOW;
-	}
-
-	if (KMALLOC_MIN_SIZE >=3D 64) {
-		/*
-		 * The 96 byte size cache is not used if the alignment
-		 * is 64 byte.
-		 */
-		for (i =3D 64 + 8; i <=3D 96; i +=3D 8)
-			size_index[size_index_elem(i)] =3D 7;
-
-	}
-
-	if (KMALLOC_MIN_SIZE >=3D 128) {
-		/*
-		 * The 192 byte sized cache is not used if the alignment
-		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
-		 * instead.
-		 */
-		for (i =3D 128 + 8; i <=3D 192; i +=3D 8)
-			size_index[size_index_elem(i)] =3D 8;
-	}
+	for (i =3D 8; i < KMALLOC_MIN_SIZE && i <=3D 192; i +=3D 8)
+		size_index[size_index_elem(i)] =3D 0;
 }
=20
 static void __init
@@ -1214,21 +1188,9 @@ void __init create_kmalloc_caches(slab_flags_t fla=
gs)
 	enum kmalloc_cache_type type;
=20
 	for (type =3D KMALLOC_NORMAL; type <=3D KMALLOC_RECLAIM; type++) {
-		for (i =3D KMALLOC_SHIFT_LOW; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+		for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
 			if (!kmalloc_caches[type][i])
 				new_kmalloc_cache(i, type, flags);
-
-			/*
-			 * Caches that are not of the two-to-the-power-of size.
-			 * These have to be created immediately after the
-			 * earlier power of two caches
-			 */
-			if (KMALLOC_MIN_SIZE <=3D 32 && i =3D=3D 6 &&
-					!kmalloc_caches[type][1])
-				new_kmalloc_cache(1, type, flags);
-			if (KMALLOC_MIN_SIZE <=3D 64 && i =3D=3D 7 &&
-					!kmalloc_caches[type][2])
-				new_kmalloc_cache(2, type, flags);
 		}
 	}
=20
@@ -1236,7 +1198,7 @@ void __init create_kmalloc_caches(slab_flags_t flag=
s)
 	slab_state =3D UP;
=20
 #ifdef CONFIG_ZONE_DMA
-	for (i =3D 0; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+	for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
 		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
=20
 		if (s) {
diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..0e92ebdcacc9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4711,7 +4711,7 @@ static void __init resiliency_test(void)
 	pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
 	       p + 16);
=20
-	validate_slab_cache(kmalloc_caches[type][4]);
+	validate_slab_cache(kmalloc_caches[type][1]);
=20
 	/* Hmmm... The next two are dangerous */
 	p =3D kzalloc(32, GFP_KERNEL);
@@ -4720,33 +4720,33 @@ static void __init resiliency_test(void)
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
=20
-	validate_slab_cache(kmalloc_caches[type][5]);
+	validate_slab_cache(kmalloc_caches[type][2]);
 	p =3D kzalloc(64, GFP_KERNEL);
 	p +=3D 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p =3D 0x56;
 	pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches[type][6]);
+	validate_slab_cache(kmalloc_caches[type][3]);
=20
 	pr_err("\nB. Corruption after free\n");
 	p =3D kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p =3D 0x78;
 	pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][7]);
+	validate_slab_cache(kmalloc_caches[type][5]);
=20
 	p =3D kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] =3D 0x9a;
 	pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][8]);
+	validate_slab_cache(kmalloc_caches[type][7]);
=20
 	p =3D kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] =3D 0xab;
 	pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[type][9]);
+	validate_slab_cache(kmalloc_caches[type][8]);
 }
 #else
 #ifdef CONFIG_SYSFS
--=20
2.21.0


