From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] firmware, memmap: fix firmware_map_entry leak
Date: Mon, 15 Apr 2013 15:04:15 +0800
Message-ID: <8235.41181530363$1366009501@news.gmane.org>
References: <516B94A1.4040603@jp.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1URdTG-0006bG-2n
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Apr 2013 09:04:58 +0200
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 4B49B6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 03:04:51 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Apr 2013 16:53:10 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6F98F2BB0066
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 17:04:32 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3F74LCB59506702
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 17:04:25 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3F74KWd026787
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 17:04:22 +1000
Content-Disposition: inline
In-Reply-To: <516B94A1.4040603@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wency@cn.fujitsu.co, tangchen@cn.fujitsu.com, toshi.kani@hp.com

On Mon, Apr 15, 2013 at 02:48:17PM +0900, Yasuaki Ishimatsu wrote:
>When hot removing a memory, a firmware_map_entry which has memory range
>of the memory is released by release_firmware_map_entry(). If the entry
>is allocated by bootmem, release_firmware_map_entry() adds the entry to
>map_entires_bootmem list when firmware_map_find_entry() finds the entry
>from map_entries list. But firmware_map_find_entry never find the entry
>sicne map_entires list does not have the entry. So the entry just leaks.
>
>Here are steps of leaking firmware_map_entry:
>firmware_map_remove()
>-> firmware_map_find_entry()
>   Find released entry from map_entries list
>-> firmware_map_remove_entry()
>   Delete the entry from map_entries list
>-> remove_sysfs_fw_map_entry()
>   ...
>   -> release_firmware_map_entry()
>      -> firmware_map_find_entry()
>         Find the entry from map_entries list but the entry has been
>         deleted from map_entries list. So the entry is not added
>         to map_entries_bootmem. Thus the entry leaks
>
>release_firmware_map_entry() should not call firmware_map_find_entry()
>since releaed entry has been deleted from map_entries list.
>So the patch delete firmware_map_find_entry() from releae_firmware_map_entry()
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>---
> drivers/firmware/memmap.c |    9 +++------
> 1 files changed, 3 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
>index 0b5b5f6..e2e04b0 100644
>--- a/drivers/firmware/memmap.c
>+++ b/drivers/firmware/memmap.c
>@@ -114,12 +114,9 @@ static void __meminit release_firmware_map_entry(struct kobject *kobj)
> 		 * map_entries_bootmem here, and deleted from &map_entries in
> 		 * firmware_map_remove_entry().
> 		 */
>-		if (firmware_map_find_entry(entry->start, entry->end,
>-		    entry->type)) {
>-			spin_lock(&map_entries_bootmem_lock);
>-			list_add(&entry->list, &map_entries_bootmem);
>-			spin_unlock(&map_entries_bootmem_lock);
>-		}
>+		spin_lock(&map_entries_bootmem_lock);
>+		list_add(&entry->list, &map_entries_bootmem);
>+		spin_unlock(&map_entries_bootmem_lock);
>
> 		return;
> 	}
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
