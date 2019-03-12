Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0261C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:23:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E88E206DF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:23:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E88E206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E4D8E0003; Tue, 12 Mar 2019 13:23:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3D448E0002; Tue, 12 Mar 2019 13:23:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2C208E0003; Tue, 12 Mar 2019 13:23:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7BFA8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:23:49 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x63so2811433qka.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:23:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=S2eCQorkbFr/xsa+0ccviuaWvzVqnL7p3ewxXohcNDg=;
        b=fVNwiOjSVQhQR5N6LkF2r9lElJRLdf51qS/uN/P8iK+69X/xY1yt5Y6fBye1GxDAcq
         NOVxnJXUo/0UOZx+oydeO+jLVYvfUs2/oZz3yAFb+ixEzid7yEj7OaOWMix9dbtMAm5i
         ZEieBbJY8iy1c3x1OAhmrlOTcbVVYDhqWpKtTpwNHzcifniYsx6VcHHTXdD0x85RLm7x
         lneyspFr1a3HzXwX8zLSTV40oJVBMN4tIzyBvlqtEU3wxmNlI2hFHTqWb6SpcKmlm83w
         Pra5b77MOxCmH31O4Po/ii6TeVOZcDFJFlLHB+R8DZJ/WkYTlvVhmIzvy6VdqfH/C+Zs
         qRJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0Iw6a/kA10YV6n+Sc1gvGI+3pndmaRfczH28l1Qey0jQNNbQq
	a4qFz0/if9m35O8ZanYeuyzg5deXyb0lyl/XJpb0NAvATGPWCUbqc/PE83W2eUUzcR1W9lZZn/5
	rO61I3y5AsvGPlq/qOOZARh6z8q+bghtwN3+GgsP7yZKldrM+30P6oNjl7l2zce7GmA==
X-Received: by 2002:a0c:cd8f:: with SMTP id v15mr8414295qvm.144.1552411429452;
        Tue, 12 Mar 2019 10:23:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3tLUG+Ddu8qC93V0zlDT9608HaK8R1SG+uKFDvO33UZcWsOZ1TVJ4zb1X5qu7m7XsFSw5
X-Received: by 2002:a0c:cd8f:: with SMTP id v15mr8414259qvm.144.1552411428796;
        Tue, 12 Mar 2019 10:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552411428; cv=none;
        d=google.com; s=arc-20160816;
        b=dOERJ/yDVPZOzLVav43JMBq2mO8T6sJzj3LLSbD+rFz+oNCZeBO99XLOkFsgFzFnGN
         3keuE/m1jY+wIxt30moOL/WUdn+s1JSw2gXZX/JmoTNvzm4UrVFM4z8+mrVkp59UGSOL
         yF3nxJNw1IoM81c9KePBIJUyhHZP3BHRHynMZ9whIfcLj0PaThw6HHFvt/I5xQAltTQk
         axE/tqL5DeqMVZUtMlPwNV3KH8vIgtKCRLmVcLdq9lPRM2AIK3IUDKJuMCDpD3YbHMxn
         671p40quvCr7IFoVV77L7sAeyxa8NK1em7Q3884J2Ja/rXkO8rMTrIm1+iiroiQG/jk9
         7Kgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=S2eCQorkbFr/xsa+0ccviuaWvzVqnL7p3ewxXohcNDg=;
        b=D/esSc+eJppZgh9umAin/4XOU7x6GHnvz0i6yeXATz0s8yzMPijoEsKVH3DCpZ84KZ
         082i2KT76AznjRiw5efKXsj8duheZPKaOI54vN07E9nx5Dt5hs2M9j76OnMXd/P4rMEJ
         aXsBf2FQjedg+zTxmI7T0yj4TOpZLB7kUvCuDgot8Y1tv3Kri6YFBeX5ij/LM92ILhne
         i+ujydovk09dPb4juWbbkg7SshEUewbS79cUBIqiXLQ2V6ahpDXkodJhun/9nq2R17HI
         KZsfnuSCu+RfNIr90a9p9e5DHnapOqtIAP5LWaKNVxPCrhp+r8okF3SPdpeBDJvmgPjq
         T69Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w21si458600qtn.233.2019.03.12.10.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 10:23:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 77D2E30F10B8;
	Tue, 12 Mar 2019 17:23:47 +0000 (UTC)
Received: from [10.36.117.44] (ovpn-117-44.ams2.redhat.com [10.36.117.44])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4452B1001E63;
	Tue, 12 Mar 2019 17:23:44 +0000 (UTC)
Subject: Re: xen: Can't insert balloon page into VM userspace (WAS Re:
 [Xen-devel] [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Matthew Wilcox <willy@infradead.org>, Julien Grall <julien.grall@arm.com>
Cc: osstest service owner <osstest-admin@xenproject.org>,
 xen-devel@lists.xenproject.org, Juergen Gross <jgross@suse.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Stefano Stabellini <sstabellini@kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>, k.khlebnikov@samsung.com,
 Julien Freche <jfreche@vmware.com>, Nadav Amit <namit@vmware.com>,
 "VMware, Inc." <pv-drivers@vmware.com>, linux-mm@kvack.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <28a72642-d0db-214c-2bf2-d1a6c6e03d92@redhat.com>
Date: Tue, 12 Mar 2019 18:23:43 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190312171421.GJ19508@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 12 Mar 2019 17:23:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.03.19 18:14, Matthew Wilcox wrote:
> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>> It looks like all the arm test for linus [1] and next [2] tree
>>> are now failing. x86 seems to be mostly ok.
>>>
>>> The bisector fingered the following commit:
>>>
>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>> Author: Matthew Wilcox <willy@infradead.org>
>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>
>>>      mm/memory.c: prevent mapping typed pages to userspace
>>>      Pages which use page_type must never be mapped to userspace as it would
>>>      destroy their page type.  Add an explicit check for this instead of
>>>      assuming that kernel drivers always get this right.
> 
> Oh good, it found a real problem.
> 
>> It turns out the problem is because the balloon driver will call
>> __SetPageOffline() on allocated page. Therefore the page has a type and
>> vm_insert_pages will deny the insertion.
>>
>> My knowledge is quite limited in this area. So I am not sure how we can
>> solve the problem.
>>
>> I would appreciate if someone could provide input of to fix the mapping.
> 
> I don't know the balloon driver, so I don't know why it was doing this,
> but what it was doing was Wrong and has been since 2014 with:

Just to clarify on that point, XEN balloon does not use balloon
compaction as far as I know (only virtio-balloon and as far as I know
now also vmware balloon). Both of them don't map any such pages to user
space, so it never was and isn't a problem.

> 
> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Date:   Thu Oct 9 15:29:27 2014 -0700
> 
>     mm/balloon_compaction: redesign ballooned pages management
> 
> If ballooned pages are supposed to be mapped into userspace, you can't mark
> them as ballooned pages using the mapcount field.
> 


-- 

Thanks,

David / dhildenb

