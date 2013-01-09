Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 335866B0071
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 18:11:43 -0500 (EST)
Date: Wed, 9 Jan 2013 15:11:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 02/15] memory-hotplug: check whether all memory
 blocks are offlined or not when removing memory
Message-Id: <20130109151140.76982b9e.akpm@linux-foundation.org>
In-Reply-To: <1357723959-5416-3-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-3-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:26 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> We remove the memory like this:
> 1. lock memory hotplug
> 2. offline a memory block
> 3. unlock memory hotplug
> 4. repeat 1-3 to offline all memory blocks
> 5. lock memory hotplug
> 6. remove memory(TODO)
> 7. unlock memory hotplug
> 
> All memory blocks must be offlined before removing memory. But we don't hold
> the lock in the whole operation. So we should check whether all memory blocks
> are offlined before step6. Otherwise, kernel maybe panicked.

Well, the obvious question is: why don't we hold lock_memory_hotplug()
for all of steps 1-4?  Please send the reasons for this in a form which
I can paste into the changelog.


Actually, I wonder if doing this would fix a race in the current
remove_memory() repeat: loop.  That code does a
find_memory_block_hinted() followed by offline_memory_block(), but
afaict find_memory_block_hinted() only does a get_device().  Is the
get_device() sufficiently strong to prevent problems if another thread
concurrently offlines or otherwise alters this memory_block's state?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
