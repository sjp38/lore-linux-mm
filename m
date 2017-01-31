Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28CB56B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 01:15:31 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g49so359853950qta.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:15:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si11258564qts.267.2017.01.30.22.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 22:15:30 -0800 (PST)
Date: Tue, 31 Jan 2017 01:15:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC V2 00/12] Define coherent device memory node
Message-ID: <20170131061522.GA2470@redhat.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <1e57493b-1981-7c36-612d-3ddaf6ca88b7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1e57493b-1981-7c36-612d-3ddaf6ca88b7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue, Jan 31, 2017 at 11:18:49AM +0530, Anshuman Khandual wrote:
> Hello Dave/Jerome/Mel,
> 
> Here is the overall layout of the functions I am trying to put together
> through this patch series.
> 
> (1) Define CDM from core VM and kernel perspective
> 
> (2) Isolation/Special consideration for HugeTLB allocations
> 
> (3) Isolation/Special consideration for buddy allocations
> 
> 	(a) Zonelist modification based isolation (proposed)
> 	(b) Cpuset modification based isolation	  (proposed)
> 	(c) Buddy modification based isolation	  (working)
> 
> (4) Define VMA containing CDM memory with a new flag VM_CDM
> 
> (5) Special consideration for VM_CDM marked VMAs
> 
> 	(a) Special consideration for auto NUMA
> 	(b) Special consideration for KSM

I believe (5) should not be done on per vma basis but on a page basis.
Thus rendering (4) pointless. A vma shouldn't be special because it has
some special kind of memory irespective of what the vma points to.


> Is there are any other area which needs to be taken care of before CDM
> node can be represented completely inside the kernel ?

Maybe thing like swap or suspend and resume (i know you are targetting big
computer and not laptop :)) but you can't presume what platform CDM might
be use latter on.

Also userspace might be confuse by looking a /proc/meminfo or any of the
sysfs file and see all this device memory without understanding that it
is special and might be unwise to be use for regular CPU only task.

I would probably want CDM memory be reported separatly from the rest of
memory. Which also most likely have repercution with memory cgroup.

My expectation is that you only want to use device memory in a process
if and only if that process also use the device to some extent. So
having new group hierarchy for this memory is probably a better path
forward.


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
