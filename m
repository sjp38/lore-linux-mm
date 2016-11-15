Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB5F26B0253
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 02:05:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j128so41372511pfg.4
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 23:05:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1si21154382paw.186.2016.11.14.23.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 23:05:57 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAF746dr063884
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 02:05:56 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26qpxdpynr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 02:05:56 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 15 Nov 2016 02:05:55 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 2/5] mm: remove x86-only restriction of movable_node
In-Reply-To: <1479160961-25840-3-git-send-email-arbab@linux.vnet.ibm.com>
References: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com> <1479160961-25840-3-git-send-email-arbab@linux.vnet.ibm.com>
Date: Tue, 15 Nov 2016 12:35:42 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87lgwlb4u1.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org

Reza Arbab <arbab@linux.vnet.ibm.com> writes:

> In commit c5320926e370 ("mem-hotplug: introduce movable_node boot
> option"), the memblock allocation direction is changed to bottom-up and
> then back to top-down like this:
>
> 1. memblock_set_bottom_up(true), called by cmdline_parse_movable_node().
> 2. memblock_set_bottom_up(false), called by x86's numa_init().
>
> Even though (1) occurs in generic mm code, it is wrapped by #ifdef
> CONFIG_MOVABLE_NODE, which depends on X86_64.
>
> This means that when we extend CONFIG_MOVABLE_NODE to non-x86 arches,
> things will be unbalanced. (1) will happen for them, but (2) will not.
>
> This toggle was added in the first place because x86 has a delay between
> adding memblocks and marking them as hotpluggable. Since other arches do
> this marking either immediately or not at all, they do not require the
> bottom-up toggle.
>
> So, resolve things by moving (1) from cmdline_parse_movable_node() to
> x86's setup_arch(), immediately after the movable_node parameter has
> been parsed.


Considering that we now can mark memblock hotpluggable, do we need to
enable the bottom up allocation for ppc64 also ?


>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  Documentation/kernel-parameters.txt |  2 +-
>  arch/x86/kernel/setup.c             | 24 ++++++++++++++++++++++++

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
