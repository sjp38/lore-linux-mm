Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3140EC282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4BAA206BA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WlX0xHZB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4BAA206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 596076B000C; Fri,  5 Apr 2019 13:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 545CD6B000D; Fri,  5 Apr 2019 13:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E4706B0010; Fri,  5 Apr 2019 13:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC7F6B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 13:39:07 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v193so5975729itv.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 10:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yhCfl/dsZCpeyHFNxA3bv0f5LElE2bX0taQuTIsB/uk=;
        b=Hf74R2CQyyAiwHeMS6WytopLdAc3s6TtDMzAFm8lXc9qae/1JGEHlacuvizZFwcFsy
         66d1ELr0diMaSM6m7uXAFkKpnjrkW6djetrpyPkm5Uwlh83sPrPrDWldw2wM2YFcHDHl
         W9lUSPVTJEY+IaQPalesBc+qpmPMGikYfz4KEoJcSMU0PHBOgwOqWLsRfVIgQGY5/aFP
         y9J4blGXyTOeQ2qX+2o3LAI6c3X3wuDHZsa0doCrvT7L60P/Qw1wfaajg5TXBSU66uB/
         AYuPnpFP0DeJtY1rrAcNBcq2xJ+zPq9WSgjDz5nioAb0D7Zb/z0/om7GVQSgezbUrQJA
         adBQ==
X-Gm-Message-State: APjAAAUlbuPcSE7iI6O1bRdLQksOr5s8xlnyDzN7+kV83yZjuwIEvUnU
	SgHY4RW+X4DbgzzLMcqJVK1XYVhVYOIAdxjR0QIZSF08mGp5/555en0WpnHWrCzhRyhc7GbpdKs
	a6JY6EZJ9ROQdBK5aiPhJ6KUxyaeyK3iQFCSyE4CYP3iLpb9+NJgtKx89jDsVESd2ww==
X-Received: by 2002:a24:90:: with SMTP id 138mr10324296ita.69.1554485946820;
        Fri, 05 Apr 2019 10:39:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy24v6ffAtw96giet0yF/0hXHYDAHadFIbOMBAH/cCLwNcVliwoB0gP4ki9snfNAW12QtJt
X-Received: by 2002:a24:90:: with SMTP id 138mr10324235ita.69.1554485945847;
        Fri, 05 Apr 2019 10:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554485945; cv=none;
        d=google.com; s=arc-20160816;
        b=PZSV2d9hz5MQS0JnaYuWVnGFDTO42pB1RCYUvrmJRCzE4XN7IFy9tfxoTD682DFF6f
         BZO5PelGDXisAp1UfkQ9NDZcHuljHNtkyyloaTnCZ98LprU1sa5PXTzUakRQwqxpsyq5
         yKvXljK0YmeFaQfT10I/CmrB5HkQEyDmuDuDwTJehPBczEsqH+jjkFhMCcVGNPQiRYig
         JA9J+0EniOJJlLAvWsckrZe5qSNpADc8XCKcX3F2v/Kf9YtKA86nTL0m/X8+fXCiivh9
         OFW8G7ABKwrQZ2coxV5kut5JJPKv1EL2Ic102G7dEzOKKs1pv+m+2+6cbSOmxNlk1cwu
         Oe0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=yhCfl/dsZCpeyHFNxA3bv0f5LElE2bX0taQuTIsB/uk=;
        b=oTLJb+XehsFhbH5wJlehH8wURziBnoImy0ERUVzS3eFM9pHzZDyUkKdrbQKzxvmU5F
         WzpjFezpJGtOCvfHJkC8T439v6GyQz1000Zun6CVeCbhl9ZNzQDB8FoDufgHcTP8r8Kl
         f9kwCvDLFJ6/Iw+Hk3C69QQe0Nwbd1rQKn9jw+/Q25qntPhgfybtQIcQjPeUYDkEiq30
         8enRATmMcoKU+6QjUyHz+VS83WsuLT7ThUtYQ1jAukz91riE9ERkDJxwbtV8GpQ5zHzy
         LYRxSUjtMwHzUuKARa/cpg7/4rsADaCpXEx/DaSGlwZWeSJ2gNFHnI8LSEbG5HLl6mCS
         kItA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WlX0xHZB;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d12si11539222ioc.128.2019.04.05.10.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 10:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WlX0xHZB;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35HNZ7d103905;
	Fri, 5 Apr 2019 17:37:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=yhCfl/dsZCpeyHFNxA3bv0f5LElE2bX0taQuTIsB/uk=;
 b=WlX0xHZB2A31SaXIF2spbCzB8KM8iXDHR7cFwFgQs92U/71T9SrzQ/av0+D3eO2Xgt00
 H/4X17j85Kv7DS68kFzTfO8cf7M0aBPctEvOH04kReF/7KdczslNVrO7DWFQvgpE48K8
 PG3UfTczU/CY0ZQuuslxMa56/5ue12RXmja3oVPl63a5Of2LFktgGqusoU0vCC8D90Ob
 bDL+fQzy6n5FssRfIaauBnoCRIkmzOPqeRuwe0/yI7Fh2H7nyHZOSVh2RCRYz0Lcfz4b
 0Z55Pb4WiH8VVDqviGPOmNF2OX4p3BOxwFvWVCGdnsj+fCB8NMzq9r7O5kKCCRWAJ8Ns yw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rhwydpafe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 17:37:44 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35HZgSJ098019;
	Fri, 5 Apr 2019 17:35:44 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2rp369ga9b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 17:35:43 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x35HZR1K013561;
	Fri, 5 Apr 2019 17:35:27 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 05 Apr 2019 10:35:26 -0700
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>,
        Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
        jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>,
        liran.alon@oracle.com, Kees Cook <keescook@google.com>,
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
        Matthew Wilcox <willy@infradead.org>, yaojun8558363@gmail.com,
        Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Khalid Aziz <khalid@gonehiking.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
 <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
 <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
 <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
 <36b999d4-adf6-08a3-2897-d77b9cba20f8@intel.com>
 <E0BBD625-6FE0-4A8A-884B-E10FAFC3319E@amacapital.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <9a1dcf02-a737-33c2-fee4-f475069e731f@oracle.com>
Date: Fri, 5 Apr 2019 11:35:22 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <E0BBD625-6FE0-4A8A-884B-E10FAFC3319E@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904050118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904050118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/5/19 10:27 AM, Andy Lutomirski wrote:
> At the risk of asking stupid questions: we already have a mechanism for=
 this: highmem.  Can we enable highmem on x86_64, maybe with some heurist=
ics to make it work well?
>=20

I proposed using highmem infrastructure for xpfo in my cover letter as
well as in my earlier replies discussing redesigning
xpfo_kmap/xpfo_kunmap. So that sounds like a reasonable question to me
:) Looks like we might be getting to an agreement that highmem
infrastructure is a good thing to use here.

--
Khalid

