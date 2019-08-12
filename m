Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 956F3C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:29:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A4012075B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:29:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A4012075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB7826B0003; Mon, 12 Aug 2019 17:29:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E67EB6B0005; Mon, 12 Aug 2019 17:29:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D56256B0006; Mon, 12 Aug 2019 17:29:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id AD1D46B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:29:28 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4BC11180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:29:28 +0000 (UTC)
X-FDA: 75815067216.24.ant39_357135b4e912d
X-HE-Tag: ant39_357135b4e912d
X-Filterd-Recvd-Size: 3015
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:29:27 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CBB40C05AA57;
	Mon, 12 Aug 2019 21:29:25 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 233026A225;
	Mon, 12 Aug 2019 21:29:24 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>,  Linux MM <linux-mm@kvack.org>,  Jason Gunthorpe <jgg@mellanox.com>,  Andrew Morton <akpm@linux-foundation.org>,  Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/memremap: Fix reuse of pgmap instances with internal references
References: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
	<x49blwuidqn.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jZWbBUrig3wnE+VGptMEv3fHeRJbRhmMncQwkjLUbvxg@mail.gmail.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Mon, 12 Aug 2019 17:29:24 -0400
In-Reply-To: <CAPcyv4jZWbBUrig3wnE+VGptMEv3fHeRJbRhmMncQwkjLUbvxg@mail.gmail.com>
	(Dan Williams's message of "Mon, 12 Aug 2019 09:44:10 -0700")
Message-ID: <x49ftm6gjij.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 12 Aug 2019 21:29:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Mon, Aug 12, 2019 at 8:51 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>>
>> Dan Williams <dan.j.williams@intel.com> writes:
>>
>> > Currently, attempts to shutdown and re-enable a device-dax instance
>> > trigger:
>>
>> What does "shutdown and re-enable" translate to?  If I disable and
>> re-enable a device-dax namespace, I don't see this behavior.
>
> I was not seeing this either until I made sure I was in 'bus" device model mode.
>
> # cat /etc/modprobe.d/daxctl.conf
> blacklist dax_pmem_compat
> alias nd:t7* dax_pmem
>
> # make TESTS="daxctl-devices.sh" check -j 40 2>out
>
> # dmesg | grep WARN.*devm
> [  225.588651] WARNING: CPU: 10 PID: 9103 at mm/memremap.c:211
> devm_memremap_pages+0x234/0x850
> [  225.679828] WARNING: CPU: 10 PID: 9103 at mm/memremap.c:211
> devm_memremap_pages+0x234/0x850

Ah, you see this when reconfiguring the device.  So, the lifetime of the
pgmap is tied to the character device, which doesn't get torn down.  The
fix looks good to me, and tests out fine.

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

