Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC3AFC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB39921019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB39921019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FA516B0270; Tue, 21 May 2019 00:53:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D18E6B0271; Tue, 21 May 2019 00:53:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 826606B0272; Tue, 21 May 2019 00:53:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7F76B0270
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so28730755edi.20
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=gq3ARRXvCrviE7zgDZslDMgDa+RfCscNJ5KD1KW354Q=;
        b=GgWh6zxhoMqObHh5pgTzp98YowJ3Cq3OLH8Hck34FEeWLI5KbMYFTvA6uF6F48JQTh
         E6/xq8SYm79Q5xcN+GVNFjrE+gnYS2PZtEzDvTB2sw7luQ6gfBWP2CWyRh0H8qEL0bL0
         nLg9OLOCDkVVTBfKNsgj7nrTXdQdZBx+mKJO4LA37/5jVEJJQ+ckL/HkNVcKyhP7kC7k
         KMiqu/ewH/RpW41yBld0tlkv+GnmsYgNJYrzT+MlPnw5dkYcNCaO/Ghz407MUZdehx/+
         WAAtsn4YO24qjR/ll3CFbbmNvgHMeYmE0bCz/ekhok0UTu/zmV03PhFnmhYvBToPb27/
         Vtzg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVahjx+j7gmnluiIRejVm41CbPlutKe/J7f5m3DpKYob3s8+c7j
	xkp2azGFFPXT7MGu2TYGwAkyN1gzI8yGpTKF823DVg/c4QKSmXcdic/pRIaInBROkDQHR3DFZ/6
	fW/r4/FLjWXaVTQ8D/FVQzc64Jn/GsXq7nqA70Y65ilNalfSl+ei59u9VHPCBoPc=
X-Received: by 2002:a50:8dc5:: with SMTP id s5mr52447482edh.138.1558414427693;
        Mon, 20 May 2019 21:53:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHLNvYRoUWxfX5liysODhwl0Wf0BR5aL7EakA+qlbV+BUYa8BMxbJP4LhovVsADUukkDGZ
X-Received: by 2002:a50:8dc5:: with SMTP id s5mr52447410edh.138.1558414426501;
        Mon, 20 May 2019 21:53:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414426; cv=none;
        d=google.com; s=arc-20160816;
        b=TwxDk3CPtuouT4jQ1QP4DkF10gwH9Sa4CG4j99AMvrqN8JrDcNmx7hWFyli64j3+//
         3adk8tqI//Pq4X8P5AGpUh8/9WbZUVqBEaPnqKqN9C2HMVibiMB7XxyiXjwZslWdCoBz
         9CGfnYgO6vlPIICxfZ7t/RA+s22SJUomnKhGm7THUYWlLNNL22/uOmEWiHyVVQAuEr0J
         LAIa06PQiK2cQwY3Q54pnkelvzQo9o90W2DhLC8jGkP6bNJlAIGyFkHSJS19KtxAkXMD
         QAMrMo2d2zoal5D7I7xpvFPJD5KSeAVlZZDDGlP8l70Liq04/EyLwHEmdWgWAn+OaNL3
         K9Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=gq3ARRXvCrviE7zgDZslDMgDa+RfCscNJ5KD1KW354Q=;
        b=FjspRDSYpc3RD4dICwOoKsjHGw9OT4N7oDYyjRUFwQXRNbn0RA1JbSqr9bZSRnEu7f
         Y7qZ8IPZSighv18KUITk6Lg5HJ0Fw4hfWu4+zqfyUg1T+Hu4umaa6nPmnf4VhZR8l0el
         7nRg4k7H4P6xVEjHV3sT5oclXAxhY3r5Da+H3h6arjia4wYbKniMI0D+W2NiP23iAdwv
         IcbKiJT9o/+EJwy/uSi7GJqmBMUcdM7gvN3buW50c11VPwCuJ2g21QAlOmylOiW/+iOM
         J9CgXA86dYvmf0Zoa/Cm3QARyScbrjR+PLI7St7ohl71eOyHbnGHJd8ZOJNTDXHVaft7
         wcig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id 60si8526733edg.284.2019.05.20.21.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:45 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:17 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 10/14] net: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:38 -0700
Message-Id: <20190521045242.24378-11-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time. No change in
semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 net/ipv4/tcp.c     | 5 +++--
 net/xdp/xdp_umem.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 53d61ca3ac4b..2be929dcafa8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1731,6 +1731,7 @@ static int tcp_zerocopy_receive(struct sock *sk,
 	struct tcp_sock *tp;
 	int inq;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (address & (PAGE_SIZE - 1) || address != zc->address)
 		return -EINVAL;
@@ -1740,7 +1741,7 @@ static int tcp_zerocopy_receive(struct sock *sk,
 
 	sock_rps_record_flow(sk);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 
 	ret = -EINVAL;
 	vma = find_vma(current->mm, address);
@@ -1802,7 +1803,7 @@ static int tcp_zerocopy_receive(struct sock *sk,
 		frags++;
 	}
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	if (length) {
 		tp->copied_seq = seq;
 		tcp_rcv_space_adjust(sk);
diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 2b18223e7eb8..2bf444fb998d 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -246,16 +246,17 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
 	unsigned int gup_flags = FOLL_WRITE;
 	long npgs;
 	int err;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	umem->pgs = kcalloc(umem->npgs, sizeof(*umem->pgs),
 			    GFP_KERNEL | __GFP_NOWARN);
 	if (!umem->pgs)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	npgs = get_user_pages(umem->address, umem->npgs,
 			      gup_flags | FOLL_LONGTERM, &umem->pgs[0], NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	if (npgs != umem->npgs) {
 		if (npgs >= 0) {
-- 
2.16.4

