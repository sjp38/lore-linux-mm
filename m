Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEBC06B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q27so5009080pfi.8
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:20:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a2si23093769pln.77.2017.05.24.01.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 01:20:30 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4O8F0FJ114394
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:30 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2amvavnk74-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:29 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 24 May 2017 09:20:27 +0100
Date: Wed, 24 May 2017 10:20:22 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [-next] memory hotplug regression
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20170524082022.GC5427@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Michal,

I just re-tested linux-next with respect to your memory hotplug changes and
actually (finally) figured out that your patch ("mm, memory_hotplug: do not
associate hotadded memory to zones until online)" changes behaviour on
s390:

before your patch memory blocks that were offline and located behind the
last online memory block were added by default to ZONE_MOVABLE:

# cat /sys/devices/system/memory/memory16/valid_zones
Movable Normal

With your patch this changes, so that they will be added to ZONE_NORMAL by
default instead:

# cat /sys/devices/system/memory/memory16/valid_zones
Normal Movable

Sorry, that I didn't realize this earlier!

Having the ZONE_MOVABLE default was actually the only point why s390's
arch_add_memory() was rather complex compared to other architectures.

We always had this behaviour, since we always wanted to be able to offline
memory after it was brought online. Given that back then "online_movable"
did not exist, the initial s390 memory hotplug support simply added all
additional memory to ZONE_MOVABLE.

Keeping the default the same would be quite important.

FWIW, and a bit unrelated: we had/have very basic lsmem and chmem tools
which can be used to list memory states and bring memory online and
offline. These tools were part of the s390-tools package and only recently
moved to util-linux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
