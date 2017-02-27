Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3D26B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:25:30 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d18so173213055pgh.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 03:25:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r78si9257809pfg.71.2017.02.27.03.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 03:25:29 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1RBOWX4010663
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:25:28 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28u7bbasc5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:25:27 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 27 Feb 2017 11:25:23 -0000
Date: Mon, 27 Feb 2017 12:25:10 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
 <87lgssvtni.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgssvtni.fsf@vitty.brq.redhat.com>
Message-Id: <20170227112510.GA4129@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Mon, Feb 27, 2017 at 11:02:09AM +0100, Vitaly Kuznetsov wrote:
> A couple of other thoughts:
> 1) Having all newly added memory online ASAP is probably what people
> want for all virtual machines.

This is not true for s390. On s390 we have "standby" memory that a guest
sees and potentially may use if it sets it online. Every guest that sets
memory offline contributes to the hypervisor's standby memory pool, while
onlining standby memory takes memory away from the standby pool.

The use-case is that a system administrator in advance knows the maximum
size a guest will ever have and also defines how much memory should be used
at boot time. The difference is standby memory.

Auto-onlining of standby memory is the last thing we want.

> Unfortunately, we have additional complexity with memory zones
> (ZONE_NORMAL, ZONE_MOVABLE) and in some cases manual intervention is
> required. Especially, when further unplug is expected.

This also is a reason why auto-onlining doesn't seem be the best way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
