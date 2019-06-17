Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A37EEC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:13:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 633EE2082C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:13:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 633EE2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8B38E0003; Mon, 17 Jun 2019 09:13:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E62CA8E0001; Mon, 17 Jun 2019 09:13:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB56B8E0003; Mon, 17 Jun 2019 09:13:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A55728E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:13:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so9120964qke.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:13:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=PgmP5ucjDKSbzUYyZ2qdVnklw4VhCpLLHp443UNXt8o=;
        b=WEmcWxB3b/FIM+PquGIxO9Q9rX3ieE+4kuaPlTtC1BJRg55l+/DWHIqGHQHDFf71pW
         JSKMoL7/189UZ67sW+rsrkOQAcNXxYT6Ab1PvFMgIf1wJTXse6zpDD5FuV4bxxxydkHm
         wHyMKMwUq7AARG87k4XkVkYt88DUazI6tzbE8+RHfpFPVLJhm9f44jNXBmot3Y9H40u7
         vBhiGOotZfIiNr+b2VI1qAaaEKOKJWoAk3OU3qbuJdpjCBNPZ/HF11EsXf09UeA+luv4
         4CgLoa35tw01jyY4wraYU/Vz8U19MtLaFVzazgdnRtzes+YTDhXFuQQgCTk2o2TcNGD3
         yUVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4xtAVE/0VBcG2PjkSO97tk0opPh3WSQlH2wriwPPqJu/6gXDn
	4SW3K9fKxKJNkT/ds7feTlVJUalIN65ABSs1heOPbNaWVjEfZYr0eRBeQ5KEfGJ5rfIR05TPvjW
	EceCReNCP4kgZyDu/S+xj7JCqfJYOkisq9/Rgv/kCw4JXZ12AN5VsSEJU77wTaUNM+w==
X-Received: by 2002:ac8:3faa:: with SMTP id d39mr94450119qtk.240.1560777219415;
        Mon, 17 Jun 2019 06:13:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx347NUmicf2Z8rOm/np23yksrnil2rZR1/ow7qHdSXS6Oxt0Tynk7dmv5Bdfi31tLHHisj
X-Received: by 2002:ac8:3faa:: with SMTP id d39mr94450051qtk.240.1560777218712;
        Mon, 17 Jun 2019 06:13:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560777218; cv=none;
        d=google.com; s=arc-20160816;
        b=k503lTomDe8E6YUPCRWlj3pMtr+A3MgyKPRtK+oYM/CHXoK1tRisBVbpkAKEgDEPrv
         8PFfubwXlC1J2/xeFst7TxFiNzOFMl8NtMGNRLmtjJ9YQLGVxBCM8+9J5Zjc7kdbyx9N
         nFa63HpM4j5G/NZMknSaMGNvbPBptraWvqJ5bdaR50dapuBD5owWNf7Inis0DhCEpDdQ
         5uVEGny3yPUp8cFV2aRYYZ2xoXRuJv4JKyi7eQSSDn0Es+QGtqsISa41yy8VUYbjsh3o
         VhYsHepztENv7+cXj8GJup7zVpiyq14qvIxsK3Ee58VFXhsgNCxmSEIBMHEUUWWoZoPp
         ib0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=PgmP5ucjDKSbzUYyZ2qdVnklw4VhCpLLHp443UNXt8o=;
        b=pzBRviN/36MS9wnigft/W/jU6c2yd7dot2T12EtsH4HZwio/eZx9fKDnDBxiBtOqA9
         QfIfzqZTj03JJhIgFUrsJOP/siiDVNh+kcny9o7I8nHXkviIR3g6GUBXn0SgO9hRs037
         CS5nZhTjmiHbnGzj0nmymhdlnnGAsXqWCxyR8sVzLIxE9LmgZCzlN1RTN49KggIA68Kx
         uSCythmBQQzcfLNs6Xf+0QZeBT8ScqLyWF2trAu81E15Z9jZwTb3r7TPVToJVqvt0+6U
         wXqL+c0d3/UTIWR6JWsonOI3iY+5Szt0CHrFyO21tlT2s0Hesowq7vSMZfJCuabwVPLQ
         TQ7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h57si7204360qvd.131.2019.06.17.06.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 06:13:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A9E5030872E5;
	Mon, 17 Jun 2019 13:13:37 +0000 (UTC)
Received: from [10.36.117.132] (ovpn-117-132.ams2.redhat.com [10.36.117.132])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6CE2C63F6B;
	Mon, 17 Jun 2019 13:13:34 +0000 (UTC)
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
To: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, osalvador@suse.de
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <0a1704aa-6f5b-6e0b-eb3f-4038c2523aeb@redhat.com>
Date: Mon, 17 Jun 2019 15:13:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190616023554.19316-1-richardw.yang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 17 Jun 2019 13:13:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.06.19 04:35, Wei Yang wrote:
> section_to_node_table[] is used to record section's node id, which is
> used in page_to_nid(). While for hot-add memory, this is missed.
> 
> BTW, current online_pages works because it leverages nid in memory_block.
> But the granularity of node id should be mem_section wide.

set_section_nid() is only relevant if the NID is not part of the vmemmaps.

> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
> ---
>  mm/sparse.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..3ba8f843cb7a 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -735,6 +735,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	 */
>  	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
>  
> +	set_section_nid(section_nr, nid);
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> 

Although I dislike basically all of the current ->nid design, this seems
to be the right thing to do

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

