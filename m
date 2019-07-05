Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D199BC4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 849B321721
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:50:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=web.de header.i=@web.de header.b="VBTUGH4b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 849B321721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=web.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F1726B0003; Fri,  5 Jul 2019 10:50:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A3418E0003; Fri,  5 Jul 2019 10:50:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 042C08E0001; Fri,  5 Jul 2019 10:50:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE0AB6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 10:50:33 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id g2so3857149wrq.19
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 07:50:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:openpgp
         :autocrypt:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=TKLFIU6D13zx1N/Jp4vw89FUtPLQcozmodD6xhJ13kI=;
        b=ZWKVm8F4XDRVq5qUmIrapBOb6WhAxekjZETAh5qezhMLZxRD/5LtVRRbRr8lkHl2w7
         fl6g/bDh04WZw66hsk6GKadbPlrVNszeaLfnV+E16WIavfIun6+Md/e5B6kF8UhRjd4b
         FC7OakiL6nslkihoqANvGdSPI20tduyOfqG3RcEI+35n4lXUD2PHuvQfA08lCXyck3YY
         V5E9TdvCxvzQoCXiszQqADrz+AqTwKPDmMtQFlIsRv8DiURxlqZs/iqM3NFKf2xChd0D
         Qh3gOpFUGIkuOmVNeQwVDU6y+gmz4lWxucbfN6pG7CelL+A9tu5h9WnXRf7yua15FeaP
         NnsQ==
X-Gm-Message-State: APjAAAV8805e38pnVn2mRFbkJW4lyPaiSGm4woYefcJjnVHT3dnh/EYW
	48DrAK4OFBHn59U5DIkWiuAYs/d71XMgLAxfck0Xz46wAQAnTAcLIuro/GI3Kmz8dCAcc39cdmx
	IwfWKi8hRiTMqRTI7y+vs+vqkKJmTV272x2D3wVVwKpeEOES+Epgx+GYy9ToAMbkaDw==
X-Received: by 2002:adf:f902:: with SMTP id b2mr4537480wrr.199.1562338233263;
        Fri, 05 Jul 2019 07:50:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0OzOD/4aRJgJTZ3fT0CkHKHvJ5UJK5EYPpihA/iDM+WKzx0bF7A9g6F4RNcE6dXmx5C9I
X-Received: by 2002:adf:f902:: with SMTP id b2mr4537424wrr.199.1562338232175;
        Fri, 05 Jul 2019 07:50:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562338232; cv=none;
        d=google.com; s=arc-20160816;
        b=UV5fGyHaEeNvLVVknstSOBZWdxSlzYIFFlNs8eDBatAlSHeAdiFjQqhRYIv+f+C3UC
         PC99CA1NJ/WFrLfW/xHncynzTrdoUplBYxErlNK3u6jvE+HqqQoiYgquEMZ65PkcpeVA
         hFRlgbBIOBa3L2e6+iT6o6LAOWMC4Vwu3XU3WDgeS0q5jWdmloaJPqw0mBLdCW3ENv3/
         bjCYsbmAExqRgNbUaDORJT/Do2GrcYVV3y88RfbYVBcC1HWAYQpu4lRLi3QAykhVj28C
         /2qRcUjrISmneXwqYRR+MEIYauEFzJgnMeIaugPYIFIctZciIFrfnOVOWj7KtjGBwopO
         uegw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:autocrypt:openpgp:subject:from:cc:to:dkim-signature;
        bh=TKLFIU6D13zx1N/Jp4vw89FUtPLQcozmodD6xhJ13kI=;
        b=bKkVmojbR5G4/iwAiC5QGiB00qsYa+bTj8gyzgpbiCwTft3JWBZyqHxxNBuoFGqfh2
         NJjhe1Lr+UjMulGH8JUsjHfvNerFGTcHIID98tOZbGEaN07qvRwhjibE0Vw7IiYNHR4J
         2yv2gmeDwfoqvSwOYEXvne/mc2Dfye4VnUr43gRnIpmrncTn1oZzWbG/Ph5mipqPbp5o
         85jQyD8fNeZnIqJIDs8uHA6R6Ue/tykct4oyQ8FmgR0v5aWPP8VIzL02ysiH2I/mBLBF
         BT8Y1bMpeE+kdcz8mUNs6Sqnh6/MRCL2oY55l+KoUg2Oddri6qlW89iw8jfIIuDSI2sj
         7KYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@web.de header.s=dbaedf251592 header.b=VBTUGH4b;
       spf=pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) smtp.mailfrom=Markus.Elfring@web.de
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id d76si4122912wmd.0.2019.07.05.07.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 07:50:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) client-ip=217.72.192.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@web.de header.s=dbaedf251592 header.b=VBTUGH4b;
       spf=pass (google.com: domain of markus.elfring@web.de designates 217.72.192.78 as permitted sender) smtp.mailfrom=Markus.Elfring@web.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de;
	s=dbaedf251592; t=1562338229;
	bh=AHWuVzfHlb6NYXmK7t9+VzffJ18kF++Ty2DSAVesCBE=;
	h=X-UI-Sender-Class:To:Cc:From:Subject:Date;
	b=VBTUGH4bzvq2KBlgyq2sV7SXK1Ov5qTohld7u1ROGLCEDTwXmuJxjasTJGvznVbA6
	 N8ocmRkJBLtUEv8Di96jtiioXy39BBOsyt0AGhEKMo5ic5D5C/3qrHNhyM3KazDbif
	 mLhHWkcMhOZ0iAZjJfKDAQ2rSqyiuWhVU8jGf2OM=
X-UI-Sender-Class: c548c8c5-30a9-4db5-a2e7-cb6cb037b8f9
Received: from [192.168.1.2] ([2.244.45.164]) by smtp.web.de (mrweb101
 [213.165.67.124]) with ESMTPSA (Nemesis) id 0LoYjO-1iBcUB1tNq-00gbgC; Fri, 05
 Jul 2019 16:50:29 +0200
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org
From: Markus Elfring <Markus.Elfring@web.de>
Subject: [PATCH] mm/slab: One function call less in verify_redzone_free()
Openpgp: preference=signencrypt
Autocrypt: addr=Markus.Elfring@web.de; prefer-encrypt=mutual; keydata=
 mQINBFg2+xABEADBJW2hoUoFXVFWTeKbqqif8VjszdMkriilx90WB5c0ddWQX14h6w5bT/A8
 +v43YoGpDNyhgA0w9CEhuwfZrE91GocMtjLO67TAc2i2nxMc/FJRDI0OemO4VJ9RwID6ltwt
 mpVJgXGKkNJ1ey+QOXouzlErVvE2fRh+KXXN1Q7fSmTJlAW9XJYHS3BDHb0uRpymRSX3O+E2
 lA87C7R8qAigPDZi6Z7UmwIA83ZMKXQ5stA0lhPyYgQcM7fh7V4ZYhnR0I5/qkUoxKpqaYLp
 YHBczVP+Zx/zHOM0KQphOMbU7X3c1pmMruoe6ti9uZzqZSLsF+NKXFEPBS665tQr66HJvZvY
 GMDlntZFAZ6xQvCC1r3MGoxEC1tuEa24vPCC9RZ9wk2sY5Csbva0WwYv3WKRZZBv8eIhGMxs
 rcpeGShRFyZ/0BYO53wZAPV1pEhGLLxd8eLN/nEWjJE0ejakPC1H/mt5F+yQBJAzz9JzbToU
 5jKLu0SugNI18MspJut8AiA1M44CIWrNHXvWsQ+nnBKHDHHYZu7MoXlOmB32ndsfPthR3GSv
 jN7YD4Ad724H8fhRijmC1+RpuSce7w2JLj5cYj4MlccmNb8YUxsE8brY2WkXQYS8Ivse39MX
 BE66MQN0r5DQ6oqgoJ4gHIVBUv/ZwgcmUNS5gQkNCFA0dWXznQARAQABtCZNYXJrdXMgRWxm
 cmluZyA8TWFya3VzLkVsZnJpbmdAd2ViLmRlPokCVAQTAQgAPhYhBHDP0hzibeXjwQ/ITuU9
 Figxg9azBQJYNvsQAhsjBQkJZgGABQsJCAcCBhUICQoLAgQWAgMBAh4BAheAAAoJEOU9Figx
 g9azcyMP/iVihZkZ4VyH3/wlV3nRiXvSreqg+pGPI3c8J6DjP9zvz7QHN35zWM++1yNek7Ar
 OVXwuKBo18ASlYzZPTFJZwQQdkZSV+atwIzG3US50ZZ4p7VyUuDuQQVVqFlaf6qZOkwHSnk+
 CeGxlDz1POSHY17VbJG2CzPuqMfgBtqIU1dODFLpFq4oIAwEOG6fxRa59qbsTLXxyw+PzRaR
 LIjVOit28raM83Efk07JKow8URb4u1n7k9RGAcnsM5/WMLRbDYjWTx0lJ2WO9zYwPgRykhn2
 sOyJVXk9xVESGTwEPbTtfHM+4x0n0gC6GzfTMvwvZ9G6xoM0S4/+lgbaaa9t5tT/PrsvJiob
 kfqDrPbmSwr2G5mHnSM9M7B+w8odjmQFOwAjfcxoVIHxC4Cl/GAAKsX3KNKTspCHR0Yag78w
 i8duH/eEd4tB8twcqCi3aCgWoIrhjNS0myusmuA89kAWFFW5z26qNCOefovCx8drdMXQfMYv
 g5lRk821ZCNBosfRUvcMXoY6lTwHLIDrEfkJQtjxfdTlWQdwr0mM5ye7vd83AManSQwutgpI
 q+wE8CNY2VN9xAlE7OhcmWXlnAw3MJLW863SXdGlnkA3N+U4BoKQSIToGuXARQ14IMNvfeKX
 NphLPpUUnUNdfxAHu/S3tPTc/E/oePbHo794dnEm57LuuQINBFg2+xABEADZg/T+4o5qj4cw
 nd0G5pFy7ACxk28mSrLuva9tyzqPgRZ2bdPiwNXJUvBg1es2u81urekeUvGvnERB/TKekp25
 4wU3I2lEhIXj5NVdLc6eU5czZQs4YEZbu1U5iqhhZmKhlLrhLlZv2whLOXRlLwi4jAzXIZAu
 76mT813jbczl2dwxFxcT8XRzk9+dwzNTdOg75683uinMgskiiul+dzd6sumdOhRZR7YBT+xC
 wzfykOgBKnzfFscMwKR0iuHNB+VdEnZw80XGZi4N1ku81DHxmo2HG3icg7CwO1ih2jx8ik0r
 riIyMhJrTXgR1hF6kQnX7p2mXe6K0s8tQFK0ZZmYpZuGYYsV05OvU8yqrRVL/GYvy4Xgplm3
 DuMuC7/A9/BfmxZVEPAS1gW6QQ8vSO4zf60zREKoSNYeiv+tURM2KOEj8tCMZN3k3sNASfoG
 fMvTvOjT0yzMbJsI1jwLwy5uA2JVdSLoWzBD8awZ2X/eCU9YDZeGuWmxzIHvkuMj8FfX8cK/
 2m437UA877eqmcgiEy/3B7XeHUipOL83gjfq4ETzVmxVswkVvZvR6j2blQVr+MhCZPq83Ota
 xNB7QptPxJuNRZ49gtT6uQkyGI+2daXqkj/Mot5tKxNKtM1Vbr/3b+AEMA7qLz7QjhgGJcie
 qp4b0gELjY1Oe9dBAXMiDwARAQABiQI8BBgBCAAmFiEEcM/SHOJt5ePBD8hO5T0WKDGD1rMF
 Alg2+xACGwwFCQlmAYAACgkQ5T0WKDGD1rOYSw/+P6fYSZjTJDAl9XNfXRjRRyJSfaw6N1pA
 Ahuu0MIa3djFRuFCrAHUaaFZf5V2iW5xhGnrhDwE1Ksf7tlstSne/G0a+Ef7vhUyeTn6U/0m
 +/BrsCsBUXhqeNuraGUtaleatQijXfuemUwgB+mE3B0SobE601XLo6MYIhPh8MG32MKO5kOY
 hB5jzyor7WoN3ETVNQoGgMzPVWIRElwpcXr+yGoTLAOpG7nkAUBBj9n9TPpSdt/npfok9ZfL
 /Q+ranrxb2Cy4tvOPxeVfR58XveX85ICrW9VHPVq9sJf/a24bMm6+qEg1V/G7u/AM3fM8U2m
 tdrTqOrfxklZ7beppGKzC1/WLrcr072vrdiN0icyOHQlfWmaPv0pUnW3AwtiMYngT96BevfA
 qlwaymjPTvH+cTXScnbydfOQW8220JQwykUe+sHRZfAF5TS2YCkQvsyf7vIpSqo/ttDk4+xc
 Z/wsLiWTgKlih2QYULvW61XU+mWsK8+ZlYUrRMpkauN4CJ5yTpvp+Orcz5KixHQmc5tbkLWf
 x0n1QFc1xxJhbzN+r9djSGGN/5IBDfUqSANC8cWzHpWaHmSuU3JSAMB/N+yQjIad2ztTckZY
 pwT6oxng29LzZspTYUEzMz3wK2jQHw+U66qBFk8whA7B2uAU1QdGyPgahLYSOa4XAEGb6wbI FEE=
Message-ID: <c724416e-c8bc-6927-00c5-7a4c433c562f@web.de>
Date: Fri, 5 Jul 2019 16:50:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:IgBpO+x92bqAHhKEvFHLnCtvGIZ2+CxgiyJimlJNnsG5Rr88EKB
 vVTTu4h9eYSf9TDILgiJJVfH9KgnOYIgcd5YA2cUut67+9uW55fEPdUQTG5RoRZm7FbvgRR
 xq/INQCcb3kLdA49xJY46eEVY5Xl2To/Ii9vKUtSmTgHuqDWgytDTOjdGPhtZ5JfArK5tM2
 x0iQZBXVNrIa6678K9BSQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:j32V0O5rkgA=:uq8kW04SL4cjFmlB7ihdJX
 kGyEKOSeyxyo3oa/TKCZSKK3WrmzyNggc2llbcWwPrMvZvNRoivDshPAz4L81nPieCcF77dFy
 /aodCJVxWHq22H4mWBA+WdyWiclukm0J8sXh0Tg/EWHZTCfNHHoHoxmQL5jZzwPjd/1gp4Rzo
 wIyKZodKRZXQjMFWg+PGn9xp4/xUoF/V8fhR1PGGd0xHw0i7/fx7RyG7ERrkl498oAMjwdq/U
 LOgaT+KUvLW9jGtgUi7fnNcqTjH8L54vnKNrjNzpudI3z/2n2hHegmd6BBLbEMOgnGrqmgkKR
 E7KGxvKj29KaffcM04wQYFBrTNAguefuBMdx/DjRqEA8ro1L7l5KuSFtshlqoYTcMZXPZSeS7
 81C3wfGtpbqklP2EFtj7WnfKDeGSmCvE4nbtjXgW73AcBtmD7jvsnWcAdfcb/6B7+7QsA9re6
 t78cvfq/L1LZMzBBWiJ+6Y09XsY3UZr6FoQKjnmbwkaRi1G1M74ambVRep9q3Sjntoq4o3QSc
 vrlQsd2lRRsL8Pp5973fCRO3C0TaxJN5sJSXWi+Lrm5blGM/hfCBi4x5E642jmQXnZawzu6SZ
 cD/Iyg8o3htIxY9yoZbkr4NIQTYz0edFhblIUEgM2qk8ehFTLlBk50ze6UF2fGI8dPbgwLxe2
 mUoNlDJm/2q2e20m7zg1zDkxwewP55FkDflf1rgwq3EyiLGBaBAJ2ycqDTj9BbpoIbxZQ/w5e
 e3BiV+D6CE9bIn8p/C+XGj8tMt+M+C5dSrwQA912olIKtvinyiCQnH4kGVDPHMzgKeDNMa800
 JtC/mqliQmggdHFJakjsNnPQgSlQr/pQ5qXZvrPEatmjJv+2kU/HPYC3fNyzQfu/6t3arr9Nk
 mSc0spCV1hBxHiJlj0SCf8WfV9EU+6uGBFfIbQ3JR8lnmBOVwG8iGUxajhHyIqY21QyQfk3L8
 BaxPdVKyZC/ffMj55b5DWZWPUMtj6E2140aXkZzNQDMoMkO7ix4fZSDBHVZbzy6iamQoCz5cg
 jT4l0nfSuVXlraBGvvBhRfkErc+3dS4CECLEThUJXvkAOln8RHi0nyxzSxsS6nWjRgGBSOwQt
 OfZyIwWoeHNwhXPwwq/8FTzsDk1M+cbt13t
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

