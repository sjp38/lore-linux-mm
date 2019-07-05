Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A696CC4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DC7021721
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=web.de header.i=@web.de header.b="lyH3f050"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DC7021721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=web.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76F686B0006; Fri,  5 Jul 2019 10:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7208E8E0003; Fri,  5 Jul 2019 10:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E95E8E0001; Fri,  5 Jul 2019 10:50:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1144A6B0006
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 10:50:35 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id x2so3834132wru.22
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 07:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:openpgp
         :autocrypt:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=TKLFIU6D13zx1N/Jp4vw89FUtPLQcozmodD6xhJ13kI=;
        b=l+mXTJznvQymAhIDgmReu0Xg6Js9I8uaL1ZlV0iJ2WQgaQNy+ZlyMGQy2KbzcVj6Vf
         sVpWrcmKRHKxgbXmzv1jtZpgRrN7+tq7uMVyP3KfJAWFl8InER90TULdh+0+o1PrE5FQ
         lvUPsC0DIU7WwcktVfmP67kJEBSL9cjy2QD+Rhr9N9M5Z8LrrJa2ABSOS44R9MQUeYW4
         d5zirQNXXHNrEq2klVMAdOXFw5khKahN48szSVI37St6Q10HJ2atLHpHEcWdM7CKYpLF
         JpwUAAaQlJ7h618qBbU/uSdgUP8Y6A6f20xPg3aT2ErBJURSW0EOrAXiyRQy2TK0ZpiL
         QDfg==
X-Gm-Message-State: APjAAAXL5lasL1zuduWGvchldZbixHoDXQbVfLQFVrGlyvxpdzr3qetD
	Hr4ZOEgGRUN8T4nttbQZTwyJFTqrCZ/4zfqjiFKSNhVKUi42K+AaGxP6vz6Wgl5PKXnBaSF/G+g
	fKY5+xzbEJKQghBMT7RwahJMIz2FSQfrayHDS4sRjOtsQrN9mRyCOd9+cprhklsLMRQ==
X-Received: by 2002:a5d:540e:: with SMTP id g14mr4744341wrv.346.1562338234677;
        Fri, 05 Jul 2019 07:50:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFJnWAQr6DrBG9sSLO8DDlKn7rSzb0R56TKkxx7tWYU45P40ZH+q957EZ0egDsL4so/eq1
X-Received: by 2002:a5d:540e:: with SMTP id g14mr4744307wrv.346.1562338234036;
        Fri, 05 Jul 2019 07:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562338234; cv=none;
        d=google.com; s=arc-20160816;
        b=duwVBnS8EbQ9EG5bWqd4R3lN922473tb6BKfE7RvaXjXc4QFtcg4tAABUDb6Llo2xP
         ErG9A2OQXVFZOqIItfsUbFcmoM7m8zsGlEjNxAFXwu0sug27hokpMZ5HNID4r+228L0b
         QPAviBWTQyReDx8dCKNTN/rxmqRAsBPvCaBBDnB+AkHT4/DtgaaoPWx1R2lKJD2woRlf
         uJiKeRkRu5QH5BE25SntFgc+QxTVX+BnG5/VouMQRrWMHzOyYhMNcEk3vKYNJvK3IlaW
         Pt+bIYGmNlxBa5UOq7O9n6rU2DoLmdUvRHSlpUA+tDhLH/k6Hib8UR9bX28JeCijzqOU
         C8MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:autocrypt:openpgp:subject:from:cc:to:dkim-signature;
        bh=TKLFIU6D13zx1N/Jp4vw89FUtPLQcozmodD6xhJ13kI=;
        b=F4GS9mxQNtjUgiTOsCoeqGe4O/o4Zt7FeM2ttMFyE7bBxwNtjCEXIN4cKq9YLqSYLM
         fYinDZ5NKOedQTO6BBwJyoDwHf0hPt7rolVwWlsZAADycnJzpvdUFEsDNYBC2ZdL95Wp
         BPQex5/kabpmmrraYYQ6ec5bzkMQ9DOENr8qVd/FNZ0m2COJDQX0ZcLoBjrL0nd7B9fF
         3IlZjjlv9Cp/T5TBGz7IhVfVfOO9H1jTZ6CLaEkWq5ZPHKExCo3NN1noB2NGvGnFI47x
         j2nB832HXv113+ozNcrPfgfMWwkGiN7kNLQpzgtq7Iz3BKArg1yl97YV49oPLSjqfCXs
         REbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@web.de header.s=dbaedf251592 header.b=lyH3f050;
       spf=pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) smtp.mailfrom=Markus.Elfring@web.de
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id f3si2349790wmg.44.2019.07.05.07.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 07:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) client-ip=217.72.192.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@web.de header.s=dbaedf251592 header.b=lyH3f050;
       spf=pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) smtp.mailfrom=Markus.Elfring@web.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de;
	s=dbaedf251592; t=1562338228;
	bh=AHWuVzfHlb6NYXmK7t9+VzffJ18kF++Ty2DSAVesCBE=;
	h=X-UI-Sender-Class:To:Cc:From:Subject:Date;
	b=lyH3f050DGwnY9BQ7oK1CAPIgIaOqtfMuysq+aQ3PhKVVP2RdhjdeKZL+LWlAH6QM
	 X1rjNnzw4Go07ywV85kg6r9XZA9hAaF/ZjCRDT+p5UugseZozk3XCfnsi6aPJ5D94h
	 2hlqjrF0yzMuEY5Fqv0YNtWIdy7B6Zc4L43Tub+c=
X-UI-Sender-Class: c548c8c5-30a9-4db5-a2e7-cb6cb037b8f9
Received: from [192.168.1.2] ([2.244.45.164]) by smtp.web.de (mrweb103
 [213.165.67.124]) with ESMTPSA (Nemesis) id 0LbrZ2-1iQPn547ds-00jMl5; Fri, 05
 Jul 2019 16:50:28 +0200
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org
From: Markus Elfring <Markus.Elfring@web.de>
Subject: [PATCH] mm/slab: One function call less in verify_redzone_free()
Openpgp: preference=signencrypt
Autocrypt: addr=Markus.Elfring@web.de; prefer-encrypt=mutual; keydata=
 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 FEE=
Message-ID: <90ca26d4-cc94-d7db-5ab4-ed04b29ced19@web.de>
Date: Fri, 5 Jul 2019 16:50:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:QpkNiuBupiQ5eD6VrsoIqXZ3Q9nZAQJUYje5ATMR1Y+Qh2ZBv8b
 FTpeQQEfGPeiXrVBMTkyWy9St+I4N7Bg+Y4gK7cz90TmfvqOalHzA+0OOrYIOf8Q5VOPkjS
 mH172jvhk1vVdyY+S2C0HvhiGd3M7At7f0QqojdZrm4HG1EuQhLs2uU8CMIE80H1uu+Ae0l
 rZD8AsCuVg1DnDOSJmgZw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:Lid/wJVXkKY=:9MwFr07rbNiYiVtsqn+TXi
 6ACxIDhRn9+aJS230v9XinE6mPveP4q9j3PKQFDYs+EzKc7nWtBsYeuaUjpYkCFVQ/zabh34F
 yedOB7EcZ8JNZIYbiSAgKZw/1R/OW1+IMvTQVFrKGNGaVMmMnm6SYc9Re+dDEtsAQHvNrYLpB
 +HUTGeHJV6RJMxjSlGX02PJelnRotMPun83RaW6rfpRkRQwNEpG64Az7KJ++fglFk8STx/bls
 HrymkN+90HcekKUYvaQykI2y+Ai1vp6ou0fl4HJ6B8r3uUvHiWy8m5drTc3EMZ73L+R9ld1It
 KK/+GIha61yxtsX3I/MdK5qg3f8GYnfRGt2w6pOszn7S0NutKEnJ3bsx+H1KaW2eK8anWLgLD
 zA8b4Z+XUFv3zN5kk/FX5nr4gYVMYqFtzOeKp0TLXGHASC3DJ3e4HhSWFtMb/+CcrK9ZqfT0v
 XCrQ1SwZ+Y/5TBDVoNEMT1AyMRe5ubJlHxCzmu7YPPXOjw1PgmDSUxmGaNlw2PXGlEijEh/hb
 HGMbXXzMFrpiF+EMS9OGC8PfOhEhqKWukC3mjYkrOgDUDaEZHA9i/KLQgEOys7UI4CoRQwerU
 7M5hfQy/WwBPuMVgEBm0+tXeLkMLO1NJe5Bn6dKt295MVB4BNLr1FbA43LHKEfjP9JDdyUeT7
 8s0sWJQb4d1SmMI/lfv+yMiqISQMcoJLqWpEm6zCJ/VfqkrArgRewig9k22PTPVDWzGIKUDst
 y6YBHfhXyEFwF0OkbZY8MMkysCP+2Ego+ZO1wxW6F4ByKAYnZmb3nI+53Kwb3l0LlI3snAcX4
 g+e6NYIB3NJPIARvPqYIvGwmJJRbv4nl+E3er0OE1zfANqb4x0zA6M1JB0PFsfTG6vUn3xNlE
 UJs5QKkIsHDreTfzOydnANZcsTQth/IQQ9HSH2Z2tjYsee5+bzbuVt3Qw23r45UtRloYGMppB
 E0Imw33VR3c29Il5Gobc25qSM97JTiu56jOmWh9zmL4I2D3kol+Ld8KKJ/4/aRl6Bz2HnAb+Y
 hxzWnvCZv4V+XOtFi6psM99A2nM+vcAYWXLaoFtEPoi16gM2rghXVNwu/JOiFWWoYhfPKIuUB
 VhRpJGtQRBDWkurI2OrZTiQqmJW4YEcuSsW
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 5 Jul 2019 16:40:09 +0200

Avoid an extra function call by using a ternary operator instead of
a conditional statement for a string literal selection.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
=2D--
 mm/slab.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9df370558e5d..849b5c276588 100644
=2D-- a/mm/slab.c
+++ b/mm/slab.c
@@ -2701,10 +2701,10 @@ static inline void verify_redzone_free(struct kmem=
_cache *cache, void *obj)
 	if (redzone1 =3D=3D RED_ACTIVE && redzone2 =3D=3D RED_ACTIVE)
 		return;

-	if (redzone1 =3D=3D RED_INACTIVE && redzone2 =3D=3D RED_INACTIVE)
-		slab_error(cache, "double free detected");
-	else
-		slab_error(cache, "memory outside object was overwritten");
+	slab_error(cache,
+		   redzone1 =3D=3D RED_INACTIVE && redzone2 =3D=3D RED_INACTIVE
+		   ? "double free detected"
+		   : "memory outside object was overwritten");

 	pr_err("%px: redzone 1:0x%llx, redzone 2:0x%llx\n",
 	       obj, redzone1, redzone2);
=2D-
2.22.0

