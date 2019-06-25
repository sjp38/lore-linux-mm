Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA09C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:23:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87E3F20883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:23:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87E3F20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AF976B0005; Tue, 25 Jun 2019 14:23:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360328E0003; Tue, 25 Jun 2019 14:23:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 200918E0002; Tue, 25 Jun 2019 14:23:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF5366B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:22:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so12385062pfn.15
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:22:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RcQZ8PqvadPXEFZ4k+4JsSARneaNQKWeJLeusj3xHWE=;
        b=nmPJUuXkoLQQXbwg4SqNPRxgom5EHJ2FmNKrwEEaR75ouOGTkyLWHeEQFVWuDjqrOQ
         C13qlzQtycxV/ADB6kgmw+1nGp6JH9KhkUZaO/+H7RltX3yX++9AR6AQkMiXy4V8qQYs
         4pCIb9H8S843NQm9pmhHUeR4MlKsl03DSKgOyaYNeT/ibmT4ifj25idHA8HbWBWw/H0f
         /WX8Puu9BPT6+9tzUideiQ9Ll0wvZW7ci42yRuPf2g5kMVho5/1OqcL4srC8bDTSJN1u
         pRLTW2XVclKEROVufZR42sQYOnZ0rwnlVI95yr586eahOXgxZof3cnu8PF4pXyPDknCQ
         WYPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXMqOIYTf3FJKnmN0K45QtSP7wU9JTeCdDyMG1XGlviLNl+ctVj
	MSJP50nQfrSqJk+gJYztyhcq1ECeYXYxsWBH1RL0StzrRRoX7I5av8tDDeiZs0iKogWSDqFgIQx
	yBmJEWNac9V0FeevWpT9Tdx7eQI45dLAZwY7WYI74NmWjwum4xJh7YazpmFam6mU7vg==
X-Received: by 2002:a17:902:a986:: with SMTP id bh6mr109950plb.100.1561486979531;
        Tue, 25 Jun 2019 11:22:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOMPE/uhzTnnCHCAg3xdDLIR4YenGYYsoxR19dYAOvaEmwyGbLDZwBZR/PPgdfdekbjFHd
X-Received: by 2002:a17:902:a986:: with SMTP id bh6mr109909plb.100.1561486978896;
        Tue, 25 Jun 2019 11:22:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561486978; cv=none;
        d=google.com; s=arc-20160816;
        b=X+XwAmlIiEjktj9Nc70HTS7kwwhTgc7lPKDwFr94pJmO4UpKxPpPT/sb75N1Dw42GK
         R+mpRA898P69vEBFZPyT3849CQ4a93T2Aoa55YG38L6LW99B+ARuY/KXgBR1NgYsIDGx
         /A0jKgPfz0LRS0xwOuQjx30PK4RIHdth8QIyxWeXtLtsne3qWoLCEWhtXZsAK1aF4diy
         jCeuRfBL42QNoOTtNX1awl/tNvLbQVw6kjfp545HryG3+ybB+8ZzljBVHZUnJNAZeDaA
         qCDFPGNvf2QwXtXTa2NBhC5zfrPckmz+SkecjnAdPPc4N9zfPJFe7fjdvtYfc+kdH+ru
         pHxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=RcQZ8PqvadPXEFZ4k+4JsSARneaNQKWeJLeusj3xHWE=;
        b=iL3nRtXXpzqhOPYlMNzb39ua/+pdUEOMQuc8Kg7AId/6gTOCXPuoL3OSBh5mfgx/OX
         drA0UoPQjmo37ETXnNumXUV0EjZFOOn9IKcBaFcof4P4YwhoHro6cXmFQcRpAkFU9Iyr
         BHLuG2aZpCrYiyugXncXrA1MW6+33Kp2Wu3RmlB2VeLvhGA9gMM52CE/OMNzua+V4/PC
         yZaiWvsSAaRfusKEPct/08D9NtJiX5gpfZhm7CdPkktf/NPrwfCOqZOK124eVaFXNKAc
         3V3f3s/n5kKb0s59aHDcrnBHekYUuWNf6S6O8xJ8BrK/sjyQKjdrtBxBURGlMs7kp1Wi
         ACxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j36si961715plb.77.2019.06.25.11.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 11:22:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jun 2019 11:22:58 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,416,1557212400"; 
   d="scan'208";a="172454799"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 25 Jun 2019 11:22:58 -0700
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 "Michael S. Tsirkin" <mst@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
 Rik van Riel <riel@surriel.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com,
 wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>,
 Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
 <8fea71ba-2464-ead8-3802-2241805283cc@intel.com>
 <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <bc4bb663-585b-bee0-1310-b149382047d0@intel.com>
Date: Tue, 25 Jun 2019 11:22:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/25/19 10:00 AM, Alexander Duyck wrote:
> Basically what we are doing is inflating the memory size we can report
> by inserting voids into the free memory areas. In my mind that matches
> up very well with what "aeration" is. It is similar to balloon in
> functionality, however instead of inflating the balloon we are
> inflating the free_list for higher order free areas by creating voids
> where the madvised pages were.

OK, then call it "free page auto ballooning" or "auto ballooning" or
"allocator ballooning".  s390 calls them "unused pages".

Any of those things are clearer and more meaningful than "page aeration"
to me.

