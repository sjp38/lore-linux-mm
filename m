Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8FDAC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:34:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F94A2166E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:34:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F94A2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EFC56B0003; Thu, 29 Aug 2019 12:34:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09F746B0005; Thu, 29 Aug 2019 12:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF7246B0008; Thu, 29 Aug 2019 12:34:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id CDCC66B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:34:51 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 812CD82437C9
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:34:51 +0000 (UTC)
X-FDA: 75876014382.28.burst58_4778c3b83f33f
X-HE-Tag: burst58_4778c3b83f33f
X-Filterd-Recvd-Size: 3945
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:34:51 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id s18so4143848wrn.1
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:34:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rXp82d/Wh2JCj1MeKUCs7Dh59nPL823HHzcVIr15+Dw=;
        b=NQ7ieNKdg8Dc/eWF44C4KCALUopoB5+nZ27hFF4xuvbUO9SamjkStPDYYMLL6htksa
         1ccyreYGaL4J7/un6tD2z2CeY9UtItvQgjOvuUitOe2TQYfHMIGVvebXfignyV83F7xW
         SopwwHXmm7S0oIuAjq+cAaFhic2YJ1W3zkkCQ9F1eC60ZwBCxpkksB+C2w9CmaCi2oAD
         ObpusK2GTM2+gKaAZaGtpmIwisSQPpX7XMkwVxup6uZE33Fc0MiyLC38wro4zZ1bBiuo
         COjlFLRnDC2Ed47nb8gs82GWcslT+uxsUWB7n5YOACLyvvLhXzazi4j9BcOBJD7RcRqI
         RA4g==
X-Gm-Message-State: APjAAAWl3KI6H0qHID0LKYTLgXaCknOLDaazrBvCzvBj2iDpYb/mY+5f
	TjbCjbkaq6Hbj2XzKYba/Y0=
X-Google-Smtp-Source: APXvYqywxm1LMKB2iR0OTC1ykV3jOzNzHtzu435QnQl4bZncpfWFDjKeO3SolUO0I3KlMVVZLyo6kg==
X-Received: by 2002:a5d:414f:: with SMTP id c15mr13062250wrq.248.1567096489955;
        Thu, 29 Aug 2019 09:34:49 -0700 (PDT)
Received: from tiehlicka.suse.cz (ip-37-188-253-38.eurotel.cz. [37.188.253.38])
        by smtp.gmail.com with ESMTPSA id z25sm3623081wml.5.2019.08.29.09.34.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 09:34:48 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
	David Hildenbrand <david@redhat.com>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH] mm, oom: consider present pages for the node size
Date: Thu, 29 Aug 2019 18:34:43 +0200
Message-Id: <20190829163443.899-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

constrained_alloc calculates the size of the oom domain by using
node_spanned_pages which is incorrect because this is the full range of
the physical memory range that the numa node occupies rather than the
memory that backs that range which is represented by node_present_pages.

Sparsely populated nodes (e.g. after memory hot remove or simply sparse
due to memory layout) can have really a large difference between the
two. This shouldn't really cause any real user observable problems
because the oom calculates a ratio against totalpages and used memory
cannot exceed present pages but it is confusing and wrong from code
point of view.

Noticed-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a0bdc6..16af3da97d08 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -287,7 +287,7 @@ static enum oom_constraint constrained_alloc(struct o=
om_control *oc)
 	    !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
 		oc->totalpages =3D total_swap_pages;
 		for_each_node_mask(nid, *oc->nodemask)
-			oc->totalpages +=3D node_spanned_pages(nid);
+			oc->totalpages +=3D node_present_pages(nid);
 		return CONSTRAINT_MEMORY_POLICY;
 	}
=20
@@ -300,7 +300,7 @@ static enum oom_constraint constrained_alloc(struct o=
om_control *oc)
 	if (cpuset_limited) {
 		oc->totalpages =3D total_swap_pages;
 		for_each_node_mask(nid, cpuset_current_mems_allowed)
-			oc->totalpages +=3D node_spanned_pages(nid);
+			oc->totalpages +=3D node_present_pages(nid);
 		return CONSTRAINT_CPUSET;
 	}
 	return CONSTRAINT_NONE;
--=20
2.20.1


