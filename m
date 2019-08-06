Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B4C3C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:39:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B62E420717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:39:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pQAib5PL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B62E420717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 163336B0005; Tue,  6 Aug 2019 11:39:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 143676B0006; Tue,  6 Aug 2019 11:39:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0507B6B000D; Tue,  6 Aug 2019 11:39:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3DFA6B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:39:35 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id e11so35212405oiy.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:39:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=gt3S7UkVzjw6LIvcKPfkFEn5u9lYh4HRDfRBOdHZyYs=;
        b=cW+elY1PYwLmbReoNoxa0UIhf3QpBP0jxDNBGofRKbv8tpWLQP7me3cESVyxMeMREJ
         g0NsmkqIGr/6ERsQfEkS3yb47hq6YZLixDo8n+nmIWMK+ib9IxJzaqWKJbmWHzxOrRhB
         iL2xeG4ZsyDOvXmDk3JcBE25+hJOYwMLroCmC7Gkzc0TJTWhGsQM16/QTkXm3OhDWOva
         Zuj9fhf62pQMnIFzhP6u3ecQoeJ4RswPzCvNtky5K3shCJ4JVrq6wz999yE2pi9c8+LB
         nDjdkuqPZa9ah6UxEBYezfoR8kgejEWRomrQBejVNBpAQF5bwR4OvxiUJa8bWiwtW5iK
         gqBA==
X-Gm-Message-State: APjAAAWy9oDc+FicjK9MN/ptt3avUH3enCeVTDpDsAsafDoecC1MQ8F6
	CuaRf4Z1QzSq/xl3in46EmcmBoIidvlo3HVhIg9qlaXil42s62akrTTrMyl8nS69+FhgW/dDEFb
	zp+D8Vlt3L7HQ57a/oP/LxPqoBD8t/CT3nmEiU9KoPdVNJaeRIJyC4uUC0VyM63Kzqw==
X-Received: by 2002:a5d:9618:: with SMTP id w24mr4092497iol.279.1565105975464;
        Tue, 06 Aug 2019 08:39:35 -0700 (PDT)
X-Received: by 2002:a5d:9618:: with SMTP id w24mr4092428iol.279.1565105974393;
        Tue, 06 Aug 2019 08:39:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565105974; cv=none;
        d=google.com; s=arc-20160816;
        b=tqyAc17jJQTXwdxYI4pxnKJBZ6AgVougZgpTNH7Pq4eP68GJHcR3TwtxQp3oNxS1E1
         gLAPc/bFzt0cAbA2tlav/OhfZaa6yHFQfY0RgIOjvSX11ZKTI5Mffvft88FmT6EJNubh
         +78sKDzh/gFhf2QiVyn7VM8LRgYu6HXB1R+dhT6ezU1jAkWDi3iMZ38yVDpMLn99JSiH
         ugRaFMB/vZaKjjEEvjMovRjQKwWy2SkGJCQqsRYnZsVxGgmfeCX17Za3nYywXr1K2AfY
         Af5hSLyZx/cyxSRZErhFX6nAtsfPI856hjMYwUE036dSrWCyBDBpm44TfhpWhvWWb8ji
         8rRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=gt3S7UkVzjw6LIvcKPfkFEn5u9lYh4HRDfRBOdHZyYs=;
        b=SjuK8Bj7CLgdWH1UmjegvnOIzOedIPo3xP5TsaMwmHD+14DTRcR1KRPKYegUxZtmDS
         e9s8nmd9mLlnk7R0LA3UxHR7REj0MPQARSJlSOIQz5eWPXGe5XiLpDFwQyfQKNRZSPdS
         cunDfLyHwIn4n/Al2f0EtsY0hZU+by3SggabXGsGQU9HYHvc7XZeIl0UNuTK9f5a7QiS
         oRm3Q0kzfGGnrQRkPNRqKfIdQZK7AzTT+ogGMUdcJ3vyzxmgKwUS8UqEjnfYAxBV4tdw
         Vt2ontyy8T7XMMNS3UxbkdUqQc0a2+pnLYFnhFl22Dq3zvcWx/AkOlpDGirz/R+ZFyF2
         SiDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pQAib5PL;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21sor59646479iom.119.2019.08.06.08.39.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 08:39:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pQAib5PL;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=gt3S7UkVzjw6LIvcKPfkFEn5u9lYh4HRDfRBOdHZyYs=;
        b=pQAib5PLARsBrZVN0xKr1AbRs2+IZj7BHjQOid7d93wjbVJHjoo8lzthx2DKPJ6IBe
         DvsSY2UiShge/HH3jMjFre2KxgYoEx3tCpRBNA39hbJ4Q2MWp3SXxHKu/KIrrEnqUY2P
         d8CEM3XLzALfQazBv//GBTjfKLHJ/raRB3pxHE1EwMItgC9xNKuW9/ME6IVbYiRJUK+V
         e6IPNu4a6ceSVwRNyVtZLHS8CNCCBtzTswCETFfk6teP8z2tasFxyefZqh4sJHCtt7Lq
         /oJTZ+IUwGN2rcqsWdQ8ebRQyqbA/yR8bFEzufgQQGDdPBXxOZ1zX3UQr2H/IxXgWZck
         8gVQ==
X-Google-Smtp-Source: APXvYqzHM+OwCqOEibmv7e5QtMK/krXngaJ1fMi8SyR+ovgJWuTNDyX2RJJzye+8PIdERFUKXm88EqhQ6bOwqlIpOew=
X-Received: by 2002:a02:5b05:: with SMTP id g5mr4772443jab.114.1565105973854;
 Tue, 06 Aug 2019 08:39:33 -0700 (PDT)
MIME-Version: 1.0
From: Antoine Reversat <a.reversat@gmail.com>
Date: Tue, 6 Aug 2019 11:39:22 -0400
Message-ID: <CAA=2nCbZWGvUPVeYZJB7fU7Fkmnu0MEYMDr_RYkTEY79CeLOjw@mail.gmail.com>
Subject: [BUG] Kernel panic on >= 4.12 because of NX
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="0000000000009b853c058f74a19c"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000215, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000009b853c058f74a19c
Content-Type: text/plain; charset="UTF-8"

Sorry for the maybe not so helpful title.

Here is the problem :
I'm running Linux on a Mac pro 1,1 (the first x86 mac pro). It's a dual
xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M and 2x2G (this one
:
http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=&ktcpartno=KTA-MP667AK2/4G
)

If I only have the 2x512M kit everything works fine for all kernel versions
but if I have both kits or just the 2x2G kit any kernel above 4.10 panics
very early on (picture of said panic https://imgur.com/a/PipU5Oc). The
picture was taken on 4.15 (using earlyprintk=efi,keep) on other versions
even using earlyprintk I don't get any output.

I have been trying several kernels and everything up to 4.11 works no
problem. Then on 4.11 I got a panic which mentionned NX and pages being in
W+X which prompted me to try noexec=off on newer versions and that fixes
the panic. This works up to 5.2.5.

/proc/cpuinfo reports that the CPU support the NX flag.

I would need help in order to troubleshoot this further.

--0000000000009b853c058f74a19c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Sorry for the maybe not so helpful title.</div><div><=
br></div><div>Here is the problem :</div><div>I&#39;m running Linux on a Ma=
c pro 1,1 (the first x86 mac pro). It&#39;s a dual xeon 5150 with ECC ram. =
I have 2 ram kits in it : 2x512M and 2x2G (this one : <a href=3D"http://www=
.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&amp;ktcpartno=3DKTA-M=
P667AK2/4G">http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D=
&amp;ktcpartno=3DKTA-MP667AK2/4G</a>)</div><div><br></div><div>If I only ha=
ve the 2x512M kit everything works fine for all kernel versions but if I ha=
ve both kits or just the 2x2G kit any kernel above 4.10 panics very early o=
n (picture of said panic <a href=3D"https://imgur.com/a/PipU5Oc">https://im=
gur.com/a/PipU5Oc</a>). The picture was taken on 4.15 (using earlyprintk=3D=
efi,keep) on other versions even using earlyprintk I don&#39;t get any outp=
ut.<br></div><div><br></div><div>I have been trying several kernels and eve=
rything up to 4.11 works no problem. Then on 4.11 I got a panic which menti=
onned NX and pages being in W+X which prompted me to try noexec=3Doff on ne=
wer versions and that fixes the panic. This works up to 5.2.5.<br></div><di=
v><br></div><div>/proc/cpuinfo reports that the CPU support the NX flag. <b=
r></div><div><br></div><div>I would need help in order to troubleshoot this=
 further.<br></div></div>

--0000000000009b853c058f74a19c--

