Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E38CC76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:18:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 303452184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:18:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 303452184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9510B6B0005; Fri, 19 Jul 2019 05:18:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 901746B0008; Fri, 19 Jul 2019 05:18:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CB8D8E0001; Fri, 19 Jul 2019 05:18:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE246B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:18:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d9so25725148qko.8
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:18:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=oc8Y05x5GCKHIHEd6IPCFMl3PjHXHcC08EkEuTFcPAs=;
        b=brNRVyZqMEFD9HjsssZwTCfz72tEZSG+psA4qcJmlNPBZQzr2zdjJXoPJ6xsXGl6no
         rnzU2/C8jnfjRWN6b9rY0NRlclkeFjKGDf+Y1ORT96bvZhSZG+fNeFGLctMSSS7G2PHD
         C8T4mscLu7afLe2GarMtUbSaD4QGb/B5SDSu+IxSbqJxKH01sn4UmpSbuChCmuVmNiu+
         jdBlzc+eKX0yXJ41rElpYBdZM9+7/eu6na3krGpY1ZFA9ifscypP75inXjvg2gLYvjzf
         PhOEZmV2eXhHjuncOg56ucyVQgZ+vQAh+wKWIEfyPlzXyZo8/APkM+rpnILJFbjdIvnV
         uyPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVxr8rKUS46aKtxml3c6Kg+QPDNDeNmBBp5oyZkH2Mt2uVKfXoF
	bGJVhqbO3RB+pkiQ/CKL+4ifbVahVd0HGwsAROwyRU0s/8rH3MX4Ulnv6o/S/opu1RyHfgk7wTv
	Dt0BZ3XbjYWVqSlNMQEwb0Khy8q8mu9r2Xvxy88mKBnupVHA4Ng6beSuUZDKB/i+BWA==
X-Received: by 2002:a0c:ae6d:: with SMTP id z42mr36633400qvc.8.1563527907156;
        Fri, 19 Jul 2019 02:18:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIh8a+hovyv9z/4N61DFXVJEfAg+qcVTslt0wQIO4SuQz5N7Vc92O2Ckvze/A3No9OWK/S
X-Received: by 2002:a0c:ae6d:: with SMTP id z42mr36633367qvc.8.1563527906613;
        Fri, 19 Jul 2019 02:18:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563527906; cv=none;
        d=google.com; s=arc-20160816;
        b=RXKJ0IS/YXTjJe2vJYs+wFADeAiLAtAZqF0euEpo+7i2pyVM4MGlecuXIn1AhwNOH+
         TJxhDAJpTiC5I02osNkaNrrHnflm51v9kiPqti+B/YwQN9eJOv1gt+hWrHRcxCk3oFDF
         1LlAySvoiqXKhQ6I+yZClefzaqy+YJ3zE1SjFOMeNmqVOnaRVB1znkEP1mnQRHyXWZSc
         NK9l1dMh+etHqUpSDXaiq5STLedu1ufk9QypZgn53+c+LlqzvcTPgFy5UhVS6zJSIZ4h
         D4ZYUsusZvtZ5+bIWq4er9XSH98q6YjHbpsUhNr+e0eL8wo66ysXJK+vyq0a6OK7jM81
         EFnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=oc8Y05x5GCKHIHEd6IPCFMl3PjHXHcC08EkEuTFcPAs=;
        b=XxT8C6vduzhAIbO8Wy7NX0sXmAK0wTOtFAw6GoizdmBS7XDWyBXImyQpJGO3SkHEM3
         h9LAtfRYh63xzZr13/ywYlu/PGja0tOdIRy5RfvAw/rLLZq7NTd3HwoxJpUP2yAwrplp
         G1bnWjAoIEC5nCq1YUkWNKVhI2NYxSLTN8isbMDzQRNNHbu09m/YUQOW++K1LXv1IF0m
         Y3IPgNrmE427n5AcJOSms/ZspgfoLbJ0riabio/+nTdK86zslF8knTwTPGcHK//EVgke
         +NT2m40mCqu8K+XqrVDslcf233L+xtigOAQKPTOGugbKQfjwRtTdYLBnKGgd+rhyfxrt
         gMJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d49si19908117qta.198.2019.07.19.02.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 02:18:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B69928110A;
	Fri, 19 Jul 2019 09:18:25 +0000 (UTC)
Received: from [10.36.117.221] (ovpn-117-221.ams2.redhat.com [10.36.117.221])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A173760BE5;
	Fri, 19 Jul 2019 09:18:23 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Oscar Salvador <osalvador@suse.de>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <4eefc51b-4cda-0ede-72d1-0f1c33d87ce8@redhat.com>
 <20190719090942.GQ30461@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <2f0d851e-6edb-4d92-afcd-6c69aa7f45d1@redhat.com>
Date: Fri, 19 Jul 2019 11:18:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190719090942.GQ30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 19 Jul 2019 09:18:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.07.19 11:09, Michal Hocko wrote:
> On Fri 19-07-19 10:48:19, David Hildenbrand wrote:
>> On 19.07.19 10:42, Michal Hocko wrote:
>>> On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
>>>> We don't allow to offline memory block devices that belong to multiple
>>>> numa nodes. Therefore, such devices can never get removed. It is
>>>> sufficient to process a single node when removing the memory block.
>>>>
>>>> Remember for each memory block if it belongs to no, a single, or mixed
>>>> nodes, so we can use that information to skip unregistering or print a
>>>> warning (essentially a safety net to catch BUGs).
>>>
>>> I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
>>> node that is magic. Why should we even care? In other words why is this
>>> patch an improvement?
>>
>> I mean we can of course go ahead and drop the "NUMA_NO_NODE - 1" thingy
>> from the patch. A memory block with multiple nodes would (as of now)
>> only indicate one of the nodes.
> 
> Yes and that seemed to work reasonably well so far. Sure there is a
> potential confusion but platforms with interleaved nodes are rare enough
> to somebody to even notice so far.

Let's hope there are no BUGs related to that and we just didn't catch
them yet because it's barely used :)

> 
>> Then there is simply no way to WARN_ON_ONCE() in case unexpected things
>> would happen. (I mean it really shouldn't happen or we have a BUG
>> somewhere else)
> 
> I do not really see much point to warn here. What can user potentially
> do?

We could detect this while testing and see that some other code seems to
do unexpected things (remove such memory blocks although not allowed).

> 
>> Alternative: Add "bool mixed_nids;" to "struct memory block".
> 
> That would be certainly possible but do we actually care?

Only if we want to warn. And I am fine with dropping this part.

-- 

Thanks,

David / dhildenb

