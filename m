Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 096C76B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:37:03 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so57670411lfg.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:37:02 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id a84si4580007wmd.66.2016.07.14.10.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 10:37:01 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id f65so74255858wmi.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:37:01 -0700 (PDT)
Date: Thu, 14 Jul 2016 19:36:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160714173659.GA29355@dhcp22.suse.cz>
References: <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <740b17f0-e1bb-b021-e9e1-ad6dcf5f033a@redhat.com>
 <20160714153120.GD12289@dhcp22.suse.cz>
 <9ca3459a-8226-b870-163e-58e2bb10df74@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ca3459a-8226-b870-163e-58e2bb10df74@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ondrej Kozina <okozina@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Thu 14-07-16 19:07:52, Ondrej Kozina wrote:
> On 07/14/2016 05:31 PM, Michal Hocko wrote:
> > On Thu 14-07-16 16:08:28, Ondrej Kozina wrote:
> > [...]
> > > As Mikulas pointed out, this doesn't work. The system froze as well with the
> > > patch above. Will try to tweak the patch with Mikulas's suggestion...
> > 
> > Thank you for testing! Do you happen to have traces of the frozen
> > processes? Does the flusher still gets throttled because the bias it
> > gets is not sufficient. Or does it get throttled at a different place?
> > 
> 
> Sure. Here it is (including sysrq+t and sysrq+w output): https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/4.7.0-rc7+/1/4.7.0-rc7+.log

Thanks a lot! This is helpful.
[  162.716376] active_anon:107874 inactive_anon:108176 isolated_anon:64
[  162.716376]  active_file:1086 inactive_file:1103 isolated_file:0
[  162.716376]  unevictable:0 dirty:0 writeback:69824 unstable:0
[  162.716376]  slab_reclaimable:3119 slab_unreclaimable:24124
[  162.716376]  mapped:2165 shmem:57 pagetables:1509 bounce:0
[  162.716376]  free:701 free_pcp:0 free_cma:0

No surprise that PF_LESS_THROTTLE didn't help. It gives some bias but
considering how many pages are under writeback it cannot possibly help
to prevent from sleeping in throttle_vm_writeout. I suppose adding
the following on top of the memalloc patch helps, right?
It is an alternative to what you were suggesting in other email but
it doesn't affect current_may_throttle paths which I would rather not
touch.
---
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7fbb2d008078..a37661f1a11b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1971,6 +1971,9 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 
+	if (current->flags & PF_LESS_THROTTLE)
+		return;
+
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
