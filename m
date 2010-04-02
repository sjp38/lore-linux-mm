Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E6C916B0208
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 03:21:39 -0400 (EDT)
Received: from il06vts03.mot.com (il06vts03.mot.com [129.188.137.143])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o327LsGP026641
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 01:21:54 -0600 (MDT)
Received: from mail-yw0-f193.google.com (mail-yw0-f193.google.com [209.85.211.193])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o327LnLj026618
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 01:21:53 -0600 (MDT)
Received: by mail-yw0-f193.google.com with SMTP id 31so1209452ywh.25
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 00:21:36 -0700 (PDT)
MIME-Version: 1.0
From: ShiYong LI <a22381@motorola.com>
Date: Fri, 2 Apr 2010 15:21:16 +0800
Message-ID: <k2s4810ea571004020021hade8123mb571b803b8472aef@mail.gmail.com>
Subject: [PATCH] Fix missing of last user while dumping slab corruption log
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
store redzone and last user data around allocated memory space if arch
cache line > sizeof(unsigned long long). As a result, last user information
is unexpectedly MISSED while dumping slab corruption log.

This patch makes sure that redzone and last user tags get stored whatever
arch cache line.

Compared to original codes, the change surely affects head redzone (redzone1).
Actually, with SLAB_RED_ZONE and SLAB_STORE_USER enabled,
allocated memory layout is as below:

[ redzone1 ]   <--------- Affected area.
[ real object space ]
[ redzone2 ]
[ last user ]
[ ... ]

Let's do some analysis: (whatever SLAB_STORE_USER is).

1) With SLAB_RED_ZONE on, "align" >= sizeof(unsigned long long) according to
    the following codes:
	/* 2) arch mandated alignment */
	if (ralign < ARCH_SLAB_MINALIGN) {
		ralign = ARCH_SLAB_MINALIGN;
	}
	/* 3) caller mandated alignment */
	if (ralign < align) {
		ralign = align;
	}
	...
	/*
	 * 4) Store it.
	 */
	align = ralign;

    That's to say, could guarantee that redzone1 does NOT get broken
at all. Meanwhile,
    Real object space could meet the need of cache line size by using
"align"  argument.

2) With SLAB_RED_ZONE off, the change has no impact.
