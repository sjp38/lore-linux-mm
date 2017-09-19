Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E28D06B0268
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 19:15:21 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o200so1950511itg.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:15:21 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 192si2552042itw.92.2017.09.19.16.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 16:15:20 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: DAX error inject/page poison
Message-ID: <11e8c954-7d54-ae4f-f4fe-459da79c2990@oracle.com>
Date: Tue, 19 Sep 2017 16:15:13 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal L Verma <vishal.l.verma@intel.com>


We were trying to simulate pmem errors in an environment where a DAX
filesystem is used (ext4 although I suspect it does not matter).  The
sequence attempted on a DAX filesystem is:
- Populate a file in the DAX filesystem
- mmap the file
- madvise(MADV_HWPOISON)

The madvise operation fails with EFAULT.  This appears to come from
get_user_pages() as there are no struct pages for such mappings?

The idea is to make sure an application can recover from such errors
by hole punching and repopulating with another page.

A couple questions:
It seems like madvise(MADV_HWPOISON) is not going to work (ever?) in
such situations.  If so, should we perhaps add a IS_DAX like check and
return something like EINVAL?  Or, at least document expected behavior?

If madvise(MADV_HWPOISON) will not work, how can one inject errors to
test error handling code?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
