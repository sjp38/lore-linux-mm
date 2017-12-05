Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 834246B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 15:59:45 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 80so838049wmb.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 12:59:45 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 5si961358edm.313.2017.12.05.12.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 12:59:44 -0800 (PST)
Subject: Re: [RFC PATCH v3 1/7] ktask: add documentation
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
 <20171205195220.28208-2-daniel.m.jordan@oracle.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <d5f3ff84-50cd-15c4-56b6-26f94f127d53@oracle.com>
Date: Tue, 5 Dec 2017 15:59:03 -0500
MIME-Version: 1.0
In-Reply-To: <20171205195220.28208-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com, rdunlap@infradead.org

Forgot to cc Randy Dunlap and add his Reviewed-by from v2.

On 12/05/2017 02:52 PM, Daniel Jordan wrote:
> Motivates and explains the ktask API for kernel clients.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Steve Sistare <steven.sistare@oracle.com
Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

Daniel

> Cc: Aaron Lu <aaron.lu@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> ---
>   Documentation/core-api/index.rst |   1 +
>   Documentation/core-api/ktask.rst | 173 +++++++++++++++++++++++++++++++++++++++
>   2 files changed, 174 insertions(+)
>   create mode 100644 Documentation/core-api/ktask.rst
> 
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> index d5bbe035316d..255724095814 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -15,6 +15,7 @@ Core utilities
>      assoc_array
>      atomic_ops
>      cpu_hotplug
> +   ktask
>      local_ops
>      workqueue
>      genericirq
> diff --git a/Documentation/core-api/ktask.rst b/Documentation/core-api/ktask.rst
> new file mode 100644
> index 000000000000..703f200c7d36
> --- /dev/null
> +++ b/Documentation/core-api/ktask.rst
> @@ -0,0 +1,173 @@
> +============================================
> +ktask: parallelize CPU-intensive kernel work
> +============================================
> +
> +:Date: December, 2017
> +:Author: Daniel Jordan <daniel.m.jordan@oracle.com>
> +
> +
> +Introduction
> +============
> +
> +ktask is a generic framework for parallelizing CPU-intensive work in the
> +kernel.  The intended use is for big machines that can use their CPU power to
> +speed up large tasks that can't otherwise be multithreaded in userland.  The
> +API is generic enough to add concurrency to many different kinds of tasks--for
> +example, zeroing a range of pages or evicting a list of inodes--and aims to
> +save its clients the trouble of splitting up the work, choosing the number of
> +threads to use, maintaining an efficient concurrency level, starting these
> +threads, and load balancing the work between them.
> +
> +
> +Motivation
> +==========
> +
> +To ensure that applications and the kernel itself continue to perform well as
> +core counts and memory sizes increase, the kernel needs to scale.  For example,
> +when a system call requests a certain fraction of system resources, the kernel
> +should respond in kind by devoting a similar fraction of system resources to
> +service the request.
> +
> +Before ktask, for example, when booting a NUMA machine with many CPUs, only one
> +thread per node was used to initialize struct pages.  Using additional CPUs
> +that would otherwise be idle until the machine is fully up avoids a needless
> +bottleneck during system boot and allows the kernel to take advantage of unused
> +memory bandwidth.
> +
> +Why a new framework when there are existing kernel APIs for managing
> +concurrency and other ways to improve performance?  Of the existing facilities,
> +workqueues aren't designed to divide work up (although ktask is built on
> +unbound workqueues), and kthread_worker supports only one thread.  Existing
> +scalability techniques in the kernel such as doing work or holding locks in
> +batches are helpful and should be applied first for performance problems, but
> +eventually a single thread hits a wall.
> +
> +
> +Concept
> +=======
> +
> +A little terminology up front:  A 'task' is the total work there is to do and a
> +'chunk' is a unit of work given to a thread.
> +
> +To complete a task using the ktask framework, a client provides a thread
> +function that is responsible for completing one chunk.  The thread function is
> +defined in a standard way, with start and end arguments that delimit the chunk
> +as well as an argument that the client uses to pass data specific to the task.
> +
> +In addition, the client supplies an object representing the start of the task
> +and an iterator function that knows how to advance some number of units in the
> +task to yield another object representing the new task position.  The framework
> +uses the start object and iterator internally to divide the task into chunks.
> +
> +Finally, the client passes the total task size and a minimum chunk size to
> +indicate the minimum amount of work that's appropriate to do in one chunk.  The
> +sizes are given in task-specific units (e.g. pages, inodes, bytes).  The
> +framework uses these sizes, along with the number of online CPUs and an
> +internal maximum number of threads, to decide how many threads to start and how
> +many chunks to divide the task into.
> +
> +For example, consider the task of clearing a gigantic page.  This used to be
> +done in a single thread with a for loop that calls a page clearing function for
> +each constituent base page.  To parallelize with ktask, the client first moves
> +the for loop to the thread function, adapting it to operate on the range passed
> +to the function.  In this simple case, the thread function's start and end
> +arguments are just addresses delimiting the portion of the gigantic page to
> +clear.  Then, where the for loop used to be, the client calls into ktask with
> +the start address of the gigantic page, the total size of the gigantic page,
> +and the thread function.  Internally, ktask will divide the address range into
> +an appropriate number of chunks and start an appropriate number of threads to
> +complete these chunks.
> +
> +
> +Configuration
> +=============
> +
> +To use ktask, configure the kernel with CONFIG_KTASK=y.
> +
> +If CONFIG_KTASK=n, calls to the ktask API are simply #define'd to run the
> +thread function that the client provides so that the task is completed without
> +concurrency in the current thread.
> +
> +
> +Interface
> +=========
> +
> +.. Include ktask.h inline here.  This file is heavily commented and documents
> +.. the ktask interface.
> +.. kernel-doc:: include/linux/ktask.h
> +
> +
> +Resource Limits and Auto-Tuning
> +===============================
> +
> +ktask has resource limits on the number of workqueue items it queues.  In
> +ktask, a workqueue item is a thread that runs chunks of the task until the task
> +is finished.
> +
> +These limits support the different ways ktask uses workqueues:
> + - ktask_run to run threads on the calling thread's node.
> + - ktask_run_numa to run threads on the node(s) specified.
> + - ktask_run_numa with nid=NUMA_NO_NODE to run threads on any node in the
> +   system.
> +
> +To support these different ways of queueing work while maintaining an efficient
> +concurrency level, we need both system-wide and per-node limits on the number
> +of threads.  Without per-node limits, a node might become oversubscribed
> +despite ktask staying within the system-wide limit, and without a system-wide
> +limit, we can't properly account for work that can run on any node.
> +
> +The system-wide limit is based on the total number of CPUs, and the per-node
> +limit on the CPU count for each node.  A per-node work item counts against the
> +system-wide limit.  Workqueue's max_active can't accommodate both types of
> +limit, no matter how many workqueues are used, so ktask implements its own.
> +
> +If a per-node limit is reached, the work item is allowed to run anywhere on the
> +machine to avoid overwhelming the node.  If the global limit is also reached,
> +ktask won't queue additional work items until we fall below the limit again.
> +
> +These limits apply only to workqueue items--that is, additional threads beyond
> +the one starting the task.  That way, one thread per task is always allowed to
> +run.
> +
> +Within the resource limits, ktask uses a default maximum number of threads per
> +task to avoid disturbing other processes on the system.  Callers can change the
> +limit with ktask_ctl_set_max_threads.  For example, this might be used to raise
> +the maximum number of threads for a boot-time initialization task when more
> +CPUs than usual are idle.
> +
> +
> +Backward Compatibility
> +======================
> +
> +ktask is written so that existing calls to the API will be backwards compatible
> +should the API gain new features in the future.  This is accomplished by
> +restricting API changes to members of struct ktask_ctl and having clients make
> +an opaque initialization call (DEFINE_KTASK_CTL).  This initialization can then
> +be modified to include any new arguments so that existing call sites stay the
> +same.
> +
> +
> +Error Handling
> +==============
> +
> +Calls to ktask fail only if the provided thread function fails.  In particular,
> +ktask avoids allocating memory internally during a task, so it's safe to use in
> +sensitive contexts.
> +
> +To avoid adding features before they're used, ktask currently has only basic
> +error handling.  Each call to ktask_run and ktask_run_numa returns a simple
> +error code, KTASK_RETURN_SUCCESS or KTASK_RETURN_ERROR.  As usage of the
> +framework expands, however, error handling will likely need to be enhanced in
> +two ways.
> +
> +First, ktask may need client-specific error reporting.  It's possible for tasks
> +to fail for different reasons, so the framework should have a way to
> +communicate client-specific error information.  For this purpose, allow the
> +client to pass a pointer for its own error information in struct ktask_ctl.
> +
> +Second, tasks can fail midway through their work.  To recover, the finished
> +chunks of work need to be undone in a task-specific way, so ktask should allow
> +clients to pass an "undo" callback that is responsible for undoing one chunk of
> +work.  To avoid multiple levels of error handling, this "undo" callback should
> +not be allowed to fail.  The iterator used for the original task can simply be
> +reused for the undo operation.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
