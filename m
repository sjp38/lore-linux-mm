Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 14B175F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:33:15 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3EJOnrn013098
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:24:49 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3EJXgGV181214
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:33:42 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3EJXgkm005277
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:33:42 -0400
Subject: meminfo Committed_AS underflows
From: Dave Hansen <dave@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 14 Apr 2009 12:33:39 -0700
Message-Id: <1239737619.32604.118.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I have a set of ppc64 machines that seem to spontaneously get underflows
in /proc/meminfo's Committed_AS field:
        
        # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
              1 Committed_AS: 18446744073709323392 kB
             11 Committed_AS: 18446744073709455488 kB
              6 Committed_AS:    35136 kB
              5 Committed_AS: 18446744073709454400 kB
              7 Committed_AS:    35904 kB
              3 Committed_AS: 18446744073709453248 kB
              2 Committed_AS:    34752 kB
              9 Committed_AS: 18446744073709453248 kB
              8 Committed_AS:    34752 kB
              3 Committed_AS: 18446744073709320960 kB
              7 Committed_AS: 18446744073709454080 kB
              3 Committed_AS: 18446744073709320960 kB
              5 Committed_AS: 18446744073709454080 kB
              6 Committed_AS: 18446744073709320960 kB

As you can see, it bounces in and out of it.  I think the problem is
here:
        
        #define ACCT_THRESHOLD  max(16, NR_CPUS * 2)
        ...
        void vm_acct_memory(long pages)
        {
                long *local;
        
                preempt_disable();
                local = &__get_cpu_var(committed_space);
                *local += pages;
                if (*local > ACCT_THRESHOLD || *local < -ACCT_THRESHOLD) {
                        atomic_long_add(*local, &vm_committed_space);
                        *local = 0;
                }
                preempt_enable();
        }

Plus, some joker set CONFIG_NR_CPUS=1024.

nr_cpus (1024) * 2 * page_size (64k) = 128MB.  That means each cpu can
skew the counter by 128MB.  With 1024 CPUs that means that we can have
~128GB of outstanding percpu accounting that meminfo doesn't see.  Let's
say we do vm_acct_memory(128MB-1) on 1023 of the CPUs, then on the other
CPU, we do  vm_acct_memory(-128GB).

The 1023 cpus won't ever hit the ACCT_THRESHOLD.  The 1 CPU that did
will decrement the global 'vm_committed_space'  by ~128 GB.  Underflow.
Yay.  This happens on a much smaller scale now.

Should we be protecting meminfo so that it spits slightly more sane
numbers out to the user?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
