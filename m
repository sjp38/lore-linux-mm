Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CED5C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25B482173C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="HE+2jI9y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25B482173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 944B66B000E; Mon, 20 May 2019 17:39:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F7966B0010; Mon, 20 May 2019 17:39:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 749866B0266; Mon, 20 May 2019 17:39:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 298F06B000E
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:39:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 18so27208576eds.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:39:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eXUjiROiFGqrcZrxiXfMd6x0O70wFn+SjDBkygnZtOE=;
        b=Ek3r4NkVYxcS6ZmqN1HamBUzGA9A5z96eJ4fVR70XgRbGBS2HqKxxOYALwsliBF5CF
         ofzjDGm/Wzthi9iMUI4Sf4Dj28J6h9v6fdk2a7jn2UtSO7Zcn0toQrYyD4jfntHmqI2k
         bkNID9w1H8KF5mUVa34tD5Z5BuqFlSFd8vf15U6imq5GNYWxCdfOYL6sALfC3i/8zBmi
         jtFd8Zi6sUpLfObv77u7nMBkp9j2weNqfWl9OzwqV9oHE5UKK/jxozJ3O6olkN1+GRvy
         i3fg+sbthEcqoeBH1y3mrIIxNe5cp1G7t9Bi7c1bK9WYwAyIRXkECc4eIQK80uSUwj8Z
         BnUA==
X-Gm-Message-State: APjAAAXLm2++Uvna+VCZ0hqid2gCQM8ljXHi7NSimT73IGSVsT0ItSIx
	TbbcRrgx/eO+VKEH4cnqsvGBDms4sIpMUImcCln1vQ54zRBYUbZHDgbHMa07KHjC9sZPf8KviMv
	jyP0UlwuKB6KPqOctQaZLJmOK8w/ow95HOBJ7L+2diZm14gNzjhrSkfgr+5PrfU4FHA==
X-Received: by 2002:a50:9490:: with SMTP id s16mr78381797eda.260.1558388396688;
        Mon, 20 May 2019 14:39:56 -0700 (PDT)
X-Received: by 2002:a50:9490:: with SMTP id s16mr78381747eda.260.1558388395753;
        Mon, 20 May 2019 14:39:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388395; cv=none;
        d=google.com; s=arc-20160816;
        b=d82yYwSonLaPA9MuLP8OuhKGxamVm2nSrZeR7CcBAZxAz8IiaZkuLiXt4JGA/alP5w
         FIN5oT5ilvvMY7t4XzpoFfRHJkCUDr5B0PzxwKoNqZgA5zTq/SULqBzuWs20NpcviKl8
         1HdVFUWe6KE1MXyAEHZqwloPkD/zwZAqq32pWgnqeUmVusIQCvmGtefOJarqyMsjO9hP
         kf6KISMtcg7BmT85zOi6exVYzizkeicRrQx11sAMbtEBwZFkRyzBcKYPDNnnIn0vhZc5
         Febr1wbpAckqN5CdbUSTu+JJ+83gHgH2URZOgnRk3uBeIIi+mOqCsFOTO7gBdYhWR1x/
         WHcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eXUjiROiFGqrcZrxiXfMd6x0O70wFn+SjDBkygnZtOE=;
        b=Xj099LZovyYx36OEha87infgIQw/NEDQuL2I1ssMfSTlIhcP2zisxgMtyxdPn1Mabh
         4p0v6hrcKK1UUB076IJySwNdhwRdqMVQoF56ueaNl6D5qwRhjA1AEvnG2Mb0/Pe6ifza
         GGtUBfOYolFi2Tu0B+GKNwcJcDHsywnb4hn34iAEln+TzoOn/UEjWyoQ0D7+Szs3/0xl
         iEAoLA1595O/crxnCOYVLGJEvx2kG71CqVneIIJGRQcCpg4bcaE+aOfMvdK5uyPlan3P
         /n+jAKpNPL9Vpui50XXjsnBdsIEKybmaM0SYTHtk7BqHpkNRRTHb3QTeP3Dn2wMHu3dT
         Tl9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=HE+2jI9y;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m19sor1756994ejx.25.2019.05.20.14.39.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:39:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=HE+2jI9y;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=eXUjiROiFGqrcZrxiXfMd6x0O70wFn+SjDBkygnZtOE=;
        b=HE+2jI9yKoWCqEtPmGEmHm4ylYNZon4lbb4PF4NHS53IZxF8pOEgpY8SO8PWwjK/yd
         Kr/K3az9UYI2fpQ8PMsRr6OEK8DOagVNchYQwPKerYeVImZ6A8MUoeqdUStHHSrf9OL7
         JAAzKQQ0avwTjuYS01lKURpWOQUYPaK/I6Hmg=
X-Google-Smtp-Source: APXvYqz2Kva8jHAMyBKyLi3aGikci686nvq4u0U8stYOPI/ZCt3pyHtCQHVoinWV1c/CI2ko59Od2g==
X-Received: by 2002:a17:906:4d4f:: with SMTP id b15mr1630714ejv.116.1558388395426;
        Mon, 20 May 2019 14:39:55 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id v27sm3285772eja.68.2019.05.20.14.39.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:39:54 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 3/4] mm, notifier: Catch sleeping/blocking for !blockable
Date: Mon, 20 May 2019 23:39:44 +0200
Message-Id: <20190520213945.17046-3-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We need to make sure implementations don't cheat and don't have a
possible schedule/blocking point deeply burried where review can't
catch it.

I'm not sure whether this is the best way to make sure all the
might_sleep() callsites trigger, and it's a bit ugly in the code flow.
But it gets the job done.

Inspired by an i915 patch series which did exactly that, because the
rules haven't been entirely clear to us.

v2: Use the shiny new non_block_start/end annotations instead of
abusing preempt_disable/enable.

v3: Rebase on top of Glisse's arg rework.

v4: Rebase on top of more Glisse rework.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Reviewed-by: Christian König <christian.koenig@amd.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index c05e406a7cd7..a09e737711d5 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -176,7 +176,13 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start) {
-			int _ret = mn->ops->invalidate_range_start(mn, range);
+			int _ret;
+
+			if (!mmu_notifier_range_blockable(range))
+				non_block_start();
+			_ret = mn->ops->invalidate_range_start(mn, range);
+			if (!mmu_notifier_range_blockable(range))
+				non_block_end();
 			if (_ret) {
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
-- 
2.20.1

