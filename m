Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4B086B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:51:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so18636931wme.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:51:44 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id 85si10322128ljj.1.2016.06.06.06.51.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 06:51:43 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id k192so5044328lfb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:51:43 -0700 (PDT)
Date: Mon, 6 Jun 2016 16:51:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Message-ID: <20160606135140.GA21513@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: neha agarwal <neha.agbk@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> Hi All,
> 
> I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> Cassandra (NoSQL database). I am seeing significant performance gap between
> these two implementations (~30%). Hugh's implementation performs better
> than Kirill's implementation. I am surprised why I am seeing this
> performance gap. Following is my test setup.
> 
> Patchsets
> ========
> - For Hugh's:
> I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied the
> THP patches posted on April 16 (01 to 29 patches).
> 
> - For Kirill's:
> I am using his branch  "git://
> git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8", which
> is based off of 4.6-rc3, posted on May 12.
> 
> 
> Khugepaged settings
> ================
> cd /sys/kernel/mm/transparent_hugepage
> echo 10 >khugepaged/alloc_sleep_millisecs
> echo 10 >khugepaged/scan_sleep_millisecs
> echo 511 >khugepaged/max_ptes_none
> 
> 
> Mount options
> ===========
> - For Hugh's:
> sudo sysctl -w vm/shmem_huge=2
> sudo mount -o remount,huge=1 /hugetmpfs
> 
> - For Kirill's:
> sudo mount -o remount,huge=always /hugetmpfs
> echo force > /sys/kernel/mm/transparent_hugepage/shmem_enabled
> echo 511 >khugepaged/max_ptes_swap
> 
> 
> Workload Setting
> =============
> Please look at the attached setup document for Cassandra (NoSQL database):
> cassandra-setup.txt
> 
> 
> Machine setup
> ===========
> 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM running
> Ubuntu. I use control groups for resource isolation. Server and client
> threads run on different sockets. Frequency governor set to "performance"
> to remove any performance fluctuations due to frequency variation.
> 
> 
> Throughput numbers
> ================
> Hugh's implementation: 74522.08 ops/sec
> Kirill's implementation: 54919.10 ops/sec

In my setup I don't see the difference:

v4.7-rc1 + my implementation:
[OVERALL], RunTime(ms), 822862.0
[OVERALL], Throughput(ops/sec), 60763.53021527304
ShmemPmdMapped:  4999168 kB

v4.6-rc2 + Hugh's implementation:
[OVERALL], RunTime(ms), 833157.0
[OVERALL], Throughput(ops/sec), 60012.698687042175
ShmemPmdMapped:  5021696 kB

It's basically within measuarment error. 'ShmemPmdMapped' indicate how
much memory is mapped with huge pages by the end of test.

It's on dual-socket 24-core machine with 64G of RAM.

I guess we have some configuration difference or something, but so far I
don't see the drastic performance difference you've pointed to.

May be my implementation behaves slower on bigger machines, I don't know..
There's no architectural reason for this.

I'll post my updated patchset today.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
