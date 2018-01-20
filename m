Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6266B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 21:12:58 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id w17so3601920iow.23
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 18:12:58 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id g80si9399054ioe.172.2018.01.19.18.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 18:12:57 -0800 (PST)
Date: Fri, 19 Jan 2018 20:12:55 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
In-Reply-To: <2BEFC6DE-7A47-4CB9-AAE5-CEF70453B46F@oracle.com>
Message-ID: <alpine.DEB.2.20.1801192002161.14056@nuc-kabylake>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com> <1516130924-3545-2-git-send-email-henry.willard@oracle.com> <20180116212614.gudglzw7kwzd3get@suse.de> <alpine.DEB.2.20.1801171219270.23209@nuc-kabylake>
 <2BEFC6DE-7A47-4CB9-AAE5-CEF70453B46F@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-1740495615-1516414375=:14056"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henry Willard <henry.willard@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1740495615-1516414375=:14056
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 18 Jan 2018, Henry Willard wrote:

> If MPOL_MF_LAZY were allowed and specified things would not work
> correctly. change_pte_range() is unaware of and cana??t honor the
> difference between MPOL_MF_MOVE_ALL and MPOL_MF_MOVE.

Not sure how that relates to what I said earlier... Sorry.

>
> For the case of auto numa balancing, it may be undesirable for shared
> pages to be migrated whether they are also copy-on-write or not. The
> copy-on-write test was added to restrict the effect of the patch to the
> specific situation we observed. Perhaps I should remove it, I dona??t
> understand why it would be desirable to modify the behavior via sysfs.

I think the most common case of shared pages occurs for pages that contain
code. In that case a page may be mapped into hundreds if not thousands of
processes. In particular that is often the case for basic system libraries
like the c library which may actually be mapped into every binary that is
running.

It is very difficult and expensive to unmap these pages from all the
processes in order to migrate them. So some sort of limit would be useful
to avoid unnecessary migration attempts. One example would be to forbid
migrating pages that are mapped in more than 5 processes. Some sysctl know
would be useful here to set the boundary.

Your patch addresses a special case here by forbidding migration of any
page mapped by more than a single process (mapcount !=1).

That would mean f.e. that the complete migration of a set of processes
that rely on sharing data via a memory segment is impossible because those
shared pages can never be moved.

By setting the limit higher that migration would still be possible.

Maybe we can set that limit by default at 5 and allow a higher setting
if users have applications that require a higher mapcoun? F.e. a
common construct is a shepherd task and N worker threads. If those
tasks each have their own address space and only communicate via
a shared data segment then one may want to set the limit higher than N
in order to allow the migration of the group of processes.

--8323329-1740495615-1516414375=:14056--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
