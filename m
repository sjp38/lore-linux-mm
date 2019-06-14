Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5376DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0581320866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:58:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0581320866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CDC46B0006; Fri, 14 Jun 2019 04:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77E5E6B0007; Fri, 14 Jun 2019 04:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6946B6B0008; Fri, 14 Jun 2019 04:58:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9246B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:58:51 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d6so2028642ybj.16
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=3cY7snI7yW30fqydwfpeO2RnX8hO+FC+i7/Ga9P8IUw=;
        b=Cviyf+ZS8vHasS0ymPv2ovV463bQgwnznbZL4tFh1c/iNi4tC8i7NRecK5EhX6YLrI
         CP6GGA4V9GuaFLu9gBKK8usQZPPEUo5iSVZdMpU3XzSInWoOOK435IGr0wDL8Y3gLgMZ
         XFBo2AdkbYuiaC6f/pJVWWdG50r4T2xTqIeX5ict6+byAsQX2H2CNTQh6dIvSGxlxkYj
         /ibFNOPF42mveAikDjA0NghQmmuA9r/Q0E/acrPWnbWwb+Ou+KIB1NXc7XZAdUY7D5Cb
         ViylvoUeSA99gDPlFB5mEDhG918LIi5Cb4qWTEixZ2vZwsQXdiR30GyVXMiHDI4i5Wu0
         YFMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVKABu/h3qA4JE2+iqx7sKXKi/Sff9Ngzequm/4Ef6J9b8LftEe
	mAP7utQhq/VqU9/pUdRO3gk3erdD2s+yd7lwVSxFqkm3YCTD1V9AAijJxDedW3r9PZiQgM0Ar70
	H6cEaPUvfMpybCC1BYD+IpWjfHZdCOtegqIhopY9xRck3rjsR/Pf6G74PLX1JWNuozw==
X-Received: by 2002:a25:42c7:: with SMTP id p190mr41768283yba.503.1560502731085;
        Fri, 14 Jun 2019 01:58:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa2kZLz1lPQ/SshNJ7QCK4UzuHa1WbLhLAxz5PAJVjKBZa/pkjrmJUrW4hRDxFUlE8XI5U
X-Received: by 2002:a25:42c7:: with SMTP id p190mr41768266yba.503.1560502730455;
        Fri, 14 Jun 2019 01:58:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560502730; cv=none;
        d=google.com; s=arc-20160816;
        b=nHRGxLj6kUhV44vspqaAGVhguh4FsfJ9arQWMtEJ0EXUgWFxEAevYYA5Mejcu9nYb5
         YhCPunJAuQOUClKi7dPu8Bp0FLuArDKU8cAzzA3VWXDcALc8ngX8gsWmkKrL5S+x9cBE
         IndVKAtZEjTqdP+urFrsCOO/rI63HbepCA5wRrY6u5OwZXqdPZlOMLZy7YrqZayKgct0
         DUJtO3CF+8xIhkLML/WpKmQe7fApybdAhqf7HTbx0GLaga7hxC2Il0Z0csBwsZpIbAP6
         PUc+hdrfnLPcbcmq3fTl71YtBfV4jWHMAqRX3hi+P83VLf5JnRbZAEwDe6zaSZ8zI1HM
         q41A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=3cY7snI7yW30fqydwfpeO2RnX8hO+FC+i7/Ga9P8IUw=;
        b=VEgi/auplL7rXX+Wh15s/7QpPj/b8gql4EAuwd6IgaRRlIr3a9gpeaOHRr9SyCm877
         Btf9jshpJuBVbfxeuaY0l1p10/QE6TvrHQ5wpzt9PNsSqtrWj4kd03jx6tBSmsgz3Tyq
         KotLkQ02O8V7/0zfvE6NAlLgXWmAvCcuKseHpp+OQ5rY++CsdPBD9S4xplz351kGvafA
         dJRzxhMjWZr2wN9QS1DS/SL4+0hSkQmeA7CJK2MlZWXjT9YpK9QjaaShJTrxyLSvxufq
         rgg3yvA0WvqmXVwvD4NKCwAdoQ6DdqU8hnuEyDXIm6er/Iy8ZffYx+c6lc3OnEaoWFki
         Ve5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i84si720313ybi.110.2019.06.14.01.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 01:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5E8vPIU124503
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:58:50 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t46fucsdg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:58:49 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 14 Jun 2019 09:58:47 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 14 Jun 2019 09:58:45 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5E8wjxc45285512
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 08:58:45 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E5803AE053;
	Fri, 14 Jun 2019 08:58:44 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5B175AE051;
	Fri, 14 Jun 2019 08:58:43 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.60.77])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 08:58:43 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Qian Cai <cai@lca.pw>, Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.de>, Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
In-Reply-To: <1560376072.5154.6.camel@lca.pw>
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com> <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com> <1560376072.5154.6.camel@lca.pw>
Date: Fri, 14 Jun 2019 14:28:40 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061408-0008-0000-0000-000002F3B1CA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061408-0009-0000-0000-00002260BB0E
Message-Id: <87lfy4ilvj.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Qian Cai <cai@lca.pw> writes:


> 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed the same
> pfn_section_valid() check.
>
> 2) powerpc booting is generating endless warnings [2]. In vmemmap_populated() at
> arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> PAGES_PER_SUBSECTION, but it alone seems not enough.
>

Can you check with this change on ppc64.  I haven't reviewed this series yet.
I did limited testing with change . Before merging this I need to go
through the full series again. The vmemmap poplulate on ppc64 needs to
handle two translation mode (hash and radix). With respect to vmemap
hash doesn't setup a translation in the linux page table. Hence we need
to make sure we don't try to setup a mapping for a range which is
arleady convered by an existing mapping. 

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a4e17a979e45..15c342f0a543 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
  * which overlaps this vmemmap page is initialised then this page is
  * initialised already.
  */
-static int __meminit vmemmap_populated(unsigned long start, int page_size)
+static bool __meminit vmemmap_populated(unsigned long start, int page_size)
 {
 	unsigned long end = start + page_size;
 	start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
 
-	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
-		if (pfn_valid(page_to_pfn((struct page *)start)))
-			return 1;
+	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
 
-	return 0;
+		struct mem_section *ms;
+		unsigned long pfn = page_to_pfn((struct page *)start);
+
+		if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+			return 0;
+		ms = __nr_to_section(pfn_to_section_nr(pfn));
+		if (valid_section(ms))
+			return true;
+	}
+	return false;
 }
 
 /*

