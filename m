Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45EA96B0009
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 08:49:53 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id t18so3503919plo.9
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 05:49:53 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 34-v6si2049464plz.22.2018.02.01.05.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 05:49:51 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/sparse.c: Add nr_present_sections to change the
 mem_map allocation
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-3-bhe@redhat.com>
 <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6def8374-2de2-a30c-69ff-2a49fb57dc9a@linux.intel.com>
Date: Thu, 1 Feb 2018 05:49:50 -0800
MIME-Version: 1.0
In-Reply-To: <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 02/01/2018 02:16 AM, Kirill A. Shutemov wrote:
> On Thu, Feb 01, 2018 at 03:19:56PM +0800, Baoquan He wrote:
>> In sparse_init(), we allocate usemap_map and map_map which are pointer
>> array with the size of NR_MEM_SECTIONS. The memory consumption can be
>> ignorable in 4-level paging mode. While in 5-level paging, this costs
>> much memory, 512M. Kdump kernel even can't boot up with a normal
>> 'crashkernel=' setting.
>>
>> Here add a new variable to record the number of present sections. Let's
>> allocate the usemap_map and map_map with the size of nr_present_sections.
>> We only need to make sure that for the ith present section, usemap_map[i]
>> and map_map[i] store its usemap and mem_map separately.
>>
>> This change can save much memory on most of systems. Anytime, we should
>> avoid to define array or allocate memory with the size of NR_MEM_SECTIONS.
> That's very desirable outcome. But I don't know much about sparsemem.

... with the downside being that we can no longer hot-add memory that
was not part of the original, present sections.

Is that OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
