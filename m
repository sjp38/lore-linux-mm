Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB737C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:11:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9446A214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:11:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9446A214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B086B0007; Thu,  8 Aug 2019 10:11:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20AF66B0008; Thu,  8 Aug 2019 10:11:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149946B000A; Thu,  8 Aug 2019 10:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC32C6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 10:11:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p18so8981656qke.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 07:11:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:to:cc:subject:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=iUeaBtNknoNIuo+MfYBccSjF5YTHu77Rw5kwqTJ56Yk=;
        b=X5k8lDqpju2EarA1DGworOiCSO7mgTa5RzBdsk1ERvGef+AFgmLaEMz7xpxMpGbvdp
         zCtWA2H3UvaDB5NgN2hNRWGdmhJq/8H7V1VMrmEpwAl+3BLRRZnxijdb3Y0xJWJnAUm/
         6wyBlXAaUnZmoCQfabzVgvfcFAe0W136zhtUWCo+asWWRUYP3u69KkupzYN12KZOf2ap
         w1v8hJJPzhe+C8IKBVFbejBiJAboQro+yeJEW0G+tQdssFHn6CKDyYxdtYfYcZ/gvjpj
         oDY+N8cMg6rGKd/wDajd8RL8Hnr9kfW0dwgjVAmMomajjN6OGjmUfFb7V70Egkiv504U
         z+Sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQtJ14lTBzq/0zJEptPElY78PsUWQRueqvdhuKJWyiFQRNm5Fj
	dQeIoWMRCGpwOlwAZqdnxwZknXT6WYk5apxrquUF/DqlnAroofHSueU/vl9B2neEkjNsgrv5SXf
	jniu81AF1B47p0dmZnpta1TnOP6ob20kSwxZDXqgZ7Ocwe7diiKsnOguqbK52ehMTUw==
X-Received: by 2002:aed:33e6:: with SMTP id v93mr13412954qtd.157.1565273514663;
        Thu, 08 Aug 2019 07:11:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7F2FzGBC4jOLpDJFPuXtq72w9xjkaJDLgCqr15ptsXrKkOnsrGhlvpS+pXrp047QpYLhl
X-Received: by 2002:aed:33e6:: with SMTP id v93mr13412890qtd.157.1565273513892;
        Thu, 08 Aug 2019 07:11:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565273513; cv=none;
        d=google.com; s=arc-20160816;
        b=mCkQFhU0i1IQvQbrxACIawlug0LB9aCXcwtNgGkEcX7fERvPo8fPZsGC/sMM7aK3/J
         KUNnGNwzHsVnPJS3DKPGx+fYwE2stfD5dJZerB37TBDEa7+Yg+w/pF5GwTx6tz/EnFNn
         ofYCPlfA+ImH7dS3x2T28w7dx1YXNjonDRqHaVs2mzBQ97C1Man1Ez76JsdaTF9ekT5o
         m9sLxoyCZ80j3mtbpFreiC0xrJYRDYxInXyCRGOnlr6QnZSFyRlHuDZYjjsP9XhrQLUr
         8+K8B3XiKRS0DF8VBqUb+GJ/WlmdEqmw/vVsbtk4zbg2lWHKJ3C04WXl2Y9gNE1uZPxg
         a2PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :subject:cc:to:from:organization;
        bh=iUeaBtNknoNIuo+MfYBccSjF5YTHu77Rw5kwqTJ56Yk=;
        b=GCt7mY2YbmFSFjUjbcX1eLFPJkG/RDd9AIo4WoCBck6jH/Ef/GywrFHmC52vOqkwP1
         VZFFWpqpRdHVbNbKpnB/6RrJDRyzD+9TUQVUvlF2u3t7RzWjg1vuex4+Wq6gF/lwinj9
         xRPSqxI/DLHgSIoac38uCtl8YyvHywFmMWh7kn6NoS6XIsGRrT2hXwCqkfA+potEwtr+
         9i1zjFxCMjc5Za8JTTU6lIkxPmuuoavGXDgHrUpc4Z2HRl6r5EbLRgEIyFNX5ZCDYR6V
         bh5I9AbHKRltAqSY+d58VyTsLG5OVx33Y8OdZBCDLLAdpKiafneRlvd2vFLB2Az5YvTp
         j4Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si51540012qkc.224.2019.08.08.07.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 07:11:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0AAE751F0C;
	Thu,  8 Aug 2019 14:11:53 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-255.rdu2.redhat.com [10.10.120.255])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5BCD1608AB;
	Thu,  8 Aug 2019 14:11:52 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
To: Christoph Lameter <cl@linux.com>
cc: dhowells@redhat.com, linux-mm@kvack.org
Subject: [PATCH] Add a slab corruption tracepoint
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <26517.1565273511.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Aug 2019 15:11:51 +0100
Message-ID: <26518.1565273511@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 08 Aug 2019 14:11:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

    =

Add a tracepoint to log slab corruption messages to the trace log also so
that it's easier to correlate with other trace messages that are being use=
d
to track refcounting.

Signed-off-by: David Howells <dhowells@redhat.com>
---
 include/trace/events/kmem.h |   23 +++++++++++++++++++++++
 mm/slab.c                   |    2 ++
 2 files changed, 25 insertions(+)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eb57e3037deb..c96f3b03a6e2 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -315,6 +315,29 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->change_ownership)
 );
 =

+TRACE_EVENT(slab_corruption,
+	TP_PROTO(const char *slab, void *object, unsigned int size, unsigned int=
 offset),
+
+	TP_ARGS(slab, object, size, offset),
+
+	TP_STRUCT__entry(
+		__field(	void *,		object		)
+		__field(	unsigned int,	size		)
+		__field(	unsigned int,	offset		)
+		__array(	char,		slab, 16	)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->slab, slab, sizeof(__entry->slab));
+		__entry->object		=3D object;
+		__entry->size		=3D size;
+		__entry->offset		=3D offset;
+	),
+
+	TP_printk("slab=3D%s obj=3D%px size=3D%x off=3D%x",
+		  __entry->slab, __entry->object, __entry->size, __entry->offset)
+);
+
 #endif /* _TRACE_KMEM_H */
 =

 /* This part must be outside protection */
diff --git a/mm/slab.c b/mm/slab.c
index 9df370558e5d..47c5a86e39be 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1527,6 +1527,8 @@ static void check_poison_obj(struct kmem_cache *cach=
ep, void *objp)
 				       print_tainted(), cachep->name,
 				       realobj, size);
 				print_objinfo(cachep, objp, 0);
+				trace_slab_corruption(cachep->name, realobj,
+						      size, i);
 			}
 			/* Hexdump the affected line */
 			i =3D (i / 16) * 16;

