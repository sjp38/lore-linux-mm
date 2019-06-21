Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 239ACC48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:04:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D825120449
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D825120449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BC9A8E0003; Fri, 21 Jun 2019 11:04:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D168E0001; Fri, 21 Jun 2019 11:04:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C808E0003; Fri, 21 Jun 2019 11:04:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 292148E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:04:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s25so7755001qkj.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:04:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=9wdwnabVEYwl3zN5HWjLxCO+kcRfTIL5aOf9iQerNAM=;
        b=hUeu4rGc3G1NEesa1OBxxYr99PwkGcHuo2G7tXTMnz0gFPvmJ63g2reK/VbrHayo+F
         xeLZyhMEsYqCoy60LxCGVlhj+1ZNFLr5HKF/7GYFK4d5Kyo1Pvh376m045wUzXu3pw+E
         ECVBTMqgHzeiwlCab7U3jLqA5w0nenzGVLYdNWw8UwRnshudj9dsuFyK63jyFvQJxoLU
         4pujLHuMj9mMqHD0zXBjfwTEGBohaSC/SL3ZKrQ4fe6dsWFwxFTvTsnVgImmvHFZKG0k
         WJUV96rz2CvRTcqAre+9YfcQfL47ychlDIIzfm1GP6cG0rawf2buhb2DILA6ePTQvt7y
         ID1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVAFk0xUl47vkORPis6mZY+nZ4zpEM4sDCNjAIWSrvB7ZwbuE2a
	abtchFK9mVXv/gyYA62iifrkHTstqOZh1amP5vY7CnskBo02BetwEAUNj6HgY6e7e51RjZyTTeV
	UHzfhLtPDICP9PiLGiuuIaU9+Eu/R0X+XHjYxp9vq5il9cysBMro4xU4hkC3Wo+KgVA==
X-Received: by 2002:a0c:9e5b:: with SMTP id z27mr43430058qve.67.1561129496979;
        Fri, 21 Jun 2019 08:04:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/hYIdFpuWZedqjS13bRf9juJZ7iJN96dxI/jh2YJcfsty/64PwmC4edqQN209H/ubtaWK
X-Received: by 2002:a0c:9e5b:: with SMTP id z27mr43430008qve.67.1561129496451;
        Fri, 21 Jun 2019 08:04:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561129496; cv=none;
        d=google.com; s=arc-20160816;
        b=TxDK0qHxWZzt61KpbcTWN/b3VgUY4cO8GDqfazqgxt+25/+ZOqGavUzHZiQmEe9FIP
         oYeTy+zmRo54HlL3H7ALbwH6rnuQBzcUdcjcyH8thGuEN8BjNYogUlQqK7Ci7Wc4vVv6
         L7pk5eCeW39IrZRyMRsfno6mcd6JznJyO028KO+Xi3ppsXK+zFk+FYPRphr/qsiSvoIy
         v3F7o3VNWd5LHNIXSTJKxucAnrliSvY47xWtDBEeXXrMs+77uPoIM7Hl/9gNDLgK4hew
         68BufUaTntUWRkQCrUEGb3+tuoiFYT2xnrKz8RXZdqvGRAs+9xjl7PxcJChhmPlC7HSk
         JgRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=9wdwnabVEYwl3zN5HWjLxCO+kcRfTIL5aOf9iQerNAM=;
        b=LokOt/i7HRYaTOeLAjcYtCkGt+OZw2YcAnxmcmBq5d20fwmBejF2TMA/NTQnS6StSL
         JJ9oSncUaAS9DkRdB7MLw/9MCUlXGX1N1R9Xsx4rVmNl/yVwSnaciuC/nNCpZDsM5/MP
         7Dg3X7XjRKvP5SySU5uRLS24orw18y2iR/myL0d9FtjdteXZogfE1ZUolgmIQQ3qPByP
         vEXpbpuLKOpDYnjEtPg2KGWGFpuF20KpFu5+R1aeqO5TPSWi1mCwvD2lFcuOO6r6FbiT
         X81ml0iQFS5xfZoM5x1bucbHk3FnMrclUI8sXtlp76K5XQIGdeYeaDZZUROrLINKk3sb
         jGSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k28si2113672qtf.34.2019.06.21.08.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 08:04:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 949BF223875;
	Fri, 21 Jun 2019 15:04:50 +0000 (UTC)
Received: from [10.36.118.55] (unknown [10.36.118.55])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 77CE2608D0;
	Fri, 21 Jun 2019 15:04:46 +0000 (UTC)
Subject: Re: [PATCH] mm/sparsemem: Cleanup 'section number' data types
To: Matthew Wilcox <willy@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
References: <156107543656.1329419.11505835211949439815.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190621145805.GN32656@bombadil.infradead.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ed4ccc6e-082b-df7a-6633-0b5f95e7bf2d@redhat.com>
Date: Fri, 21 Jun 2019 17:04:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190621145805.GN32656@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 21 Jun 2019 15:04:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21.06.19 16:58, Matthew Wilcox wrote:
> On Thu, Jun 20, 2019 at 05:06:46PM -0700, Dan Williams wrote:
>> David points out that there is a mixture of 'int' and 'unsigned long'
>> usage for section number data types. Update the memory hotplug path to
>> use 'unsigned long' consistently for section numbers.
> 
> ... because we're seriously considering the possibility that we'll need
> more than 4 billion sections?
> 

To make it consistent ;)

-- 

Thanks,

David / dhildenb

