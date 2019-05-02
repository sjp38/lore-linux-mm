Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 762A1C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 11:27:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2454120652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 11:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2454120652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88EDD6B0005; Thu,  2 May 2019 07:27:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83FF26B0006; Thu,  2 May 2019 07:27:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7069C6B0007; Thu,  2 May 2019 07:27:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9BF6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 07:27:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p43so1861273qtf.1
        for <linux-mm@kvack.org>; Thu, 02 May 2019 04:27:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=+7599Kwqc3dOKB2HZpKrU8A7KG6HBvUIFJHEQ03+5f8=;
        b=IvkaN3u7FVSfyJatpTO8YZ58L4dkTIcpjWirqISfUUy0Pmha7KX4RUjx0ArorW1vOh
         +/1Kk5zz13SDHFROaz0MPPzPFOfL6EnJp5EEC47+EHdgQsGdo/Tl2sGxiIWvMdM2mkzX
         0kIM/w+LthblxOLOc/pkyEoGHDFiCUKEb8IqAgFQQHZYFTWtvZzzDmzpRMGHLuOaavtG
         O/seKJFXHCxC9PtWy4U0p1RjCd+sgJ6Nt3yNdOCxOUl3rL7+QXM0b1JsQeId2ghmdsEv
         FFll8DJrWqKlllWpplZknDHclbru3qcwwkVKvOXl5KLrYfZi1ZqFOS9Cfd7n6iyOhyq+
         5UKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVbxSpk2uudP7hNPCUvn5Q0dvbm2wFdTX/e0oXesh+HwEJ7eKM4
	+Mc4J3zWbDtP9vx5ybHnE/cPruvWVMf76QvsLTyFFtGFCsrXqDKxJJDGux1+T7aJWU0mtOWnmWX
	wRvz3y3cXjiHCqbI3SO9tg7sjCKGUfcK3QekfMqTu3YTnqoVZ8ZjgEmFGqpO3RryxnQ==
X-Received: by 2002:a05:620a:146c:: with SMTP id j12mr2408851qkl.116.1556796448075;
        Thu, 02 May 2019 04:27:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz89ZWy2bw8pEioRAg3bqWqfS3G83atQQAmZgsT110WnwYYXur4qy54QNnKqiHNzDrtcZLn
X-Received: by 2002:a05:620a:146c:: with SMTP id j12mr2408810qkl.116.1556796447249;
        Thu, 02 May 2019 04:27:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556796447; cv=none;
        d=google.com; s=arc-20160816;
        b=aFhorcaLdgerHisfA5d99iG0aInM8pVNIM+kIH0Jhl4xTV4n930Evy6qUh/ecmObeU
         LQ9Q8ALPHkdDcDzs6+djR5KJ6wZ9ICkJfgut13jySlR6DGfYJlmantMBAIpqm1SpjG2N
         JxElN1QVR/j4CK3AnCwSObr1r3cu6PQArhcV0qcrpp2p6RNTdCKaghDo07vx1Geq/0f3
         mKGUFob3q2bOO+sL5V6loOW8hfnX7ruC+E/ZcUYPYwQZp8ViLzk7+++LhTO6dZlubRLK
         FXdZFesBLMWS4bfDUV5+FbOKDuCucl/i3u4YN+Awyx6+RIs0ce+M/HQ1Yx4ecldkseMY
         DpFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=+7599Kwqc3dOKB2HZpKrU8A7KG6HBvUIFJHEQ03+5f8=;
        b=pDhW0NZWuu+Uyfi+ma/KttUKsgy3kkqt0Auc5tE9uQPP8zIzQoVjj4IIEG6fJuycrO
         hl2mVqkVjwplFoJhSKaEDjkd0n4AOf5cMnIltYsulmcpPwfM6uFVEGZEhCGKxvWWfeZu
         ehn1JfKUQlmghRdA8B+7y74vFllXUJd/krqtgXNTcUrWr100zoXjSbAZu+ylEUEduNmj
         J9SzbkgYOkdJkmCfqXB9UjGH3Fc9wftNOtjrd39c871by5H6IpybnLK1/tcMbQvgpRr6
         Nj5wlgH86sw3yRty4WEeizOi1OL9u3JHHNo6GzzGLmRSgByAyYNtq3UrReghDWQXPsew
         O2BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c3si2536784qvu.149.2019.05.02.04.27.26
        for <linux-mm@kvack.org>;
        Thu, 02 May 2019 04:27:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 782FD31AB8A6;
	Thu,  2 May 2019 11:27:14 +0000 (UTC)
Received: from [10.36.117.88] (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A04D182E8;
	Thu,  2 May 2019 11:27:12 +0000 (UTC)
Subject: Re: [PATCH v7 06/12] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677655373.2336373.15845721823034005000.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Message-ID: <e5542928-de60-d83c-0e9e-f0f5961b97f3@redhat.com>
Date: Thu, 2 May 2019 13:27:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155677655373.2336373.15845721823034005000.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 02 May 2019 11:27:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.05.19 07:55, Dan Williams wrote:
> The zone type check was a leftover from the cleanup that plumbed altmap
> through the memory hotplug path, i.e. commit da024512a1fa "mm: pass the
> vmem_altmap to arch_remove_memory and __remove_pages".
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: David Hildenbrand <david@redhat.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/memory_hotplug.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0d379da0f1a8..108380e20d8f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -544,11 +544,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  	unsigned long map_offset = 0;
>  	int sections_to_remove;
>  
> -	/* In the ZONE_DEVICE case device driver owns the memory region */
> -	if (is_dev_zone(zone)) {
> -		if (altmap)
> -			map_offset = vmem_altmap_offset(altmap);
> -	}
> +	if (altmap)
> +		map_offset = vmem_altmap_offset(altmap);
>  
>  	clear_zone_contiguous(zone);
>  
> 


That can be picked up independently

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

