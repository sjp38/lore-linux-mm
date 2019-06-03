Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBE0CC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:56:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3DED27A3F
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:56:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3DED27A3F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2319D6B0008; Mon,  3 Jun 2019 10:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E32D6B000A; Mon,  3 Jun 2019 10:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D1D56B000C; Mon,  3 Jun 2019 10:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFC76B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:56:40 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so2615691ljj.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:56:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=u804m70+Vd+AX4Xnhw6E92rP9KDkFvsEVMb/kcLJ4X0=;
        b=B2v3xiMDzkjh+h09cKGk+mq91uQ3Njl244yjHnteVBpTMgkuN25YXyC3m2vP7Y2nrD
         97kV1mom6jxBQWZXz+QAWzBSVaq2Bm/rB0X3AKK2b2DoK1pcyv3xl35mceVQLhRTKLYY
         jHxsclOjEjm7pMRHsIdej+n4pXT7wGKUZjmGa/F0+z7N86rYKaZEtgt+s07fSZrcEUGR
         iUDLoCpkZDgrdzCIKRyJDkVQSKpVj2WbOecNGe+nMqKI2OZ4EcLIaYj9gO0ppyGcAA+v
         IR7lEahNKaA2CUczbXJTILE2JV0arINfMUyxeQtbjUV+/SgOHb1YaQzvF/c7etTio4ag
         dMig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWvSSkLdlA0kzaSwdVXTbfFKXJ/QN/blkM4VH8s1XTGKlpXFxCE
	WUNlIOwHwCBwTok2VIJyyDc7164P57xxLo9U8IrQRwVrL2I7TaoouX/36EjTI9VWu/akIqEchKc
	0VzRVEm+Sig3PiEKtqlIzdGNxbAnZjLr+vBhNp5Cg64QQFP2zwUuE+36h05rgudGmWg==
X-Received: by 2002:a2e:834f:: with SMTP id l15mr10175727ljh.56.1559573800110;
        Mon, 03 Jun 2019 07:56:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylF7wStAHPTVmXBiTLm9bHbGirhmkYCnIcEFMEj1r7brUCSMgd+p8tVsWYLPzFWN+KgUJq
X-Received: by 2002:a2e:834f:: with SMTP id l15mr10175680ljh.56.1559573799237;
        Mon, 03 Jun 2019 07:56:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559573799; cv=none;
        d=google.com; s=arc-20160816;
        b=E/ynKlcLYOXmCyWGkJVpLK4WRrA58bgvs4Qz+UJXlOtfg1FH9ty5Rpkd76ireTUz4I
         ckvqhpbcUO/MstqJ/o6n4Bl+lfx7Xh9Pbt+xNeVZuHzjZzBldSQpT762QRUudI2pjlc5
         jKjk/JINOpG5t+gEYfh3B9X0/g/N30SLVvn+QEM7a6v/hSHndG0wMpMCtZYDJRB/8XJi
         XaF7vHX/N/IAT/FgcEvwhpu1dKe8+gc9+QD7HsnvwbRUcBfXgedGJrDVs3t3uMs27WIN
         GrbzObAuqg6fkVFfMuhwYhL81q88uipSBa4pcvxtVqnZWei4HlcuqaDuaOLXKS5XseJo
         HUMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=u804m70+Vd+AX4Xnhw6E92rP9KDkFvsEVMb/kcLJ4X0=;
        b=Ccn0vbelFksPeS+IUL7eByDnG9Zq6yYEUcGFWOA1bcqT9hdgxK1HuVQbRcNeVkz9Y6
         KE+Muy5MP2qF+beeJ71SXmSH+MCJUalVtGeGM2t/pO2qQo0WT2mXOo9w6NC6yj5VB5i2
         bUminneKlyr0zWojxe44GSO9OpCYHCUMm3JcNguXoWqRs+YmZRpadPstPkjDOdsN5rgh
         yZ2JtwDKNEeMInhq4O9d47LL+LHR5mpFs3Oo8mGhBhSkk24KtlvkwKz49MdRBlN/W3FB
         aTbOJyRIe3styBq1bTP8cOBBTlite3G8tEGJ56XVaZ0fBbP2oVUstgWlVy9fKznYIf4H
         6Mnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f12si13292308ljg.158.2019.06.03.07.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:56:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hXoO0-0004bx-Na; Mon, 03 Jun 2019 17:56:32 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
 <4228b541-d31c-b76a-2570-1924df0d4724@virtuozzo.com>
Message-ID: <5ae7e3c1-3875-ea1e-54b3-ac3c493a11f0@virtuozzo.com>
Date: Mon, 3 Jun 2019 17:56:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <4228b541-d31c-b76a-2570-1924df0d4724@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.06.2019 17:38, Kirill Tkhai wrote:
> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
>> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>>> This patchset adds a new syscall, which makes possible
>>> to clone a VMA from a process to current process.
>>> The syscall supplements the functionality provided
>>> by process_vm_writev() and process_vm_readv() syscalls,
>>> and it may be useful in many situation.
>>
>> Kirill, could you explain how the change affects rmap and how it is safe.
>>
>> My concern is that the patchset allows to map the same page multiple times
>> within one process or even map page allocated by child to the parrent.
> 
> Speaking honestly, we already support this model, since ZERO_PAGE() may
> be mapped multiply times in any number of mappings.

Picking of huge_zero_page and mremapping its VMA to unaligned address also gives
the case, when the same huge page is mapped as huge page and as set of ordinary
pages in the same process.

Summing up two above cases, is there really a fundamental problem with
the functionality the patch set introduces? It looks like we already have
these cases in stable kernel supported.

Thanks,
Kirill

