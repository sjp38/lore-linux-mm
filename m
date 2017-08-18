Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C80FF6B02F3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 20:25:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b65so16258586wrd.1
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:25:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c20si3347268wre.400.2017.08.17.17.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 17:25:26 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I0O0I6027658
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 20:25:24 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cdhumjet4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 20:25:24 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 17 Aug 2017 18:25:23 -0600
Date: Thu, 17 Aug 2017 17:25:12 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v7 26/25] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add
 sysfs interface
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1501459946-11619-1-git-send-email-linuxram@us.ibm.com>
 <20170811173443.6227-1-bauerman@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811173443.6227-1-bauerman@linux.vnet.ibm.com>
Message-Id: <20170818002512.GE5427@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Haren Myneni <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Aug 11, 2017 at 02:34:43PM -0300, Thiago Jung Bauermann wrote:
> Expose useful information for programs using memory protection keys.
> Provide implementation for powerpc and x86.
> 
> On a powerpc system with pkeys support, here is what is shown:
> 
> $ head /sys/kernel/mm/protection_keys/*
> ==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
> true

We should not just call out disable_execute_supported.
disable_access_supported and disable_write_supported should also 
be called out.

> 
> ==> /sys/kernel/mm/protection_keys/total_keys <==
> 32
> 

> ==> /sys/kernel/mm/protection_keys/usable_keys <==
> 30

This is little nebulous.  It depends on how we define
usable as.  Is it the number of keys that are available
to the app?  If that is the case that value is dynamic.
Sometime the OS steals one key for execute-only key.
And anything that is dynamic can be inherently racy.
So I think we should define 'usable' as guaranteed number
of keys available to the app and display a value that is
one less than what is available.

in the above example the value should be 29.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
