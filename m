Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 084866B0280
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:15:01 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id n12-v6so1518696otk.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:15:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t67-v6si7925392oie.247.2018.10.02.08.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:14:59 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92FEs1E033646
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 11:14:59 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mv8a8gefu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 11:14:59 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <mwb@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 11:14:58 -0400
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
 <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
 <20181002145922.GZ18290@dhcp22.suse.cz>
From: Michael Bringmann <mwb@linux.vnet.ibm.com>
Date: Tue, 2 Oct 2018 10:14:49 -0500
MIME-Version: 1.0
In-Reply-To: <20181002145922.GZ18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d338b385-626b-0e79-9944-708178fe245d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On 10/02/2018 09:59 AM, Michal Hocko wrote:
> On Tue 02-10-18 09:51:40, Michael Bringmann wrote:
> [...]
>> When the device-tree affinity attributes have changed for memory,
>> the 'nid' affinity calculated points to a different node for the
>> memory block than the one used to install it, previously on the
>> source system.  The newly calculated 'nid' affinity may not yet
>> be initialized on the target system.  The current memory tracking
>> mechanisms do not record the node to which a memory block was
>> associated when it was added.  Nathan is looking at adding this
>> feature to the new implementation of LMBs, but it is not there
>> yet, and won't be present in earlier kernels without backporting a
>> significant number of changes.
> 
> Then the patch you have proposed here just papers over a real issue, no?
> IIUC then you simply do not remove the memory if you lose the race.

The problem occurs when removing memory after an affinity change references a node that was previously unreferenced.  Other code in 'kernel/mm/memory_hotplug.c' deals with initializing an empty node when adding memory to a system.  The   'removing memory' case is specific to systems that perform LPM and allow device-tree changes.  The powerpc kernel does not have the option of accepting some PRRN requests and accepting others.  It must perform them all.

The kernel/mm code that removes memory blocks does not (before this patch) recognize that the affinity of a memory block could have changed to a previously unused node.  If every path to try_offline_node made such a check, then this patch would be unnecessary.  However, putting a patch at a single location to check for a relatively rare occurrence, would seem to be a more efficient implementation.

Michael

-- 
Michael W. Bringmann
Linux Technology Center
IBM Corporation
Tie-Line  363-5196
External: (512) 286-5196
Cell:       (512) 466-0650
mwb@linux.vnet.ibm.com
