Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C914C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BB7526D39
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:33:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BB7526D39
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674086B0010; Fri, 31 May 2019 13:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624EF6B026F; Fri, 31 May 2019 13:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED136B0272; Fri, 31 May 2019 13:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25AFE6B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 13:33:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q12so4823145oth.15
        for <linux-mm@kvack.org>; Fri, 31 May 2019 10:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=yJlyTOlr4vanpESdmI1P2i3VvJrPSQPDQEgFRiyQVGw=;
        b=OFMAy0RbJW86TcI10M3sCNv+TAQpL/RWf5F5VFccMpm4CyHuT1PXxvbfNu5p9G6ZdJ
         R9baj2whnCud6zTDHPc93s1AmwGojt108tFtiEh6l5ZoP1EQ3rke5uL/ZKWeMQ0AdwFi
         b/ZoTf1tz4jOvt5I4ZdfFTGFURdmFBNRcrHx5q5jVd/3aEY4AqfXOIdQyPuMypM+XRPE
         QchsfhRVZMfJc2CGHTNiOKRILMsxzcJV2Hpm19cmukUx3JqxEAyqw4UqklBk69HVQtnL
         v6a8nY0eK3HKpk8Hk0tiOGESLzdmCPsUSyZcLeLz6CLjM1yfCFmWd5nRNs7HL2shjMbq
         JrAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV6KliKv5qSJTOTHRZY4T6IbLE8p+DNGKwwhkqUD4Xo2XqWJD1K
	hP4/HoBmg4vZLuDK0Z3pYXFhxc/9lhV0Msoz29Fk8NT/HZ/PX2XRZmHoX3oKm8/xXUVZ0Hes7Ho
	mLNCBGM3RX5d2x6MVstOjBJnflsNvl9jRr3v6eU3w/OIouY0svHFsV2XsYPILe2bf9Q==
X-Received: by 2002:a54:4793:: with SMTP id o19mr3027731oic.120.1559324023741;
        Fri, 31 May 2019 10:33:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmfPYnFiH3FbGJKZVjWc4mEeWGla7CxGJDe846Xq2iSmwuzuCybUQ3TwusDtbhTQng9EGH
X-Received: by 2002:a54:4793:: with SMTP id o19mr3027694oic.120.1559324022998;
        Fri, 31 May 2019 10:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559324022; cv=none;
        d=google.com; s=arc-20160816;
        b=WdLrjjZhxmX/93w4+yDX//EsoyXiHLetU0bzTchKrhQxLTnwpKv+J4WpkLbR5QZywn
         pD0AM8lrX8Ahr7NilJLX/x7aTYhSq+YHlwrOF0ZNDyKDlcUPbVaFIJFZ5y38HY6BnDR4
         jW0qFiw2RDu/tgAQ3RnhbQXGG9zL503vWrXKd9R7CpObj0onaykb0t9OedZW2tvWw0we
         c55f+CAijlfBh1/VD+r2ZhP4wgxPm5q2kS8IbgFygY14jGQMGd8opO5QoabONoHLf4bv
         jxqZW7uXDOZBKGPeKyOlAzTgFD12MGXNbFdCWooBePeqV1KmNnnsTyOJUL9bWeBqHUsD
         Oulg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=yJlyTOlr4vanpESdmI1P2i3VvJrPSQPDQEgFRiyQVGw=;
        b=B7YiKqfDeIBoiHM21daZZuACeMaADrrge1jW943s+GY0jDHEQLnjNJu/kV6OGthm6/
         C4HnI0vZuB3xgtiEOePKoGcVe27uphhQ09OfRcBO22PT2bUf8eMk0kMPvgx+E6bWlQqB
         yFZ+847qe8RCKdt7fBklSynfZ+12mXg7NbWJBZPlrYcWmYf4friaZstcGzjjQJ5cAdgT
         ojRKYFUe1ahhXb2XiSiy8+YgMU9qYK2DcQivotEo309RD39nah72OKcVV90bXX/nHJ8+
         a+kklU52ToJ48jp/thscoxtQnba7JrPh/FqeFyHTINhe2y70rtyKQYMQmEu5s3+Wp6Zj
         lWLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s65si3476752oih.22.2019.05.31.10.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 10:33:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 193ED3086228;
	Fri, 31 May 2019 17:33:37 +0000 (UTC)
Received: from [10.36.116.233] (ovpn-116-233.ams2.redhat.com [10.36.116.233])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6E6BA19C69;
	Fri, 31 May 2019 17:33:33 +0000 (UTC)
Subject: Re: [PATCH -next] drivers/base/memory: fix a compilation warning
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: gregkh@linuxfoundation.org, rafael@kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559320186-28337-1-git-send-email-cai@lca.pw>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b88a55b2-b101-b266-24df-377bb49d93e1@redhat.com>
Date: Fri, 31 May 2019 19:33:32 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1559320186-28337-1-git-send-email-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 31 May 2019 17:33:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.05.19 18:29, Qian Cai wrote:
> The linux-next commit 8553938ba3bd ("drivers/base/memory: pass a
> block_id to init_memory_block()") left an unused variable,
> 
> drivers/base/memory.c: In function 'add_memory_block':
> drivers/base/memory.c:697:33: warning: variable 'section_nr' set but not
> used [-Wunused-but-set-variable]
> 
> Also, rework the code logic a bit.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  drivers/base/memory.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f28efb0bf5c7..826dd76f662e 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -694,17 +694,13 @@ static int init_memory_block(struct memory_block **memory, int block_id,
>  static int add_memory_block(int base_section_nr)
>  {
>  	struct memory_block *mem;
> -	int i, ret, section_count = 0, section_nr;
> +	int i, ret, section_count = 0;
>  
>  	for (i = base_section_nr;
>  	     i < base_section_nr + sections_per_block;
> -	     i++) {
> -		if (!present_section_nr(i))
> -			continue;
> -		if (section_count == 0)
> -			section_nr = i;
> -		section_count++;
> -	}
> +	     i++)
> +		if (present_section_nr(i))
> +			section_count++;
>  
>  	if (section_count == 0)
>  		return 0;
> 

Thanks!

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

