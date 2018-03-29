Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19B226B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 12:32:47 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 204-v6so5874095itu.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 09:32:47 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id i130-v6si1664197iti.74.2018.03.29.09.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 09:32:46 -0700 (PDT)
Date: Thu, 29 Mar 2018 11:32:44 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: mm/vmstat.c: fix vmstat_update() preemption BUG
Message-ID: <alpine.DEB.2.20.1803291126230.27735@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: "Steven J. Hill" <steven.hill@cavium.com>, linux-mm@kvack.org

Just saw

commit c7f26ccfb2c31eb1bf810ba13d044fcf583232db
Author: Steven J. Hill <steven.hill@cavium.com>
Date:   Wed Mar 28 16:01:09 2018 -0700

    mm/vmstat.c: fix vmstat_update() preemption BUG

    Attempting to hotplug CPUs with CONFIG_VM_EVENT_COUNTERS enabled can
    cause vmstat_update() to report a BUG due to preemption not being
    disabled around smp_processor_id().



The fix is wrong.

vmstat_update cannot be moved to a differentprocessor and thus
preemption should be off.

vmstat_update repeatedly accesses per cpu information.

vmstat_update first checks if there are counter to be updated on the
current cpu and then updates the counters. This cannot happen if the
process can be moved to a different cpu.

The patch "switches off" preemption after the check if there are changes
to the local per cpu counter.

Lets find out what changed in the callers of vmstat_update() that caused
the BUG to be triggered.
