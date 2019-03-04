Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB602C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 07:15:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92DDB20863
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 07:15:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92DDB20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE508E0003; Mon,  4 Mar 2019 02:15:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16CDD8E0001; Mon,  4 Mar 2019 02:15:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05D238E0003; Mon,  4 Mar 2019 02:15:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6D248E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 02:15:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a9so2217343edy.13
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 23:15:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=UIqKjVw6zXIlgp+pCnBsV3pcfmamnx1f6tQPJUXWIdo=;
        b=GQnkJjUpkwXLMYOw9UAR6m5n0lgGm7f0KoRpfkQpKx9GAFc+fjAyrmiMZZv00fo68/
         BRg9V/z9W4edC48RWFcgVfhtrvTHi24mTF3SlKJdVJIckaTWyr04jpoBhQ5RiTn3v8fL
         0Cv0Llf3S3koV8oKrDO5c5WoV3YEtvfiRlKjgzbWXUUevnBsUf0flZTSbjsiTGu4ufnS
         4oWU3TkwHi1yujsGwEbVHJcQ8p4K6ktNhLrzlY5ClJBBAZ3DPCV22pKTWdJ8gEtkZ6dP
         LTfir+wHRsiSt6yyNbf6B/v2Ks29nyMg5Zkv431NBsrahcjJFcMiGywcqp54sMNvNWY3
         uCBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAWtj6gIWmhaozuQZe9+odP4oooto1FUxsRfztZq/C5gs1KR8kmb
	DIXsEu2jTlbu55Q8mZbJHvWqFvhl7RUh0um6u0O7ITO9+sWH+yBX3K+rykeP4X0A3PtPNQRljaF
	KSvbnBRD4ip9kl4WfBDLHVfekfyms2jyKOmf+srHmuyN62rNIELYvjFN/03Zw78eg3A==
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr11519615ejk.177.1551683706253;
        Sun, 03 Mar 2019 23:15:06 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsQy4jSNZEG8ycLUHuf6e30YBgnZMhHHKAMLbsQLhiSe5xbnUETQ0a7bfMJ4EAijiu1NYp
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr11519570ejk.177.1551683705383;
        Sun, 03 Mar 2019 23:15:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551683705; cv=none;
        d=google.com; s=arc-20160816;
        b=vCA8JVuItfnYjhvcF50g1fU4TJNUm8+4vcB6xbdYGjX5mxEvZDYYMeMJXnL7tMqA+v
         xOtRXSfvUcEk7SJwwEL0BPXhi6gk7ZlmT+Yhp8PqEN7q1pqBnlepvwYbJlAb8RH6IYFV
         tiny/ARZLGzqDWlizz0Mj41p3bCWlAhngGPwG6Rh/fJym4AH9JF61/S4yft+OLXpzEIq
         lKpJoVyQdeiecWjWwncvchEAGuIUMLcUmBuYCRX+EjRfYtZtjAChUbGmMxvRCe54wvr0
         L5jxn5Cbo8WL6WaroDsKYc5Qkzd2ykxY8v96tvKuG8uj4OeOjeJbt5l7OndYkinz/sdl
         KvFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=UIqKjVw6zXIlgp+pCnBsV3pcfmamnx1f6tQPJUXWIdo=;
        b=UnoY4tAPWKIgmrIrnpnIXs3SrC/J/RAGVZkpudUzJ8eMQryB4rR5PNnEXQ/vxP81uy
         qS4Y1WrGIlXekOFuFqmZLxuWUA6zQ6Kbme2DoKi8z2N8oEC6ELZgIDURSUVk9XseN7lh
         kbw0VXsZQStDr1OXE3e33GQbzWa4s7ArVNhChSOgwx4tRQpQUDWqsrMamXkRs2Wzh8hy
         ibf92f+amzSyR+FAsqaXnss37RRPr2sLpcBcvIFBpbaJWiAlOwWYwKz8bv3fGFeR7e/3
         sFEVrJYyL+7Yv6fxzIyZzUdLHSZXgV+AyC3tjIYGEdOGdASv9ZFfS9H3Ez+rC6TvmV1E
         ArTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r25si2335854edb.15.2019.03.03.23.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 23:15:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E133EACD3;
	Mon,  4 Mar 2019 07:15:02 +0000 (UTC)
Subject: Re: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are
 logically offline
To: Dave Young <dyoung@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org,
 linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org,
 kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexey Dobriyan <adobriyan@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
 Baoquan He <bhe@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Christian Hansen <chansen3@cisco.com>, David Rientjes <rientjes@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>,
 Julien Freche <jfreche@vmware.com>, Kairui Song <kasong@redhat.com>,
 Kazuhito Hagio <k-hagio@ab.jp.nec.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Konstantin Khlebnikov <koct9i@gmail.com>,
 "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>,
 Lianbo Jiang <lijiang@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>,
 Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Miles Chen <miles.chen@mediatek.com>, Nadav Amit <namit@vmware.com>,
 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>,
 Pankaj gupta <pagupta@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Stefano Stabellini <sstabellini@kernel.org>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
 Xavier Deguillard <xdeguillard@vmware.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
 <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
 <20190304062118.GA31037@dhcp-128-65.nay.redhat.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <2fb07c46-79c8-a49e-1b05-ffb33ad6c7da@suse.com>
Date: Mon, 4 Mar 2019 08:14:52 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190304062118.GA31037@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/03/2019 07:21, Dave Young wrote:
> On 02/28/19 at 11:45am, Andrew Morton wrote:
>> On Wed, 27 Feb 2019 13:32:14 +0800 Dave Young <dyoung@redhat.com> wrote:
>>
>>> This series have been in -next for some days, could we get this in
>>> mainline? 
>>
>> It's been in -next for two months?
> 
> Should be around 3 months
> 
>>
>>> Andrew, do you have plan about them, maybe next release?
>>
>> They're all reviewed except for "xen/balloon: mark inflated pages
>> PG_offline". 
>> (https://ozlabs.org/~akpm/mmotm/broken-out/xen-balloon-mark-inflated-pages-pg_offline.patch).

I did review that one:

https://lore.kernel.org/lkml/3d5250b7-870e-e702-a6e4-937d2362fea4@suse.com/


Juergen

