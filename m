Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FD60C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C02722077C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:01:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C02722077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1446B0006; Wed, 17 Jul 2019 04:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 551938E0003; Wed, 17 Jul 2019 04:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 417DF8E0001; Wed, 17 Jul 2019 04:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21EB46B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:01:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s25so19319600qkj.18
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:01:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=FzDA67Pdfhr1vmdVI3OK6LREwU1NqIs3gqdlPp/Itvc=;
        b=ra+Th2WKdZ/WlSMS30RGS5Arh5L7HQuaFfwfJMWimdzox7JXmZklVGvr2rlrBIG2Tm
         v1AB6r10g5W1Z5AHSrZjBwRmBOdnihSAfkaB2P+2dHaQNd31fZyvmIDnKsSboAY+dfO6
         tX32CqeLXodPbe/rBk7XlfA4lsdbz5Y1hXpX9ZaZdlP73uahMzbOML2xn2HPS2RO+OLl
         gVuhuYzTyXJMFzgAIyA4SLZEY/WpcsyWJK0Tx8vITXWX2pBQxunr1Zfy4mDtjiuoEbqp
         +IWcRHgDjnNS3ORurUyoP/FPZO3wvzpBIjLWf5QrG1irQJ7fuY3uzHj4TCpbmodNU74l
         0A7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHzJ68N0i+k9pmop5+4H+5nH970V41FcG5y1fq1MvtJFsVU3Bs
	zSMDaJrqmoDin5ZhnccMrSmJpHPwE821uEAnRCPoeQ78xAz2uApMRW4iAmTgBZXJJb+mWBNBYkZ
	/9ZkAgH6YcR7lVAA4d87U+0Po6m/uoNYrGxBj+ZMRFu4DSkXvQQlvOZNjkZumTAhw2g==
X-Received: by 2002:aed:220e:: with SMTP id n14mr26806801qtc.388.1563350465815;
        Wed, 17 Jul 2019 01:01:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE4Vz9Ch5+wK3ZeZmt+7fETy5mUQs56DoBdwji6CPwLh1/DreBIzYPhJVoVmk+FvjjowqS
X-Received: by 2002:aed:220e:: with SMTP id n14mr26806756qtc.388.1563350465195;
        Wed, 17 Jul 2019 01:01:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563350465; cv=none;
        d=google.com; s=arc-20160816;
        b=Hhk7M++obPFyxVbpCZIPAqyA2I9GbrYPhY2x2HV/ngm1Dp6kEq99tiHZdq/qW3Jg0A
         g6eeOW7Iu23oXL+me+NGXP1st34YCikYmAGuRJ/edXA0UfI1NF3bwozl0i3sq/GEBcte
         nyU8s+Ea+QlesXCQuNfw8pjPVF67EHqnkKX3Vz+VsK10GV8A0bdezeXghjn5/K7uDQrg
         0JDbNMyARl8jgTZMeW+SKt3/sqhptUyWR7tRDsK0ZxoD7RXqNHfPRWcaoegnrrqBxGV+
         514OztILwu5ufcDwpox1jBctALI93t4NMqdRYwtARqdwyxASxWAWz1A8/3KLIL/u36Fk
         5oLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=FzDA67Pdfhr1vmdVI3OK6LREwU1NqIs3gqdlPp/Itvc=;
        b=E+UGgdlRr0bwcN5ZySLSIOwD1oVV/8G16s9QOmEHehANcoa412pRzRi7VBwAHSYq0/
         fW94GEejHRozT2pAId3pe9235kxMQkDXs+DqRRcjPRQZOSVJXcxVY0X3Ay+K8O5FVzIC
         Ezkmb+D1CrvdGs+sB7g/Glla2th5Ww7ErRadwIBU6JkAMssn2ak0vNM1gvolm6fTZTrT
         6kHiCuLkYhyIZ2W8TUvR1Ii8j197DMJLa+wAmmR1Zix41/Y+gWo/7lPuKaiyRWzeLtkW
         AxzOV938NCKc8RKfpqIVYsu1S1Guve1nCXctC8BBxHh+fMrOc1Hx4A3nwo9tlZaxkmtq
         rjhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z68si14382980qkd.208.2019.07.17.01.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 01:01:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FF6B309178C;
	Wed, 17 Jul 2019 08:01:04 +0000 (UTC)
Received: from [10.36.117.65] (ovpn-117-65.ams2.redhat.com [10.36.117.65])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6D5AE5C29A;
	Wed, 17 Jul 2019 08:01:02 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
To: Oscar Salvador <osalvador@suse.de>,
 Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20190715081549.32577-1-osalvador@suse.de>
 <20190715081549.32577-3-osalvador@suse.de> <87tvbne0rd.fsf@linux.ibm.com>
 <1563225851.3143.24.camel@suse.de>
 <CAPcyv4gp18-CRADqrqAbR0SnjKBoPaTyL_oaEyyNPJOeLybayg@mail.gmail.com>
 <20190717073853.GA22253@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <da07d964-fcfa-1406-bc12-faebbe38696e@redhat.com>
Date: Wed, 17 Jul 2019 10:01:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717073853.GA22253@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 17 Jul 2019 08:01:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.07.19 09:38, Oscar Salvador wrote:
> On Tue, Jul 16, 2019 at 07:28:54PM -0700, Dan Williams wrote:
>> This makes it more clear that the problem is with the "start_pfn ==
>> pfn" check relative to subsections, but it does not clarify why it
>> needs to clear pfn_valid() before calling shrink_zone_span().
>> Sections were not invalidated prior to shrink_zone_span() in the
>> pre-subsection implementation and it seems all we need is to keep the
>> same semantic. I.e. skip the range that is currently being removed:
> 
> Yes, as I said in my reply to Aneesh, that is the other way I thought
> when fixing it.
> The reason I went this way is because it seemed more reasonable and
> natural to me that pfn_valid() would just return the next active
> sub-section.
> 
> I just though that we could leverage the fact that we can deactivate
> a sub-section before scanning for the next one.
> 
> On a second thought, the changes do not outweight the case, being the first
> fix enough and less intrusive, so I will send a v2 with that instead.
> 
> 

I'd also like to note that we should strive for making all zone-related
changes when offlining in the future, not when removing memory. So
ideally, any core changes we perform from now, should make that step
(IOW implementing that) easier, not harder. Of course, BUGs have to be
fixed.

The rough idea would be to also mark ZONE_DEVICE sections as ONLINE (or
rather rename it to "ACTIVE" to generalize).

For each section we would then have

- pfn_valid(): We have a valid "struct page" / memmap
- pfn_present(): We have actually added that memory via an oficial
  interface to mm (e.g., arch_add_memory() )
- pfn_online() / (or pfn_active()): Memory is active (online in "buddy"-
  speak, or memory that was moved to the ZONE_DEVICE zone)

When resizing the zones (e.g., when offlining memory), we would then
search for pfn_online(), not pfn_present().

In addition to move_pfn_range_to_zone(), we would have
remove_pfn_range_from_zone(), called during offline_pages() / by
devmem/hmm/pmem code before removing.

(I started to look into this, but I don't have any patches yet)

-- 

Thanks,

David / dhildenb

