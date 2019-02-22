Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD5A6C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:42:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 670372070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:42:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 670372070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B08B8E0118; Fri, 22 Feb 2019 10:42:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163A38E0109; Fri, 22 Feb 2019 10:42:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0795B8E0118; Fri, 22 Feb 2019 10:42:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB0D18E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:42:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id h6so1752324qke.18
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:42:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=/Jzxd+pGq41UQeApEioESmjz8YYTedgxSdHQUtrtGb0=;
        b=iINhYBW55LQ5XXkkeluLjEKZbcnir9QUk46ahJwFGgqUvLW2CZNEkrJ9WI9P5h3m2I
         2aLGfKauATjwoBFRB6p18dAG00IryrK4KHY0dwjlehpARrjEegkyUSCQMQBRD9fP2Vxt
         KlPtezppC/C1gx6QI/MIE+oACIC+qOat8FG6WQV1X36TGpznBiIQybbNLSmi6TIkG23I
         xfbr8blwxkHNHhBIOH4ah56rIosocnIINYfgrCqnKqLSpQPw+lOJqKi9dIYoutVxmeEE
         BsHIkKZlP4eypZXeHDZgZbYTnpWhMBSydf26Or7+P+MIi1tuW2zgqX7W1ZbBYM1O3QWG
         fccQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZTNPyeOPluV1n+cMb+/au7TNqshfx+5hIjYIDCESgV10rkkmw5
	xDyoLDEej382qguF1Z3bJRaeTUi3Ov0G3kq/swMooGmdNZSnPi6xSt5pvqRf53vU1sdpsOfSei7
	+RzeAp4RSbJwe0uEFA2feGJXAEywFrC6DZ1dJOSPmRejHyD84exh6Dx+D4KxyjoEqhA==
X-Received: by 2002:a37:7681:: with SMTP id r123mr3243515qkc.319.1550850126579;
        Fri, 22 Feb 2019 07:42:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGIWppbPDgkxFpzHhHywTkWO+OJ3PUVx6zULDuZY1ofMpkd/dCsaWyu8miMIIzLmeTx4I1
X-Received: by 2002:a37:7681:: with SMTP id r123mr3243481qkc.319.1550850125712;
        Fri, 22 Feb 2019 07:42:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550850125; cv=none;
        d=google.com; s=arc-20160816;
        b=jwJPNYOgHEM00rXh4Tq1uJki/dCPQlJrAypsRA+gE+IXxbKB1ke5SeHswcT4eITmUX
         uaXbezHNlqQgujBzAY7e14sW1GRUnCnzwF2llQhwc9KqZ7WuiJcsa1HNizFl40rTWPWu
         T6dk+qoypHpGXd7rl6wkNjAKr9SR/46DfnXZoWwzHYhhmCxiIK9f9GRVpX6Sq4vaIRQU
         qsXFEN5UVj4DRp4VQXyVmBsX9kUQt75KAZxw+ppy0sJoUTgzorYxRolPuGn8YyWnTkkB
         02y8IPHZemdhvS5061Txv3jOVqt1nNAFtmBZk4HDjNDCVSUTXa814Q+63m8HlUYgi20G
         WONw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=/Jzxd+pGq41UQeApEioESmjz8YYTedgxSdHQUtrtGb0=;
        b=KTuVF47TqIX1MD24STdCZrnOWO/rJg9sW6a0KBPu7piQYxXZd5KwBZnTo3Kli8mmkf
         T+VVTDXWld0jDFq2Rk1kIhigduViUUBtz8a1T/1y0YGXVRevTGmRdgfHdKDPUnpO9jV+
         4CMLqZDYFAkMFIwQV4MQI7cNibuQ3srnjGjhsfITdmoleZY8T0dC+fUosfUcQ3b4zqWF
         bUru1ciBn8iG+29VHC+9UsyJuhhQIgVfegGMhw3HYalPFC/FARsv+YXnxXUS4PEvKSWo
         dGRg0MMYFp8JMEqR9NKPjIdyKGuFMxbv92gHzRb61/YeiJCyhPml+c65eBLIsgOZplPr
         GImQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i64si1070724qtb.225.2019.02.22.07.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:42:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 895E3A70C;
	Fri, 22 Feb 2019 15:42:04 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C42495C1A1;
	Fri, 22 Feb 2019 15:42:03 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>,  stable <stable@vger.kernel.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Vishal L Verma <vishal.l.verma@intel.com>,  linux-fsdevel <linux-fsdevel@vger.kernel.org>,  Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH 7/7] libnvdimm/pfn: Fix 'start_pad' implementation
References: <155000668075.348031.9371497273408112600.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com>
	<x49ftsgsnzp.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4h9s1jYROGqkMfKk0MNBUedP=vQ1nJObLRwFiTB405nOg@mail.gmail.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Fri, 22 Feb 2019 10:42:02 -0500
In-Reply-To: <CAPcyv4h9s1jYROGqkMfKk0MNBUedP=vQ1nJObLRwFiTB405nOg@mail.gmail.com>
	(Dan Williams's message of "Thu, 21 Feb 2019 19:58:51 -0800")
Message-ID: <x49imxbx22d.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 22 Feb 2019 15:42:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

>> > However, to fix this situation a non-backwards compatible change
>> > needs to be made to the interpretation of the nd_pfn info-block.
>> > ->start_pad needs to be accounted in ->map.map_offset (formerly
>> > ->data_offset), and ->map.map_base (formerly ->phys_addr) needs to be
>> > adjusted to the section aligned resource base used to establish
>> > ->map.map formerly (formerly ->virt_addr).
>> >
>> > The guiding principles of the info-block compatibility fixup is to
>> > maintain the interpretation of ->data_offset for implementations like
>> > the EFI driver that only care about data_access not dax, but cause older
>> > Linux implementations that care about the mode and dax to fail to parse
>> > the new info-block.
>>
>> What if the core mm grew support for hotplug on sub-section boundaries?
>> Would't that fix this problem (and others)?
>
> Yes, I think it would, and I had patches along these lines [2]. Last
> time I looked at this I was asked by core-mm folks to await some
> general refactoring of hotplug [3], and I wasn't proud about some of
> the hacks I used to make it work. In general I'm less confident about
> being able to get sub-section-hotplug over the goal line (core-mm
> resistance to hotplug complexity) vs the local hacks in nvdimm to deal
> with this breakage.

You first posted that patch series in December of 2016.  How long do we
wait for this refactoring to happen?

Meanwhile, we've been kicking this can down the road for far too long.
Simple namespace creation fails to work.  For example:

# ndctl create-namespace -m fsdax -s 128m
  Error: '--size=' must align to interleave-width: 6 and alignment: 2097152
  did you intend --size=132M?

failed to create namespace: Invalid argument

ok, I can't actually create a small, section-aligned namespace.  Let's
bump it up:

# ndctl create-namespace -m fsdax -s 132m
{
  "dev":"namespace1.0",
  "mode":"fsdax",
  "map":"dev",
  "size":"126.00 MiB (132.12 MB)",
  "uuid":"2a5f8fe0-69e2-46bf-98bc-0f5667cd810a",
  "raw_uuid":"f7324317-5cd2-491e-8cd1-ad03770593f2",
  "sector_size":512,
  "blockdev":"pmem1",
  "numa_node":1
}

Great!  Now let's create another one.

# ndctl create-namespace -m fsdax -s 132m
libndctl: ndctl_pfn_enable: pfn1.1: failed to enable
  Error: namespace1.2: failed to enable

failed to create namespace: No such device or address

(along with a kernel warning spew)

And at this point, all further ndctl create-namespace commands fail.
Lovely.  This is a wart that was acceptable only because a fix was
coming.  2+ years later, and we're still adding hacks to work around it
(and there have been *several* hacks).

> Local hacks are always a sad choice, but I think leaving these
> configurations stranded for another kernel cycle is not tenable. It
> wasn't until the github issue did I realize that the problem was
> happening in the wild on NVDIMM-N platforms.

I understand the desire for expediency.  At some point, though, we have
to address the root of the problem.

-Jeff

>
> [2]: https://lore.kernel.org/lkml/148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com/
> [3]: https://lore.kernel.org/lkml/20170319163531.GA25835@dhcp22.suse.cz/
>
>>
>> -Jeff
>>
>> [1] https://github.com/pmem/ndctl/issues/76

