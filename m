Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE647C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:07:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 978A620675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:07:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 978A620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DBA46B0269; Tue,  7 May 2019 17:07:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28DEA6B026A; Tue,  7 May 2019 17:07:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12CC16B026B; Tue,  7 May 2019 17:07:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E374D6B0269
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:07:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y13so18737112qtc.7
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:07:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=n9SIz7T4munjVwMYC97jk6/NoYcqt2g2PHsSbj/BV4w=;
        b=RtebRyu8gMHY9aQK4VnwsRZ1eQGvk357u2xkc4WP8hQUpVJrpm3laHSinr33RSN/Lw
         r5vL1fzzrCzpCBK9Iq2XRuhHsbOXIgBuz8ImEGfGjcAnNelyYTKJW2a7Fu+bqX9g5Ito
         CXzsZyhjNah9UmI49212LpEBOBgYa8eBL5UaRzzWI7ee0fkuD8pOz1NTLuN8PWRG0Yk1
         BIjSf1gmYwSvsZ9gTmxYXoV1Squz7zS+kOZ4v1iRn17bMlKdhB98le7X+T6ephDX/fbn
         UeRHLvyviEA358A79O5feyQrdEWhXATGMOZ2790XFWJshzNVl7OD3F4DNAsXqBv0xOpB
         ip9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLZZyX6+oOXM6bOYouMwDEKOeE2qQ0oRwQWHtYFzCKvI7fFbVN
	LrBpGHeYxAlV790j3XE7JwNsKjKHiZQ+Xrkkbr6vcwLEnhYbho4Xr6G42DEBov0LauwxpM/hj+R
	COFpbbo7dLVeptuRFY6YrcobzYhliRXexm6d3kMwUz51gK4JANQlVjpvLEaNZxr835A==
X-Received: by 2002:a37:8c44:: with SMTP id o65mr26866301qkd.224.1557263229725;
        Tue, 07 May 2019 14:07:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLsVqC5n80uYRW17PdJKVWuAq7tJmWf3AtgT+FGZiUbbMADA4vClLGcBvvOjRFXW4qlKis
X-Received: by 2002:a37:8c44:: with SMTP id o65mr26866261qkd.224.1557263229127;
        Tue, 07 May 2019 14:07:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557263229; cv=none;
        d=google.com; s=arc-20160816;
        b=uk1BFSke97svr1yTLQv4Y2EmBHk+sg3BgJM7AJ5WSJ42ZwDVEys5nnRb16+RsAE8rc
         WvqxSYC1em1VM4sgNa5ZqrXyBnOLCJA5ewLKqcTIRsv7kSh0WGTe2rQV6UVbSssSryYG
         G98szg4JVaDBFshh0kMRyraBF3Cd3REvCXxSQgeK41g7kMjriWAafz5M9Os+8zeDOVTT
         Vb8hyTNHOB7CUthQ4aLQVuwfDA2NdXMckQCiXNKMJQ02RmgyK9Yu9HejM9A4TE795LmM
         tLV9yby1qA1GCqgNMdH15uvOuOtd87i3TnHerdfRQyTvthRkpWXbI8QPcpkU59j98OYM
         atvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=n9SIz7T4munjVwMYC97jk6/NoYcqt2g2PHsSbj/BV4w=;
        b=ZXjOF45Nufh35QwChlXQm72CdYUy9YLY8gidf+ksOwnuMWKsNiuLn0LMbOhhFRCGoN
         S+pCTDca1blOO2sRxcs6ipP0AXw46bLy9ANdsvwlQVksE6OQZC+j1loUNG4GmFIrBwN+
         YIA1Nm1+09c2vs5X6zfCEbOpVbJl2SGQhf1KNdL/RAfrDVV8Ykn1l3bdZtWPEbekZRWa
         YS3AjqNkvYGITWp5lVkD5Ck1dt8wFVoTX3ANjMJOjxJKgVfmEK5o69cHCOS2AIiHkSt8
         nAZ5F0VVT1iKbIMgSBENZ99U4u+OB2E/lfWuB9/49Ls/t2bh1LsSELS2yKfFQk0Ntxjv
         5yrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q31si1529711qtq.129.2019.05.07.14.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 14:07:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E4FA5307E052;
	Tue,  7 May 2019 21:06:58 +0000 (UTC)
Received: from [10.36.116.95] (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E282E5EDE4;
	Tue,  7 May 2019 21:06:44 +0000 (UTC)
Subject: Re: [PATCH v2 3/8] mm/memory_hotplug: arch_remove_memory() and
 __remove_pages() with CONFIG_MEMORY_HOTPLUG
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Nicholas Piggin <npiggin@gmail.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Rob Herring <robh@kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Andrew Banman <andrew.banman@hpe.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>,
 Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-4-david@redhat.com>
 <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
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
Message-ID: <d92537c1-983b-2610-f68e-369a37232acb@redhat.com>
Date: Tue, 7 May 2019 23:06:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 07 May 2019 21:07:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 23:02, Dan Williams wrote:
> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> Let's prepare for better error handling while adding memory by allowing
>> to use arch_remove_memory() and __remove_pages() even if
>> CONFIG_MEMORY_HOTREMOVE is not set. CONFIG_MEMORY_HOTREMOVE effectively
>> covers
>> - Offlining of system ram (memory block devices) - offline_pages()
>> - Unplug of system ram - remove_memory()
>> - Unplug/remap of device memory - devm_memremap()
>>
>> This allows e.g. for handling like
>>
>> arch_add_memory()
>> rc = do_something();
>> if (rc) {
>>         arch_remove_memory();
>> }
>>
>> Whereby do_something() will for example be memory block device creation
>> after it has been factored out.
> 
> What's left after this?

I tried to describe this above here:

- Offlining of system ram (memory block devices) - offline_pages()
- Unplug of system ram - remove_memory()
- Unplug/remap of device memory - devm_memremap()

So administrators cannot trigger offlining/removal of memory.

> Can we just get rid of CONFIG_MEMORY_HOTREMOVE
> option completely when CONFIG_MEMORY_HOTPLUG is enabled? It's not
> clear to me why there was ever the option to compile out the remove
> code when the add code is included.

I guess it was a configure option because initially, offlining/unplug
was extremely unstable. Now it's only slightly unstable :D

I would actually favor getting rid of CONFIG_MEMORY_HOTREMOVE
completely. After all, unplug always has to be triggered by an admin (HW
or software).

Opinions?

-- 

Thanks,

David / dhildenb

