Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 773F2C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16B552184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:57:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5fGlsPen"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16B552184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A3826B0008; Fri,  5 Apr 2019 11:57:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82AAA6B000D; Fri,  5 Apr 2019 11:57:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3EB6B0266; Fri,  5 Apr 2019 11:57:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 497656B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:57:21 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id v193so5700721itv.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WRUJkxssls3GC9KBeX15T16DarlkEO0tjOUvcslQoD0=;
        b=Es/8rw7/JFU4i1J6PqFRjI0Mu7zPrhSk26+s0Gjny3pjid0XFTqAYDpqeAehOV7va+
         mFoEO/RbZmI28g1hz3OUU+Xmj1xMCNtVBqJB7XdCzp6STLt9+lxIWL/nyz4jSyjPJ9Aj
         iyUEgc4OyNZtc+ynmBHXycErcqc0H0XWP3e/JCBmKIUPOp5bV0LpWrygZXsYm3yWM+dx
         359Fvm4sZ+iMxl+EyNU0VFTxv/PKBiJuVuyJ0hQwHsHZdwvrvRQj1iTsuRGw1zavfs1t
         o+PXwuyr+OJ3q0bDuMHl91Wu/8GrxkleNtQJR0iMqu6qKWSbnO1qNREz28ZfVETYJJjL
         yMCw==
X-Gm-Message-State: APjAAAXqBSi5OkRRfgAdOlLyUmKHNXXZd0BnkJLsIXfwq9MgTgSfJjNC
	WxvBjeTfwezLvn+1ytE+jkq4MOvJgG247HEBx0SdRdyUVKDu8La7iT2JTxcySA/gWQnwdZg4rVM
	mtxM0RLiOPQfRNaTVXI/jxMO7NdxKYBesH9W05i7t6PJgCphyFEkLdWhsXY9WWDRnLA==
X-Received: by 2002:a02:9f08:: with SMTP id z8mr10378600jal.6.1554479840999;
        Fri, 05 Apr 2019 08:57:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1PrWxHyoTxZtMbAtVAfgCMip7yC4O/3qIsgIO0PtlTM3f0anbDv4iWtmZzkgeLihUAGqJ
X-Received: by 2002:a02:9f08:: with SMTP id z8mr10378530jal.6.1554479840010;
        Fri, 05 Apr 2019 08:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554479840; cv=none;
        d=google.com; s=arc-20160816;
        b=kj1AX9CPuuumCj8tEZcCktATKt3Zj9IpGIM2sQ3AsQF5PF1vhmww6BwQ3e2C/UEreS
         9TzLVcTjdaJnDus73DbbZEqdoE4TkFlBxiW2tR5sRjDpTPy+W/zB1Un0QdzJfc5yML/h
         EaSjsrEpgkmvIQHvCqNir2qccJH8ROpyBE/Poq7CwXzZ6rq+qrH6UiE4IqGPNn8gtdgy
         HKEEmAmWLK0jJWw9wddp1SjOKMUZki5y8WAJmHYmY1YfFDZMapyF+/mVikbhvyEW/Oey
         7BuVjAYGn822s+cjKj6fjunwtY2uTHKCtMF5kLYf1/om4XiavQ+jqFq+94scWQlTq+0n
         ZdaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=WRUJkxssls3GC9KBeX15T16DarlkEO0tjOUvcslQoD0=;
        b=cRa4dn2EPvMB2GlMvni05QrBNSTED8vGzEoYZY1GJNKWxitvFBO1ytOgvuY+m6mcPg
         A0t8e4XL9en/5PomixrL7ZeO3nTTjyPTrvTAJRNfItFpEtGIfZa+9brit8N7xdBZElD5
         jBFPYAICIVn1s6YP8BrrkuxrCfCo25Jb3oUqoQQ4Jej8UnwVvY32fVdk1FpZujVJYEA4
         0KK3hc49d2yK1QCLui5eZ8ZHrXRfzfm1l19B7yEzA+niHSKBCQEKTJ7tLHs/yHrIb2w9
         V8hawKk2PqUIn1To2G+S2ny8zIw/oh1btrYpXSvPiMYaeGjH0xqi1DfQhzGh8kFSsszC
         njuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5fGlsPen;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p22si10879646ioh.160.2019.04.05.08.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 08:57:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5fGlsPen;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35Fresr028235;
	Fri, 5 Apr 2019 15:56:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=WRUJkxssls3GC9KBeX15T16DarlkEO0tjOUvcslQoD0=;
 b=5fGlsPeny3lKV5g4pGEfyGSW7lDg4Vp/7R/YLGfDWdSQfJAi/h22T55ffkv4ltHWyIOU
 rAe160eHi+OPda5VW5bIJ17tYKirqxZ3FfAmTkzs3T6JmXour2Y6F7BGar33JBZhE+YQ
 X0nX1ToN5pxh4JoumB4NPi/UH8mcFqjhbd2xY/YdbpNbXIhHHk5XmYaBot//EigNftSN
 WeBM4E8n2cTDaMS408OIlTHpzhP0XJ7TRglzPkQQr0vB5xqqKDd2cOL8aiLheHbITKm8
 wX4fV0Ua8BAynkxn7APv9evY2t3Egcwyd0V/2DPRWfWJP8HZljD4cqzl1PCstN4ssI2v zw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rhwydnud9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 15:56:19 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x35FtN0b049678;
	Fri, 5 Apr 2019 15:56:19 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2rp34jepkt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 05 Apr 2019 15:56:19 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x35FuApl008745;
	Fri, 5 Apr 2019 15:56:10 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 05 Apr 2019 08:56:09 -0700
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
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <66dba8f0-18dc-e623-9a1a-21e3e7ba7790@oracle.com>
Date: Fri, 5 Apr 2019 09:56:03 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904050108
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9218 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904050108
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/5/19 9:24 AM, Andy Lutomirski wrote:
>=20
>=20
>> On Apr 5, 2019, at 8:44 AM, Dave Hansen <dave.hansen@intel.com> wrote:=

>>
>> On 4/5/19 12:17 AM, Thomas Gleixner wrote:
>>>> process. Is that an acceptable trade-off?
>>> You are not seriously asking whether creating a user controllable ret=
2dir
>>> attack window is a acceptable trade-off? April 1st was a few days ago=
=2E
>>
>> Well, let's not forget that this set at least takes us from "always
>> vulnerable to ret2dir" to a choice between:
>>
>> 1. fast-ish and "vulnerable to ret2dir for a user-controllable window"=

>> 2. slow and "mitigated against ret2dir"
>>
>> Sounds like we need a mechanism that will do the deferred XPFO TLB
>> flushes whenever the kernel is entered, and not _just_ at context swit=
ch
>> time.  This permits an app to run in userspace with stale kernel TLB
>> entries as long as it wants... that's harmless.
>=20
> I don=E2=80=99t think this is good enough. The bad guys can enter the k=
ernel and arrange for the kernel to wait, *in kernel*, for long enough to=
 set up the attack.  userfaultfd is the most obvious way, but there are p=
lenty. I suppose we could do the flush at context switch *and* entry.  I =
bet that performance still utterly sucks, though =E2=80=94 on many worklo=
ads, this turns every entry into a full flush, and we already know exactl=
y how much that sucks =E2=80=94 it=E2=80=99s identical to KPTI without PC=
ID.  (And yes, if we go this route, we need to merge this logic together =
=E2=80=94 we shouldn=E2=80=99t write CR3 twice on entry).

Performance impact might not be all that much from flush at kernel
entry. This flush will happen only if there is a pending flush posted to
the processor and will be done in lieu of flush at the next context
switch. So we are not looking at adding more TLB flushes, rather change
where they might happen. That still can result in some performance
impact and measuring it with real code will be the only way to get that
number.

>=20
> I feel like this whole approach is misguided. ret2dir is not such a gam=
e changer that fixing it is worth huge slowdowns. I think all this effort=
 should be spent on some kind of sensible CFI. For example, we should be =
able to mostly squash ret2anything by inserting a check that the high bit=
s of RSP match the value on the top of the stack before any code that pop=
s RSP.  On an FPO build, there aren=E2=80=99t all that many hot POP RSP i=
nstructions, I think.
>=20
> (Actually, checking the bits is suboptimal. Do:
>=20
> unsigned long offset =3D *rsp - rsp;
> offset >>=3D THREAD_SHIFT;
> if (unlikely(offset))
> BUG();
> POP RSP;
>=20
> This means that it=E2=80=99s also impossible to trick a function to ret=
urn into a buffer that is on that function=E2=80=99s stack.)
>=20
> In other words, I think that ret2dir is an insufficient justification f=
or XPFO.
>=20

That is something we may want to explore further. Closing down
/proc/<pid>/pagemap has already helped reduce one way to mount ret2dir
attack. physmap spraying technique still remains viable. XPFO
implementation is expensive. Can we do something different to mitigate
physmap spraying?

Thanks,
Khalid


