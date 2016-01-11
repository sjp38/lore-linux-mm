Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB3AE828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:03:46 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id b35so274383210qge.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:03:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e132si114119387qhc.70.2016.01.11.07.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 07:03:45 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v3] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
	<20160108140123.GK3485@olila.local.net-space.pl>
	<87y4c02eqc.fsf@vitty.brq.redhat.com>
	<20160111081013.GM3485@olila.local.net-space.pl>
	<20160111124233.GN3485@olila.local.net-space.pl>
Date: Mon, 11 Jan 2016 16:03:35 +0100
In-Reply-To: <20160111124233.GN3485@olila.local.net-space.pl> (Daniel Kiper's
	message of "Mon, 11 Jan 2016 13:42:33 +0100")
Message-ID: <87twmki2ew.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Daniel Kiper <daniel.kiper@oracle.com> writes:

[skip]

>> > > And we want to have it working out of the box.
>> > > So, I think that we should find proper solution. I suppose that we can schedule
>> > > a task here which auto online attached blocks. Hmmm... Not nice but should work.
>> > > Or maybe you have better idea how to fix this issue.
>> >
>> > I'd like to avoid additional delays and memory allocations between
>> > adding new memory and onlining it (and this is the main purpose of the
>> > patch). Maybe we can have a tristate online parameter ('online_now',
>> > 'online_delay', 'keep_offlined') and handle it
>> > accordingly. Alternatively I can suggest we have the onlining in Xen
>> > balloon driver code, memhp_auto_online is exported so we can call
>> > online_pages() after we release the ballon_mutex.
>>
>> This is not nice too. I prefer the same code path for every case.
>> Give me some time. I will think how to solve that issue.
>
> It looks that we can safely call mutex_unlock() just before add_memory_resource()
> call and retake lock immediately after add_memory_resource(). add_memory_resource()
> itself does not play with balloon stuff and even if online_pages() does then it
> take balloon_mutex in right place. Additionally, only one balloon task can run,
> so, I think that we are on safe side. Am I right?

I think you are as balloon_mutex is internal to xen driver and there is
only one balloon_process() running at the time. I just smoke-tested the
following:

commit 0fce4746a0090d533e9302cc42b3d3c0645d756d
Author: Vitaly Kuznetsov <vkuznets@redhat.com>
Date:   Mon Jan 11 14:22:11 2016 +0100

    xen_balloon: make hotplug auto online work
    
    Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 890c3b5..08bbf35 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -338,7 +338,10 @@ static enum bp_state reserve_additional_memory(void)
 	}
 #endif
 
-	rc = add_memory_resource(nid, resource, false);
+	mutex_unlock(&balloon_mutex);
+	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	mutex_lock(&balloon_mutex);
+
 	if (rc) {
 		pr_warn("Cannot add additional memory (%i)\n", rc);
 		goto err;
@@ -565,8 +568,10 @@ static void balloon_process(struct work_struct *work)
 		if (credit > 0) {
 			if (balloon_is_inflated())
 				state = increase_reservation(credit);
-			else
+			else {
+				printk("balloon_process: adding memory (credit: %ld)!\n", credit);
 				state = reserve_additional_memory();
+			}
 		}
 
 		if (credit < 0)

And it seems to work (unrelated rant: 'xl mem-set' after 'xl max-mem'
doesn't work with "libxl: error: libxl.c:4809:libxl_set_memory_target:
memory_dynamic_max must be less than or equal to memory_static_max". At
the same time I'm able to increase the reservation with "echo
NEW_VALUE > /sys/devices/system/xen_memory/xen_memory0/target_kb" from
inside the guest. Was it supposed to be like that?).

While the patch misses the logic for empty pages (see David's comment in
a parallel thread) it should work for the general case the same way
auto-online works for Hyper-V and ACPI memory hotplugs.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
