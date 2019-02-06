Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AA1AC282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 10:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6FD22175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 10:46:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6FD22175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 735DC8E00B5; Wed,  6 Feb 2019 05:46:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3858E00B4; Wed,  6 Feb 2019 05:46:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AC3B8E00B5; Wed,  6 Feb 2019 05:46:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2889A8E00B4
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 05:46:20 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id h136so2739063vsd.8
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 02:46:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=PVSuqpGbYJd/jXR6ZgRT/TQKS5MPikc/vteV34VX6BU=;
        b=qo2CZuvSkF3Od7aB0tkpCXb0lGL3Ug0lrM1O79e+1ajToJgDglX1urtGjuvhvpBeGJ
         6RVQ4J9xaKNQJAqKxs6AnUQsHiLTJL74450OsitnqXgWZDB+x7opTljuVthsz71HI6j4
         X8XVjrmKRSpBrhrKAcntUMI6FXn/6/p5/5fLgmleJ6YltJt+pPDT4cO8dgZwN8+egjHX
         6h6IHCYKqg2yO369WUuray8STIyRfXIBu0VClPT4ps0Dl0n6xCLfjajNEMXDGkmf8jB4
         WRJdBHBHpUF5+lYt19wOvA90O3fq+KafPdSg+tLEGx+yJDRFndrpv197pGaZtAacONuG
         bL2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZ92qMtkjSAojWWAmbQE3vebtvZOQHwzFp5nzyp64kE67wyOJpT
	whPjvKNTiNDDbxYQDYcP0YoTgmO5TKVCSUEwHst8FRV6dl3rSWv0zzb1hhiTD87a7bzPtimfOAc
	QPJ1KiSvLI4cd4pcjKhUXqeQkgFU3y/o/ks2WQpriU1DkyIaI50sx+8RRREsaf1RRGw==
X-Received: by 2002:a67:7b4a:: with SMTP id w71mr1786305vsc.105.1549449979730;
        Wed, 06 Feb 2019 02:46:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamhG34AAybQjVChcSyvYq1P7hG0Med0lYUB19Ja103KCSJbDtwH+WN/khyGro2FUtZts8F
X-Received: by 2002:a67:7b4a:: with SMTP id w71mr1786277vsc.105.1549449978438;
        Wed, 06 Feb 2019 02:46:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549449978; cv=none;
        d=google.com; s=arc-20160816;
        b=icPIMwhp/I8v47eG9Ph0mJvXZ1Ux+HaCOBOOFetMookL81jIVPyo5C9pqTGO04ZlQZ
         SbOGxIOW6tNDJgc8ukAXV4pebUE2s5n+1Nrauexm2Q8rzchP9qXHNayvFQ5sD2pbB+n4
         25dU/G8i4pINn8RrO/0mVFj6EP/wCeggz9yYYOsDZGkzXM6YydKGcaYvlIWJrJh6KKOt
         F38MDPri/uXiGgtbCteuReH1g+nY4alyoBN2T+qeemd90oS3MVoiQuyS0vh0gj/lzv74
         8PZP9moe6lN1vXegwQ6Ic5TIRq5Zddwr09LDRYp+qkrP+Oxv/UzXBSgWMgt9k2ArTfYe
         Xo0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=PVSuqpGbYJd/jXR6ZgRT/TQKS5MPikc/vteV34VX6BU=;
        b=mIwja/5eNGrj370T7aV6GAQemezFnMSfnRqUZv56p3yL78ftE8jgDINtNodd4nNbsX
         qE1fNiqxCr7ePiIwC9w9rkhkq3zaH1P+V1gbXghEwbCC6ju/+pi/nsjq/jd4uiw+q9jw
         Eg7HsuuK4D9y0BbQdo30H+3pQXO8osdW/lgG4N/G9swKF2hlLpvr2WgGnZOVSc/w9knt
         ec3JlseIfTyyUiNj92yWDJEaQXxi1dOvejX1PFPX1iz+6dfyI1Ql6dHtaB6Pf7LmLJwq
         tZ7rXTVyiKJVXUzjI2tj+pTw8vEWiy0UZppg26EFTZiLf36qYtzSBiQnrDK3uCBuYO/Z
         A6rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v2si4869080vsi.270.2019.02.06.02.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 02:46:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 16630B7C2F6F0E17D115;
	Wed,  6 Feb 2019 18:46:12 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 18:46:04 +0800
Date: Wed, 6 Feb 2019 10:45:52 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>, <linuxarm@huawei.com>
Subject: Re: [PATCHv5 10/10] doc/mm: New documentation for memory
 performance
Message-ID: <20190206104552.00003bad@huawei.com>
In-Reply-To: <20190124230724.10022-11-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-11-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 16:07:24 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Platforms may provide system memory where some physical address ranges
> perform differently than others, or is side cached by the system.
> 
> Add documentation describing a high level overview of such systems and the
> perforamnce and caching attributes the kernel provides for applications
> wishing to query this information.
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Hi Keith,

Nice doc in general. Comments inline.

> ---
>  Documentation/admin-guide/mm/numaperf.rst | 167 ++++++++++++++++++++++++++++++
>  1 file changed, 167 insertions(+)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> 
> diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> new file mode 100644
> index 000000000000..52999336a8ed
> --- /dev/null
> +++ b/Documentation/admin-guide/mm/numaperf.rst
> @@ -0,0 +1,167 @@
> +.. _numaperf:
> +
> +=============
> +NUMA Locality
> +=============
> +
> +Some platforms may have multiple types of memory attached to a single
> +CPU. These disparate memory ranges share some characteristics, such as
> +CPU cache coherence, but may have different performance. For example,
> +different media types and buses affect bandwidth and latency.

This seems a bit restrictive, but I it gives a starting point.
I guess anyone who has a more complex system should look elsewhere for
how this maps to it!

> +
> +A system supporting such heterogeneous memory by grouping each memory
> +type under different "nodes" based on similar CPU locality and performance
> +characteristics.  Some memory may share the same node as a CPU, and others
> +are provided as memory only nodes. While memory only nodes do not provide
> +CPUs, they may still be directly accessible, or local, to one or more
> +compute nodes.

Perhaps define directly accessible?  I'm not keen on saying that they don't
involve an interconnect as that rules out things like CCIX with remote
memory homes.  The reality is this patch set works fine for that case.

The one or more compute nodes can only happen (I think) with a very weird
setup of an interconnect involved which is likely to have other data on it.

+ The following diagram shows one such example of two compute
> +nodes with local memory and a memory only node for each of compute node:
> +
> + +------------------+     +------------------+
> + | Compute Node 0   +-----+ Compute Node 1   |
> + | Local Node0 Mem  |     | Local Node1 Mem  |
> + +--------+---------+     +--------+---------+
> +          |                        |
> + +--------+---------+     +--------+---------+
> + | Slower Node2 Mem |     | Slower Node3 Mem |
> + +------------------+     +--------+---------+
> +
> +A "memory initiator" is a node containing one or more devices such as
> +CPUs or separate memory I/O devices that can initiate memory requests.
> +A "memory target" is a node containing one or more physical address
> +ranges accessible from one or more memory initiators.
> +
> +When multiple memory initiators exist, they may not all have the same
> +performance when accessing a given memory target. Each initiator-target
> +pair may be organized into different ranked access classes to represent
> +this relationship. The highest performing initiator to a given target
> +is considered to be one of that target's local initiators, and given
> +the highest access class, 0. Any given target may have one or more
> +local initiators, and any given initiator may have multiple local
> +memory targets.
> +
> +To aid applications matching memory targets with their initiators, the
> +kernel provides symlinks to each other. The following example lists the
> +relationship for the access class "0" memory initiators and targets, which is
> +the of nodes with the highest performing access relationship::
> +
> +	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
> +	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
> +
> +	# symlinks -v /sys/devices/system/node/nodeY/access0/initiators/
> +	relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
> +
> +================
> +NUMA Performance
> +================
> +
> +Applications may wish to consider which node they want their memory to
> +be allocated from based on the node's performance characteristics. If
> +the system provides these attributes, the kernel exports them under the
> +node sysfs hierarchy by appending the attributes directory under the
> +memory node's access class 0 initiators as follows::
> +
> +	/sys/devices/system/node/nodeY/access0/initiators/
> +
> +These attributes apply only when accessed from nodes that have the
> +are linked under the this access's inititiators.
> +
> +The performance characteristics the kernel provides for the local initiators
> +are exported are as follows::
> +
> +	# tree -P "read*|write*" /sys/devices/system/node/nodeY/access0/
> +	/sys/devices/system/node/nodeY/access0/
> +	|-- read_bandwidth
> +	|-- read_latency
> +	|-- write_bandwidth
> +	`-- write_latency

These seem to be under
/sys/devices/system/node/nodeY/access0/initiators/
(so one directory deeper).

> +
> +The bandwidth attributes are provided in MiB/second.
> +
> +The latency attributes are provided in nanoseconds.
> +
> +The values reported here correspond to the rated latency and bandwidth
> +for the platform.
> +
> +==========
> +NUMA Cache
> +==========
> +
> +System memory may be constructed in a hierarchy of elements with various
> +performance characteristics in order to provide large address space of
> +slower performing memory side-cached by a smaller higher performing
> +memory. The system physical addresses that initiators are aware of
> +are provided by the last memory level in the hierarchy. The system
> +meanwhile uses higher performing memory to transparently cache access
> +to progressively slower levels.
> +
> +The term "far memory" is used to denote the last level memory in the
> +hierarchy. Each increasing cache level provides higher performing
> +initiator access, and the term "near memory" represents the fastest
> +cache provided by the system.
> +
> +This numbering is different than CPU caches where the cache level (ex:
> +L1, L2, L3) uses a CPU centric view with each increased level is lower
> +performing. In contrast, the memory cache level is centric to the last
> +level memory, so the higher numbered cache level denotes memory nearer
> +to the CPU, and further from far memory.
> +
> +The memory side caches are not directly addressable by software. When
> +software accesses a system address, the system will return it from the
> +near memory cache if it is present. If it is not present, the system
> +accesses the next level of memory until there is either a hit in that
> +cache level, or it reaches far memory.
> +
> +An application does not need to know about caching attributes in order
> +to use the system. Software may optionally query the memory cache
> +attributes in order to maximize the performance out of such a setup.
> +If the system provides a way for the kernel to discover this information,
> +for example with ACPI HMAT (Heterogeneous Memory Attribute Table),
> +the kernel will append these attributes to the NUMA node memory target.
> +
> +When the kernel first registers a memory cache with a node, the kernel
> +will create the following directory::
> +
> +	/sys/devices/system/node/nodeX/side_cache/
> +
> +If that directory is not present, the system either does not not provide
> +a memory side cache, or that information is not accessible to the kernel.
> +
> +The attributes for each level of cache is provided under its cache
> +level index::
> +
> +	/sys/devices/system/node/nodeX/side_cache/indexA/
> +	/sys/devices/system/node/nodeX/side_cache/indexB/
> +	/sys/devices/system/node/nodeX/side_cache/indexC/
> +
> +Each cache level's directory provides its attributes. For example, the
> +following shows a single cache level and the attributes available for
> +software to query::
> +
> +	# tree sys/devices/system/node/node0/side_cache/
> +	/sys/devices/system/node/node0/side_cache/
> +	|-- index1
> +	|   |-- associativity
> +	|   |-- level

What is the purpose of having level in here?  Isn't it the same as the A..C
in the index naming?

> +	|   |-- line_size
> +	|   |-- size
> +	|   `-- write_policy
> +
> +The "associativity" will be 0 if it is a direct-mapped cache, and non-zero
> +for any other indexed based, multi-way associativity.

Is it worth providing the ACPI mapping in this doc?  We have None, Direct and
'complex'.   Fun question of what None means?  Not specified?

> +
> +The "level" is the distance from the far memory, and matches the number
> +appended to its "index" directory.
> +
> +The "line_size" is the number of bytes accessed on a cache miss.

Maybe "number of bytes accessed from next cache level" ?

> +
> +The "size" is the number of bytes provided by this cache level.
> +
> +The "write_policy" will be 0 for write-back, and non-zero for
> +write-through caching.
> +
> +========
> +See Also
> +========
> +.. [1] https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> +       Section 5.2.27


