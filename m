Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE1B0C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 14:53:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CAD8218B0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 14:53:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CAD8218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18506B0285; Fri, 15 Mar 2019 10:53:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCAA86B0286; Fri, 15 Mar 2019 10:53:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C91836B0287; Fri, 15 Mar 2019 10:53:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7033C6B0285
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:53:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u12so3984499edo.5
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 07:53:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ZAzMSWHx0WmVC9ocBpL/95fw7z1KnsO8j+p5ZzjUWSc=;
        b=s19vboy8o2NsRTULtwTobWU0xg+iXIjHStu3k8HuWcqvABIrKA40mNZYk2z5QIP431
         1fTKPblFTRrj+GvDSBlPw14w8E29/BdOjA7l6pPHehSZ1H2BpM8GsGGZcCuh4dBtaCOX
         fhbdC1HCkQaYIGOJY2I3qYU/EeONTKLTPdOgBu1nndjlZIr4yTdr488IS2ZgdH8VD2Fc
         0LF4Gs31nZtLtc3rCIrhv+2i83ESqR4mcZfVBJb5Z8hln+1FQYgOY1lLJ8wGYBdSo84V
         yzksMBNsCoYK8rEQrPCUhwEhxvcUx3bRjM8r6QWN+jJp8lT+6dBwo23zV5+gYDx0N3IY
         SQTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAVURcLJLJP80VB/OVQHFnYpHIz+5BC+teDhOs1URFRTuF1Ssdij
	hWnFx8rkEp+WJOCbYhdB/1MYJA0/9rmOBLke9v8vWm+XI9CmFFlQJ5rPIvAO6qklPVWv+/7K7dj
	xVvxCd5x8Xv+cdWGHGwZWv+d6mXTIfLJKKJShLjirVuHiJefzzN0N2ie2PSOEdspnGg==
X-Received: by 2002:a05:6402:1682:: with SMTP id a2mr3022414edv.158.1552661638064;
        Fri, 15 Mar 2019 07:53:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMoxMDzXa+3EMZbIYMtEG9yhT6635Y8g4plKFJsvoj85NZ1QTXpq/4FDNLvSnfas59Uwbs
X-Received: by 2002:a05:6402:1682:: with SMTP id a2mr3022351edv.158.1552661636852;
        Fri, 15 Mar 2019 07:53:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552661636; cv=none;
        d=google.com; s=arc-20160816;
        b=B8YgG+MUpNvAKL4Oe+vcPppkT0a1AHKVWKTz0RbcJYgKcT8/K8uwZRb4yeMjf9ZT+q
         YjhjYH4i039ZgjmuQVvDfvSCytM9ZYy9eBjHblnDWJZbA0CoVlO7vVi0PG2pfZk9po1n
         zwOaaB3R1faBOHdSbleedVxpFQslcwx1Ggw/lqUQUe8kL8BVzsflKadSxtkjVBX9B6wI
         VTRF/RRyFC841mTUXXKnsEJv8mciF/rC9fZbDmoeum7PJa1V2T15+VPK2kv2x/ofc7+r
         Won8FQx/ULCZCCHuUsxDa5GzVH2901CIwkRFFEmRcxkchdXEmSyGu7pkDSuaKuP/olNG
         z/kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ZAzMSWHx0WmVC9ocBpL/95fw7z1KnsO8j+p5ZzjUWSc=;
        b=Yl3ghNNiUn+gt2nahmYo1DNnzXJI7I4dDUfOvGFthzzlUpU3Fsgv/zmD/yW5tx02Y+
         sC/k4ou9L7Cvr1JfMAaSQyytLC8so9oyS1ZZ3j8TF8b3nYoCmF+6x18HWg86Wma4+Exo
         PBEAwxK/A+XJ070K9oNJDhfnVuUrcfGmo9+V/JKe+MXJBFl3y2s11PN4Qbsi0iUSdhhz
         8q2fx8cvl6AzAeGzbFOWVPGzETbtaG3OgK3XXuRoN7+AEFUc39MesYB/dNuuPib7+3cx
         Ay1j6lgCCtovijiJZGti/P3t2LDXTqjYErOvJ7xi5a6kcxTiZv68erV+Job804AlXfpj
         JHHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si238041edh.445.2019.03.15.07.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 07:53:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B5CE6AC4A;
	Fri, 15 Mar 2019 14:53:55 +0000 (UTC)
Subject: Re: [PATCH v2] xen/balloon: Fix mapping PG_offline pages to user
 space
To: David Hildenbrand <david@redhat.com>, xen-devel@lists.xenproject.org
Cc: linux-kernel@vger.kernel.org, Boris Ostrovsky
 <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>,
 Julien Grall <julien.grall@arm.com>, Matthew Wilcox <willy@infradead.org>,
 Nadav Amit <namit@vmware.com>, Andrew Cooper <andrew.cooper3@citrix.com>,
 akpm@linux-foundation.org, linux-mm@kvack.org,
 Oscar Salvador <osalvador@suse.de>, Jan Beulich <JBeulich@suse.com>
References: <20190314160256.21713-1-david@redhat.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 mQENBFOMcBYBCACgGjqjoGvbEouQZw/ToiBg9W98AlM2QHV+iNHsEs7kxWhKMjrioyspZKOB
 ycWxw3ie3j9uvg9EOB3aN4xiTv4qbnGiTr3oJhkB1gsb6ToJQZ8uxGq2kaV2KL9650I1SJve
 dYm8Of8Zd621lSmoKOwlNClALZNew72NjJLEzTalU1OdT7/i1TXkH09XSSI8mEQ/ouNcMvIJ
 NwQpd369y9bfIhWUiVXEK7MlRgUG6MvIj6Y3Am/BBLUVbDa4+gmzDC9ezlZkTZG2t14zWPvx
 XP3FAp2pkW0xqG7/377qptDmrk42GlSKN4z76ELnLxussxc7I2hx18NUcbP8+uty4bMxABEB
 AAG0H0p1ZXJnZW4gR3Jvc3MgPGpncm9zc0BzdXNlLmNvbT6JATkEEwECACMFAlOMcK8CGwMH
 CwkIBwMCAQYVCAIJCgsEFgIDAQIeAQIXgAAKCRCw3p3WKL8TL8eZB/9G0juS/kDY9LhEXseh
 mE9U+iA1VsLhgDqVbsOtZ/S14LRFHczNd/Lqkn7souCSoyWsBs3/wO+OjPvxf7m+Ef+sMtr0
 G5lCWEWa9wa0IXx5HRPW/ScL+e4AVUbL7rurYMfwCzco+7TfjhMEOkC+va5gzi1KrErgNRHH
 kg3PhlnRY0Udyqx++UYkAsN4TQuEhNN32MvN0Np3WlBJOgKcuXpIElmMM5f1BBzJSKBkW0Jc
 Wy3h2Wy912vHKpPV/Xv7ZwVJ27v7KcuZcErtptDevAljxJtE7aJG6WiBzm+v9EswyWxwMCIO
 RoVBYuiocc51872tRGywc03xaQydB+9R7BHPuQENBFOMcBYBCADLMfoA44MwGOB9YT1V4KCy
 vAfd7E0BTfaAurbG+Olacciz3yd09QOmejFZC6AnoykydyvTFLAWYcSCdISMr88COmmCbJzn
 sHAogjexXiif6ANUUlHpjxlHCCcELmZUzomNDnEOTxZFeWMTFF9Rf2k2F0Tl4E5kmsNGgtSa
 aMO0rNZoOEiD/7UfPP3dfh8JCQ1VtUUsQtT1sxos8Eb/HmriJhnaTZ7Hp3jtgTVkV0ybpgFg
 w6WMaRkrBh17mV0z2ajjmabB7SJxcouSkR0hcpNl4oM74d2/VqoW4BxxxOD1FcNCObCELfIS
 auZx+XT6s+CE7Qi/c44ibBMR7hyjdzWbABEBAAGJAR8EGAECAAkFAlOMcBYCGwwACgkQsN6d
 1ii/Ey9D+Af/WFr3q+bg/8v5tCknCtn92d5lyYTBNt7xgWzDZX8G6/pngzKyWfedArllp0Pn
 fgIXtMNV+3t8Li1Tg843EXkP7+2+CQ98MB8XvvPLYAfW8nNDV85TyVgWlldNcgdv7nn1Sq8g
 HwB2BHdIAkYce3hEoDQXt/mKlgEGsLpzJcnLKimtPXQQy9TxUaLBe9PInPd+Ohix0XOlY+Uk
 QFEx50Ki3rSDl2Zt2tnkNYKUCvTJq7jvOlaPd6d/W0tZqpyy7KVay+K4aMobDsodB3dvEAs6
 ScCnh03dDAFgIq5nsB11j3KPKdVoPlfucX2c7kGNH+LUMbzqV6beIENfNexkOfxHf4kBrQQY
 AQgAIBYhBIUSZ3Lo9gSUpdCX97DendYovxMvBQJa3fDQAhsCAIEJELDendYovxMvdiAEGRYI
 AB0WIQRTLbB6QfY48x44uB6AXGG7T9hjvgUCWt3w0AAKCRCAXGG7T9hjvk2LAP99B/9FenK/
 1lfifxQmsoOrjbZtzCS6OKxPqOLHaY47BgEAqKKn36YAPpbk09d2GTVetoQJwiylx/Z9/mQI
 CUbQMg1pNQf9EjA1bNcMbnzJCgt0P9Q9wWCLwZa01SnQWFz8Z4HEaKldie+5bHBL5CzVBrLv
 81tqX+/j95llpazzCXZW2sdNL3r8gXqrajSox7LR2rYDGdltAhQuISd2BHrbkQVEWD4hs7iV
 1KQHe2uwXbKlguKPhk5ubZxqwsg/uIHw0qZDk+d0vxjTtO2JD5Jv/CeDgaBX4Emgp0NYs8IC
 UIyKXBtnzwiNv4cX9qKlz2Gyq9b+GdcLYZqMlIBjdCz0yJvgeb3WPNsCOanvbjelDhskx9gd
 6YUUFFqgsLtrKpCNyy203a58g2WosU9k9H+LcheS37Ph2vMVTISMszW9W8gyORSgmw==
Message-ID: <a889fdc1-c857-eb94-1f5e-21943c182e4f@suse.com>
Date: Fri, 15 Mar 2019 15:53:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190314160256.21713-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/03/2019 17:02, David Hildenbrand wrote:
> The XEN balloon driver - in contrast to other balloon drivers - allows
> to map some inflated pages to user space. Such pages are allocated via
> alloc_xenballooned_pages() and freed via free_xenballooned_pages().
> The pfn space of these allocated pages is used to map other things
> by the hypervisor using hypercalls.
> 
> Pages marked with PG_offline must never be mapped to user space (as
> this page type uses the mapcount field of struct pages).
> 
> So what we can do is, clear/set PG_offline when allocating/freeing an
> inflated pages. This way, most inflated pages can be excluded by
> dumping tools and the "reused for other purpose" balloon pages are
> correctly not marked as PG_offline.
> 
> Fixes: 77c4adf6a6df (xen/balloon: mark inflated pages PG_offline)
> Reported-by: Julien Grall <julien.grall@arm.com>
> Tested-by: Julien Grall <julien.grall@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Pushed to xen/tip.git for-linus-5.1b


Juergen

