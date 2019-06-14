Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42002C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FD062183F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:09:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FD062183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7CD76B000C; Fri, 14 Jun 2019 13:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A06966B000D; Fri, 14 Jun 2019 13:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CD8E6B0269; Fri, 14 Jun 2019 13:09:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 694B76B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:09:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id s9so2656369qtn.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:09:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Rv1UNHV6Hq+k6RcBLpv73zo+QvQPCa12e4dH0M4WBCA=;
        b=tgF2r0rSNuQquN/rmRCW6JzDL56SYi2P92oCikMBv/EguwDNbWVthq05OJieLNBBOB
         ROm2bD50Krvgii8J70D21iYfvEXbJYxTAm0lbjbZYiSy231DwRHJYflQjQbFK1uH5fJ0
         bi+XLD7nX1t2e8bFz682FIzG87aQI9yU8yrllhHHbZXSkZ5Dpehi39nJX8V4bmT6UTca
         iu/rYrvSPLNNL+xTTLIYIaoIMr8GDw9KjU94946RF8l6HW5M5hNfFyfRrM49G3krgkuH
         S7LPtcWXIysJzor2bhcRTOn2I3+mpNCstos/N/B6C2KfVpwvxPxGlmfn+fQ/qlCEEUTw
         UsOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKqoEmwtjq2RDUgXgd61J7BeQcBOKvutOy2OScAxpKWcaFJ4tg
	AMtdaYn27Jll10bFT18Ck03rG0TCv+He0aZHPJsBQjQ/tlNdKXhW4q+rRy+9Ey2cPSg7XxoXvbs
	cIHqNbupFDK/vJOg6AUU9vyy8tRUzYFjbzFyf5yoJV1yeY7qP9/xbz9w/qQz16QQB+Q==
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr8009891qvi.125.1560532145175;
        Fri, 14 Jun 2019 10:09:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoA6Y5FIPSkdZDEOsI+5/vm8QhnejOMqj8ff41TmmBuYqoKbiXJ+c2skvwLNThcMbtN9wu
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr8009852qvi.125.1560532144655;
        Fri, 14 Jun 2019 10:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560532144; cv=none;
        d=google.com; s=arc-20160816;
        b=GwEJi1OL6NPNCe2KgcXjInTMrDhkDr7k0xaJx8t+N+OCUVo5IqsuVppfEyzjbhab5Y
         pwqJJ5utgzgmw6Fsdbd2n1nTXGXs5JlXFTYNvIIfe4Wlh/2x0PKFNUsAwER15nAtpDMy
         bZhTIYc5sR4VTo18Q3I9CUQ74WY5ugbjvD4tzbd+d4FkIfDxfnUVyVUAx6dHx2urcInF
         h3mm7cx9mffxace+NZbdEKB92BXbLBFN2NfmeyZbUEL3HsPy3pigFyVsA74riQfkCmce
         7Cx7Nb1bqiwKywU/+K7/jn5JE53JWIRXakX3VQAIyWqVswOAizOz/FyDD8mFVXJFZD94
         XdfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Rv1UNHV6Hq+k6RcBLpv73zo+QvQPCa12e4dH0M4WBCA=;
        b=nVDotAcf0gcuXo0Y25VMBPzkjNAT7VxiOSBfnqxbf3OnwQutFp5FASqoexBJP9j7M7
         8wNcJXYu6p2ayR/hot4yypEJJku+Ft8DIvZbUXe6kBvtNs9DUdybJFieBwp7/I/Fqfyf
         6matmv93v0d9YN7f5xRY8MziSBHruvFaybOVcJFKI4NMIBmHeH8x/i1T3uljYtVpjXmN
         yeDeBZqyRYk8GkM2Un7CV2zoXZqYYqLuK6e2wZLesoFaL53dyuqodsVtwo82tKWI5gDG
         VRErZvlc+v3nJ/95g0Kg6QXO5pZJ7rmpBOzsWxzCwtyEZSIsVkCa/H57W6/LCpOQsEk2
         blHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a5si1989299qva.8.2019.06.14.10.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:09:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8CEA5C18B2D6;
	Fri, 14 Jun 2019 17:08:51 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 973FC54382;
	Fri, 14 Jun 2019 17:08:49 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>,  Oscar Salvador <osalvador@suse.de>,  Qian Cai <cai@lca.pw>,  Andrew Morton <akpm@linux-foundation.org>,  Linux MM <linux-mm@kvack.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  linux-nvdimm <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
	<CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
	<CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
	<1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
	<20190614153535.GA9900@linux>
	<c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
	<CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
	<24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
	<CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
	<16108dac-a4ca-aa87-e3b0-a79aebdcfafd@linux.ibm.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Fri, 14 Jun 2019 13:08:48 -0400
In-Reply-To: <16108dac-a4ca-aa87-e3b0-a79aebdcfafd@linux.ibm.com> (Aneesh
	Kumar K. V.'s message of "Fri, 14 Jun 2019 22:25:18 +0530")
Message-ID: <x49ef3wytzz.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 14 Jun 2019 17:08:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> On 6/14/19 10:06 PM, Dan Williams wrote:
>> On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
>> <aneesh.kumar@linux.ibm.com> wrote:
>
>>> Why not let the arch
>>> arch decide the SUBSECTION_SHIFT and default to one subsection per
>>> section if arch is not enabled to work with subsection.
>>
>> Because that keeps the implementation from ever reaching a point where
>> a namespace might be able to be moved from one arch to another. If we
>> can squash these arch differences then we can have a common tool to
>> initialize namespaces outside of the kernel. The one wrinkle is
>> device-dax that wants to enforce the mapping size,
>
> The fsdax have a much bigger issue right? The file system block size
> is the same as PAGE_SIZE and we can't make it portable across archs
> that support different PAGE_SIZE?

File system blocks are not tied to page size.  They can't be *bigger*
than the page size currently, but they can be smaller.

Still, I don't see that as an arugment against trying to make the
namespaces work across architectures.  Consider a user who only has
sector mode namespaces.  We'd like that to work if at all possible.

-Jeff

