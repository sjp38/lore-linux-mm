Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9825C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:13:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C66E20684
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:13:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C66E20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3166B0277; Thu,  6 Jun 2019 09:13:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 083EB6B0278; Thu,  6 Jun 2019 09:13:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB4166B0279; Thu,  6 Jun 2019 09:13:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2BB86B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 09:13:36 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id v1so1020854otj.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 06:13:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JAErcRwTm4Fxv7hc/ipsQuGC8OwztSmhtOobDqFAvak=;
        b=XWuyNpKyTjkl7XrEZMqbfrHo5soH+/zScP8SlQbjiZlnCGjIjNOFIxT34jbZ9R2fxg
         0iXPgVKGXQf2mnQcNTEtKQpS8loLzAAAmKHiW3vtRJns4e1gHuL2tqkxXfedJW/v86sj
         O8Ur2hjhAkgdTjtxum633hr4QlYajajfNfpJaRnnwlRidkoUrmhtord1X1Msbm1KTd5B
         8y4cWc4Ece4z4717AVey4IcyzkfMYAi43qz/HuWxqB9LR0uw2YP/s0+zQLEKuVjPqkNL
         U8Vgqfoc9iKZ5WW603uwnuUVLPtyJ+k+L6AAFpgpd+01jAF6mI/yUGft8ZObCeSISzay
         Dc8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfields@fieldses.org designates 173.255.197.46 as permitted sender) smtp.mailfrom=bfields@fieldses.org
X-Gm-Message-State: APjAAAXRenUU9y+aMOQL/b/sulwKYCvR4ttPnmrI/C3iGVdUvxRzmR1B
	nbNTE5qXS0Gm7wGzqbWgvGWwZ/wQTQIFO8QOfJGyAQGpj/y62aOZ1yrHj0h9ia5WimSMe1IveqB
	Wf4aDV5hvXbAd5iZuE7CG6g4/SDW4B4+mRzRtlh8K6pCSsSRStN4EUYJqY3l2xJ0Qrg==
X-Received: by 2002:a9d:4b0b:: with SMTP id q11mr14774130otf.69.1559826816462;
        Thu, 06 Jun 2019 06:13:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfiJIi/cla7AD5h+CHESIxyg5HLlL0axpBwZnuQJRr2bSegKlXU3gQX/KFH9vRWCvgB1qR
X-Received: by 2002:a9d:4b0b:: with SMTP id q11mr14774036otf.69.1559826815243;
        Thu, 06 Jun 2019 06:13:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559826815; cv=none;
        d=google.com; s=arc-20160816;
        b=hT3EGm4QCk3iAQT3Csrjpln1zU5tlmVUN9IS5O3fkZ8rvvULomC2XseTE2ZjCl/oeh
         EdzuKwmzfmqYXFWgUxNnoaKdc3zh26ReWFgaLfXj68hOzLq5pM27ZAkzJY6wOfdGZjmx
         uZ5bYePqLeBc+5vOKmjLKF31OK1+otUicVXuxFqVDyBvxtPyfT3GitsJvHMukrwhk5AQ
         MNhy1tWnlVFpHZl2nRbVh8Opq2fC+ddsF42j8sInfCSND7Vj3/PsFAMckRngAPl6pd/L
         RBeLhoKrFSfc2rd6squBVSYCUaNGK69JUCOnX9yb1wovJGkdZ+5FAwZ9j9pkxQvpSyBA
         yFeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JAErcRwTm4Fxv7hc/ipsQuGC8OwztSmhtOobDqFAvak=;
        b=B6XC0h0oGZbwG/IpVJPnJSWuYUnWRcIagNLA9nJozPDAk2yoV5vxb1t/hYJBnlT/oc
         zJhvE/H2xVXcUoCgc+PM4blNqmPiEpNSEdkBp2pY3xsUq1xKWmSMps+m6Qnfh9/zzXqz
         lW0YBN8gprlcXMMS3eG7YXP7HlNRn/CYGo2R4o1lMISQrYbYywETC6kbvn5ERX/1Xe2n
         3O7g56B38FHf1W0HN3vXooj1rGUwYfrxv4GrlPGf1PsfONhkRZuLnPm7HNwwELuQDX+W
         ZGOn4jOs5s0gqXD1jabELE5vNTu4dNiLZ8JHPW0+pJLW7bcdjmUyRRDO680nF/qcmiLe
         900g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfields@fieldses.org designates 173.255.197.46 as permitted sender) smtp.mailfrom=bfields@fieldses.org
Received: from fieldses.org (fieldses.org. [173.255.197.46])
        by mx.google.com with ESMTP id u124si1424668oif.125.2019.06.06.06.13.34
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 06:13:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfields@fieldses.org designates 173.255.197.46 as permitted sender) client-ip=173.255.197.46;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfields@fieldses.org designates 173.255.197.46 as permitted sender) smtp.mailfrom=bfields@fieldses.org
Received: by fieldses.org (Postfix, from userid 2815)
	id 8384214DB; Thu,  6 Jun 2019 09:13:34 -0400 (EDT)
Date: Thu, 6 Jun 2019 09:13:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, bfields@redhat.com, chris@chrisdown.name,
	daniel.m.jordan@oracle.com, guro@fb.com, hannes@cmpxchg.org,
	jlayton@kernel.org, laoar.shao@gmail.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nfs@vger.kernel.org, mgorman@techsingularity.net,
	mhocko@suse.com, sfr@canb.auug.org.au,
	syzkaller-bugs@googlegroups.com, yang.shi@linux.alibaba.com
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
Message-ID: <20190606131334.GA24822@fieldses.org>
References: <0000000000005a4b99058a97f42e@google.com>
 <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
> This may be connected with that shrinker unregistering is forgotten on error path.

I was wondering about that too.  Seems like it would be hard to hit
reproduceably though: one of the later allocations would have to fail,
then later you'd have to create another namespace and this time have a
later module's init fail.

This is the patch I have, which also fixes a (probably less important)
failure to free the slab cache.

--b.

commit 17c869b35dc9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 5 18:03:52 2019 -0400

    nfsd: fix cleanup of nfsd_reply_cache_init on failure
    
    Make sure everything is cleaned up on failure.
    
    Especially important for the shrinker, which will otherwise eventually
    be freed while still referred to by global data structures.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ea39497205f0..3dcac164e010 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -157,12 +157,12 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 	nn->nfsd_reply_cache_shrinker.seeks = 1;
 	status = register_shrinker(&nn->nfsd_reply_cache_shrinker);
 	if (status)
-		return status;
+		goto out_nomem;
 
 	nn->drc_slab = kmem_cache_create("nfsd_drc",
 				sizeof(struct svc_cacherep), 0, 0, NULL);
 	if (!nn->drc_slab)
-		goto out_nomem;
+		goto out_shrinker;
 
 	nn->drc_hashtbl = kcalloc(hashsize,
 				sizeof(*nn->drc_hashtbl), GFP_KERNEL);
@@ -170,7 +170,7 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 		nn->drc_hashtbl = vzalloc(array_size(hashsize,
 						 sizeof(*nn->drc_hashtbl)));
 		if (!nn->drc_hashtbl)
-			goto out_nomem;
+			goto out_slab;
 	}
 
 	for (i = 0; i < hashsize; i++) {
@@ -180,6 +180,10 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 	nn->drc_hashsize = hashsize;
 
 	return 0;
+out_slab:
+	kmem_cache_destroy(nn->drc_slab);
+out_shrinker:
+	unregister_shrinker(&nn->nfsd_reply_cache_shrinker);
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
 	return -ENOMEM;

