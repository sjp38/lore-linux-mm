Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7891C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94F2A20880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94F2A20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 372676B0005; Mon,  1 Apr 2019 10:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 315056B0008; Mon,  1 Apr 2019 10:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F496B000A; Mon,  1 Apr 2019 10:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E58E96B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 10:55:01 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 75so8736778qki.13
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 07:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=kVphtkbLPZKk9Vp9xPikaH/1wF8HQ1Bm6YLGIoJrgGQ=;
        b=WRHV90mWbhP62dAjFexG66sPS4GHPQ+AOU3D+OCvj8V7jTtUFW5yqdkO+tdRSLAELg
         AafEfHnngmCBww6ROn3zh/bpw4D5rHELjiEj9UDGk4VAz/WYPttLtHicxmje9C4fA0fA
         qfdHw5CYU5LlKtKhgTGgMU952tesRhezinICi72dxjVOZ9+iWKmPE1Ycw+6h4Yn7vssh
         nYtziXXxLBgrWQM/c7Hhh3H/eikjtofH+cmdmgZA8odzqcOJVKHx+T13Eb8SxdloqRz6
         1K+lVevG0Cedir8ZHYpL6/KKbB63x5AuKC6h6O6YT03gsTrjI2kjGVg7qxQrpg2t40Pb
         kKfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+qo/O4G8r2q/rzFFei+QxkK8sY5mZDHLZEOUA/uhtUK/KX564
	OoOclifwGIjvJlINYKw8IS3AGfI+QKaP21r69SUAVZwZhFzBh0v8NEC0JCNrcEn+6YE2+DzUDZo
	mppkj4Zq9o/f/RqriBwYPgh4hYb7WiX65NAJaVOMH56V/wpOssYG+nI4EmONUvXcVtQ==
X-Received: by 2002:a37:5088:: with SMTP id e130mr26653465qkb.206.1554130501727;
        Mon, 01 Apr 2019 07:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqLLu1TAYw2UCxY/deCSVSF05mxpNxYzlQz40GBjv4ro/LsEPz0rNtzklgB9i4W8HjPaTo
X-Received: by 2002:a37:5088:: with SMTP id e130mr26653439qkb.206.1554130501233;
        Mon, 01 Apr 2019 07:55:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554130501; cv=none;
        d=google.com; s=arc-20160816;
        b=fJzGwIZSCRKMug+KFEKujE4aiLA8Z0kSzmxHmfW28fFBf0rwFGMlRIdryfiGYUl+I/
         q6G0PST8vPGZGZJ9bbbwS0akdOE9No4ma6RX07BI+q2OhrUqJVTsIoAKk87vE9KwrReM
         biUTcnDjRO4FGEp4y0xOODb0zrm+LDMCIMt0nrm7azawFd4614ymGwAV3Q7ioki7Yi8H
         E3DwGkqFBA5DTaM18OzAmpZnt1kjJP/dMc3XGVjqVXtSoWYpHlnyQ4GNGTLJdwqOlJHv
         Zd7Ntmv7MMYmZXQvaqt8hloSNnvfItJ2vyZ0EytDqbVqdYpJFSzTRKd++VGSiTJY+oo+
         /xWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=kVphtkbLPZKk9Vp9xPikaH/1wF8HQ1Bm6YLGIoJrgGQ=;
        b=GhQ7oUtv/olWw4kIhmv3VsjQVzlQNOuZkDE95wXHG9RYyGAqLllcMODTkNanJZHg4Z
         uM1u/Mom9Q11d9Y0K1MBBfdA38zka3bkh6aU0atCBVmNX/PNGytH8Anq5SyzweTcibuJ
         TEAwGA3JUhNPxZ/7qszxaBnqPePkSytLkB09L+DGp+KEOAuK2mXd/WhTmDysWnA6PtiN
         Nb7gvcB2A90yfq7lJGloK+4/rHDzjjkg0EruJ3Ha9FWhGT56KZKQrWQHcgCeaobIE/gu
         oGhV2lcFlwGcuFSb2WTF/WCKNRQm+pnHXrg4Cv8UoC97Byzbmp/QwczJHl4RjVeUDwqW
         z9wA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p29si236906qta.404.2019.04.01.07.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 07:55:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63B443091784;
	Mon,  1 Apr 2019 14:55:00 +0000 (UTC)
Received: from [10.36.118.81] (unknown [10.36.118.81])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A5E035ED37;
	Mon,  1 Apr 2019 14:54:50 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5c64d235-a17d-b832-5cea-9e2a991823d2@redhat.com>
Date: Mon, 1 Apr 2019 16:54:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190401104608-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 01 Apr 2019 14:55:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.04.19 16:47, Michael S. Tsirkin wrote:
> On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
>>> The interesting thing is most probably: Will the hinting size usually be
>>> reasonable small? At least I guess a guest with 4TB of RAM will not
>>> suddenly get a hinting size of hundreds of GB. Most probably also only
>>> something in the range of 1GB. But this is an interesting question to
>>> look into.
>>>
>>> Also, if the admin does not care about performance implications when
>>> already close to hinting, no need to add the additional 1Gb to the ram size.
>>
>> "close to OOM" is what I meant.
> 
> Problem is, host admin is the one adding memory. Guest admin is
> the one that knows about performance.

If we think about guest admins only caring about performance, then a
guest admin owill unloads virtio-balloon module to

a) get all the memory available (inflated memory returned to the guest)
b) not use hinting :)

But I get your idea. One side wants hinting, other side has to agree.

-- 

Thanks,

David / dhildenb

