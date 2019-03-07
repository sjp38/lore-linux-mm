Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99B79C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 08:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3398620652
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 08:41:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3398620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74AB38E0003; Thu,  7 Mar 2019 03:41:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FB128E0002; Thu,  7 Mar 2019 03:41:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EAFE8E0003; Thu,  7 Mar 2019 03:41:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34BAB8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 03:41:25 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p40so14404437qtb.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 00:41:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=a/9DxzPpcPbbDU3VE07Uwxj8pi0fwDEEQG6s/QSqbss=;
        b=QrkDSYjFhAozzJQTC6P2moO9mYK1+qUy1z9p0qW6TOs5BJbylOo5rIdu8ncnpUJRoM
         n0DOibriLuZSkT2C2Qa+WI88VlURJSwBmrtnjPp4f/ebbIitu5Pxbw+tOFZQ3MLJiAzm
         OI7HLUkEolUF879zOGrTxlbBg81/XSLhUsHHJX/hcvPUwIV5lmtH3XjIpcHujk963ubd
         g+PA0DnEeCLxQz2kGB+6GTZKLud9/M8S91jCXK9jlc/u3r7KzK+vEzwQQrg0QlAGQti0
         4KLblCMsqCdGAcJ2r+H21Qt1RRcwIF0JQVZdNMvXEbbUbNR2hzqWZfoxC8XJeKbKczvF
         rjrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX3Lwyz5yqnnnl+cOkgjUwUmvjRmgFeqj82Kg33xCn2lHRS6jaQ
	dmjgTZRjFWbjrvG0rmHEMs8zpH7TAnjTmvBaMlKMf6b848uWb6He89fsRFhR+bGeQflg3sJRbBB
	Y112x0pI5ZIRW/0pKLaTEB0h5TWFIuAJfAJynGN0w5fVdpV/xbFjrAlxYECh049xLgg==
X-Received: by 2002:ac8:21c9:: with SMTP id 9mr9293638qtz.78.1551948084907;
        Thu, 07 Mar 2019 00:41:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqyLSoe36eIseEAbjakbX5DV/zUySE2ZhjGgGhSDsSTf8pxfYWzfhJQD4CUqJbYnAeA1Kd6g
X-Received: by 2002:ac8:21c9:: with SMTP id 9mr9293605qtz.78.1551948084179;
        Thu, 07 Mar 2019 00:41:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551948084; cv=none;
        d=google.com; s=arc-20160816;
        b=DXDjeFskRspuAonEx8cQeEE9W93DMW12qmWlNAgNr9GXyhuny5BXbuPxIVExUV+zfs
         /Ubt939FFWPaFRjBW/oXjlPPvjUBwBCIdTs4p/VfW7mPW0PlVfJho/p62QUeSPc+bO0K
         6IEnDwiCgsYOLhkUs7+0FK1k4yBOvuNuqILEpE6+aHdroIE5cbBjdrhlZDDIblQYWuhc
         S2Sm+tbPTPTK9HbBCD5c/jgCzqRFG44xHGVzOIawe4Hj+Gr7Jx/E8GXIqENdr1nFoIG2
         zfNGb39pXTK52jA3cmhQGdt2ER9iXonqaF31780kcCPw+6GLpbX27ZNn/PLS3UVizQqv
         A3ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=a/9DxzPpcPbbDU3VE07Uwxj8pi0fwDEEQG6s/QSqbss=;
        b=GPFicK/hmytOCcEEdqAoc+ArHkCLPy34UtN6ofhGfEE1Df5KYcx8SijYR0zd+n8dYf
         0R2jY4JQ5GephFST81jHjJuiu5h3jJ4jq/aU6h6FxZD9m5xO6cv0xmb0lpbI67xrgjJd
         oC6LlBl4aZa1zpEpl/lfVSA1wytGUpnHWKBNhW0GJcKn2PgYx1c6elVPsAVWCnhSTGvE
         YuXTPMpiqeFJmGEuKHCjuwU9+MzptGyXImFGAdt9Jc/KITQFWnaFtUx1DFz+xrH3phLU
         DrKvDhrGOU4pzKdvEWQtbi+rp6Jn4FGBsEHzq+DlnetE7vEsB0GDTd/WX5QgRM60+imG
         ulqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u1si2060279qth.256.2019.03.07.00.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 00:41:24 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AFE8C0467FA;
	Thu,  7 Mar 2019 08:41:23 +0000 (UTC)
Received: from [10.36.117.175] (ovpn-117-175.ams2.redhat.com [10.36.117.175])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 352CD60139;
	Thu,  7 Mar 2019 08:41:20 +0000 (UTC)
Subject: Re: [PATCH v2] makedumpfile: exclude pages that are logically offline
To: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
 "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
 kexec-ml <kexec@lists.infradead.org>,
 "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100938.5567-1-david@redhat.com>
 <4AE2DC15AC0B8543882A74EA0D43DBEC03561800@BPXM09GP.gisp.nec.co.jp>
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
Message-ID: <7c9d6d5c-d6cf-00a7-7f23-bf28cbb382af@redhat.com>
Date: Thu, 7 Mar 2019 09:41:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <4AE2DC15AC0B8543882A74EA0D43DBEC03561800@BPXM09GP.gisp.nec.co.jp>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 07 Mar 2019 08:41:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.11.18 17:32, Kazuhito Hagio wrote:
>> Linux marks pages that are logically offline via a page flag (map count).
>> Such pages e.g. include pages infated as part of a balloon driver or
>> pages that were not actually onlined when onlining the whole section.
>>
>> While the hypervisor usually allows to read such inflated memory, we
>> basically read and dump data that is completely irrelevant. Also, this
>> might result in quite some overhead in the hypervisor. In addition,
>> we saw some problems under Hyper-V, whereby we can crash the kernel by
>> dumping, when reading memory of a partially onlined memory segment
>> (for memory added by the Hyper-V balloon driver).
>>
>> Therefore, don't read and dump pages that are marked as being logically
>> offline.
>>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> Thanks for the v2 update.
> I'm going to merge this patch after the kernel patches are merged
> and it tests fine with the kernel.
> 
> Kazu

Hi Kazu,

the patches are now upstream. Thanks!

-- 

Thanks,

David / dhildenb

