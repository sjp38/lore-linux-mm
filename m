Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1943C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:46:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85BCB2184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:46:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sUuIMJJ7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85BCB2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 241DC6B0008; Fri,  5 Apr 2019 11:46:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CB586B000D; Fri,  5 Apr 2019 11:46:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01D6A6B0269; Fri,  5 Apr 2019 11:46:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF78A6B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:46:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id x66so4792759ywx.1
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:46:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=aW5eO1Y1EqwbPPw39yD2qVZTCtUucALBP6ZcE8RoydE=;
        b=tPWN+m+d1rSPfXdoZDv0q0d4iET2xlBYqfonZxbdXgiqOgsthmoZKpECzoNVPSkaTv
         DT0CLD9j/y8fmrs9rIwo7icrSKmBLq3eQyP9jSrsy9kgdFMGZkwCbn1CB9qNYzMzBQ4w
         ToPX3u0nsZqR+AXZ9R+Q0XLLR1CCb2kKrp9k+5yovl6ycbYvzD0S+bfcLFcIh3Koq3Nh
         eWjKGHzKDB3J3Mb+GSUapu2K3WgPQ/gmphZN5A766EywBlulXI68DJ3K5l1znre3/0UV
         1reIR9uJwhFnRbIWsgY/U0y/+gAHG0d8TKQxOkfqWZ7+sShpsYy/BBoRYtC3EkTO6S3y
         ddtQ==
X-Gm-Message-State: APjAAAWMkkPKKd2w3YGOWtiiepqFvlFy0parusRve3SjdHslNAOOf6PB
	NCr5ybkT36vbHz9IOBZ4OetnndLhJJl/Ll9ZbaO4mTNcJQ7I6e/hKiMRaleQwHkAKJnlxZEjlqL
	kOWAozQyAgZ7srP5JBImPnyCM9SW/q9EnBwzIX1+eCwZ9ox9JT9VDwlycGF31GeCXTA==
X-Received: by 2002:a81:378a:: with SMTP id e132mr10922107ywa.137.1554479166472;
        Fri, 05 Apr 2019 08:46:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfVtqSRbRINUix+q2uCNjmE20Q2ipF0gaqHAYGNdmvjWbnKSGY4rvmBqV+KJNpFshgfOz5
X-Received: by 2002:a81:378a:: with SMTP id e132mr10922016ywa.137.1554479165414;
        Fri, 05 Apr 2019 08:46:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554479165; cv=none;
        d=google.com; s=arc-20160816;
        b=l2ONdCjKSEhh3sK5wdiPltdYeb7KSzWn3D27JBQrku5cD81C7OQrmvTKnFtF8Scvn0
         C5ST/Csq1SxOycpzLClz1Oyk30Hjblkw1IQkVSlrGJnU+360rFQduvw1KtIeUxTmaRnb
         IqCrhnmt/r0AUu28q7MqWAuTbVD19IcxOQVV6gM6wLiVPg6H6KnmHa5UuhoouAw6THHi
         7CEpSnXAPAwaXklCJ+TyYXyS12BSAhtrEIYUx8HmQZ+5Ozqlz6j63nCard2eSLGCQxCT
         81x4DDs6hh6V6L+7ssK1BSw/2Lz9gawbLr5y59ItP+mjxFxTpTvKYN5XuuLLzWSPyhkY
         8EUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=aW5eO1Y1EqwbPPw39yD2qVZTCtUucALBP6ZcE8RoydE=;
        b=pvjGj0FjMfCsOfzxxntnjVQUYdxFiT22Mi4dUZTd6pLoewWshc24ji5PRCSU90rJVM
         1zqLrEI4BUz/WoQ2RfNydSPI/14HOt34lXDgln5hHjhgp/oUbv5VPpCIQwJ5jI+oopCa
         sDWT5bKmJuEJvr4wW6IVpCOABJsprKfQcWXphVoOtfwWiVpFP/dH8vo47zoEU9E9N5i8
         je67v6qQ7rcrM/RbKnNGpPA6rfCRv0T9fEy+u6HH232N2LUA8ZrowqNQ7kgxgekFNWs8
         ke6IogOXl1Q5sAE4V9XLSjTyejAb6MmEYO6tQGTun+mkwI60hDN/vXpf57tzI1jIWY/8
         Lygw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sUuIMJJ7;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j2si3384285ybm.394.2019.04.05.08.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 08:46:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sUuIMJJ7;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35FhrLK026668;
	Fri, 5 Apr 2019 15:45:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=aW5eO1Y1EqwbPPw39yD2qVZTCtUucALBP6ZcE8RoydE=;
 b=sUuIMJJ70LKZCsyXOAF45n8HvPFH4UW3fh0oycGVdLivZfpUXrUw1KKLCZi785NH89m/
 yApQkgSt3xhCZmm01LdEACVxdeUxXM18nHTYZcoTlnr+cHKNyHVcqMjlD29JSn5qSLS0
 2Z5O2MFRjQeGU3kRhNzkohxnVzJHX88G4/32Dm7SCP7syRYYwk35b7UJl2beMBOAc1Ua
 w8u5dZYY01gtoKQJ1G0Kn0CVKjrKdR3MtCLcd1jtAMGcJPHAqUBcLk/2/Mi8NVr9OjC7
 bcsVzP/Tj8DTC7eMxmKZ2WySnfdXWQKPXogVEL4yGagQ7+bCNrr830/w/gUmWEgKVBsK dA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2rj13qnjdv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 15:45:01 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35FhQPb044273;
	Fri, 5 Apr 2019 15:45:00 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2rp35rxevv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 15:45:00 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x35FidGg024942;
	Fri, 5 Apr 2019 15:44:39 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 05 Apr 2019 08:44:38 -0700
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Juerg Haefliger <juergh@gmail.com>,
        Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de,
        Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
        Kees Cook <keescook@google.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        "Woodhouse, David" <dwmw@amazon.co.uk>,
        Andrew Cooper <andrew.cooper3@citrix.com>,
        Jon Masters <jcm@redhat.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>,
        Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
        John Haxby <john.haxby@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
        Laura Abbott <labbott@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
        Ben Hutchings <ben@decadent.org.uk>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
        Catalin Marinas <catalin.marinas@arm.com>,
        Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
        Daniel Vetter <daniel.vetter@ffwll.ch>,
        Dan Williams <dan.j.williams@intel.com>,
        Greg KH
 <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>,
        Juergen Gross <jgross@suse.com>, Jiri Kosina <jkosina@suse.cz>,
        James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
        Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
        Mark Rutland <mark.rutland@arm.com>,
        Mel Gorman
 <mgorman@techsingularity.net>,
        Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>,
        Mike Kravetz <mike.kravetz@oracle.com>, Ingo Molnar <mingo@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
        richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
        David Rientjes <rientjes@google.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Mike Rapoport
 <rppt@linux.vnet.ibm.com>,
        Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Steve Capper <steve.capper@arm.com>, thymovanbeers@gmail.com,
        Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>,
        Matthew Wilcox <willy@infradead.org>, yang.shi@linux.alibaba.com,
        yaojun8558363@gmail.com, Huang Ying <ying.huang@intel.com>,
        zhangshaokun@hisilicon.com, iommu@lists.linux-foundation.org,
        X86 ML <x86@kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Khalid Aziz <khalid@gonehiking.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
 <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
 <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <c17d5528-59a9-411a-ac1a-58af0b4def60@oracle.com>
Date: Fri, 5 Apr 2019 09:44:32 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904050106
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904050107
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/5/19 8:44 AM, Dave Hansen wrote:
> On 4/5/19 12:17 AM, Thomas Gleixner wrote:
>>> process. Is that an acceptable trade-off?
>> You are not seriously asking whether creating a user controllable ret2=
dir
>> attack window is a acceptable trade-off? April 1st was a few days ago.=

>=20
> Well, let's not forget that this set at least takes us from "always
> vulnerable to ret2dir" to a choice between:
>=20
> 1. fast-ish and "vulnerable to ret2dir for a user-controllable window"
> 2. slow and "mitigated against ret2dir"
>=20
> Sounds like we need a mechanism that will do the deferred XPFO TLB
> flushes whenever the kernel is entered, and not _just_ at context switc=
h
> time.  This permits an app to run in userspace with stale kernel TLB
> entries as long as it wants... that's harmless.

That sounds like a good idea. This TLB flush only needs to be done at
kernel entry when there is a pending flush posted for that cpu. What
this does is move the cost of TLB flush from next context switch to
kernel entry and does not add any more flushes than what we are doing
with these xpfo patches. So the overall performance impact might not
change much. It seems worth coding up.

Thanks,
Khalid

