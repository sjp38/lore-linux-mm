Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9D7B96B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 21:02:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AF2563EE0C7
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:02:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D56645DE54
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:02:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6481745DE53
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:02:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34817E18008
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:02:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 401351DB803E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:02:27 +0900 (JST)
Message-ID: <51B130F9.8070408@jp.fujitsu.com>
Date: Fri, 07 Jun 2013 10:01:45 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6> <20130523052547.13864.83306.stgit@localhost6.localdomain6> <10307835.fkACLi6FUD@wuerfel>
In-Reply-To: <10307835.fkACLi6FUD@wuerfel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

(2013/06/07 6:31), Arnd Bergmann wrote:
> On Thursday 23 May 2013 14:25:48 HATAYAMA Daisuke wrote:
>> This patch introduces mmap_vmcore().
>>
>> Don't permit writable nor executable mapping even with mprotect()
>> because this mmap() is aimed at reading crash dump memory.
>> Non-writable mapping is also requirement of remap_pfn_range() when
>> mapping linear pages on non-consecutive physical pages; see
>> is_cow_mapping().
>>
>> Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by
>> remap_vmalloc_range_pertial at the same time for a single
>> vma. do_munmap() can correctly clean partially remapped vma with two
>> functions in abnormal case. See zap_pte_range(), vm_normal_page() and
>> their comments for details.
>>
>> On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This
>> limitation comes from the fact that the third argument of
>> remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned long.
>>
>> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
>> Acked-by: Vivek Goyal <vgoyal@redhat.com>
>
> I get build errors on 'make randconfig' from this, when building
> NOMMU kernels on ARM. I suppose the new feature should be hidden
> in #ifdef CONFIG_MMU.
>
> 	Arnd
>

Thanks for trying the build and your report!

OTOH, I don't have no-MMU architectures; x86 box only. I cannot reproduce this build error. Could you give me your build log? I want to use it to detect what part depends on CONFIG_MMU.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
