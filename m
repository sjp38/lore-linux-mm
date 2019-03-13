Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F44AC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 11:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0D0214AE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 11:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0D0214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E2188E0003; Wed, 13 Mar 2019 07:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 293D78E0001; Wed, 13 Mar 2019 07:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 183768E0003; Wed, 13 Mar 2019 07:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE2608E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:54:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b11so1301948qka.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=ogRWZ3iGubDxzTl9EIVKtJVVn3H7fMHROG3bNVqaajI=;
        b=jIO48huUvp2JyWpCSQsYXDtrUkWZuBAJFfEKcJDk2zT241vw6Gmt2xwcEa5hbYKMD0
         rzRUpXksPuxUWAhdTCpR6X0e3w3ZRp/4SLy9HkM++iwYkwHGILgJMhFuoJhYlXgIUmYU
         MeVFOZIeGEMj+7OrWi5gjB77T2HDwXpIksLsRYaJm/lMHbfl1DJs0l+8o3ygAmSa1HBg
         h350nZ94N0msigpwQ+HXKs+NdxhpNAvAW6ZDqaQWzWNJZ/a1LcnN9B35nJmRJul5Gpil
         0smS8lTXit92fhDbqr1hsM2kFj3iqtx7FdN1eGkoZhEIwaHUVJfJy+dguTL5QyZ3dIPm
         2BPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWwIzJqcWlNjPDPatH+MTSfWgzFivgoDH5I3+X9j54e6vXoBzVA
	p6FExSWWDWS4vX8F/vi8Noi+n7ExfgfGrOXH+oEsrzIybd1N6zh9pM5YEi+V+dUKu1/HiyxU9cr
	TtN90rrnyofkibYtp0Y7YriMSLXnCKSwbFpK17LGP7yc2C/V8vAaeYM5xPeDwNCaaNQ==
X-Received: by 2002:a0c:987a:: with SMTP id e55mr34704003qvd.21.1552478078604;
        Wed, 13 Mar 2019 04:54:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxv2Q+R62329WAlUfCZc/+hvVgPAlbGNmPnD10TwBCC0hFqLbsXwU28qNk4jrtD/TO5rq3H
X-Received: by 2002:a0c:987a:: with SMTP id e55mr34703936qvd.21.1552478077315;
        Wed, 13 Mar 2019 04:54:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552478077; cv=none;
        d=google.com; s=arc-20160816;
        b=uKnH459kIGCQhIGUlqD0cx2VXhUZ4cTV184nG1k8jQcTfYZli4bW2rpILrV92iYzvO
         WkyqZ55WIr+NrwtnIELjoHSQu4ZgEeujPdB/QkNusQAAmlDUOj1mqDAh7Um4e8lzPTbE
         uParBc/rHKMAFrutPI1AVdazyPYN86N0kW3VO7q6TcNykuuUFNVnDW2thwDOPFus5KQa
         Qtg1wF2dOcK4mbp+Zn1iS0caGNG7lwxkg8cZ0MEkuJWTp487TPeLNOZekaFNLqusbNt6
         PI3caGnjdgu57gJeT9AgyttnCqJeitla7qGRD0vz/7JfTSvsACLWD87IIvwXE75UZ2IE
         ttfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=ogRWZ3iGubDxzTl9EIVKtJVVn3H7fMHROG3bNVqaajI=;
        b=yH4qqLXeLw4D7hA1AeSvojXFwQAf+6ePRFM3xSxfsrMmVaLOCjGifH4EfCg/CUeIPH
         QN39EQt2YcrGQh/j9WCEyrC9Y4GyTd6l1rA0whW0t4wDNKyU36EjQnW8afJiX5AhX6y4
         zp+2C0nSldRHoUyUZOIraZlqTgEMi01Z2Aqq7taOgUe9BZVpUpYFUYMRxKKfS4fEjHvh
         mu2BhR7V5iESfcIjKWRm47HsEpOhn4uixnP78gSC3c/NoCD0zXmDSt5HzzguIhzpdMBi
         h6c6NaBrD5B0ejmA8577gL7/ff6ap1aypz4qS/q+dX7EEQ2UumZdhrrohjRR9kpz/TX+
         IWUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e125si2158992qkd.76.2019.03.13.04.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 04:54:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 538DB307EA97;
	Wed, 13 Mar 2019 11:54:36 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BF59B27CB0;
	Wed, 13 Mar 2019 11:54:27 +0000 (UTC)
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
 <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
 <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
 <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 mQINBFl4pQoBEADT/nXR2JOfsCjDgYmE2qonSGjkM1g8S6p9UWD+bf7YEAYYYzZsLtbilFTe
 z4nL4AV6VJmC7dBIlTi3Mj2eymD/2dkKP6UXlliWkq67feVg1KG+4UIp89lFW7v5Y8Muw3Fm
 uQbFvxyhN8n3tmhRe+ScWsndSBDxYOZgkbCSIfNPdZrHcnOLfA7xMJZeRCjqUpwhIjxQdFA7
 n0s0KZ2cHIsemtBM8b2WXSQG9CjqAJHVkDhrBWKThDRF7k80oiJdEQlTEiVhaEDURXq+2XmG
 jpCnvRQDb28EJSsQlNEAzwzHMeplddfB0vCg9fRk/kOBMDBtGsTvNT9OYUZD+7jaf0gvBvBB
 lbKmmMMX7uJB+ejY7bnw6ePNrVPErWyfHzR5WYrIFUtgoR3LigKnw5apzc7UIV9G8uiIcZEn
 C+QJCK43jgnkPcSmwVPztcrkbC84g1K5v2Dxh9amXKLBA1/i+CAY8JWMTepsFohIFMXNLj+B
 RJoOcR4HGYXZ6CAJa3Glu3mCmYqHTOKwezJTAvmsCLd3W7WxOGF8BbBjVaPjcZfavOvkin0u
 DaFvhAmrzN6lL0msY17JCZo046z8oAqkyvEflFbC0S1R/POzehKrzQ1RFRD3/YzzlhmIowkM
 BpTqNBeHEzQAlIhQuyu1ugmQtfsYYq6FPmWMRfFPes/4JUU/PQARAQABtCVOaXRlc2ggTmFy
 YXlhbiBMYWwgPG5pbGFsQHJlZGhhdC5jb20+iQI9BBMBCAAnBQJZeKUKAhsjBQkJZgGABQsJ
 CAcCBhUICQoLAgQWAgMBAh4BAheAAAoJEKOGQNwGMqM56lEP/A2KMs/pu0URcVk/kqVwcBhU
 SnvB8DP3lDWDnmVrAkFEOnPX7GTbactQ41wF/xwjwmEmTzLrMRZpkqz2y9mV0hWHjqoXbOCS
 6RwK3ri5e2ThIPoGxFLt6TrMHgCRwm8YuOSJ97o+uohCTN8pmQ86KMUrDNwMqRkeTRW9wWIQ
 EdDqW44VwelnyPwcmWHBNNb1Kd8j3xKlHtnS45vc6WuoKxYRBTQOwI/5uFpDZtZ1a5kq9Ak/
 MOPDDZpd84rqd+IvgMw5z4a5QlkvOTpScD21G3gjmtTEtyfahltyDK/5i8IaQC3YiXJCrqxE
 r7/4JMZeOYiKpE9iZMtS90t4wBgbVTqAGH1nE/ifZVAUcCtycD0f3egX9CHe45Ad4fsF3edQ
 ESa5tZAogiA4Hc/yQpnnf43a3aQ67XPOJXxS0Qptzu4vfF9h7kTKYWSrVesOU3QKYbjEAf95
 NewF9FhAlYqYrwIwnuAZ8TdXVDYt7Z3z506//sf6zoRwYIDA8RDqFGRuPMXUsoUnf/KKPrtR
 ceLcSUP/JCNiYbf1/QtW8S6Ca/4qJFXQHp0knqJPGmwuFHsarSdpvZQ9qpxD3FnuPyo64S2N
 Dfq8TAeifNp2pAmPY2PAHQ3nOmKgMG8Gn5QiORvMUGzSz8Lo31LW58NdBKbh6bci5+t/HE0H
 pnyVf5xhNC/FuQINBFl4pQoBEACr+MgxWHUP76oNNYjRiNDhaIVtnPRqxiZ9v4H5FPxJy9UD
 Bqr54rifr1E+K+yYNPt/Po43vVL2cAyfyI/LVLlhiY4yH6T1n+Di/hSkkviCaf13gczuvgz4
 KVYLwojU8+naJUsiCJw01MjO3pg9GQ+47HgsnRjCdNmmHiUQqksMIfd8k3reO9SUNlEmDDNB
 XuSzkHjE5y/R/6p8uXaVpiKPfHoULjNRWaFc3d2JGmxJpBdpYnajoz61m7XJlgwl/B5Ql/6B
 dHGaX3VHxOZsfRfugwYF9CkrPbyO5PK7yJ5vaiWre7aQ9bmCtXAomvF1q3/qRwZp77k6i9R3
 tWfXjZDOQokw0u6d6DYJ0Vkfcwheg2i/Mf/epQl7Pf846G3PgSnyVK6cRwerBl5a68w7xqVU
 4KgAh0DePjtDcbcXsKRT9D63cfyfrNE+ea4i0SVik6+N4nAj1HbzWHTk2KIxTsJXypibOKFX
 2VykltxutR1sUfZBYMkfU4PogE7NjVEU7KtuCOSAkYzIWrZNEQrxYkxHLJsWruhSYNRsqVBy
 KvY6JAsq/i5yhVd5JKKU8wIOgSwC9P6mXYRgwPyfg15GZpnw+Fpey4bCDkT5fMOaCcS+vSU1
 UaFmC4Ogzpe2BW2DOaPU5Ik99zUFNn6cRmOOXArrryjFlLT5oSOe4IposgWzdwARAQABiQIl
 BBgBCAAPBQJZeKUKAhsMBQkJZgGAAAoJEKOGQNwGMqM5ELoP/jj9d9gF1Al4+9bngUlYohYu
 0sxyZo9IZ7Yb7cHuJzOMqfgoP4tydP4QCuyd9Q2OHHL5AL4VFNb8SvqAxxYSPuDJTI3JZwI7
 d8JTPKwpulMSUaJE8ZH9n8A/+sdC3CAD4QafVBcCcbFe1jifHmQRdDrvHV9Es14QVAOTZhnJ
 vweENyHEIxkpLsyUUDuVypIo6y/Cws+EBCWt27BJi9GH/EOTB0wb+2ghCs/i3h8a+bi+bS7L
 FCCm/AxIqxRurh2UySn0P/2+2eZvneJ1/uTgfxnjeSlwQJ1BWzMAdAHQO1/lnbyZgEZEtUZJ
 x9d9ASekTtJjBMKJXAw7GbB2dAA/QmbA+Q+Xuamzm/1imigz6L6sOt2n/X/SSc33w8RJUyor
 SvAIoG/zU2Y76pKTgbpQqMDmkmNYFMLcAukpvC4ki3Sf086TdMgkjqtnpTkEElMSFJC8npXv
 3QnGGOIfFug/qs8z03DLPBz9VYS26jiiN7QIJVpeeEdN/LKnaz5LO+h5kNAyj44qdF2T2AiF
 HxnZnxO5JNP5uISQH3FjxxGxJkdJ8jKzZV7aT37sC+Rp0o3KNc+GXTR+GSVq87Xfuhx0LRST
 NK9ZhT0+qkiN7npFLtNtbzwqaqceq3XhafmCiw8xrtzCnlB/C4SiBr/93Ip4kihXJ0EuHSLn
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <1ae522f1-1e98-9eef-324c-29585fe574d6@redhat.com>
Date: Wed, 13 Mar 2019 07:54:26 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="iHa4rglTlXOsn1mpauERKuWjGcGGQtF1D"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 13 Mar 2019 11:54:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iHa4rglTlXOsn1mpauERKuWjGcGGQtF1D
Content-Type: multipart/mixed; boundary="KSQ9FEIrt46Kzcap3MtQpnkVZGofCC5QT";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <1ae522f1-1e98-9eef-324c-29585fe574d6@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
 <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
 <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
 <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
In-Reply-To: <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>

--KSQ9FEIrt46Kzcap3MtQpnkVZGofCC5QT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/12/19 5:13 PM, Alexander Duyck wrote:
> On Tue, Mar 12, 2019 at 12:46 PM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>> On 3/8/19 4:39 PM, Alexander Duyck wrote:
>>> On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com=
> wrote:
>>>> On 3/8/19 2:25 PM, Alexander Duyck wrote:
>>>>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.c=
om> wrote:
>>>>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
>>>>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com=
> wrote:
>>>>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:=

>>>>>>>>> The only other thing I still want to try and see if I can do is=
 to add
>>>>>>>>> a jiffies value to the page private data in the case of the bud=
dy
>>>>>>>>> pages.
>>>>>>>> Actually there's one extra thing I think we should do, and that =
is make
>>>>>>>> sure we do not leave less than X% off the free memory at a time.=

>>>>>>>> This way chances of triggering an OOM are lower.
>>>>>>> If nothing else we could probably look at doing a watermark of so=
me
>>>>>>> sort so we have to have X amount of memory free but not hinted be=
fore
>>>>>>> we will start providing the hints. It would just be a matter of
>>>>>>> tracking how much memory we have hinted on versus the amount of m=
emory
>>>>>>> that has been pulled from that pool.
>>>>>> This is to avoid false OOM in the guest?
>>>>> Partially, though it would still be possible. Basically it would ju=
st
>>>>> be a way of determining when we have hinted "enough". Basically it
>>>>> doesn't do us much good to be hinting on free memory if the guest i=
s
>>>>> already constrained and just going to reallocate the memory shortly=

>>>>> after we hinted on it. The idea is with a watermark we can avoid
>>>>> hinting until we start having pages that are actually going to stay=

>>>>> free for a while.
>>>>>
>>>>>>>  It is another reason why we
>>>>>>> probably want a bit in the buddy pages somewhere to indicate if a=
 page
>>>>>>> has been hinted or not as we can then use that to determine if we=
 have
>>>>>>> to account for it in the statistics.
>>>>>> The one benefit which I can see of having an explicit bit is that =
it
>>>>>> will help us to have a single hook away from the hot path within b=
uddy
>>>>>> merging code (just like your arch_merge_page) and still avoid dupl=
icate
>>>>>> hints while releasing pages.
>>>>>>
>>>>>> I still have to check PG_idle and PG_young which you mentioned but=
 I
>>>>>> don't think we can reuse any existing bits.
>>>>> Those are bits that are already there for 64b. I think those exist =
in
>>>>> the page extension for 32b systems. If I am not mistaken they are o=
nly
>>>>> used in VMA mapped memory. What I was getting at is that those are =
the
>>>>> bits we could think about reusing.
>>>>>
>>>>>> If we really want to have something like a watermark, then can't w=
e use
>>>>>> zone->free_pages before isolating to see how many free pages are t=
here
>>>>>> and put a threshold on it? (__isolate_free_page() does a similar t=
hing
>>>>>> but it does that on per request basis).
>>>>> Right. That is only part of it though since that tells you how many=

>>>>> free pages are there. But how many of those free pages are hinted?
>>>>> That is the part we would need to track separately and then then
>>>>> compare to free_pages to determine if we need to start hinting on m=
ore
>>>>> memory or not.
>>>> Only pages which are isolated will be hinted, and once a page is
>>>> isolated it will not be counted in the zone free pages.
>>>> Feel free to correct me if I am wrong.
>>> You are correct up to here. When we isolate the page it isn't counted=

>>> against the free pages. However after we complete the hint we end up
>>> taking it out of isolation and returning it to the "free" state, so i=
t
>>> will be counted against the free pages.
>>>
>>>> If I am understanding it correctly you only want to hint the idle pa=
ges,
>>>> is that right?
>>> Getting back to the ideas from our earlier discussion, we had 3 stage=
s
>>> for things. Free but not hinted, isolated due to hinting, and free an=
d
>>> hinted. So what we would need to do is identify the size of the first=

>>> pool that is free and not hinted by knowing the total number of free
>>> pages, and then subtract the size of the pages that are hinted and
>>> still free.
>> To summarize, for now, I think it makes sense to stick with the curren=
t
>> approach as this way we can avoid any locking in the allocation path a=
nd
>> reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.
> I'm not sure what you are talking about by "avoid any locking in the
> allocation path". Are you talking about the spin on idle bit, if so
> then yes.=20
Yeap!
> However I have been testing your patches and I was correct
> in the assumption that you forgot to handle the zone lock when you
> were freeing __free_one_page.
Yes, these are the steps other than the comments you provided in the
code. (One of them is to fix release_buddy_page())
>  I just did a quick copy/paste from your
> zone lock handling from the guest_free_page_hinting function into the
> release_buddy_pages function and then I was able to enable multiple
> CPUs without any issues.
>
>> For the next step other than the comments received in the code and wha=
t
>> I mentioned in the cover email, I would like to do the following:
>> 1. Explore the watermark idea suggested by Alex and bring down memhog
>> execution time if possible.
> So there are a few things that are hurting us on the memhog test:
> 1. The current QEMU patch is only madvising 4K pages at a time, this
> is disabling THP and hurts the test.
Makes sense, thanks for pointing this out.
>
> 2. The fact that we madvise the pages away makes it so that we have to
> fault the page back in in order to use it for the memhog test. In
> order to avoid that penalty we may want to see if we can introduce
> some sort of "timeout" on the pages so that we are only hinting away
> old pages that have not been used for some period of time.

Possibly using MADVISE_FREE should also help in this, I will try this as
well.

If we could come up with something bit which we could reuse then we may
be able to=C2=A0 tackle this issue easily. I will look into this.

>
> 3. Currently we are still doing a large amount of processing in the
> page free path. Ideally we should look at getting away from trying to
> do so much per-cpu work and instead just have some small tasks that
> put the data needed in the page, and then have a separate thread
> walking the free_list checking that data, isolating the pages, hinting
> them, and then returning them back to the free_list.
I will probably defer this analysis for now, once we have other things
fixed. I can possibly evaluate/compare the performance impact with both
the approach and chose from them.
>
>> 2. Benchmark hinting v/s non-hinting more extensively.
>> Let me know if you have any specific suggestions in terms of the tools=
 I
>> can run to do the same. (I am planning to run atleast netperf, hackben=
ch
>> and stress for this).
> So I have been running the memhog 32g test and the will-it-scale
> page_fault1 test as my primary two tests for this so far.
>
> What I have seen so far has been pretty promising. I had to do some
> build fixes, fixes to QEMU to hint on the full size page instead of 4K
> page, and fixes for locking so this isn't exactly your original patch
> set, but with all that I am seeing data comparable to the original
> patch set I had.
>
> For memhog 32g I am seeing performance similar to a VM that was fresh
> booted. I make that the comparison because you will have to take page
> faults on a fresh boot as you access additional memory. However after
> the first run of the runtime drops  from 22s to 20s without the
> hinting enabled.
>
> The big one that probably still needs some work will be the multi-cpu
> scaling. With the per-cpu locking for the zone lock to pull pages out,
> and put them back in the free list I am seeing what looks like about a
> 10% drop in the page_fault1 test. Here are the results as I have seen
> so far on a 16 cpu 32G VM:
>
> -- baseline --
> ./runtest.py page_fault1
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,522242,93.73,514965,93.74,522242
> 2,929433,87.48,857280,87.50,1044484
> 3,1360651,81.25,1214224,81.48,1566726
> 4,1693709,75.01,1437156,76.33,2088968
> 5,2062392,68.77,1743294,70.78,2611210
> 6,2271363,62.54,1787238,66.75,3133452
> 7,2564479,56.33,1924684,61.77,3655694
> 8,2699897,50.09,2205783,54.28,4177936
> 9,2931697,43.85,2135788,50.20,4700178
> 10,2939384,37.63,2258725,45.04,5222420
> 11,3039010,31.41,2209401,41.04,5744662
> 12,3022976,25.19,2177655,35.68,6266904
> 13,3015683,18.98,2123546,31.73,6789146
> 14,2921798,12.77,2160489,27.30,7311388
> 15,2846758,6.51,1815036,17.40,7833630
> 16,2703146,0.36,2121018,18.21,8355872
>
> -- modified rh patchset --
> ./runtest.py page_fault1
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,527216,93.72,517459,93.70,527216
> 2,911239,87.48,843278,87.51,1054432
> 3,1295059,81.22,1193523,81.61,1581648
> 4,1649332,75.02,1439403,76.17,2108864
> 5,1985780,68.81,1745556,70.44,2636080
> 6,2174751,62.56,1769433,66.84,3163296
> 7,2433273,56.33,2121777,58.46,3690512
> 8,2537356,50.17,1901743,57.23,4217728
> 9,2737689,43.87,1859179,54.17,4744944
> 10,2718474,37.65,2188891,43.69,5272160
> 11,2743381,31.47,2205112,38.00,5799376
> 12,2738717,25.26,2117281,38.09,6326592
> 13,2643648,19.06,1887956,35.31,6853808
> 14,2598001,12.92,1916544,27.87,7381024
> 15,2498325,6.70,1992580,26.10,7908240
> 16,2424587,0.45,2137742,21.37,8435456
>
> As we discussed earlier, it would probably be good to focus on only
> pulling something like 4 to 8 (MAX_ORDER - 1) pages per round of
> hinting.=20
I agree that I should bring down the page-set on which I am working.
> You might also look at only working one zone at a time. Then
> what you could do is look at placing the pages you have already hinted
> on at the tail end of the free_list and pull a new set of pages out to
> hint on.
I think for this we still need a way to check if a particular page is
hinted or not.
>  You could do this all in one shot while holding the zone
> lock.
--=20
Regards
Nitesh


--KSQ9FEIrt46Kzcap3MtQpnkVZGofCC5QT--

--iHa4rglTlXOsn1mpauERKuWjGcGGQtF1D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyI73IACgkQo4ZA3AYy
oznWRA//QZWj0knV38rUztpCKEazF2dO2NzO9Ar7PqGwlEIJNYcuqWlsQreMl4x6
eu+KBI5owbr7Xc+Apq+IacZCon8RsFilS0iMunsYwzpxNLG1Uh24IeJeDDKu1UjH
sqZt573Gf4eM8tLBNt7zC+F0ndYeZS/vyGDbFQgXDoxnne7ebkI/M69iFBxeJVp3
YIJDFDRdPkMVGIX2PFm+gGoSwmsHWxhObR6l58ltfUB6e5asdg9il+HtSJo+eUpd
wMFWpeySlnGepHisJ2d+PI5HUOSbHqzFq5XKLfNi8K3TeKza6v5j65wjDmqg3sdv
rCxQsbV2NtB7sYKj3uNROGx0FpK/H/S6dyb/9HvqIPZheUivNyRqFxsU8a0bdN9G
mxbdVHMpu67xncUvNkk6UXtNhAQmsz/ltn5bKrBDcrpAjST7ANy2AsTpQ3/8gmjJ
VdS1RY0TOl+d2j8rowu52jVdcguj0LH2AB6fssH0+0hgnj3yl4Z3bxa8aGs4p1BG
AEuUd966tvn+xwkQ9TGL9OYVY9vJnA4KAXwWaRnk15ulxgh0aplem2gXqPS1ErM5
+K8HkdILIGPXjY7+/8SjJJFAq9ohfbhus8Vmv3drz33v97SM7nXvAT12/9iyQhP2
BM33/CRUaarrULvKJ/I1lT5K8iPmX5QmiRT+ckur6lBZTN0dJJA=
=9bI5
-----END PGP SIGNATURE-----

--iHa4rglTlXOsn1mpauERKuWjGcGGQtF1D--

