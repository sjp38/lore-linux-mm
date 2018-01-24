Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5352C800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:40:32 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id w17so4936992iow.23
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:40:32 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d16si703823iob.10.2018.01.24.11.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 11:40:30 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w0OJQrYV040005
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:40:30 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2fq04ur6pe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:40:30 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w0OJeT6o015188
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:40:29 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w0OJeTY8023249
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:40:29 GMT
Received: by mail-ot0-f174.google.com with SMTP id t20so4606756ote.11
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:40:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180112153734.1780ccc00ebced508fad397a@linux-foundation.org>
References: <20180112183405.22193-1-pasha.tatashin@oracle.com> <20180112153734.1780ccc00ebced508fad397a@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 24 Jan 2018 14:40:19 -0500
Message-ID: <CAOAebxsL_8-KfX_L9aHWcBBNpMT0tbyF9ztofS1NkNqRmChPdw@mail.gmail.com>
Subject: Re: [PATCH v1] mm: initialize pages on demand during boot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Andrew,

> Presumably this fixes some real-world problem which someone has observed?

Yes, linked below.

> Please describe that problem for us in lavish detail.

This change helps for three reasons:

1. Insufficient amount of reserved memory due to arguments provided by
user. User may request some buffers, increased hash tables sizes etc.
Currently, machine panics during boot if it can't allocate memory due
to insufficient amount of reserved memory. With this change, it will
be able to grow zone before deferred pages are initialized.

One observed example is described in the linked discussion [1] Mel
Gorman writes:

"
Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
but only 16GB was available due to deferred memory initialisation.
"

The allocations in the above scenario happen per-cpu in smp_init(),
and before deferred pages are initialized. So, there is no way to
predict how much memory we should put aside to boot successfully with
deferred page initialization feature compiled in.

2. The second reason is future proof. The kernel memory requirements
may change, and we do not want to constantly update
reset_deferred_meminit() to satisfy the new requirements. In addition,
this function is currently in common code, but potentially would need
to be split into arch specific variants, as more arches will start
taking advantage of deferred page initialization feature.

3. On demand initialization of reserved pages guarantees that we will
initialize only as many pages early in boot using only one thread as
needed, the rest are going to be efficiently initialized in parallel.

[1] https://www.spinics.net/lists/linux-mm/msg139087.html

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
