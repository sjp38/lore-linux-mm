Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 35F246B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:32:58 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so71984881ykd.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:32:58 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id f187si12814782ywd.190.2015.07.27.08.32.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 08:32:57 -0700 (PDT)
Message-ID: <55B64F1D.8090807@citrix.com>
Date: Mon, 27 Jul 2015 16:32:45 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: vmemmap_verify() BUGs during memory hotplug (4.2-rc1 regression)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Mel,

As of commit 8a942fdea560d4ac0e9d9fabcd5201ad20e0c382 (mm: meminit: make
__early_pfn_to_nid SMP-safe and introduce meminit_pfn_in_nid)
vmemmap_verify() will BUG_ON() during memory hotplug because of its use
of early_pfn_to_nid().  Previously, it would have reported bogus (or
failed to report valid) warnings.

I believe this does not affect memory hotplug on most x86 systems
because vmemmap_populate() would normally call
vmemmap_populate_hugepages() which avoids calling vmemmap_verify() in
the common case (no existing mappings covering the new area).

I'm triggering the early_pfn_to_nid() BUG_ON() with the Xen balloon
driver in a PV guest which will always call vmemmap_populate_basepages()
(since Xen PV guests lack superpage support).

Not really sure what the best way to resolve this is.  Presumably
vmmemmap_verify() needs to switch to using pfn_to_nid() after the
initial initialization but there doesn't appear to be anything suitable
to distinguish between the early and hotplug cases.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
