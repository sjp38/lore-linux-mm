Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8D8A6B0283
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:55:18 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hm5so27167578pac.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:55:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h191si21344990pgc.323.2016.10.25.08.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:55:17 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9PFs56M090653
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:55:17 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26a8dnk4t7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:55:17 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 09:55:15 -0600
Date: Tue, 25 Oct 2016 10:55:07 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 4/5] mm: make processing of movable_node arch-specific
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
 <235f2d20-cf84-08df-1fb4-08ee258fdc52@gmail.com>
 <dcfc8ace-e59e-6b4b-0f2f-4eff9f08f3c1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <dcfc8ace-e59e-6b4b-0f2f-4eff9f08f3c1@gmail.com>
Message-Id: <20161025155507.37kv5akdlgo6m2be@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 25, 2016 at 11:15:40PM +1100, Balbir Singh wrote:
>After the ack, I realized there were some more checks needed, IOW
>questions for you :)

Hey! No takebacks!

The short answer is that neither of these is a concern.

Longer; if you use "movable_node", x86 can identify these nodes at boot. 
They call memblock_mark_hotplug() while parsing the SRAT. Then, when the 
zones are initialized, those markings are used to determine ZONE_MOVABLE.

We have no analog of this SRAT information, so our movable nodes can 
only be created post boot, by hotplugging and explicitly onlining with 
online_movable.

>1. Have you checked to see if our memblock allocations spill
>over to probably hotpluggable nodes?

Since our nodes don't exist at boot, we don't have that short window 
before the zones are drawn where the node has normal memory, and a 
kernel allocation might occur within.

>2. Shouldn't we be marking nodes discovered as movable via
>memblock_mark_hotplug()?

Again, this early boot marking mechanism only applies to movable_node.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
