Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 688E36B2678
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 18:05:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h65-v6so1600078pfk.18
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 15:05:32 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
 <3c62f605-2244-6a05-2dc4-34a3f1c56300@linux.alibaba.com>
 <20180822211053.qg3dlzf6pok2x4yk@kshutemo-mobl1>
 <45a5ff36-d53d-9ec3-f869-1b1b7a6de5cb@intel.com>
 <a1642cf6-f458-3026-dca9-652fbb20f580@linux.alibaba.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7f06e97e-5efa-e0d4-f952-3f01079c7283@intel.com>
Date: Wed, 22 Aug 2018 15:03:44 -0700
MIME-Version: 1.0
In-Reply-To: <a1642cf6-f458-3026-dca9-652fbb20f580@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: owner-linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-kernel@vger.kernel.org

On 08/22/2018 02:56 PM, owner-linux-mm@kvack.org wrote:
> 
> 
> On 8/22/18 2:42 PM, Dave Hansen wrote:
>> On 08/22/2018 02:10 PM, Kirill A. Shutemov wrote:
>>>> For x86, mpx_notify_unmap() looks finally zap the VM_MPX vmas in
>>>> bound table
>>>> range with zap_page_range() and doesn't update vm flags, so it
>>>> sounds ok to
>>>> me since vmas have been detached, nobody can find those vmas. But,
>>>> I'm not
>>>> familiar with the details of mpx, maybe Kirill could help to confirm
>>>> this?
>>> I don't see anything obviously dependent on down_write() in
>>> mpx_notify_unmap(), but Dave should know better.
>> We need mmap_sem for write in mpx_notify_unmap().
>>
>> Its job is to clean up bounds tables, but bounds tables are dynamically
>> allocated and destroyed by the kernel.A  When we destroy a table, we also
>> destroy the VMA for the bounds table *itself*, separate from the VMA
>> being unmapped.
...
> Does it depends on unmap_region()? Or IOW, does it has to be called
> after unmap_region()? Now the calling sequence is:
> 
> detach vmas
> unmap_region()
> mpx_notify_unmap()
> 
> I'm wondering if it is safe to move it up before unmap_region() like:
> 
> detach vmas
> mpx_notify_unmap()
> unmap_region()
> 
> With this change we also can do our optimization to do unmap_region()
> with read mmap_sem. Otherwise it does cause problem.

I think changing the ordering is fine.

The MPX bounds table unmapping is entirely driven by the VMAs being
unmapped, so the page table unmapping in unmap_region() should not
affect it.
