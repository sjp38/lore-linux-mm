Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C77E66B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 13:52:17 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d201so133255210qkg.2
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:52:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si10166078qte.294.2017.01.30.10.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 10:52:17 -0800 (PST)
Date: Mon, 30 Jan 2017 13:52:14 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC V2 08/12] mm: Add new VMA flag VM_CDM
Message-ID: <20170130185213.GA7198@redhat.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-9-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170130033602.12275-9-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Mon, Jan 30, 2017 at 09:05:49AM +0530, Anshuman Khandual wrote:
> VMA which contains CDM memory pages should be marked with new VM_CDM flag.
> These VMAs need to be identified in various core kernel paths for special
> handling and this flag will help in their identification.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>


Why doing this on vma basis ? Why not special casing all those path on page
basis ?

After all you can have a big vma with some pages in it being cdm and other
being regular page. The CPU process might migrate to different CPU in a
different node and you might still want to have the regular page to migrate
to this new node and keep the cdm page while the device is still working
on them.

This is just an example, same can apply for ksm or any other kernel feature
you want to special case. Maybe we can store a set of flag in node that
tells what is allowed for page in node (ksm, hugetlb, migrate, numa, ...).

This would be more flexible and the policy choice can be left to each of
the device driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
