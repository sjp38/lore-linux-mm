Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4036B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:24:07 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id d17so18577656ioc.23
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:24:07 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id g131si4881648iog.1.2018.01.17.10.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 10:24:06 -0800 (PST)
Date: Wed, 17 Jan 2018 12:23:04 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
In-Reply-To: <20180116212614.gudglzw7kwzd3get@suse.de>
Message-ID: <alpine.DEB.2.20.1801171219270.23209@nuc-kabylake>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com> <1516130924-3545-2-git-send-email-henry.willard@oracle.com> <20180116212614.gudglzw7kwzd3get@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Henry Willard <henry.willard@oracle.com>, akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 16 Jan 2018, Mel Gorman wrote:

> My main source of discomfort is the fact that this is permanent as two
> processes perfectly isolated but with a suitably shared COW mapping
> will never migrate the data. A potential improvement to get the reported
> bandwidth up in the test program would be to skip the rest of the VMA if
> page_mapcount != 1 in a COW mapping as it would be reasonable to assume
> the remaining pages in the VMA are also affected and the scan is wasteful.
> There are counter-examples to this but I suspect that the full VMA being
> shared is the common case. Whether you do that or not;

Same concern here. Typically CAP_SYS_NICE will bypass the check that the
page is only mapped to a single process and the check looks exactly like
the ones for manual migration. Using CAP_SYS_NICE would be surprising
here since autonuma is not triggered by the currently running process.

Can we configure this somehow via sysfs?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
