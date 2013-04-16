Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2CAF36B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 11:13:23 -0400 (EDT)
Message-ID: <1366124458.3824.30.camel@misato.fc.hp.com>
Subject: Re: [Bug fix PATCH v2] Reusing a resource structure allocated by
 bootmem
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 16 Apr 2013 09:00:58 -0600
In-Reply-To: <516CA4F1.9060603@jp.fujitsu.com>
References: <516CA4F1.9060603@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, linuxram@us.ibm.com

On Tue, 2013-04-16 at 10:10 +0900, Yasuaki Ishimatsu wrote:
> When hot removing memory presented at boot time, following messages are shown:

 :

> The reason why the messages are shown is to release a resource structure,
> allocated by bootmem, by kfree(). So when we release a resource structure,
> we should check whether it is allocated by bootmem or not.
> 
> But even if we know a resource structure is allocated by bootmem, we cannot
> release it since SLxB cannot treat it. So for reusing a resource structure,
> this patch remembers it by using bootmem_resource as follows:
> 
> When releasing a resource structure by free_resource(), free_resource() checks
> whether the resource structure is allocated by bootmem or not. If it is
> allocated by bootmem, free_resource() adds it to bootmem_resource. If it is
> not allocated by bootmem, free_resource() release it by kfree().
> 
> And when getting a new resource structure by get_resource(), get_resource()
> checks whether bootmem_resource has released resource structures or not. If
> there is a released resource structure, get_resource() returns it. If there is
> not a releaed resource structure, get_resource() returns new resource structure
> allocated by kzalloc().
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
> v2:
> Based on following Toshi's works:
>   Support memory hot-delete to boot memory
>     https://lkml.org/lkml/2013/4/10/469
>   resource: Update config option of release_mem_region_adjustable()
>     https://lkml.org/lkml/2013/4/11/694
> Added a NULL check into free_resource()
> Remove __free_resource()

Thanks for the update.  Looks good.  Can you also address Rui's comment?

-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
