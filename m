Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A47D7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 550AD20866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:56:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BVlJnpxV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 550AD20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E83F96B0006; Thu, 13 Jun 2019 02:56:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E35AF6B0007; Thu, 13 Jun 2019 02:56:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFBEA6B000A; Thu, 13 Jun 2019 02:56:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B136F6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:56:56 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id j9so7208704ite.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:56:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=Rydac0kByKvRlT58oD81CeEmII8iE4ez/kqn0T7bhHc=;
        b=HNRFUBBL8vUWRIkC5cPYa6ztKxGS9+qeWGgyp7oTscqxq5PUF9h5mw2T9W8l9+UeVU
         5fmbLRzlj52Lb5wpsA5TzvGXD4ObOjAhWX5VMirpU5UkETWhKgB0FCo/Ftd53g8valL/
         FHNCz87aTIDaU4eYEUUIVFcl8jFVN+N83PFYa6Ty/4ichfd1GoYbXESFLFoFitfmN8Sm
         2uDX/8tpuYnqsvzaMsaTx9rgVQNPpB4MWJ98mkExWvaNF/epV1pd8lW1NnB26462tDXs
         UYsALZALTxA09WE3Mw2/5EA7szvbUW6bclRUHEcVCe2IPqeoD1EdelEE/WR7Zh7gbkjb
         nhwg==
X-Gm-Message-State: APjAAAU+vgkeTs8OeKuCrSH0JI7lx1dJ4MsSt2j7Nw0kDgVKTxv/WJDA
	5OWBuDGbCVNL6VTi0Hyhom4d/rNYu6YL4/zZxxtXHJghKlpgtljNiVEQUYeygg44OTNzFC9AJVJ
	IkEndKP6EuaHPxsjVxpadsKPDPFYhpsxotdU41yA9B6fvSfIMr2dq+CG9BiiSzb3nIA==
X-Received: by 2002:a24:b543:: with SMTP id j3mr2285608iti.23.1560409016422;
        Wed, 12 Jun 2019 23:56:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU+h3/1OUyuYanjK04tEkhe+f8YG55NHBBTYl5omRcPeqk7YEOkkq9FON/E4wmPEBqnmlB
X-Received: by 2002:a24:b543:: with SMTP id j3mr2285589iti.23.1560409015840;
        Wed, 12 Jun 2019 23:56:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560409015; cv=none;
        d=google.com; s=arc-20160816;
        b=eOKHHa4CeVwh3lzbquWtUL4k8peSu37X1wlwgb8G/3K4deDmnAAzuixhTEYmK84FeA
         PfDuPk+DJkpkVIxp2jDcZ08GnXJHThvdf3FvEaqlI4MHJqAk4DVaUYaxoQT0aDnzLNAD
         K1CJ5t7YGbFUxK3PxAjFnkeb2W2oTcH6m6Onvq4ZgVebgx9y9W4L0CrcXbjt23ZC2J+R
         tB9et1s+1vLqI5hHl2LfbmN3gDtayh+i3da7mrIy+uMyn15kMrMxipK8Zc/ik8fIvJDc
         cBdZyBVdPf1via/BJnP8B23I/0oC09q/bndLeaiLkCVy26dC+KEE3SKoL+lP5OfaOZrz
         df3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Rydac0kByKvRlT58oD81CeEmII8iE4ez/kqn0T7bhHc=;
        b=mqtHCPZIIEUv8nCn82P9aXn6cErsRJql+NoAD2K3+DAN5exGPmUXNLC6/pSkAlsTYG
         moqcE5K5TJphJv5IoIkPNemZYOnvTssYt+QGWitEDYRLp04k3n/yrEoTLY/Yym2+7M1f
         lsBqMWzXm9lAHdeT6XFEVrWHBKtw8DPQuLiDx/If3AShBe8di/Io35rYCRpGxQ0gxHlj
         w2Fy9fPwgnZA/y2mNLNuGGWCcghxiU+iCntgkpntq1JV5MS28MPTB9VSmnHn0YJvqNq6
         xBpzaoThXKbT5irZ4bowP702jl6/kXvQjmxcFzRi4nlHACppMxJ8pZfHHl+Qh1lhNEq+
         2IvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BVlJnpxV;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u193si1680344jau.21.2019.06.12.23.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 23:56:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BVlJnpxV;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5D6sMnZ030606;
	Thu, 13 Jun 2019 06:56:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=Rydac0kByKvRlT58oD81CeEmII8iE4ez/kqn0T7bhHc=;
 b=BVlJnpxV5rDOyTJgv7p3PzIaCOGoglizj9apj5P1I/OeZkHktovm318MJAQjDKX4TmtS
 yhnoh4CbT7AkSPcCWcV1DpXi70uRmTNEi9eq1iBbpEAdCl+Nop8edbPXzN0eHVYSXZBZ
 37VSiMdjE74vMS2AlqTHtnWmT02DQXWzmdEyKi004CKWNOL6zEPC23KZlDyYjUzq51FL
 mDUzHzrFCna8tLYEKpsNzLvZZIBBK9LMC7ASGdf3mA9zOnUoprMc0Oi6ooimB9rBzUfb
 lu5rZaLKeeTD3MHkwpwxDxMxyFc0AJpIXonGPYdEQyn8EUjeY/LsRTZAbuHvjRDPU2RL FA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2t02heyryp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 13 Jun 2019 06:56:50 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5D6tLbf005474;
	Thu, 13 Jun 2019 06:56:50 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2t024vbq0r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 13 Jun 2019 06:56:50 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5D6ujtG012959;
	Thu, 13 Jun 2019 06:56:46 GMT
Received: from mwanda (/41.57.98.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 12 Jun 2019 23:56:45 -0700
Date: Thu, 13 Jun 2019 09:56:37 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org
Subject: [PATCH] mm/slab: restore IRQs in kfree()
Message-ID: <20190613065637.GE16334@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906130055
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906130055
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We added a new return here but we need to restore the IRQs before
we leave.

Fixes: 4f5d94fd4ed5 ("mm/slab: sanity-check page type when looking up cache")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/slab.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9e3eee5568b6..db01e9aae31b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3745,8 +3745,10 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
-	if (!c)
+	if (!c) {
+		local_irq_restore(flags);
 		return;
+	}
 	debug_check_no_locks_freed(objp, c->object_size);
 
 	debug_check_no_obj_freed(objp, c->object_size);
-- 
2.20.1

