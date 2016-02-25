Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id C57E56B0253
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:11:06 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id x21so30594844oix.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:11:06 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id u9si4648094oiu.134.2016.02.24.18.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 18:11:06 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id jq7so36102622obb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:11:06 -0800 (PST)
Date: Wed, 24 Feb 2016 18:10:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Problems with swapping in v4.5-rc on POWER
Message-ID: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

I've plagiarized the subject from Paulus's "Problems with THP" mail
last weekend; but my similar problems are on PowerMac G5 baremetal,
with 4kB pages, not capable of THP and no THP configured in.

Under heavily swapping load, running kernel builds on tmpfs in limited
memory, I've been seeing random segfaults too, internal compiler errors
etc.  Not easily reproduced: sometimes happens in minutes, sometimes
not for several hours.

I tried and failed to construct a reproducer for you: my lack of a good
recipe has deterred me from reporting it, and seeing Paulus's mail on
THP gave me hope that the answer would come up in that thread; but no,
that was quickly resolved as a THP issue, since fixed.

(Mine had appeared to be fixed in v4.5-rc4 anyway; but I guess I
just didn't try hard enough, it resurfaced on -rc5 immediately.)

I've seen no sign of such problems on x86.  And I saw no sign of such
problems on v4.4-rc8-mm1, when I included the fixes to the _PAGE_PTE
and _PAGE_SWP_SOFT_DIRTY swapoff issues we discussed back then (in
33 hours of load, should be good enough; but did see such problems
a couple of times before including those fixes - I took them to be
a side-effect of the page flags issue, but now rather doubt that).

The minutes or hours thing: I wonder if that indicates a missing
initialization somewhere: that can easily show up soon after booting,
but then the machine settles into a steady state of reusing the same
structures, now initialized; until much later something disturbs the
state and it has to allocate more.  Sheer speculation, but I wonder.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
