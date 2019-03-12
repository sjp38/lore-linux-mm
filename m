Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8DC7C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45764205C9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:03:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lUPTn3ae"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45764205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D85388E0003; Tue, 12 Mar 2019 14:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D33978E0002; Tue, 12 Mar 2019 14:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE1868E0003; Tue, 12 Mar 2019 14:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9878E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:03:27 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y6so2942774qke.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=MVE2QKSq0HBi0ifLK6r/8roWIb0piqG77FSS+ol3O3k=;
        b=XDwMYXGPUBL1zHlwpS86bO3q5EDHXMpAkTC/fSKtOhXuUOkyIkKF1ytCwFTOY4s93k
         PKX6uH9mXbsKEYspQA8eCBNa2LtPgeWC9Acqu6vViMwyzOQhGyjk3gJ9smv3NX/hnsCk
         qAtFHb0ZZZAcw5BVQ9hVElN8KX5cfSj0/uTUNOBXHUXpQ8uBd307Bi0vOQ/pHPAPkp6K
         JluSLP99Wh73bMeOLCuD1pXUlBDo8VTfNHlDrmwdTzXfaBjOmav4LWfUTeaizQFtn3bz
         4V/ZeVDsv1EauJd9b9dUkMJauu/CIPXYL/lN83kfO9EbZ5l/lOUKthbF9fJDbKnGS2RY
         U4nQ==
X-Gm-Message-State: APjAAAWlS/D9dib/P3IMNYpvE/B/KUPOhnwR36a3R0dbY6OCgvm1hByz
	f5pTzOn4XTsZBOVveoCXN/7EN9xCJnmzugfni257rgZLIgaZIx7fkUyyXLvpZv5fbTlaFKroMNu
	IwSrBe3S79kGoJcn9xJ0zzZ48dRe2BPO/+/rtHzoztQWDU+zI17asjFnLhpLVe8vdbQ==
X-Received: by 2002:a0c:c486:: with SMTP id u6mr11182589qvi.145.1552413807292;
        Tue, 12 Mar 2019 11:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYAfGFOJdt0AHEOQVBVl2Wsx37o7Oc5iA76fDoVZ/1Urh0xnIG7zBiRzlepWZThxBkBTzQ
X-Received: by 2002:a0c:c486:: with SMTP id u6mr11182533qvi.145.1552413806533;
        Tue, 12 Mar 2019 11:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552413806; cv=none;
        d=google.com; s=arc-20160816;
        b=XNc+dlaydMub+O1c0oekFDU6zpur3FKyzQCpmWhRzCIh4zkOM4OmDCPh842XPN18/y
         wkb0H2NRhZnDNSVbEDH78y8txI5mGVzsLGAYPUrruA2ImZk7Q08EvpwqVIhN8raDPhOQ
         LXWftmfrm8RbCRccJpn2fHG8WS19KxbytrezsejbGleN+fflYCHjxL3FFcqvH3+xai6q
         Uzivc4nOyutUjYT8NtAGEB5BDFtaFN3rQouGn3ATi6Uyu6LeF4lUG+QMNOhewbcRSHry
         W2cofgK1d+4Sz//RGQf2cEgRFTcfUOHd6X531Z6a0ajbxp3Au38DsKPiOs1O305+97gD
         INwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=MVE2QKSq0HBi0ifLK6r/8roWIb0piqG77FSS+ol3O3k=;
        b=trVF5Se3rUmT6JaUDnxRAVNlWjTbzeoP+I2l72RshMDwrVAiXzBaRb//lzROU7kJDH
         +dIT2cI2NazgTXgIvYnhDZGbIVGURNGqd7yLzj+pKwti9TJ2AKIrjyqKbDp8pHU/kC8M
         7aCWLPGTGmBJTBem/2CLfpn5Mcpo6Ke4lFPiEKGUmI0X0l+Wm+spjcXz6rmv4IivqpuH
         O+bSYyX+lHYixOAnrAZEG1M1mKr10bvEwG6OWKxYjfTl8zH27a8SVwNCge7FAb0JWDti
         wPyNVYcAxvHHG/NKyIWyLOWxx1kfqM+fJuXlvoe62udfJKsSzefwXbuaSO+6ylCDa3Fb
         Drzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lUPTn3ae;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z131si5530566qka.34.2019.03.12.11.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:03:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lUPTn3ae;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2CHsUhM165160;
	Tue, 12 Mar 2019 18:02:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=MVE2QKSq0HBi0ifLK6r/8roWIb0piqG77FSS+ol3O3k=;
 b=lUPTn3aep3zmnAwsd9lPzfc99ETYH3Qjx6GygTykkFCImAJCUEektM/1jeOzXZRRLJO5
 hGmRwMQL0Ixm+eCiWruqmOVDvAoHYS+e3vy6vyEmWoZlrDp31SiJBqNdGrh+6iYXt0W/
 HX4oi0GJ/bA6vBa9bpC2trleOne6HMuLpQnA3aDYleqZnoGkOB50g6TXm6tlUVKxfSCd
 lOrK8wohhuHrIbT0voPubsLuNfxbpp2Keyc7SsSNL2PZhu+4IJ8wct5bpvQgX6g++0lH
 fdYhawXuSjjUhZaC76T9Qhb7Cl6kDUkJag0XHYdjjJj4Ym2m0H25uXbZOFccF9FB7R0d Xw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2r464rebce-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 18:02:46 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2CI2jwn017716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 18:02:45 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2CI2ikH025944;
	Tue, 12 Mar 2019 18:02:44 GMT
Received: from dhcp-burlington7-2nd-B-east-10-152-55-162.usdhcp.oraclecorp.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Mar 2019 11:02:44 -0700
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Andrew Cooper <andrew.cooper3@citrix.com>,
        David Hildenbrand <david@redhat.com>,
        Matthew Wilcox <willy@infradead.org>,
        Julien Grall <julien.grall@arm.com>
Cc: Juergen Gross <jgross@suse.com>, k.khlebnikov@samsung.com,
        Stefano Stabellini <sstabellini@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        osstest service owner <osstest-admin@xenproject.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org, Julien Freche <jfreche@vmware.com>,
        Nadav Amit <namit@vmware.com>, xen-devel@lists.xenproject.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
 <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
Date: Tue, 12 Mar 2019 14:02:31 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9193 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903120122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/12/19 1:24 PM, Andrew Cooper wrote:
> On 12/03/2019 17:18, David Hildenbrand wrote:
>> On 12.03.19 18:14, Matthew Wilcox wrote:
>>> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>>>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>>>> It looks like all the arm test for linus [1] and next [2] tree
>>>>> are now failing. x86 seems to be mostly ok.
>>>>>
>>>>> The bisector fingered the following commit:
>>>>>
>>>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>>>> Author: Matthew Wilcox <willy@infradead.org>
>>>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>>>
>>>>>      mm/memory.c: prevent mapping typed pages to userspace
>>>>>      Pages which use page_type must never be mapped to userspace as it would
>>>>>      destroy their page type.  Add an explicit check for this instead of
>>>>>      assuming that kernel drivers always get this right.
>>> Oh good, it found a real problem.
>>>
>>>> It turns out the problem is because the balloon driver will call
>>>> __SetPageOffline() on allocated page. Therefore the page has a type and
>>>> vm_insert_pages will deny the insertion.
>>>>
>>>> My knowledge is quite limited in this area. So I am not sure how we can
>>>> solve the problem.
>>>>
>>>> I would appreciate if someone could provide input of to fix the mapping.
>>> I don't know the balloon driver, so I don't know why it was doing this,
>>> but what it was doing was Wrong and has been since 2014 with:
>>>
>>> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
>>> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
>>> Date:   Thu Oct 9 15:29:27 2014 -0700
>>>
>>>     mm/balloon_compaction: redesign ballooned pages management
>>>
>>> If ballooned pages are supposed to be mapped into userspace, you can't mark
>>> them as ballooned pages using the mapcount field.
>>>
>> Asking myself why anybody would want to map balloon inflated pages into
>> user space (this just sounds plain wrong but my understanding to what
>> XEN balloon driver does might be limited), but I assume the easy fix
>> would be to revert
> I suspect the bug here is that the balloon driver is (ab)used for a
> second purpose

Yes. And its name is alloc_xenballooned_pages().

-boris

>  - to create a hole in pfn space to map some other bits of
> shared memory into.
>
> I think at the end of the day, what is needed is a struct page_info
> which looks like normal RAM, but the backing for which can be altered by
> hypercall to map other things.
>
> ~Andrew

