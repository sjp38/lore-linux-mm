Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 13D656B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:38:10 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id p61so4202631wes.7
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 08:38:10 -0800 (PST)
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
        by mx.google.com with ESMTPS id d46si1644347eeo.228.2014.01.10.08.38.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 08:38:10 -0800 (PST)
Received: by mail-ea0-f175.google.com with SMTP id z10so2170548ead.6
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 08:38:10 -0800 (PST)
Message-ID: <52D021EE.3020104@ravellosystems.com>
Date: Fri, 10 Jan 2014 18:38:06 +0200
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: set_pte_at_notify regression
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, Alex Fishman <alex.fishman@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>

Hi,

It look like commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 break the 
semantic of set_pte_at_notify.
The change of calling first to mmu_notifier_invalidate_range_start, then 
to set_pte_at_notify, and then to mmu_notifier_invalidate_range_end
not only increase the amount of locks kvm have to take and release by 
factor of 3, but in addition mmu_notifier_invalidate_range_start is zapping
the pte entry from kvm, so when set_pte_at_notify get called, it doesn`t 
have any spte to set and it acctuly get called for nothing, the result is
increasing of vmexits for kvm from both do_wp_page and replace_page, and 
broken semantic of set_pte_at_notify.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
