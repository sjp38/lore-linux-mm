Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD1BC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EAD120811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:43:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ifV2i8sW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EAD120811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A30D36B0003; Tue, 23 Apr 2019 07:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DF0B6B0006; Tue, 23 Apr 2019 07:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CBD66B0007; Tue, 23 Apr 2019 07:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 384396B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:43:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id u16so7807406edq.18
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DCLvjpORf6BjXaGc1/CiEjtNkGVT+Cqqa79V2jEk75c=;
        b=gNa7TBkb5LLtki+w50bJEz1YXOoD1GVBmUWGgVWP14DS8CKa9UMaow3q6YO33l/+Sd
         V5BiGKOMH6ptIv5J2ZJIM1xm39f4df2fNKeuedfLyrpkuNMj7ch9cCoHe0m/W/Z0xCpE
         zCp9ZMTHboh3jDUS5Dyx0extHpNzzYWibDhqTjVr4IC/FYY2TzjBZxTuAh+XPp7z7nFj
         yV1IeHML2HiCxhtCTUIwkbvxdgLU8CVo2xt+3y5Nl8HPOY4y4ytQlRHPHiLF9w0h7oET
         fAUqMQViPDnJMO/3o3ZiZ2TqzV3cjPaIi8oZ/UTpRlkpRRB5s5N83PIZsj7ohbfD6mej
         8tzg==
X-Gm-Message-State: APjAAAVAm9mnulDzvWA1ueWSwatXj90BhH0Z5FTOyeHifDsctHowQ7xk
	RJslU3UZcKpzO5D8JGktrMyYEGMyz8WgPkJ9DlOhrtD5MUYwMoqvV4UmoVI7qRaNFfmbH6jASOW
	en1raB/fWo9fSAD6M4izIetK2y/jplvDk2/RE7XUc8n9S4CZBnjPaYEunnVIeQVoSuQ==
X-Received: by 2002:a50:fc99:: with SMTP id f25mr15077051edq.237.1556019811751;
        Tue, 23 Apr 2019 04:43:31 -0700 (PDT)
X-Received: by 2002:a50:fc99:: with SMTP id f25mr15076982edq.237.1556019810464;
        Tue, 23 Apr 2019 04:43:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556019810; cv=none;
        d=google.com; s=arc-20160816;
        b=JcU+oIKf+qNcgVahqcQU5htTTTHB2kZ3RR3z2QbYKBe2NIHOYTpQ9BYIlOxDy4VPaU
         gQiPi6C6lsv9AO2oTkbeowQho0tQV2WnnUAFGvlnUQbfmUCO0yWGv9x0NjRXy+d1MYxg
         YAR2OBbsGBJOKriQAi6kvMFjL9nCxoMPLnFgIvlHsUckyl5KX7osD4iUL6HoqwODoJcP
         tABMPRIztziNmd48E6ssLKjlifQWwK40ZXOXTqKRrmwWiyIUyqv32mXiSXLkEijx7FTv
         fAXZKKGeKhVQCgvnY4sG1DFCPGZ9/ErH1LyQJM/a9IEfSnunVH+RGP/wYM13n6HTJbos
         jRgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DCLvjpORf6BjXaGc1/CiEjtNkGVT+Cqqa79V2jEk75c=;
        b=JKsi7lET+Xv7Ie5FXoNBLnz2wXh9rKPkvM5jf5ILem8G3aLyu/WrMqJpYhlEt0SNjy
         4bQcKEpTnMj/liooXLAtnskE3mvhtSaDfXcfVu5JbiFs/bXsF7jqiqv51veJ46KUKTkP
         U4xaPQ1O8sK8yu/My+AFI2V2Dz27QHiVqSRiuaA67gR8ubd7eN+YeFGdRaDec72OqO6H
         SfXwM3PTY8ue804oEC9IP8q1T8xQssRHDd5d9yQwES/JTdO+LvdbVxSD4G3pgUb/ANQz
         dvqjEOQ5ql15pvT/iV40BQWofgAAxxSkjK8PPy4e4mT2x1z1k80CdisdmHaVRhjhHgzp
         ATMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifV2i8sW;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m18sor3067457ejs.49.2019.04.23.04.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 04:43:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifV2i8sW;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DCLvjpORf6BjXaGc1/CiEjtNkGVT+Cqqa79V2jEk75c=;
        b=ifV2i8sWf35Rp6foDCNDkDsJPrtvusIguyUG7KelYqMKMFfuo3DjvdxopFNCm0SpiE
         nR7plZUXez8fKST1X57/RZcyJdGv8Elfc7spKCe239kWMU6uaFsYOwl5sOwZ4h3de4It
         /oYn9AbuN4abEHNYGM5Kvn8Olk4KGJCaST2uw0mQH5dj/0yqdXm7z+1LnNRGM70awvQ+
         d7MfCfB8ONl6X6sdc9n0+BP+757iEZ49cJqC6opfbLCFK935x+kTIwb4WvY5SK59uCzm
         8ort2Cxkv8bnCfagUaxJQv0RCJW6+nuyScqhU+c0lp3O4Rvr+wKOEetABhTEmdi+lKQw
         eCXw==
X-Google-Smtp-Source: APXvYqyVuFf/F1pkUkYWyMJpX9Y5QH3tClX8G8VQFruH8lITFF7VLrbdefDzGnfWeGolIWR5ii5rE91+yc51HuVQRVs=
X-Received: by 2002:a17:906:c145:: with SMTP id bp5mr6715226ejb.77.1556019809976;
 Tue, 23 Apr 2019 04:43:29 -0700 (PDT)
MIME-Version: 1.0
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
 <20190417110615.GC5878@dhcp22.suse.cz> <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
 <20190417114621.GF5878@dhcp22.suse.cz> <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
 <20190417133724.GC7751@bombadil.infradead.org>
In-Reply-To: <20190417133724.GC7751@bombadil.infradead.org>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Tue, 23 Apr 2019 19:43:18 +0800
Message-ID: <CAGWkznEqhHcAb0ZnO9-ssk1qQHYFKx4ML0vd4Knj_f2n_PpR0g@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	David Rientjes <rientjes@google.com>, Zhaoyang Huang <zhaoyang.huang@unisoc.com>, 
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

rebase the commit to latest mainline and update the code.
@Matthew, with regarding to your comment, I would like to say the
algorithm doesn't change at all. I do NOT judge the page's activity
via an absolute time value, but still the refault distance. What I
want to fix is the scenario which drop lots of file pages on this lru
that leading to a big refault_distance(inactive_age) and inactivate
the page. I haven't found regression of the commit yet. Could you
please suggest me more test cases? Thank you!
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..ca4ced6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -242,6 +242,7 @@ struct lruvec {
  atomic_long_t inactive_age;
  /* Refaults at the time of last reclaim cycle */
  unsigned long refaults;
+ atomic_long_t refaults_ratio;
 #ifdef CONFIG_MEMCG
  struct pglist_data *pgdat;
 #endif
diff --git a/mm/workingset.c b/mm/workingset.c
index 0bedf67..95683c1 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -171,6 +171,15 @@
  1 + NODES_SHIFT + MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK (~0UL >> EVICTION_SHIFT)

+#ifdef CONFIG_64BIT
+#define EVICTION_SECS_POS_SHIFT 19
+#define EVICTION_SECS_SHRINK_SHIFT 4
+#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
+#else
+#define EVICTION_SECS_POS_SHIFT 0
+#define EVICTION_SECS_SHRINK_SHIFT 0
+#define NO_SECS_IN_WORKINGSET
+#endif
 /*
  * Eviction timestamps need to be able to cover the full range of
  * actionable refaults. However, bits are tight in the xarray
@@ -180,12 +189,48 @@
  * evictions into coarser buckets by shaving off lower timestamp bits.
  */
 static unsigned int bucket_order __read_mostly;
-
+#ifdef NO_SECS_IN_WORKINGSET
+static void pack_secs(unsigned long *peviction) { }
+static unsigned int unpack_secs(unsigned long entry) {return 0; }
+#else
+static void pack_secs(unsigned long *peviction)
+{
+ unsigned int secs;
+ unsigned long eviction;
+ int order;
+ int secs_shrink_size;
+ struct timespec64 ts;
+
+ ktime_get_boottime_ts64(&ts);
+ secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
+ order = get_count_order(secs);
+ secs_shrink_size = (order <= EVICTION_SECS_POS_SHIFT)
+ ? 0 : (order - EVICTION_SECS_POS_SHIFT);
+
+ eviction = *peviction;
+ eviction = (eviction << EVICTION_SECS_POS_SHIFT)
+ | ((secs >> secs_shrink_size) & EVICTION_SECS_POS_MASK);
+ eviction = (eviction << EVICTION_SECS_SHRINK_SHIFT) |
(secs_shrink_size & 0xf);
+ *peviction = eviction;
+}
+static unsigned int unpack_secs(unsigned long entry)
+{
+ unsigned int secs;
+ int secs_shrink_size;
+
+ secs_shrink_size = entry & ((1 << EVICTION_SECS_SHRINK_SHIFT) - 1);
+ entry >>= EVICTION_SECS_SHRINK_SHIFT;
+ secs = entry & EVICTION_SECS_POS_MASK;
+ secs = secs << secs_shrink_size;
+ return secs;
+}
+#endif
 static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction,
  bool workingset)
 {
  eviction >>= bucket_order;
  eviction &= EVICTION_MASK;
+ pack_secs(&eviction);
  eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
  eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
  eviction = (eviction << 1) | workingset;
@@ -194,11 +239,12 @@ static void *pack_shadow(int memcgid, pg_data_t
*pgdat, unsigned long eviction,
 }

 static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
-   unsigned long *evictionp, bool *workingsetp)
+ unsigned long *evictionp, bool *workingsetp, unsigned int *prev_secs)
 {
  unsigned long entry = xa_to_value(shadow);
  int memcgid, nid;
  bool workingset;
+ unsigned int secs;

  workingset = entry & 1;
  entry >>= 1;
@@ -206,11 +252,14 @@ static void unpack_shadow(void *shadow, int
*memcgidp, pg_data_t **pgdat,
  entry >>= NODES_SHIFT;
  memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
  entry >>= MEM_CGROUP_ID_SHIFT;
+ secs = unpack_secs(entry);
+ entry >>= (EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT);

  *memcgidp = memcgid;
  *pgdat = NODE_DATA(nid);
  *evictionp = entry << bucket_order;
  *workingsetp = workingset;
+ *prev_secs = secs;
 }

 /**
@@ -257,8 +306,22 @@ void workingset_refault(struct page *page, void *shadow)
  unsigned long refault;
  bool workingset;
  int memcgid;
+#ifndef NO_SECS_IN_WORKINGSET
+ unsigned long avg_refault_time;
+ unsigned long refaults_ratio;
+ unsigned long refault_time;
+ int tradition;
+ unsigned int prev_secs;
+ unsigned int secs;
+#endif
+ struct timespec64 ts;
+ /*
+ convert jiffies to second
+ */
+ ktime_get_boottime_ts64(&ts);
+ secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;

- unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &workingset);
+ unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &workingset, &prev_secs);

  rcu_read_lock();
  /*
@@ -303,23 +366,58 @@ void workingset_refault(struct page *page, void *shadow)
  refault_distance = (refault - eviction) & EVICTION_MASK;

  inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
-
+#ifndef NO_SECS_IN_WORKINGSET
+ refaults_ratio = (atomic_long_read(&lruvec->inactive_age) + 1) / secs;
+ atomic_long_set(&lruvec->refaults_ratio, refaults_ratio);
+ refault_time = secs - prev_secs;
+ avg_refault_time = active_file / refaults_ratio;
+ tradition = !!(refault_distance < active_file);
  /*
- * Compare the distance to the existing workingset size. We
- * don't act on pages that couldn't stay resident even if all
- * the memory was available to the page cache.
+ * What we are trying to solve here is
+ * 1. extremely fast refault as refault_time == 0.
+ * 2. quick file drop scenario, which has a big refault_distance but
+ *    small refault_time comparing with the past refault ratio, which
+ *    will be deemed as inactive in previous implementation.
  */
- if (refault_distance > active_file)
+ if (refault_time && (((refault_time < avg_refault_time)
+ && (avg_refault_time < 2 * refault_time))
+ || (refault_time >= avg_refault_time))) {
+ trace_printk("WKST_INACT[%d]:rft_dis %ld, act %ld\
+ rft_ratio %ld rft_time %ld avg_rft_time %ld\
+ refault %ld eviction %ld secs %d pre_secs %d page %p\n",
+ tradition, refault_distance, active_file,
+ refaults_ratio, refault_time, avg_refault_time,
+ refault, eviction, secs, prev_secs, page);
  goto out;
+ }
+ else {
+#else
+ if (refault_distance < active_file) {
+#endif

- SetPageActive(page);
- atomic_long_inc(&lruvec->inactive_age);
- inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+ /*
+ * Compare the distance to the existing workingset size. We
+ * don't act on pages that couldn't stay resident even if all
+ * the memory was available to the page cache.
+ */

- /* Page was active prior to eviction */
- if (workingset) {
- SetPageWorkingset(page);
- inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+ SetPageActive(page);
+ atomic_long_inc(&lruvec->inactive_age);
+ inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+
+ /* Page was active prior to eviction */
+ if (workingset) {
+ SetPageWorkingset(page);
+ inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+ }
+#ifndef NO_SECS_IN_WORKINGSET
+ trace_printk("WKST_ACT[%d]:rft_dis %ld, act %ld\
+ rft_ratio %ld rft_time %ld avg_rft_time %ld\
+ refault %ld eviction %ld secs %d pre_secs %d page %p\n",
+ tradition, refault_distance, active_file,
+ refaults_ratio, refault_time, avg_refault_time,
+ refault, eviction, secs, prev_secs, page);
+#endif
  }
 out:
  rcu_read_unlock();
@@ -539,7 +637,9 @@ static int __init workingset_init(void)
  unsigned int max_order;
  int ret;

- BUILD_BUG_ON(BITS_PER_LONG < EVICTION_SHIFT);
+ BUILD_BUG_ON(BITS_PER_LONG < (EVICTION_SHIFT
+ + EVICTION_SECS_POS_SHIFT
+ + EVICTION_SECS_SHRINK_SHIFT));
  /*
  * Calculate the eviction bucket size to cover the longest
  * actionable refault distance, which is currently half of
@@ -547,7 +647,9 @@ static int __init workingset_init(void)
  * some more pages at runtime, so keep working with up to
  * double the initial memory by using totalram_pages as-is.
  */
- timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
+ timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT
+ - EVICTION_SECS_POS_SHIFT - EVICTION_SECS_SHRINK_SHIFT;
+
  max_order = fls_long(totalram_pages() - 1);
  if (max_order > timestamp_bits)
  bucket_order = max_order - timestamp_bits;

On Wed, Apr 17, 2019 at 9:37 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Apr 17, 2019 at 08:26:22PM +0800, Zhaoyang Huang wrote:
> [quoting Johannes here]
> > As Matthew says, you are fairly randomly making refault activations
> > more aggressive (especially with that timestamp unpacking bug), and
> > while that expectedly boosts workload transition / startup, it comes
> > at the cost of disrupting stable states because you can flood a very
> > active in-ram workingset with completely cold cache pages simply
> > because they refault uniformly wrt each other.
> > [HZY]: I analysis the log got from trace_printk, what we activate have
> > proven record of long refault distance but very short refault time.
>
> You haven't addressed my point, which is that you were only testing
> workloads for which your changed algorithm would improve the results.
> What you haven't done is shown how other workloads would be negatively
> affected.
>
> Once you do that, we can make a decision about whether to improve your
> workload by X% and penalise that other workload by Y%.

