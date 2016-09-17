Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 834A86B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 00:26:58 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so86723996lfs.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 21:26:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l2si7906627wjg.109.2016.09.16.21.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 21:26:57 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8H4NLmi020881
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 00:26:55 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25gxrvr2cu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 00:26:55 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 17 Sep 2016 14:26:52 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DB60D3578056
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:26:50 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8H4QoVj63111348
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:26:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8H4QoH0001021
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:26:50 +1000
Date: Sat, 17 Sep 2016 09:56:45 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <57D1C914.9090403@intel.com> <57D63CB2.8070003@linux.vnet.ibm.com> <alpine.DEB.2.10.1609121106500.39030@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1609121106500.39030@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57DCC605.10305@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 09/12/2016 11:43 PM, David Rientjes wrote:
> On Mon, 12 Sep 2016, Anshuman Khandual wrote:
> 
>>>>> after memory or node hot[un]plug is desirable. This change adds one
>>>>> new sysfs interface (/sys/devices/system/memory/system_zone_details)
>>>>> which will fetch and dump this information.
>>> Doesn't this violate the "one value per file" sysfs rule?  Does it
>>> belong in debugfs instead?
>>
>> Yeah sure. Will make it a debugfs interface.
>>
> 
> So the intended reader of this file is running as root?

Yeah.

> 
>>> I also really question the need to dump kernel addresses out, filtered 
>>> or not.  What's the point?
>>
>> Hmm, thought it to be an additional information. But yes its additional
>> and can be dropped.
>>
> 
> I'm questioning if this information can be inferred from information 
> already in /proc/zoneinfo and sysfs.  We know the no-fallback zonelist is 
> going to include the local node, and we know the other zonelists are 
> either node ordered or zone ordered (or do we need to extend 
> vm.numa_zonelist_order for default?).  I may have missed what new 
> knowledge this interface is imparting on us.

IIUC /proc/zoneinfo lists down zone internal state and statistics for
all zones on the system at any given point of time. The no-fallback
list contains the zones from the local node and fallback (which gets
used more often than the no-fallback) list contains all zones either
in node-ordered or zone-ordered manner. In most of the platforms the
default being the node order but the sequence of present nodes in
that order is determined by various factors like NUMA distance, load,
presence of CPUs on the node etc. This order of nodes in the fallback
list is the most important information derived out of this interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
