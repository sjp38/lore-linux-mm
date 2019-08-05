Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0ABEC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9834D2064A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:57:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="KNZUDma6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9834D2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BDF36B0005; Mon,  5 Aug 2019 11:57:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16E916B0006; Mon,  5 Aug 2019 11:57:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05CCD6B0007; Mon,  5 Aug 2019 11:57:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA3476B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 11:57:06 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k21so92718413ioj.3
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 08:57:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=cbBP8N3KN1Lt/OuHm+MgfpoWdZsU7dxj+qA8fUVOQUI=;
        b=T5FyxgbFJMJsjfoMxyUskpIFNN1lYL1DdT0nTG4oDgfHP1WJLhqwQKOeBHsYy0XhLE
         kb4yVPuB/EI+jiM/d4W/U9QfLn8U98V10gyxtYVSYA3OWOK1U64iq70AWFJ9/XlNJakn
         HHLDRHrggcv0mZd6EKXOLjJxLv9yRJdpBeaW+1ozm4XJymkLIa5MKlA7yLBiQrzYnysa
         eXYU8p8gHeF6q7ct7wZg2xrrlmlG0I3rXB+9aun9Lht6zmbG4TGuUNO4KrZuoeo8CAoL
         0KyjJLAbBJ5AZOGQEMk6j8CW9/+DocCsnZjm8KBRUIPXtiU//z85fpE+jEdZbeVNcwA+
         nP5w==
X-Gm-Message-State: APjAAAXslRfoQsR+BnVxUvKl/ptml+TQ0BSfFrYlavtWvtPTuIzzWhNA
	AhKPL8o/K9TjQ+pw9nGULlrWyXrG4HPszu0JQdr6UVteankRs7XTwSg8Vw5hg6JxC1mce/nxmor
	LbwG3xS8cfWeOrz/4mGdxy3dvhMtCLl2khq9rx833znPyr9FttAtK9/4F/J9hp/g+OQ==
X-Received: by 2002:a6b:8bcb:: with SMTP id n194mr13647613iod.194.1565020626642;
        Mon, 05 Aug 2019 08:57:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR6j/eHIbq/uRs3DF9MpTw2ZiMjlFEJoXfFd3mALHIgJJmhazrCdyMQt3/G5CIAA672V3e
X-Received: by 2002:a6b:8bcb:: with SMTP id n194mr13647538iod.194.1565020625739;
        Mon, 05 Aug 2019 08:57:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565020625; cv=none;
        d=google.com; s=arc-20160816;
        b=wWwAjSXon6hWfE2wBNKhRoc5VwGXHgtxOkrU6M5v64FFTseuYGGqnJ4HYovF+1BIoN
         X0EGFcuNHX1BiWi7ASGlMLwCnqSVr9wk+j07q0twg+kZ4omrfS73p5JWCUaBzk9Z3BQc
         t+s3A8D+mUGTddnpvVOjQ3poGVCxoGFeYwmAZNaS/muyXeYSwGwo4UBlayBvQ8UEr0RO
         xet51lwd263h6j4oF97IbX++mihqB2/3KZIn0wYM9T978Kns6OZXGlGkX84BDwV0+C3m
         KdjfMEwwiA5dpZQidlzejoaX//9tHzR7JRr7lpvFMVOPeH+10HmUSEmf4B/ZjsO0HksO
         0VBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=cbBP8N3KN1Lt/OuHm+MgfpoWdZsU7dxj+qA8fUVOQUI=;
        b=LeDn/b1J4cUC+ZmH01jxb93SxLoTGrRgjNFprUp5nOHLJsVX3XIB2I9OZ2Dhspom5q
         L7SZyA7ElzmXbvuw0zFbo7CLq8ir8279r9SN7Zcs/C2tRNbPMYaqkQwCrywNNK4PfOYh
         mq/aI7ApsYdgOBEnK+BD3h2IfuF4DyxuSKJ/aBaRqwfBKUAGX1eeNqdU9vy5Asy7Ekgb
         VByG0GWEt2+I4g/pdGuFalnb+oxEywGfH3wPkYU4np0GodTgwRhdZ637g1geAkhY7nyB
         JpB1gmNnlmcuf3/ZQcjTpg2TbA9Qmzp8warGPcN7MjUkEyCQjL7gkKpzPAIy64chhgSv
         Q/hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KNZUDma6;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a13si113430606jal.98.2019.08.05.08.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 08:57:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KNZUDma6;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75FsNWh057944;
	Mon, 5 Aug 2019 15:56:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=cbBP8N3KN1Lt/OuHm+MgfpoWdZsU7dxj+qA8fUVOQUI=;
 b=KNZUDma6fITUwU1tvaB+HpNehPHeFdN+M5R8VVACwjv2x5BUhh8NGDrgyEanbuRZ/97U
 qRGBId4ZPb80PXRgRx5w/Tx+l39RLzsQ9f65H/JOZil1CVs+Z8H+HtTylazqmHbKTInW
 +FuLkC33yFB+R5mwj/YMJXo9JiJW4WzCaXtx64AnF5pdQPbf2FKYuW8Cdma7NWSvLdNU
 HCluTFUDxSP9yrQJuWC/DsTUJwIOD2VuOrqOKHfLbx7IpYZBBTNDjM6ezUjoGyKgdU+J
 8SESmc35GAPz7qxCw5jW8TKSnU4mR/G09hgXDvgxqTr+Z1cY3G38B1kwrKyyB6oOwkNz dA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u527pg47w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 15:56:49 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75Fqpfq017054;
	Mon, 5 Aug 2019 15:56:49 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2u5233baxv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 15:56:49 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x75FukQD028308;
	Mon, 5 Aug 2019 15:56:47 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 08:56:46 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 13.0 \(3570.1\))
Subject: Re: [PATCH v3 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190805132854.5dnqkfaajmstpelm@box.shutemov.name>
Date: Mon, 5 Aug 2019 09:56:45 -0600
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <19A86A16-B440-4B73-98FE-922A09484DFD@oracle.com>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
 <20190731082513.16957-3-william.kucharski@oracle.com>
 <20190801123658.enpchkjkqt7cdkue@box>
 <c8d02a3b-e1ad-2b95-ce15-13d3ed4cca87@oracle.com>
 <20190805132854.5dnqkfaajmstpelm@box.shutemov.name>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Mailer: Apple Mail (2.3570.1)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908050176
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050176
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 5, 2019, at 7:28 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
>>=20
>> Is there different terminology you'd prefer to see me use here to =
clarify
>> this?
>=20
> My point is that maybe we should just use ~HPAGE_P?D_MASK in code. The =
new
> HPAGE_P?D_OFFSET doesn't add much for readability in my opinion.

Fair enough, I'll make that change.

>> OK, I can do that; I didn't want to unnecessarily eliminate the
>> VM_BUG_ON_PAGE(PageTransHuge(page)) call for everyone given this
>> is CONFIG experimental code.
>=20
> If you bring the feature, you bring the feature. Just drop these =
VM_BUGs.

OK.

> I'm not sure. It will be costly comparing to PageTransCompound/Huge as =
we
> need to check more than flags.
>=20
> To exclude hugetlb pages here, use VM_BUG_ON_PAGE(PageHuge(page), =
page).
> It will allow to catch wrong usage of the function.

That will also do it and that way we will better know if it ever =
happens,
which of course it shouldn't.

>> This routine's main function other than validation is to make sure =
the page
>> cache has not been polluted between when we go out to read the large =
page
>> and when the page is added to the cache (more on that coming up.) For
>> example, the way I was able to tell readahead() was polluting future
>> possible THP mappings is because after a buffered read I would =
typically see
>> 52 (the readahead size) PAGESIZE pages for the next 2M range in the =
page
>> cache.
>=20
> My point is that you should only see compound pages here if they are
> HPAGE_PMD_ORDER, shouldn't you? Any other order of compound page would =
be
> unexpected to say the least.

Yes, compound pages should only be HPAGE_PMD_ORDER.

The routine and the check will need to be updated if we ever can
allocate/cache larger pages.

>> It's my understanding that pages in the page cache should be locked, =
so I
>> wanted to check for that.
>=20
> No. They are get locked temporary for some operation, but not all the
> time.

OK, thanks for that.

>> I don't really care if the start of the VMA is suitable, just whether =
I can map
>> the current faulting page with a THP. As far as I know, there's =
nothing wrong
>> with mapping all the pages before the VMA hits a properly aligned =
bound with
>> PAGESIZE pages and then aligned chunks in the middle with THP.
>=20
> You cannot map any paged as huge into wrongly aligned VMA.
>=20
> THP's ->index must be aligned to HPAGE_PMD_NR, so if the combination =
VMA's
> ->vm_start and ->vm_pgoff doesn't allow for this, you must fallback to
> mapping the page with PTEs. I don't see it handled properly here.

It was my assumption that if say a VMA started at an address say one =
page
before a large page alignment, you could map that page with a PAGESIZE
page but if VMA size allowed, there was a fault on the next page, and
VMA size allowed, you could map that next range with a large page, =
taking
taking the approach of mapping chunks of the VMA with the largest page
possible.

Is it that the start of the VMA must always align or that the entire VMA
must be properly aligned and a multiple of the PMD size (so you either =
map
with all large pages or none)?

>> This is the page that content was just read to; readpage() will =
unlock the page
>> when it is done with I/O, but the page needs to be locked before it's =
inserted
>> into the page cache.
>=20
> Then you must to lock the page properly with lock_page().
>=20
> __SetPageLocked() is fine for just allocated pages that was not =
exposed
> anywhere. After ->readpage() it's not the case and it's not safe to =
use
> __SetPageLocked() for them.

In the current code, it's assumed it is not exposed, because a single =
read
of a large page that does no readahead before the page is inserted into =
the
cache means there are no external users of the page.

Regardless, I can make this change as part of the changes I will need to =
to
reorder when the page is inserted into the cache.

>> I can make that change; originally alloc_set_pte() didn't use the =
second
>> parameter at all when mapping a read-only page.
>>=20
>> Even now, if the page isn't writable, it would only be dereferenced =
by a
>> VM_BUG_ON_PAGE() call if it's COW.
>=20
> Please do change this. It has to be future-proof.

OK, thanks.

>> My thinking had been if any part of reading a large page and mapping =
it had
>> failed, the code could just put_page() the newly allocated page and =
fallback
>> to mapping the page with PAGESIZE pages rather than add a THP to the =
cache.
>=20
> I think it's must change. We should not allow inconsistent view on =
page
> cache.

Yes, I can see where it would be confusing to anyone looking at it that =
assumed
the page must already be in the cache before readpage() is called.

>> If mprotect() is called, wouldn't the pages be COWed to PAGESIZE =
pages the
>> first time the area was written to? I may be way off on this =
assumption.
>=20
> Okay, fair enough. COW will happen for private mappings.
>=20
> But for private mappings you don't need to enforce even RO. All =
permission
> mask should be fine.

Thanks.

>> Once again, the question is whether we want to make this just RO or =
RO + EXEC
>> to maintain my goal of just mapping program TEXT via THP. I'm willing =
to
>> hear arguments either way.
>=20
> It think the goal is to make feature useful and therefore we need to =
make
> it available for widest possible set of people.
>=20
> I think is should be allowed for RO (based on how file was opened, not =
on
> PROT_*) + SHARED and for any PRIVATE mappings.

That makes sense.

>> I did that because the existing code just blindly sets VM_MAYWRITE =
and I
>> obviously didn't want to, so making it a variable allowed me to shut =
it off
>> if it was a THP mapping.
>=20
> I think touching VM_MAYWRITE here is wrong. It should reflect what =
file
> under the mapping allows.

Fair enough.

Thanks again!
    -- Bill=

