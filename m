Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D54ECC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:48:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 838FD2192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:48:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="g5aUM/On"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 838FD2192D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01AF18E0002; Fri, 15 Feb 2019 09:48:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE50C8E0001; Fri, 15 Feb 2019 09:48:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D61888E0002; Fri, 15 Feb 2019 09:48:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 928298E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:48:17 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so6959842pgc.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:48:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LEY7b8sXzNhyukf/ItsQKn6GFmrxWnF+Kj6inOmoBHc=;
        b=RxraQQUlxU/WmVuVMcoYjk6UJkK16SNgPbii1gYYQJ9dUTPJn9ytfrxYy3NAD8F5mb
         RZ6hEZkNMHHvG7t+6cAk7UbgkJSBCQv2mWB5b8mcqs+X9mmg4p/adYKciaM9UR2bDUup
         LH5ZrDYNKyx3do0RUMOBd7x59e/2ub+1mMwGp/Ah4LZ3Fzb32rXIDgxxUeZVZtUdl3Bv
         Glf416s7WCT2oh99KLa11yxNOyG9BsMMDMXhTF0Ais+Qv7j3yHoup0SjOGin5l4qJ69p
         VHjRsHULJfQU5MGgNDqfsAwK2pEcuxOMqOC1C/mq8GHrgSsFZeelzVYTF7RaW0HvDPTy
         t73w==
X-Gm-Message-State: AHQUAubNOadvTzwHi+6Bnj10yDnmiHX2F9s6K95IxZK715/FlMf/3rNw
	md3O75PhR1zPcho5ztlvMqBMX0eIBRA3k6+4KmUIwYQms+yYqbGAoF/PONMbmLJhKgdXcfB5Kh8
	9jnQ41D9ZD4c+QvxV/ut6MY4bgc9vot1g8VMgxEBkXm/y6t7Wl/ec7NcL+kNk8en2QA==
X-Received: by 2002:a62:b248:: with SMTP id x69mr10107194pfe.256.1550242097041;
        Fri, 15 Feb 2019 06:48:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/oxOSD1y8IHakI9Qg17Pk5xa1GDgxN+Wl50D+RwWOawvDEdSQpTW0fdfkNzJbL+fjljj6
X-Received: by 2002:a62:b248:: with SMTP id x69mr10107143pfe.256.1550242096190;
        Fri, 15 Feb 2019 06:48:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550242096; cv=none;
        d=google.com; s=arc-20160816;
        b=uq8SDOm2Z7da71n2bA7jObAgIAveDAlDSQMNUmLbZzvXByhv1ZzExRr+yGykiRQUym
         hRpA+ypfxXY49tQI51Fo1h3uaqdzb671slpBR4UmWHbd4NhvnjrkC51lFb/+Ma87trdQ
         fTVI4qxrhHQLW/KtUrJWxmSDCIy5DkwGQLzLTOc4zBHNQg5RAGNbZGZCjoU1LZQW0Tia
         J/xo8Xut9n+jDBdVcv5bAX76E7sUZOdXBCtAWY9yC3Og+Q6CeV1P72zD3J8rgwaoQB8k
         3RxvlGXU1U5HCanKZ12IJ20vh+bnTWcURk0wC8pEw0rZMFmKMcYUkIZRS7l0LmRMe/Z8
         0CLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=LEY7b8sXzNhyukf/ItsQKn6GFmrxWnF+Kj6inOmoBHc=;
        b=Kxxz5hxWVHTB9/qS2jb1dWydaMPR2WF2ogoCDE1WnWLXWDDFx/WbEBRyADLeIN/0TO
         AvNAeIF0xXRCXvJsbylieK7TJSBc78SSQl+NPKbdklVED43blyww02qJKnTjxfnQZRq4
         t6UH9AqhFzudusG9VuAfE8k9CWFsI2kAV+rmewx17YZ9e9nzOFSdTOp54CenPZFbFEmi
         U+Nm5aL8F8Ce6sabunvDd3zA2yC3mO4au/KID11/lBxmiL+o4o5ADF3p7FYQzTJKyNZA
         nKIE1ZWvPhXkGPE4M1D3AhP5xL9tw3r0ZWFgiUPd9MFckdxgnrrL/pOiKYsf1VItOki/
         ZZlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="g5aUM/On";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 61si2686407plc.364.2019.02.15.06.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 06:48:16 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="g5aUM/On";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1FEhRvN145107;
	Fri, 15 Feb 2019 14:47:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LEY7b8sXzNhyukf/ItsQKn6GFmrxWnF+Kj6inOmoBHc=;
 b=g5aUM/On3juV/6dNCJ2/OPN3ycrzeV3k+bTRNIwfJ5yfySj0ogZ65V6Ery9ajs+y+1K6
 xQDwcYHlLsxTVGxBV8ZWA3LT2FJhKKd2yIk4Ltc2YEVL1Q8qeDbrVX4rnZKdxo60pC2h
 a+9qBgfNukozi/KUtGkG6l3uJCPI0dsggN1RLy/LdTqBKeYBM6/LDe8OCznIOKL0sGnt
 dSfomHBKKf5Dzv2Zrv1yTCgOfa8hasNabaEVOnl+MwIQ+1JpEb/91xKVgN9JLyGsclyL
 3+8N2FM42kLuumKB62tz2JlM/ZeCqYl8mlM8oMcSNa/aJxdVwcgE7ZEbX+Y+ODel/LYk pQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2qhrekx7nq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Feb 2019 14:47:44 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1FEliLE020615
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Feb 2019 14:47:44 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1FEldPL008491;
	Fri, 15 Feb 2019 14:47:39 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 15 Feb 2019 14:47:39 +0000
Subject: Re: [RFC PATCH v8 08/14] arm64/mm: disable section/contiguous
 mappings if XPFO is enabled
To: Mark Rutland <mark.rutland@arm.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com, Tycho Andersen <tycho@docker.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <0b9624b6c1fe5a31d73a6390e063d551bfebc321.1550088114.git.khalid.aziz@oracle.com>
 <20190215130942.GD53520@lakrids.cambridge.arm.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <259cac45-3337-d446-5abc-21b694d916e1@oracle.com>
Date: Fri, 15 Feb 2019 07:47:37 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190215130942.GD53520@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902150102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 6:09 AM, Mark Rutland wrote:
> Hi,
>=20
> On Wed, Feb 13, 2019 at 05:01:31PM -0700, Khalid Aziz wrote:
>> From: Tycho Andersen <tycho@docker.com>
>>
>> XPFO doesn't support section/contiguous mappings yet, so let's disable=
 it
>> if XPFO is turned on.
>>
>> Thanks to Laura Abbot for the simplification from v5, and Mark Rutland=
 for
>> pointing out we need NO_CONT_MAPPINGS too.
>>
>> CC: linux-arm-kernel@lists.infradead.org
>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
>=20
> There should be no point in this series where it's possible to enable a=

> broken XPFO. Either this patch should be merged into the rest of the
> arm64 bits, or it should be placed before the rest of the arm64 bits.
>=20
> That's a pre-requisite for merging, and it significantly reduces the
> burden on reviewers.
>=20
> In general, a patch series should bisect cleanly. Could you please
> restructure the series to that effect?
>=20
> Thanks,
> Mark.

That sounds reasonable to me. I will merge this with patch 5 ("arm64/mm:
Add support for XPFO") for the next version unless there are objections.

Thanks,
Khalid

>=20
>> ---
>>  arch/arm64/mm/mmu.c  | 2 +-
>>  include/linux/xpfo.h | 4 ++++
>>  mm/xpfo.c            | 6 ++++++
>>  3 files changed, 11 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index d1d6601b385d..f4dd27073006 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -451,7 +451,7 @@ static void __init map_mem(pgd_t *pgdp)
>>  	struct memblock_region *reg;
>>  	int flags =3D 0;
>> =20
>> -	if (debug_pagealloc_enabled())
>> +	if (debug_pagealloc_enabled() || xpfo_enabled())
>>  		flags =3D NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>> =20
>>  	/*
>> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
>> index 1ae05756344d..8b029918a958 100644
>> --- a/include/linux/xpfo.h
>> +++ b/include/linux/xpfo.h
>> @@ -47,6 +47,8 @@ void xpfo_temp_map(const void *addr, size_t size, vo=
id **mapping,
>>  void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
>>  		     size_t mapping_len);
>> =20
>> +bool xpfo_enabled(void);
>> +
>>  #else /* !CONFIG_XPFO */
>> =20
>>  static inline void xpfo_kmap(void *kaddr, struct page *page) { }
>> @@ -69,6 +71,8 @@ static inline void xpfo_temp_unmap(const void *addr,=
 size_t size,
>>  }
>> =20
>> =20
>> +static inline bool xpfo_enabled(void) { return false; }
>> +
>>  #endif /* CONFIG_XPFO */
>> =20
>>  #endif /* _LINUX_XPFO_H */
>> diff --git a/mm/xpfo.c b/mm/xpfo.c
>> index 92ca6d1baf06..150784ae0f08 100644
>> --- a/mm/xpfo.c
>> +++ b/mm/xpfo.c
>> @@ -71,6 +71,12 @@ struct page_ext_operations page_xpfo_ops =3D {
>>  	.init =3D init_xpfo,
>>  };
>> =20
>> +bool __init xpfo_enabled(void)
>> +{
>> +	return !xpfo_disabled;
>> +}
>> +EXPORT_SYMBOL(xpfo_enabled);
>> +
>>  static inline struct xpfo *lookup_xpfo(struct page *page)
>>  {
>>  	struct page_ext *page_ext =3D lookup_page_ext(page);
>> --=20
>> 2.17.1
>>


