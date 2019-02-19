Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA5EC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA3122083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:20:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA3122083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29FBD8E0003; Tue, 19 Feb 2019 12:20:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24DDD8E0002; Tue, 19 Feb 2019 12:20:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13EA78E0003; Tue, 19 Feb 2019 12:20:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C68F48E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:20:16 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y12so14224148pll.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:20:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=aHp6pwrxMVd0x/X9OxlhYOyadXI32T8uslMqBopyWz4=;
        b=RY88/LhLrMxBFXu73x5kkhUWjP8LkIeTeaUh0fJYDLD49kpPU8TrR2X8uK39kVl4lp
         5A/Z2JVJPFcolGUO27b0OuKDBwbIJdXAlxR/2lm8vnZuxsCaisz7+Ehf0LH/41p6bS44
         A61XnPQPaVKy7/TBs1RVW/kvKkmItTjGt91BL+LqIcjjFMhfHOqiN0V02appIP9Oslba
         sUmOar/OdWfuMKTsf0TOQ2wDf8+PvQobFw5WdyYJeI6ZOlzx2NQc95uHOBFYxeQK+WqH
         nyUT+YgQWxYrmKgfNtAwqCjgwm1i3nng6gmUeJumgUrKVD9nFzZb4OmIMBfxACAvjtG9
         6VGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubpbRfWCpf0IOcZ433vuMtJwMuj1YTaxYUMDIPB+MdKmWTUkQai
	TmE0b1GxbtdZPyOY8uh3me9SzHQlT63m6CIwKkENrTLxw6KMr9qEL9gR0k9MjvVN5UhclfH2V+4
	68gJr87x+L3rL7tXj2I8C/RiM9/oMH2RkU7IXmPVtfaTTf6BcLkVZjoaWqXVpNRHhAw==
X-Received: by 2002:a17:902:7686:: with SMTP id m6mr23286237pll.262.1550596816442;
        Tue, 19 Feb 2019 09:20:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjop2hw0mP41V3iBP5RN+nn9QfUgGRmh4oEvU4vQqYLhsjcHgJsPcJw9jAbImEkQhmGjx6
X-Received: by 2002:a17:902:7686:: with SMTP id m6mr23286132pll.262.1550596815271;
        Tue, 19 Feb 2019 09:20:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596815; cv=none;
        d=google.com; s=arc-20160816;
        b=JdjUpFhzxv7lP6VsWJgeahgACadfbrNa2MAFUbXjcYB6Kohd5o6ViAjIhYB4ee2AHo
         VgpEr9V589iWePPnWAsuiCa/2UKZt50ZayyAmnWCideYemeqAbP18/nJncCwKHGom9HG
         QUlF8wkLb+Q70pLu6HR31D+Effsq36kH0y4fATMXnF4nxsO6MfSJd0/HFbe4QnEok/H0
         tFy+wDI9r/OxK9KpQd/Nt8YoGKOeRRRl8EZ5xWwSZQCFS4KfFE4lanyo/9WhsdhbRdkd
         a0wO/Mvc20NL3ePR8nysDg6jBdrOBui6EuFqHVVSE4lVUNwt5W9W1sGAUmqHNR3vxtqb
         bg8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=aHp6pwrxMVd0x/X9OxlhYOyadXI32T8uslMqBopyWz4=;
        b=qZ5z+KaQ6Gdj9y0qXpKghp0R3ruCZIJjxNiDnncLWSUzgCrCi8S4ph7/5BqHRvci0G
         VLpZywv/6bMZ3JdPUKuD89xJCRQAEuvX0ZXu2ovxluTKVnIQpDfGUEdvu+FfAk3DCAwv
         6UF2Xu6L7hhCEFvyZF69E1kHpRS/mb8/l1Wbyq36+KkAy7Pq06NX87penQ8Y4fHBaiUw
         d2N5t03sdvOwe53Pd7HbQ/45ZLSt4w2+NKkLJKl9R2XWQkpPzaOHN2P6CjjnhTgGESSR
         i5Mb1UuFK9Xw9zOXocJlXkllQpCbU6HLPQR2qShCuloQTiRttVhNmE3pQkVwMloKTHrp
         qrCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b2si15575832pgw.113.2019.02.19.09.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:20:15 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Feb 2019 09:20:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,388,1544515200"; 
   d="scan'208";a="134708934"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 19 Feb 2019 09:20:10 -0800
Date: Tue, 19 Feb 2019 10:20:07 -0700
From: Keith Busch <keith.busch@intel.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, linux-api@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 00/10] Heterogenous memory node attributes
Message-ID: <20190219172004.GD16341@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <f2add663-a9e1-86df-0afd-22ef03d3d943@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f2add663-a9e1-86df-0afd-22ef03d3d943@inria.fr>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 03:25:31PM +0100, Brice Goglin wrote:
> Le 14/02/2019 à 18:10, Keith Busch a écrit :
> >   Determining the cpu and memory node local relationships is quite
> >   different this time (PATCH 7/10). The local relationship to a memory
> >   target will be either *only* the node from the Initiator Proximity
> >   Domain if provided, or if it is not provided, all the nodes that have
> >   the same highest performance. Latency was chosen to take prioirty over
> >   bandwidth when ranking performance.
> 
> 
> Hello Keith
> 
> I am trying to understand what this last paragraph means.
> 
> Let's say I have a machine with DDR and NVDIMM both attached to the same
> socket, and I use Dave Hansen's kmem patchs to make the NVDIMM appear as
> "normal memory" in an additional NUMA node. Let's call node0 the DDR and
> node1 the NVDIMM kmem node.
> 
> Now user-space wants to find out which CPUs are actually close to the
> NVDIMMs. My understanding is that SRAT says that CPUs are local to the
> DDR only. Hence /sys/devices/system/node/node1/cpumap says there are no
> CPU local to the NVDIMM. And HMAT won't change this, right?

HMAT actually does change this. The relationship is in 6.2's HMAT
Address Range or 6.3's Proximity Domain Attributes, and that's
something SRAT wasn't providing.

The problem with these HMAT structures is that the CPU node is
optional. The last paragraph is saying that if that optional information
is provided, we will use that. If it is not provided, we will fallback
to performance attributes to determine what is the "local" CPU domain.
 
> Will node1 contain access0/initiators/node0 to clarify that CPUs local
> to the NVDIMM are those of node0? Even if latency from node0 to node1
> latency is higher than node0 to node0?

Exactly, yes. To expand on this, what you'd see from sysfs:

  /sys/devices/system/node/node0/access0/targets/node1 -> ../../../node1

And

  /sys/devices/system/node/node1/access0/initiators/node0 -> ../../../node0

> Another way to ask this: Is the latency/performance only used for
> distinguishing the local initiator CPUs among multiple CPU nodes
> accesing the same memory node? Or is it also used to distinguish the
> local memory target among multiple memories access by a single CPU node?

It's the first one. A single CPU domain may have multiple local targets,
but each of those targets may have different performance.

For example, you could have something like this with "normal" DDR
memory, high-bandwidth memory, and slower nvdimm:

 +------------------+    +------------------+
 | CPU Node 0       +----+ CPU Node 1       |
 | Node0 DDR Mem    |    | Node1 DDR Mem    |
 +--------+---------+    +--------+---------+
          |                       |
 +--------+---------+    +--------+---------+
 | Node2 HBMem      |    | Node3 HBMem      |
 +--------+---------+    +--------+---------+
          |                       |
 +--------+---------+    +--------+---------+
 | Node4 Slow NVMem |    | Node5 Slow NVMem |
 +------------------+    +------------------+

In the above, Initiator node0 is "local" to targets 0, 2, and 4, and
would show up in node0's access0/targets/. Each memory target node,
though, has different performance than the others that are local to the
same intiator domain.

> The Intel machine I am currently testing patches on doesn't have a HMAT
> in 1-level-memory unfortunately.

Platforms providing HMAT tables are still rare at the moment, but expect
will become more common.

