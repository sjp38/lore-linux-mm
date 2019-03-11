Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CEEFC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:22:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13D5720643
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:22:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="azdQUsM/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13D5720643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02F18E0003; Mon, 11 Mar 2019 13:22:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2498E0002; Mon, 11 Mar 2019 13:22:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0608E0003; Mon, 11 Mar 2019 13:22:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61F6E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:22:56 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id n84so2686152oia.14
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:22:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TaodPRznnxHlduVShz3LecPQThljONoPOZSJMsdUCpg=;
        b=MaY5Bbz/ULHbD0almtr42rALzQqtiwCtFktyu2321mfayrFf1CS6egxmS5wREskZwv
         YEBaHFNnE80uO6g3Sx8JQj2r+/8wDbp/r0KhpfDjGQAhCn7tXUhWqkUcZs7XjYXZTnhi
         xf+SWnntnAdyPdvm/2ZDFKTyJdZbiNrfo7EwPYpagz/iFEqOdyAZhmMP3T7hb7UNQErh
         bhmebZqRO/ra+RoqeoB0TuKQigmlfa1jrTS5ROCZoVz5X4cls5tMIVG9nZ+xpdY6CkLY
         HzHY+UGXIFkeHpigxDIr0q7vXjdD0AyH0aNVpah/l5csFSNH8Pi08m6qFD7zJ1rl8m+d
         iQJQ==
X-Gm-Message-State: APjAAAXBl0nCYY6tOOTitU3L4IluV6N/SdI+ivr+mVOQGRRsDQ5S5yXw
	auNlyy4/0N0hWtX4FXsVG7uovAnqmn8848/x5jGy2tKUXYsj+zRTtwzUgFnP/5eTDfbrw1ogzSG
	TPqlxUBJ0W1m6RDZrLQITY9h6XAgVaX3PG9a3d9dUXjYHKpqr1yQ4gZ7lEfqhNb4iqKbqr7xcsi
	QceqgDa7igP32Tw3/tnxkGdEan20w7+LnRdwVExak3Qqmn2omHw+ygiNkg5RTrCpV7kYtG507K8
	mA80+Bv6hH80jHH3X0EIUhWfMeQ9EyI5HVEBNhRJSgVdpq+32/jxZZxw3ePEeMqLxzjubMWXlAD
	psMd5lOxCN0dSWAVIrkdRJeIVp0at+urPQrYEis+twvg44Q4BjYYs6QiRt6JSnNCvhGUTyJ5uf+
	g
X-Received: by 2002:aca:be02:: with SMTP id o2mr107750oif.48.1552324976020;
        Mon, 11 Mar 2019 10:22:56 -0700 (PDT)
X-Received: by 2002:aca:be02:: with SMTP id o2mr107717oif.48.1552324975273;
        Mon, 11 Mar 2019 10:22:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552324975; cv=none;
        d=google.com; s=arc-20160816;
        b=YLCllhaDMJ8onYyXQ2rw0fP/7ZAG7/BnbGPm9gaF27nGDbDFfdOGMuTJiuLnNSm9Ou
         OETzY91YPrmS0ukY1/67uv+PRDny1VYovM13Unx7NGgRup8a2ox/FkZMJrkc6FQ4nXnf
         XsaHX6x9zGAwNVWE3vYJdu6qNGbXx5bZ28qlGt9TaD1gqOLnuk4rB7y1mqmzsd2wgFuI
         u1+1UiEFuDmT5UyaEUN3PrwV99rVuTqJ8P95OyFUvgYenSLeMbIEgttx7vKdQ0l0+2dU
         2RDU6+eL71VQtXW4nlWvnIDeqSFydJ0FGEcoi5ppM0A+D582VLSHhHpNdI5vIVywBsMj
         SFzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TaodPRznnxHlduVShz3LecPQThljONoPOZSJMsdUCpg=;
        b=eztoAgBNNakudr63p0cjXEkMFaV9nbBlBvpCQkhXZwbs5OioB+1fjQxZslLiIMkXlG
         gNlKt/a9gSnnXq6ZT9M+pPs8xMY8QG3aPCsaDBglsrIJ2W94XS2bYx9IxczVztBQ22HH
         jjqdl4k+u14J0CmeWEwRuKmcxNzTOTQh8Zc6ZfMieLjyf1J4YIuLDdG6r9Mmk5WUK63i
         4SpQy5Js4ji63dOOK9y8D+V9hitpV5SIiHcFTZlFYFrxiiUaUmyPTh93MouYIMldV04Q
         9OTqTM/s/aaMiwLK/eXbGYplpLcUNM3A+YPfDbjVdoGifZbYa7zOa4IpBYdCLkRWMWFn
         n5pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="azdQUsM/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r129sor2831618oib.63.2019.03.11.10.22.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:22:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="azdQUsM/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TaodPRznnxHlduVShz3LecPQThljONoPOZSJMsdUCpg=;
        b=azdQUsM/SypcV+oYswjIzz5U++w9bggPcPOQziGhnRwC2MkwvRCbj4BJx1bE5Fkvym
         VGmV3kcEUPqzBb4f34vQyN3zdinDWsvddb2fltf5Bjuo9jUbjdO7NXlfw7kZPFQaPX88
         sP2ZF4peBkMWE+wxuYZ5Gcmr/xL9qPdqi2PMa1VqRIDC0kH4xq8AelmFEoh5Egj7xX1Y
         /znqyM1Y81ZklYCJTQDjTYIKwDzJamz7RaKuy2ZkCKjmLXVMRpBQyLyK1HUKSzurtKFH
         l4z6SpEuXV9BpPkOe/rWZpcQV2Caq8wdCVuN8OARXNqUHmsokBie2aiwCArEGkOxVo8h
         Ekog==
X-Google-Smtp-Source: APXvYqwfcPglvoE0gZcJoFACAbWWF83LdOo333KRz4SseKLOiRceInLOv7/t+V9tiynQMMYeB9eZGc8gJkn6Gf+YIxg=
X-Received: by 2002:aca:cc0f:: with SMTP id c15mr83337oig.105.1552324974952;
 Mon, 11 Mar 2019 10:22:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190311084537.16029-1-jack@suse.cz>
In-Reply-To: <20190311084537.16029-1-jack@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Mar 2019 10:22:44 -0700
Message-ID: <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Chandan Rajendra <chandan@linux.ibm.com>, 
	stable <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
>
> Aneesh has reported that PPC triggers the following warning when
> excercising DAX code:
>
> [c00000000007610c] set_pte_at+0x3c/0x190
> LR [c000000000378628] insert_pfn+0x208/0x280
> Call Trace:
> [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
>
> Now that is WARN_ON in set_pte_at which is
>
>         VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
>
> The problem is that on some architectures set_pte_at() cannot cope with
> a situation where there is already some (different) valid entry present.
>
> Use ptep_set_access_flags() instead to modify the pfn which is built to
> deal with modifying existing PTE.
>
> CC: stable@vger.kernel.org
> Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Dan Williams <dan.j.williams@intel.com>

Andrew, can you pick this up?

