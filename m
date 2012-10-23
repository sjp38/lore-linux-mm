Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 60A476B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 12:32:56 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 23 Oct 2012 12:32:52 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A02626E805E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 12:30:17 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9NGUGsg247506
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 12:30:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9NGUEZT026284
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 14:30:15 -0200
Date: Tue, 23 Oct 2012 22:02:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121023163245.GR11096@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <20121013184019.GA3837@linux.vnet.ibm.com>
 <20121014045716.GE11663@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20121014045716.GE11663@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, pzijlstr@redhat.com, mingo@elte.hu, mel@csn.ul.ie, hughd@google.com, riel@redhat.com, hannes@cmpxchg.org, dhillf@gmail.com, drjones@redhat.com, tglx@linutronix.de, pjt@google.com, cl@linux.com, suresh.b.siddha@intel.com, efault@gmx.de, paulmck@linux.vnet.ibm.com, alex.shi@intel.com, konrad.wilk@oracle.com, benh@kernel.crashing.org

* Andrea Arcangeli <aarcange@redhat.com> [2012-10-14 06:57:16]:

> I'll release an autonuma29 behaving like 28fast if there are no
> surprises. The new algorithm change in 28fast will also save memory
> once I rewrite it properly.
> 

Here are my results of specjbb2005 on a 2 node box (Still on autonuma27, but
plan to run on a newer release soon).


---------------------------------------------------------------------------------------------------
|          kernel|      vm|                              nofit|                                fit|
-                -        -------------------------------------------------------------------------
|                |        |            noksm|              ksm|            noksm|              ksm|
-                -        -------------------------------------------------------------------------
|                |        |   nothp|     thp|   nothp|     thp|   nothp|     thp|   nothp|     thp|
---------------------------------------------------------------------------------------------------
|    mainline_v36|    vm_1|  136085|  188500|  133871|  163638|  133540|  178159|  132460|  164763|
|                |    vm_2|   61549|   80496|   61420|   74864|   63777|   80573|   60479|   73416|
|                |    vm_3|   60688|   79349|   62244|   73289|   64394|   80803|   61040|   74258|
---------------------------------------------------------------------------------------------------
|     autonuma27_|    vm_1|  143261|  186080|  127420|  178505|  141080|  201436|  143216|  183710|
|                |    vm_2|   72224|   94368|   71309|   89576|   59098|   83750|   63813|   90862|
|                |    vm_3|   61215|   94213|   71539|   89594|   76269|   99637|   72412|   91191|
---------------------------------------------------------------------------------------------------
| improvement    |    vm_1|   5.27%|  -1.28%|  -4.82%|   9.09%|   5.65%|  13.07%|   8.12%|  11.50%|
|   from         |    vm_2|  17.34%|  17.23%|  16.10%|  19.65%|  -7.34%|   3.94%|   5.51%|  23.76%|
|  mainline      |    vm_3|   0.87%|  18.73%|  14.93%|  22.25%|  18.44%|  23.31%|  18.63%|  22.80%|
---------------------------------------------------------------------------------------------------


(Results with suggested tweaks from Andrea)

echo 0 > /sys/kernel/mm/autonuma/knuma_scand/pmd

echo 15000 > /sys/kernel/mm/autonuma/knuma_scand/scan_sleep_pass_millisecs 

----------------------------------------------------------------------------------------------------
|          kernel|      vm|                               nofit|                                fit|
-                -        --------------------------------------------------------------------------
|                |        |             noksm|              ksm|            noksm|              ksm|
-                -        --------------------------------------------------------------------------
|                |        |    nothp|     thp|   nothp|     thp|   nothp|     thp|   nothp|     thp|
----------------------------------------------------------------------------------------------------
|    mainline_v36|    vm_1|   136142|  178362|  132493|  166169|  131774|  179340|  133058|  164637|
|                |    vm_2|    61143|   81943|   60998|   74195|   63725|   79530|   61916|   73183|
|                |    vm_3|    61599|   79058|   61448|   73248|   62563|   80815|   61381|   74669|
----------------------------------------------------------------------------------------------------
|     autonuma27_|    vm_1|   142023|      na|  142808|  177880|      na|  197244|  145165|  174175|
|                |    vm_2|    61071|      na|   61008|   91184|      na|   78893|   71675|   80471|
|                |    vm_3|    72646|      na|   72855|   92167|      na|   99080|   64758|   91831|
----------------------------------------------------------------------------------------------------
| improvement    |    vm_1|    4.32%|      na|   7.79%|   7.05%|      na|   9.98%|   9.10%|   5.79%|
|  from          |    vm_2|   -0.12%|      na|   0.02%|  22.90%|      na|  -0.80%|  15.76%|   9.96%|
|  mainline      |    vm_3|   17.93%|      na|  18.56%|  25.83%|      na|  22.60%|   5.50%|  22.98%|
----------------------------------------------------------------------------------------------------

Host:

    Enterprise Linux Distro
    2 NUMA nodes. 6 cores + 6 hyperthreads/node, 12 GB RAM/node.
        (total of 24 logical CPUs and 24 GB RAM) 

VMs:

    Enterprise Linux Distro
    Distro Kernel
        Main VM (VM1) -- relevant benchmark score.
            12 vCPUs

	    Either 12 GB (for '< 1 Node' configuration, i.e fit case)
		 or 14 GB (for '> 1 Node', i.e no fit case) 
        Noise VMs (VM2 and VM3)
            each noise VM has half of the remaining resources.
            6 vCPUs

            Either 4 GB (for '< 1 Node' configuration) or 3 GB ('> 1 Node ')
                (to sum 20 GB w/ Main VM + 4 GB for host = total 24 GB) 

Settings:

    Swapping disabled on host and VMs.
    Memory Overcommit enabled on host and VMs.
    THP on host is a variable. THP disabled on VMs.
    KSM on host is a variable. KSM disabled on VMs. 

na: refers to I results where I wasnt able to collect the results.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
