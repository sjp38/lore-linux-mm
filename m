Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7A45C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:39:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4CD92763D
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:39:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4CD92763D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54CF96B0008; Mon,  3 Jun 2019 10:39:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FCF86B000A; Mon,  3 Jun 2019 10:39:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EC656B000C; Mon,  3 Jun 2019 10:39:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF1636B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:39:14 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id s14so477293ljd.13
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=D3ML2uXaWH9PP3frG5zr1daO8Fwu1exnM0QNu2T02BQ=;
        b=T+btwKSISgaAWsLA3QIRdLpYW6MXGTlujtDYEWFMbsr3VlcvxCCMZ6GluJ77hgwAtA
         cgAOuxpsrUPSQzJmxJEc62kOfuCMebBMlKBLi6+OWlWkIwDdTV4Vhw3DPdKG3vv398LR
         RtFc1iPHYmGkdgGk/zTcp3qbXnUeHsS6WJhocAy8eou4G5poj9f3DBRiUnXZZ/TH8Suq
         zg+WMLdMLYvlCLhn7W6hqm6vxxTSd+GHD/WIutfjm9UmfXycbbT7FXikEcxahyhxO+Eh
         BpQFrX0gRjCKwKny+fSOrvh8vrrMzk4bRPHUTG+54YBnW0n16eV4WGnp0q2COtCcE7J7
         p7oA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVTIrn/uDcgIXtjcJbhGnvu4gsT4pEazh0jLQYg0ds9lJl/9iJh
	56Xh0mnW1Z63JSdem7PLQdvADDMNMXjc27bEVMLIgMt0qrjt5/SPLywzAEDlqCHo72GtWDB4XUL
	nOkD99Gk4XtsiNKtFXasD/hk/YTxOhkVoxGjrjwBrXk7n5TgcJ9g10EWxniqZqcGneA==
X-Received: by 2002:a2e:96d7:: with SMTP id d23mr1156459ljj.206.1559572754304;
        Mon, 03 Jun 2019 07:39:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytEQkWgWCuxzZ67y8Eu2BZ+5OhcMjNHeUAgnhopudyzqSMLFwetKK5PR2N3Bc/kXJXn/bl
X-Received: by 2002:a2e:96d7:: with SMTP id d23mr1156402ljj.206.1559572753107;
        Mon, 03 Jun 2019 07:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572753; cv=none;
        d=google.com; s=arc-20160816;
        b=oj+gke/YWRgvD4snfF6ne8poKwRMk52FwAjrvFImh+UUh5/4+mr2EUHa8BCdJilFHm
         M/50FhDKTYhHoNFmTT1zm335OYFByK3u4bjVYX9Sx/3Gchp5Vf4hc6oq8ixOgdGURJAx
         6QyJsVn3c1N0FCAW6r0Ta3r0Vitr+PILVEYDFB25emW0qHTa5HZzNEoZlTYyzooc8voF
         DjLMVhqrdKgNWNu2qhNo2b29gRF/nPcQNrZePvKST8AXsty+H3LpGS4NxA159wt0G3CK
         4Agb9r4vCEdlQNyBV+iPjSYZoPZPffqxuNl8sUVAbE1XY4XvyTbtxwAYb7+KvbqDMaf5
         vX4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=D3ML2uXaWH9PP3frG5zr1daO8Fwu1exnM0QNu2T02BQ=;
        b=TXJzYXxGQDqHXb4Ls479OSdorYObYXQQVUgmiIBfaBEEop23ULlAehKkNmRBpj5Mgm
         OwfNjGNastykF153Qj+MPIqjJik/V+TfWVkhhRikqOLpz76nBCLPU7BLlzDJ20StIEc+
         +WWpqfcus6BKRgzpcbl6qim8wJbHtw3r83OPOk5U4TKSJY15PwtUgkgS0sw+c09kpjkz
         y8n97blR7lxg6LrZKbv8qG1qKqerG887Dp4/OTeRa6/OCUrGPms7MdRMTm/mtaap7Oal
         LkWEgK+sxpDlga/9HEkUbt1l2dwTTuukEo00dhBWf8fK935zTP2TH8FphY68NACw4jE1
         GUxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w3si11601414ljh.106.2019.06.03.07.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:39:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hXo72-0004Ve-7f; Mon, 03 Jun 2019 17:39:00 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
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
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4228b541-d31c-b76a-2570-1924df0d4724@virtuozzo.com>
Date: Mon, 3 Jun 2019 17:38:58 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190522152254.5cyxhjizuwuojlix@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.05.2019 18:22, Kirill A. Shutemov wrote:
> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a VMA from a process to current process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
> 
> Kirill, could you explain how the change affects rmap and how it is safe.
> 
> My concern is that the patchset allows to map the same page multiple times
> within one process or even map page allocated by child to the parrent.

Speaking honestly, we already support this model, since ZERO_PAGE() may
be mapped multiply times in any number of mappings.

Kirill

