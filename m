Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0361E6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:06:12 -0400 (EDT)
Received: by obbfy7 with SMTP id fy7so32056601obb.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:06:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c2si3821400oih.6.2015.04.15.14.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 14:06:11 -0700 (PDT)
Message-ID: <552ED2B8.3060308@oracle.com>
Date: Wed, 15 Apr 2015 14:06:00 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: hugetlbfs alignment requirements conflicting with documentation
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>

A couple of us started looking at adding fallocate() preallocation
and punch hole support to hugetlbfs.  The offset and length arguments
to fallocate are in bytes, and the man page is pretty explicit about
what is expected if ranges do not start or end on page boundaries.

Looking at fallocate led me to take a closer look at ftruncate for
hugetlbfs as ideally we would reuse some of that code.  I noticed that
ftruncate requires the length parameter to be huge page aligned.
I am pretty sure this was done because hugetlbfs only deals in increments
of huge pages.  inode size appears to never be set to anything that
is not a multiple of huge page size.  However, the ftruncate man page
does not place too many restrictions on the value of length.  And AFICT,
there is no documentation about ftruncate returning EINVAL if length
is not a multiple of huge page size.

So my question is, do we try to support hugetlbfs files that are not a
multiple of huge page size in length?  Or, document that hugetlbfs is
'special' when it comes to truncate?

This same question applies to fallocate as the man page also says that
it is possible to set file size to an arbitrary (non huge page size
aligned value).

cc'ing some people from the recent hugetlb munmap alignment thread as
I'm sure they will have an opinion here.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
